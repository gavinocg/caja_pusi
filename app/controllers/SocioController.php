<?php
require_once 'app/models/Socio.php';

class SocioController extends BaseController {

    public function listar() {
        $this->requirePermission('socio.consultar');
        $socioModel = new Socio();
        $page = $this->getPage();
        $search = $this->getParam('search', '');
        $estado = $this->getParam('estado', '');

        $where = '1=1';
        $params = [];
        if (!empty($search)) {
            $where .= " AND (cedula LIKE ? OR apellido1 LIKE ? OR nombre1 LIKE ?)";
            $term = "%$search%";
            $params = [$term, $term, $term];
        }
        if (!empty($estado)) {
            $where .= " AND estado = ?";
            $params[] = $estado;
        }

        $socios = $socioModel->paginate($page, 20, $where, $params, 'apellido1, apellido2, nombre1');
        $this->render('socio/listar', [
            'titulo' => 'Socios',
            'socios' => $socios,
            'search' => $search,
            'estado' => $estado,
        ]);
    }

    public function registrar() {
        $this->requirePermission('socio.registrar');
        $errors = [];

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $data = $this->getPostData();
            $validator = new Validator();
            $validator
                ->required('cedula', 'Cédula', $data['cedula'])
                ->cedula('cedula', 'Cédula', $data['cedula'])
                ->unique('cedula', 'Cédula', $data['cedula'], 'socios', 'cedula')
                ->required('apellido1', 'Primer apellido', $data['apellido1'])
                ->required('nombre1', 'Primer nombre', $data['nombre1'])
                ->required('fecha_nacimiento', 'Fecha de nacimiento', $data['fecha_nacimiento'])
                ->date('fecha_nacimiento', 'Fecha de nacimiento', $data['fecha_nacimiento'])
                ->required('direccion', 'Dirección', $data['direccion'])
                ->required('celular', 'Celular', $data['celular'])
                ->required('correo_electronico', 'Correo electrónico', $data['correo_electronico'])
                ->email('correo_electronico', 'Correo electrónico', $data['correo_electronico'])
                ->unique('correo_electronico', 'Correo electrónico', $data['correo_electronico'], 'socios', 'correo_electronico');

            if ($validator->hasErrors()) {
                $errors = $validator->getErrors();
            } else {
                $socioModel = new Socio();
                $idSocio = UUIDGenerator::generate();
                $insertData = [
                    'id_socio' => $idSocio,
                    'cedula' => strtoupper($data['cedula']),
                    'apellido1' => strtoupper($data['apellido1']),
                    'apellido2' => strtoupper($data['apellido2'] ?? ''),
                    'nombre1' => strtoupper($data['nombre1']),
                    'nombre2' => strtoupper($data['nombre2'] ?? ''),
                    'fecha_nacimiento' => $data['fecha_nacimiento'],
                    'genero' => $data['genero'],
                    'estado_civil' => !empty($data['estado_civil']) ? $data['estado_civil'] : null,
                    'direccion' => $data['direccion'],
                    'telefono' => $data['telefono'] ?? '',
                    'celular' => $data['celular'],
                    'correo_electronico' => $data['correo_electronico'],
                    'profesion' => $data['profesion'] ?? '',
                    'estado' => 'pendiente',
                    'fecha_ingreso' => date('Y-m-d'),
                    'menor_edad' => !empty($data['menor_edad']) ? 1 : 0,
                    'representante_nombres' => $data['representante_nombres'] ?? '',
                    'representante_cedula' => $data['representante_cedula'] ?? '',
                    'representante_telefono' => $data['representante_telefono'] ?? '',
                    'representante_correo' => $data['representante_correo'] ?? '',
                ];
                $insertData['hash_integridad'] = hash('sha256', json_encode($insertData));

                if ($socioModel->insert($insertData)) {
                    $this->redirect('/socio/ver/' . $idSocio);
                } else {
                    $errors['general'] = 'Error al registrar el socio';
                }
            }
        }

