<?php
class MultaController extends BaseController {

    public function listar() {
        $this->requireAuth();
        $cedula = $_SESSION['usuario_cedula'] ?? '';
        $idSocio = null;
        $esSocio = false;
        if ($cedula) {
            $stmt = $this->db->prepare("SELECT id_socio FROM socios WHERE cedula = ?");
            $stmt->execute([$cedula]);
            $idSocio = $stmt->fetchColumn();
            if ($idSocio) $esSocio = true;
        }

        $page = max(1, intval($_GET['p'] ?? 1));
        $porPagina = 20;
        $offset = ($page - 1) * $porPagina;

        if ($esSocio) {
            $stmt = $this->db->prepare("SELECT m.*, CONCAT_WS(' ', s.apellido1, s.apellido2, s.nombre1, s.nombre2) AS socio, s.cedula,
                                        (SELECT COUNT(*) FROM obligaciones_sesion WHERE id_referencia = m.id_multa AND tipo = 'multa' AND pagada = TRUE) AS pagada
                                        FROM multas m
                                        JOIN socios s ON m.id_socio = s.id_socio
                                        WHERE m.id_socio = ?
                                        ORDER BY m.fecha_generacion DESC LIMIT $porPagina OFFSET $offset");
            $stmt->execute([$idSocio]);
            $multas = $stmt->fetchAll();
            $total = $this->db->prepare("SELECT COUNT(*) FROM multas WHERE id_socio = ?");
            $total->execute([$idSocio]);
            $totalMultas = $total->fetchColumn();
            $totalPaginas = ceil($totalMultas / $porPagina);
            $filtroTipo = $filtroSocio = '';
        } else {
            $filtroTipo = $_GET['tipo'] ?? '';
            $filtroSocio = $_GET['socio'] ?? '';
            $where = [];
            $params = [];
            if ($filtroTipo) { $where[] = 'm.tipo = ?'; $params[] = $filtroTipo; }
            if ($filtroSocio) { $where[] = 's.apellido1 LIKE ?'; $params[] = "%$filtroSocio%"; }
            $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';
            $stmt = $this->db->prepare("SELECT m.*, CONCAT_WS(' ', s.apellido1, s.apellido2, s.nombre1, s.nombre2) AS socio, s.cedula,
                                        (SELECT COUNT(*) FROM obligaciones_sesion WHERE id_referencia = m.id_multa AND tipo = 'multa' AND pagada = TRUE) AS pagada
                                        FROM multas m
                                        JOIN socios s ON m.id_socio = s.id_socio
                                        $whereClause
                                        ORDER BY m.fecha_generacion DESC LIMIT $porPagina OFFSET $offset");
            $stmt->execute($params);
            $multas = $stmt->fetchAll();
            $total = $this->db->prepare("SELECT COUNT(*) FROM multas m JOIN socios s ON m.id_socio = s.id_socio $whereClause");
            $total->execute($params);
            $totalMultas = $total->fetchColumn();
            $totalPaginas = ceil($totalMultas / $porPagina);
        }

        $this->render('multas/listar', [
            'titulo' => 'Multas',
            'multas' => $multas,
            'page' => $page,
            'totalPaginas' => $totalPaginas,
            'filtroTipo' => $filtroTipo ?? '',
            'filtroSocio' => $filtroSocio ?? '',
            'esSocio' => $esSocio,
            'esPresidente' => $this->esPresidente(),
        ]);
    }

    private function esPresidente() {
        $roles = RBAC::obtenerRolesUsuario($_SESSION['usuario_id']);
        foreach ($roles as $r) {
            if ($r['nombre'] === 'Presidente') return true;
        }
        return false;
    }

    public function ver($id) {
        $this->requireAuth();
        $stmt = $this->db->prepare("SELECT m.*, CONCAT_WS(' ', s.apellido1, s.apellido2, s.nombre1, s.nombre2) AS socio,
                                     s.cedula, s.correo_electronico
                                     FROM multas m
                                     JOIN socios s ON m.id_socio = s.id_socio
                                     WHERE m.id_multa = ?");
        $stmt->execute([$id]);
        $multa = $stmt->fetch();
        if (!$multa) $this->redirect('/multa/listar');

        // Verificar si la multa tiene alguna obligacion pagada
        $stmt = $this->db->prepare("SELECT COUNT(*) FROM obligaciones_sesion WHERE id_referencia = ? AND tipo = 'multa' AND pagada = TRUE");
        $stmt->execute([$id]);
        $pagada = $stmt->fetchColumn() > 0;

        $this->render('multas/ver', [
            'titulo' => 'Multa',
            'multa' => $multa,
            'pagada' => $pagada,
            'esPresidente' => $this->esPresidente(),
        ]);
    }

    public function justificar($id) {
        $this->requireAuth();
        $stmt = $this->db->prepare("SELECT m.*, s.cedula FROM multas m JOIN socios s ON m.id_socio = s.id_socio WHERE m.id_multa = ?");
        $stmt->execute([$id]);
        $multa = $stmt->fetch();
        if (!$multa) $this->json(['error' => 'No encontrada'], 404);
        if ($multa['cedula'] !== ($_SESSION['usuario_cedula'] ?? '')) {
            $this->json(['error' => 'No autorizado'], 403);
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $texto = trim($_POST['justificacion'] ?? '');
            $archivo = null;

            if (empty($texto)) $this->json(['error' => 'Escriba una justificacion'], 400);

            if (!empty($_FILES['archivo']) && $_FILES['archivo']['error'] === UPLOAD_ERR_OK) {
                $ext = strtolower(pathinfo($_FILES['archivo']['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, ['pdf', 'jpg', 'jpeg', 'png'])) {
                    $this->json(['error' => 'Solo PDF, JPG o PNG'], 400);
                }
                $nombre = 'justificacion_' . substr($id, 0, 8) . '.' . $ext;
                $destino = ROOT_PATH . '/storage/documentos/' . $nombre;
                move_uploaded_file($_FILES['archivo']['tmp_name'], $destino);
                $archivo = $nombre;
            }

            if ($archivo) {
                $this->db->prepare("UPDATE multas SET justificacion = ?, justificacion_pdf = ? WHERE id_multa = ?")
                    ->execute([$texto, $archivo, $id]);
            } else {
                $this->db->prepare("UPDATE multas SET justificacion = ? WHERE id_multa = ?")
                    ->execute([$texto, $id]);
            }

            $this->json(['mensaje' => 'Justificación enviada']);
        }
    }

    public function aprobarJustificacion($id) {
        $this->requirePermission('socio.cambiar_estado');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->json(['error' => 'Método no permitido'], 405);
        $this->validateCSRF();
        $accion = $_POST['accion'] ?? '';
        $aprobada = $accion === 'aprobar' ? 1 : 0;
        $this->db->prepare("UPDATE multas SET justificacion_aprobada = ? WHERE id_multa = ?")->execute([$aprobada, $id]);
        $this->json(['mensaje' => $aprobada ? 'Justificación aprobada' : 'Justificación rechazada']);
    }

    public function impugnar($id) {
        $this->requireAuth();
        $stmt = $this->db->prepare("SELECT m.*, s.cedula FROM multas m JOIN socios s ON m.id_socio = s.id_socio WHERE m.id_multa = ?");
        $stmt->execute([$id]);
        $multa = $stmt->fetch();
        if (!$multa) $this->json(['error' => 'No encontrada'], 404);

        // Verificar si ya fue pagada via obligaciones
        $stmtPag = $this->db->prepare("SELECT COUNT(*) FROM obligaciones_sesion WHERE id_referencia = ? AND tipo = 'multa' AND pagada = TRUE");
        $stmtPag->execute([$id]);
        if ($stmtPag->fetchColumn() > 0) $this->json(['error' => 'No se puede impugnar una multa ya pagada'], 400);
        if ($multa['impugnada']) $this->json(['error' => 'Ya fue impugnada'], 400);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $texto = trim($_POST['justificacion'] ?? '');
            if (empty($texto)) $this->json(['error' => 'Escriba una justificacion'], 400);

            $archivo = null;
            if (!empty($_FILES['archivo']) && $_FILES['archivo']['error'] === UPLOAD_ERR_OK) {
                $ext = strtolower(pathinfo($_FILES['archivo']['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, ['pdf', 'jpg', 'jpeg', 'png'])) {
                    $this->json(['error' => 'Solo PDF, JPG o PNG'], 400);
                }
                $nombre = 'impugnacion_' . substr($id, 0, 8) . '.' . $ext;
                move_uploaded_file($_FILES['archivo']['tmp_name'], ROOT_PATH . '/storage/documentos/' . $nombre);
                $archivo = $nombre;
            }

            $this->db->beginTransaction();
            try {
                $this->db->prepare("UPDATE multas SET justificacion = ?, justificacion_pdf = COALESCE(?, justificacion_pdf), impugnada = TRUE WHERE id_multa = ?")
                    ->execute([$texto, $archivo, $id]);

                $this->db->prepare("UPDATE obligaciones_sesion SET pagada = TRUE WHERE id_referencia = ? AND tipo = 'multa' AND pagada = FALSE")
                    ->execute([$id]);

                $this->db->commit();

                try {
                    require_once ROOT_PATH . '/app/helpers/NotificacionHelper.php';
                    NotificacionHelper::crear([
                        'id_socio' => $multa['id_socio'],
                        'tipo' => 'multa',
                        'titulo' => 'Multa impugnada',
                        'mensaje' => 'Su multa ha sido registrada como impugnada y queda sin efecto.',
                        'enviar_pusher' => true,
                    ]);
                } catch (Exception $e) {}

                try {
                    require_once ROOT_PATH . '/app/helpers/PusherHelper.php';
                    PusherHelper::actualizarPortal($multa['id_socio']);
                } catch (Exception $e) {}

                $this->json(['mensaje' => 'Multa impugnada correctamente']);
            } catch (Exception $e) {
                $this->db->rollBack();
                $this->json(['error' => $e->getMessage()], 500);
            }
        }
    }

    public function eliminar($id) {
        $this->requireAuth();
        $roles = RBAC::obtenerRolesUsuario($_SESSION['usuario_id']);
        $esPresidente = false;
        foreach ($roles as $r) {
            if ($r['nombre'] === 'Presidente') { $esPresidente = true; break; }
        }
        if (!$esPresidente) $this->json(['error' => 'Solo el Presidente puede eliminar multas'], 403);

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->json(['error' => 'Metodo no permitido'], 405);
        $this->validateCSRF();

        $stmt = $this->db->prepare("SELECT id_multa FROM multas WHERE id_multa = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) $this->json(['error' => 'No encontrada'], 404);

        // Verificar si tiene obligacion pagada
        $stmtPag = $this->db->prepare("SELECT COUNT(*) FROM obligaciones_sesion WHERE id_referencia = ? AND tipo = 'multa' AND pagada = TRUE");
        $stmtPag->execute([$id]);
        if ($stmtPag->fetchColumn() > 0) $this->json(['error' => 'No se puede eliminar una multa con pagos asociados'], 400);

        $this->db->prepare("DELETE FROM multas WHERE id_multa = ?")->execute([$id]);
        $this->json(['mensaje' => 'Multa eliminada']);
    }
}
