<?php
require_once ROOT_PATH . '/app/helpers/NotificacionHelper.php';
require_once ROOT_PATH . '/app/helpers/PusherHelper.php';

class RetiroController extends BaseController {

    public function listar() {
        $this->requirePermission('cobro.aporte');
        $page = max(1, intval($_GET['p'] ?? 1));
        $porPagina = 20;
        $offset = ($page - 1) * $porPagina;
        $filtro = $_GET['estado'] ?? '';
        $where = $filtro ? "WHERE r.estado = ?" : '';
        $params = $filtro ? [$filtro] : [];
        $total = $this->db->query("SELECT COUNT(*) FROM solicitudes_retiro")->fetchColumn();
        $totalPaginas = ceil($total / $porPagina);
        $stmt = $this->db->prepare("SELECT r.*, CONCAT_WS(' ', s.apellido1, s.apellido2, s.nombre1, s.nombre2) AS socio, s.cedula,
                                     c.saldo_disponible
                                     FROM solicitudes_retiro r
                                     JOIN socios s ON r.id_socio = s.id_socio
                                     LEFT JOIN cuentas_ahorro c ON r.id_socio = c.id_socio
                                     $where
                                     ORDER BY r.fecha_solicitud DESC LIMIT $porPagina OFFSET $offset");
        $stmt->execute($params);
        $solicitudes = $stmt->fetchAll();

        $this->render('retiros/listar', [
            'titulo' => 'Solicitudes de retiro',
            'solicitudes' => $solicitudes,
            'page' => $page,
            'totalPaginas' => $totalPaginas,
            'filtro' => $filtro,
        ]);
    }

    public function aprobar($id) {
        $this->requirePermission('cobro.aporte');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/retiro/listar');
        $this->validateCSRF();

        $stmt = $this->db->prepare("SELECT r.*, c.saldo_disponible FROM solicitudes_retiro r
                                    LEFT JOIN cuentas_ahorro c ON r.id_socio = c.id_socio
                                    WHERE r.id_solicitud = ? AND r.estado = 'pendiente'");
        $stmt->execute([$id]);
        $s = $stmt->fetch();
        if (!$s) { $_SESSION['error'] = 'No encontrada o ya procesada'; $this->redirect('/retiro/listar'); }
        if ($s['monto'] > ($s['saldo_disponible'] ?? 0)) { $_SESSION['error'] = 'Saldo insuficiente'; $this->redirect('/retiro/listar'); }

        $this->db->beginTransaction();
        try {
            $idCobro = UUIDGenerator::generar();
            $hash = hash('sha256', $s['id_socio'] . $id . 'retiro_ahorro' . $s['monto'] . date('Y-m-d H:i:s'));

            $this->db->prepare("UPDATE cuentas_ahorro SET saldo_disponible = saldo_disponible - ?, fecha_ultimo_movimiento = NOW() WHERE id_socio = ?")
                ->execute([$s['monto'], $s['id_socio']]);

            $idSesion = $this->db->query("SELECT id_sesion FROM sesiones_mensuales WHERE estado = 'abierta' LIMIT 1")->fetchColumn();

            $this->db->prepare("INSERT INTO cobros (id_cobro, id_socio, id_sesion, tipo, monto, medio_pago, hash_integridad, usuario_registra)
                VALUES (?, ?, ?, 'retiro_ahorro', ?, 'efectivo', ?, ?)")
                ->execute([$idCobro, $s['id_socio'], $idSesion ?: null, $s['monto'], $hash, $_SESSION['usuario_id']]);

            $this->db->prepare("UPDATE solicitudes_retiro SET estado = 'aprobado', fecha_respuesta = NOW(), usuario_respuesta = ?, id_cobro = ? WHERE id_solicitud = ?")
                ->execute([$_SESSION['usuario_id'], $idCobro, $id]);

            $this->historialInsert($s['id_socio'], 'retiro_ahorro', $s['monto'], $idCobro);
            $this->db->commit();

            try {
                NotificacionHelper::crear([
                    'id_socio' => $s['id_socio'],
                    'tipo' => 'retiro',
                    'titulo' => 'Retiro aprobado',
                    'mensaje' => "Su solicitud de retiro por \${$s['monto']} ha sido aprobada y desembolsada.",
                    'enviar_pusher' => true,
                ]);
                PusherHelper::actualizarPortal($s['id_socio']);
            } catch (Exception $e) {}

            $_SESSION['success'] = 'Retiro aprobado y desembolsado';
            $this->redirect('/retiro/listar');
        } catch (Exception $e) {
            $this->db->rollBack();
            $_SESSION['error'] = $e->getMessage();
            $this->redirect('/retiro/listar');
        }
    }

    public function rechazar($id) {
        $this->requirePermission('cobro.aporte');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/retiro/listar');
        $this->validateCSRF();

        $stmt = $this->db->prepare("SELECT id_socio, monto FROM solicitudes_retiro WHERE id_solicitud = ? AND estado = 'pendiente'");
        $stmt->execute([$id]);
        $s = $stmt->fetch();

        $this->db->prepare("UPDATE solicitudes_retiro SET estado = 'rechazado', fecha_respuesta = NOW(), usuario_respuesta = ? WHERE id_solicitud = ? AND estado = 'pendiente'")
            ->execute([$_SESSION['usuario_id'], $id]);

        if ($s) {
            try {
                NotificacionHelper::crear([
                    'id_socio' => $s['id_socio'],
                    'tipo' => 'retiro',
                    'titulo' => 'Retiro rechazado',
                    'mensaje' => "Su solicitud de retiro por \${$s['monto']} ha sido rechazada.",
                    'enviar_pusher' => true,
                ]);
            } catch (Exception $e) {}
        }

        $_SESSION['success'] = 'Solicitud rechazada';
        $this->redirect('/retiro/listar');
    }
}
