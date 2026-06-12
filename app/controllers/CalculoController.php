<?php
require_once ROOT_PATH . '/app/helpers/CalculadoraInteres.php';
require_once ROOT_PATH . '/app/helpers/CajaHelper.php';

class CalculoController extends BaseController {

    public function simulador() {
        $this->requirePermission('calculo.intereses');
        $resultado = null;
        $productos = $this->db->query("SELECT id_producto, nombre, tipo, tasa_interes_anual, metodo_interes, plazo_min_meses, plazo_max_meses FROM productos_financieros WHERE activo = TRUE ORDER BY nombre")->fetchAll();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $monto = str_replace(',', '.', $_POST['monto'] ?? '0');
            $tasa = str_replace(',', '.', $_POST['tasa'] ?? '0');
            $plazo = intval($_POST['plazo'] ?? 1);
            $metodo = $_POST['metodo'] ?? 'simple';

            if (is_numeric($monto) && $monto > 0 && is_numeric($tasa) && $plazo > 0) {
                try {
                    $resultado = CalculadoraInteres::simular($monto, $tasa, $plazo, $metodo);
                } catch (Exception $e) {
                    $_SESSION['error'] = $e->getMessage();
                }
            }
        }

        $this->render('calculos/simulador', [
            'titulo' => 'Simulador de amortización',
            'productos' => $productos,
            'resultado' => $resultado,
        ]);
    }

    public function generarTabla($idCredito) {
        $this->requirePermission('calculo.intereses');
        $stmt = $this->db->prepare("SELECT c.*, p.metodo_interes FROM creditos c
                                     JOIN productos_financieros p ON c.id_producto = p.id_producto
                                     WHERE c.id_credito = ? AND c.estado = 'aprobado'");
        $stmt->execute([$idCredito]);
        $credito = $stmt->fetch();
        if (!$credito) {
            $this->json(['error' => 'Crédito no encontrado o no está aprobado'], 400);
        }

        $cuotas = CalculadoraInteres::simular($credito['monto_aprobado'], $credito['tasa_interes'], $credito['plazo_meses'], $credito['metodo_interes']);

        $this->db->beginTransaction();
        try {
            $this->db->prepare("DELETE FROM amortizaciones WHERE id_credito = ?")->execute([$idCredito]);
            $stmt = $this->db->prepare("INSERT INTO amortizaciones
                (id_amortizacion, id_credito, numero_cuota, fecha_vencimiento, capital, interes, total, saldo_restante)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

            $fechaInicio = new DateTime($credito['fecha_aprobacion'] ?? date('Y-m-d'));
            foreach ($cuotas as $i => $c) {
                $fechaVto = clone $fechaInicio;
                $fechaVto->modify('+' . ($i + 1) . ' months');
                $stmt->execute([
                    UUIDGenerator::generar(),
                    $idCredito,
                    $c['numero'],
                    $fechaVto->format('Y-m-d'),
                    $c['capital'],
                    $c['interes'],
                    $c['total'],
                    $c['saldo'],
                ]);
            }
            $this->db->commit();
            $this->json(['mensaje' => 'Tabla de amortización generada', 'cuotas' => count($cuotas)]);
        } catch (Exception $e) {
            $this->db->rollBack();
            $this->json(['error' => $e->getMessage()], 500);
        }
    }

    public function excedentes() {
        $this->requirePermission('calculo.excedentes');
        $errors = [];
        $resultado = null;

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $totalExcedente = str_replace(',', '.', $_POST['total_excedente'] ?? '0');

            if (!is_numeric($totalExcedente) || $totalExcedente <= 0) {
                $errors['total'] = 'Ingrese un monto válido';
            } else {
                $socios = $this->db->query("SELECT s.id_socio, s.cedula, CONCAT_WS(' ', s.apellido1, s.apellido2, s.nombre1, s.nombre2) AS nombre,
                                            ca.saldo_obligatorio, ca.saldo_excedente
                                            FROM socios s
                                            JOIN cuentas_ahorro ca ON s.id_socio = ca.id_socio
                                            WHERE s.estado = 'activo'
                                            ORDER BY s.apellido1, s.apellido2, s.nombre1, s.nombre2")->fetchAll();

                $totalAportes = array_sum(array_column($socios, 'saldo_obligatorio'));
                if ($totalAportes <= 0) {
                    $errors['general'] = 'No hay aportes registrados para distribuir';
                } else {
                    $ratio = $totalExcedente / $totalAportes;
                    $distribuido = 0;
                    foreach ($socios as &$s) {
            $s['participacion'] = round($s['saldo_obligatorio'] * $ratio, 2);
            $distribuido += $s['participacion'];
                    }
                    $resultado = [
                        'total_excedente' => $totalExcedente,
                        'total_aportes' => $totalAportes,
                        'ratio' => $ratio,
                        'distribuido' => round($distribuido, 2),
                        'diferencia' => round($totalExcedente - $distribuido, 2),
                        'socios' => $socios,
                    ];
                }
            }
        }

        $this->render('calculos/excedentes', [
            'titulo' => 'Distribución de excedentes',
            'errors' => $errors,
            'resultado' => $resultado,
        ]);
    }

    public function interesesAhorro() {
        $this->requirePermission('calculo.intereses');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->json(['error' => 'Método no permitido'], 405);
        $this->validateCSRF();

        $stmt = $this->db->prepare("SELECT valor FROM parametros WHERE codigo = 'tasa_interes_ahorro'");
        $stmt->execute();
        $tasaAnual = (float)($stmt->fetchColumn() ?: 0);
        if ($tasaAnual <= 0) $this->json(['error' => 'Tasa de interes de ahorro no configurada (0%)'], 400);

        $tasaMensual = $tasaAnual / 100 / 12;

        $stmt = $this->db->prepare("SELECT s.id_socio, ca.saldo_disponible
                                     FROM socios s
                                     JOIN cuentas_ahorro ca ON s.id_socio = ca.id_socio
                                     WHERE s.estado = 'activo' AND ca.saldo_disponible > 0");
        $stmt->execute();
        $socios = $stmt->fetchAll();
        if (empty($socios)) $this->json(['error' => 'No hay socios con saldo'], 400);

        $this->db->beginTransaction();
        try {
            $upd = $this->db->prepare("UPDATE cuentas_ahorro SET saldo_excedente = saldo_excedente + ?, saldo_disponible = saldo_disponible + ?, fecha_ultimo_movimiento = NOW() WHERE id_socio = ?");
            $hist = $this->db->prepare("INSERT INTO historial_operaciones (id_operacion, id_socio, tipo_operacion, monto, id_usuario_registra) VALUES (?, ?, 'interes_ganado', ?, ?)");
            $total = 0;
            foreach ($socios as $s) {
                $interes = round($s['saldo_disponible'] * $tasaMensual, 2);
                if ($interes <= 0) continue;
                $upd->execute([$interes, $interes, $s['id_socio']]);
                $hist->execute([UUIDGenerator::generar(), $s['id_socio'], $interes, $_SESSION['usuario_id']]);
                $total += $interes;
            }
            $this->db->commit();
            try { CajaHelper::registrar(['tipo'=>'egreso','concepto'=>"Intereses ahorro mensual - Total: \$" . number_format($total, 2),'categoria'=>'interes_ahorro','monto'=>$total]); } catch (Exception $e) {}
            $this->json(['mensaje' => 'Intereses calculados y acreditados para ' . count($socios) . ' socios. Total: $' . number_format($total, 2)]);
        } catch (Exception $e) {
            $this->db->rollBack();
            $this->json(['error' => $e->getMessage()], 500);
        }
    }

    public function aprobarExcedentes() {
        $this->requirePermission('calculo.aprobar_excedentes');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $totalExcedente = str_replace(',', '.', $_POST['total_excedente'] ?? '0');
            if (!is_numeric($totalExcedente) || $totalExcedente <= 0) {
                $this->json(['error' => 'Monto inválido'], 400);
            }

            $stmt = $this->db->prepare("SELECT s.id_socio, ca.saldo_obligatorio
                                         FROM socios s
                                         JOIN cuentas_ahorro ca ON s.id_socio = ca.id_socio
                                         WHERE s.estado = 'activo'");
            $stmt->execute();
            $socios = $stmt->fetchAll();
            $totalAportes = array_sum(array_column($socios, 'saldo_obligatorio'));
            if ($totalAportes <= 0) {
                $this->json(['error' => 'Sin aportes'], 400);
            }

            $ratio = $totalExcedente / $totalAportes;
            $this->db->beginTransaction();
            try {
                $upd = $this->db->prepare("UPDATE cuentas_ahorro SET saldo_excedente = saldo_excedente + ?, saldo_disponible = saldo_disponible + ?, fecha_ultimo_movimiento = NOW() WHERE id_socio = ?");
                $hist = $this->db->prepare("INSERT INTO historial_operaciones
                    (id_operacion, id_socio, tipo_operacion, monto, id_usuario_registra)
                    VALUES (?, ?, 'interes_ganado', ?, ?)");
                foreach ($socios as $s) {
                    $monto = round($s['saldo_obligatorio'] * $ratio, 2);
                    $upd->execute([$monto, $monto, $s['id_socio']]);
                    $hist->execute([UUIDGenerator::generar(), $s['id_socio'], $monto, $_SESSION['usuario_id']]);
                }
                $this->db->commit();
                try { CajaHelper::registrar(['tipo'=>'egreso','concepto'=>"Distribucion excedentes - Total: \$" . number_format($totalExcedente, 2),'categoria'=>'distribucion_excedentes','monto'=>$totalExcedente]); } catch (Exception $e) {}
                $this->json(['mensaje' => 'Excedentes distribuidos']);
            } catch (Exception $e) {
                $this->db->rollBack();
                $this->json(['error' => $e->getMessage()], 500);
            }
        }
    }
}