        $this->render('socio/registrar', [
            'titulo' => 'Registrar socio',
            'errors' => $errors,
            'data' => $_POST ?? [],
        ]);
    }

    public function editar($id) {
        $this->requirePermission('socio.editar');
        $socioModel = new Socio();
        $socio = $socioModel->getById($id);
        if (!$socio) $this->redirect('/socio/listar');

        $errors = [];
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $data = $this->getPostData();
            $validator = new Validator();
            $validator
                ->required('apellido1', 'Primer apellido', $data['apellido1'])
                ->required('nombre1', 'Primer nombre', $data['nombre1'])
                ->email('correo_electronico', 'Correo electrónico', $data['correo_electronico']);

            if ($validator->hasErrors()) {
                $errors = $validator->getErrors();
            } else {
                $updateData = [
                    'apellido1' => strtoupper($data['apellido1']),
                    'apellido2' => strtoupper($data['apellido2'] ?? ''),
                    'nombre1' => strtoupper($data['nombre1']),
                    'nombre2' => strtoupper($data['nombre2'] ?? ''),
                    'direccion' => $data['direccion'],
                    'telefono' => $data['telefono'] ?? '',
                    'celular' => $data['celular'],
                    'profesion' => $data['profesion'] ?? '',
                ];
                $updateData['hash_integridad'] = hash('sha256', json_encode($updateData));

                if ($socioModel->update($id, $updateData)) {
                    $this->redirect('/socio/ver/' . $id);
                } else {
                    $errors['general'] = 'Error al actualizar';
                }
            }
        }

        $this->render('socio/editar', [
            'titulo' => 'Editar socio',
            'socio' => $socio,
            'errors' => $errors,
        ]);
    }

    public function ver($id) {
        $this->requirePermission('socio.consultar');
        $socioModel = new Socio();
        $socio = $socioModel->getById($id);
        if (!$socio) $this->redirect('/socio/listar');

        $cuenta = null;
        $creditos = [];
        $inversiones = [];
        if (RBAC::tienePermiso($_SESSION['usuario_id'], 'socio.ver_financiero')) {
            $stmt = $this->db->prepare("SELECT * FROM cuentas_ahorro WHERE id_socio = ?");
            $stmt->execute([$id]);
            $cuenta = $stmt->fetch();

            $stmt = $this->db->prepare("SELECT * FROM creditos WHERE id_socio = ? ORDER BY fecha_solicitud DESC");
            $stmt->execute([$id]);
            $creditos = $stmt->fetchAll();

            $stmt = $this->db->prepare("SELECT * FROM inversiones WHERE id_socio = ? ORDER BY fecha_inicio DESC");
            $stmt->execute([$id]);
            $inversiones = $stmt->fetchAll();
        }

        $this->render('socio/ver', [
            'titulo' => 'Datos del socio',
            'socio' => $socio,
            'cuenta' => $cuenta,
            'creditos' => $creditos,
            'inversiones' => $inversiones,
        ]);
    }

    public function cambiarEstado($id) {
        $this->requirePermission('socio.cambiar_estado');
        $socioModel = new Socio();
        $socio = $socioModel->getById($id);
        if (!$socio) $this->json(['error' => 'Socio no encontrado'], 404);

        $nuevoEstado = $_POST['estado'] ?? '';
        $validos = ['pre_activo', 'activo', 'suspendido', 'retiro_voluntario', 'excluido', 'fallecido'];
        if (!in_array($nuevoEstado, $validos)) {
            $this->json(['error' => 'Estado no válido'], 400);
        }

        $updateData = ['estado' => $nuevoEstado];
        if ($nuevoEstado === 'retiro_voluntario') {
            $updateData['fecha_retiro'] = date('Y-m-d');
            $updateData['motivo_retiro'] = $_POST['motivo'] ?? '';
        }
        if ($nuevoEstado === 'excluido') {
            $updateData['fecha_exclusion'] = date('Y-m-d');
            $updateData['motivo_exclusion'] = $_POST['motivo'] ?? '';
        }
        if ($nuevoEstado === 'activo') {
            $updateData['fecha_aprobacion'] = date('Y-m-d');
            $updateData['numero_acta_aprobacion'] = $_POST['numero_acta'] ?? '';
            if (!empty($_FILES['acta_pdf']) && $_FILES['acta_pdf']['error'] === UPLOAD_ERR_OK) {
                $ext = strtolower(pathinfo($_FILES['acta_pdf']['name'], PATHINFO_EXTENSION));
                if ($ext === 'pdf') {
                    $nombre = 'acta_aprobacion_' . substr($id, 0, 8) . '.pdf';
                    move_uploaded_file($_FILES['acta_pdf']['tmp_name'], ROOT_PATH . '/storage/documentos/' . $nombre);
                    $updateData['acta_aprobacion_pdf'] = $nombre;
                }
            }
        }
        $updateData['hash_integridad'] = hash('sha256', json_encode($updateData));

        if ($socioModel->update($id, $updateData)) {
            $this->json(['mensaje' => 'Estado actualizado', 'estado' => $nuevoEstado]);
        } else {
            $this->json(['error' => 'Error al actualizar'], 500);
        }
    }

    public function subirDocumento($id) {
        $this->requirePermission('socio.editar');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/socio/ver/' . $id);
        $this->validateCSRF();

        $campos = [
            'foto' => ['col' => 'foto_url', 'exts' => ['jpg','jpeg','png','gif','webp']],
            'doc_frente' => ['col' => 'documento_identidad_anverso', 'exts' => ['jpg','jpeg','png','pdf']],
            'doc_reverso' => ['col' => 'documento_identidad_reverso', 'exts' => ['jpg','jpeg','png','pdf']],
            'doc_representante' => ['col' => 'representante_documento_pdf', 'exts' => ['pdf']],
        ];

        $tipo = $_POST['tipo_documento'] ?? '';
        if (!isset($campos[$tipo])) $this->json(['error' => 'Tipo inválido'], 400);

        $campo = $campos[$tipo];
        if (empty($_FILES['archivo']) || $_FILES['archivo']['error'] !== UPLOAD_ERR_OK) {
            $this->json(['error' => 'Seleccione un archivo'], 400);
        }

        $ext = strtolower(pathinfo($_FILES['archivo']['name'], PATHINFO_EXTENSION));
        if (!in_array($ext, $campo['exts'])) {
            $this->json(['error' => 'Formato no válido. Extensiones: ' . implode(', ', $campo['exts'])], 400);
        }

        $nombre = $tipo . '_' . substr($id, 0, 8) . '.' . $ext;
        move_uploaded_file($_FILES['archivo']['tmp_name'], ROOT_PATH . '/storage/documentos/' . $nombre);

        $this->db->prepare("UPDATE socios SET {$campo['col']} = ? WHERE id_socio = ?")->execute([$nombre, $id]);
        $this->json(['mensaje' => 'Documento subido']);
    }

    private function getPostData() {
        return [
            'cedula' => $_POST['cedula'] ?? '',
            'apellido1' => $_POST['apellido1'] ?? '',
            'apellido2' => $_POST['apellido2'] ?? '',
            'nombre1' => $_POST['nombre1'] ?? '',
            'nombre2' => $_POST['nombre2'] ?? '',
            'fecha_nacimiento' => $_POST['fecha_nacimiento'] ?? '',
            'genero' => $_POST['genero'] ?? '',
            'estado_civil' => $_POST['estado_civil'] ?? '',
            'direccion' => $_POST['direccion'] ?? '',
            'telefono' => $_POST['telefono'] ?? '',
            'celular' => $_POST['celular'] ?? '',
            'correo_electronico' => $_POST['correo'] ?? '',
            'profesion' => $_POST['profesion'] ?? '',
            'menor_edad' => $_POST['menor_edad'] ?? '',
            'representante_nombres' => $_POST['representante_nombres'] ?? '',
            'representante_cedula' => $_POST['representante_cedula'] ?? '',
            'representante_telefono' => $_POST['representante_telefono'] ?? '',
            'representante_correo' => $_POST['representante_correo'] ?? '',
        ];
    }
}
