<?php
class CatalogoController extends BaseController {

    public function provincias() {
        $this->requirePermission('param.catalogos');
        $stmt = $this->db->query("SELECT * FROM provincias ORDER BY nombre");
        $provincias = $stmt->fetchAll();
        $this->render('parametros/catalogos', [
            'titulo' => 'Provincias',
            'items' => $provincias,
            'tipo' => 'provincias',
            'campos' => [['nombre', 'Nombre', 'text']],
        ]);
    }

    public function cantones() {
        $this->requirePermission('param.catalogos');
        $stmt = $this->db->query("SELECT c.id_canton, c.nombre, p.nombre AS provincia
                                   FROM cantones c JOIN provincias p ON c.id_provincia = p.id_provincia
                                   ORDER BY p.nombre, c.nombre");
        $items = $stmt->fetchAll();

        $provincias = $this->db->query("SELECT id_provincia, nombre FROM provincias ORDER BY nombre")->fetchAll();

        $this->render('parametros/catalogos_cantones', [
            'titulo' => 'Cantones',
            'items' => $items,
            'provincias' => $provincias,
        ]);
    }

    public function entidades() {
        $this->requirePermission('param.catalogos');
        $stmt = $this->db->query("SELECT * FROM catastro_entidades_publicas ORDER BY razon_social");
        $items = $stmt->fetchAll();
        $this->render('parametros/catalogos', [
            'titulo' => 'Entidades públicas',
            'items' => $items,
            'tipo' => 'entidades',
            'campos' => [
                ['ruc', 'RUC', 'text'],
                ['razon_social', 'Razón social', 'text'],
            ],
        ]);
    }

    public function agregar($tipo) {
        $this->requirePermission('param.catalogos');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            if ($tipo === 'provincias') {
                $nombre = trim($_POST['nombre'] ?? '');
                if (!empty($nombre)) {
                    $this->db->prepare("INSERT INTO provincias (nombre) VALUES (?)")->execute([$nombre]);
                }
                $this->redirect('/catalogo/provincias');
            } elseif ($tipo === 'entidades') {
                $ruc = trim($_POST['ruc'] ?? '');
                $razon = trim($_POST['razon_social'] ?? '');
                if (!empty($ruc) && !empty($razon)) {
                    $this->db->prepare("INSERT INTO catastro_entidades_publicas (ruc, razon_social) VALUES (?, ?)")->execute([$ruc, $razon]);
                }
                $this->redirect('/catalogo/entidades');
            }
        }
        $this->redirect('/catalogo/' . $tipo);
    }

    public function agregarCanton() {
        $this->requirePermission('param.catalogos');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $idProvincia = intval($_POST['id_provincia'] ?? 0);
            $nombre = trim($_POST['nombre'] ?? '');
            if ($idProvincia > 0 && !empty($nombre)) {
                $this->db->prepare("INSERT INTO cantones (id_provincia, nombre) VALUES (?, ?)")->execute([$idProvincia, $nombre]);
            }
        }
        $this->redirect('/catalogo/cantones');
    }

    public function editar($tipo, $id) {
        $this->requirePermission('param.catalogos');
        $tables = ['provincias' => 'provincias', 'cantones' => 'cantones', 'entidades' => 'catastro_entidades_publicas'];
        $pk = ['provincias' => 'id_provincia', 'cantones' => 'id_canton', 'entidades' => 'id_entidad'];
        $cols = ['provincias' => ['nombre' => 'nombre'], 'cantones' => ['nombre' => 'nombre', 'id_provincia' => 'id_provincia'], 'entidades' => ['ruc' => 'ruc', 'razon_social' => 'razon_social']];

        if (!isset($tables[$tipo])) $this->redirect('/catalogo/' . $tipo);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $updates = [];
            $params = [];
            foreach ($cols[$tipo] as $col => $postField) {
                $val = $_POST[$postField] ?? '';
                $updates[] = "$col = ?";
                $params[] = $val;
            }
            $params[] = $id;
            $this->db->prepare("UPDATE {$tables[$tipo]} SET " . implode(', ', $updates) . " WHERE {$pk[$tipo]} = ?")->execute($params);
            $this->redirect('/catalogo/' . ($tipo === 'cantones' ? 'cantones' : $tipo));
        }

        $stmt = $this->db->prepare("SELECT * FROM {$tables[$tipo]} WHERE {$pk[$tipo]} = ?");
        $stmt->execute([$id]);
        $item = $stmt->fetch();
        if (!$item) $this->redirect('/catalogo/' . $tipo);

        $provincias = ($tipo === 'cantones') ? $this->db->query("SELECT id_provincia, nombre FROM provincias ORDER BY nombre")->fetchAll() : [];

        $this->render('parametros/catalogo_editar', [
            'titulo' => 'Editar ' . rtrim($tipo === 'entidades' ? 'entidad pública' : ($tipo === 'cantones' ? 'cantón' : 'provincia')),
            'item' => $item,
            'tipo' => $tipo,
            'cols' => $cols[$tipo],
            'provincias' => $provincias,
        ]);
    }

    public function eliminar($tipo, $id) {
        $this->requirePermission('param.catalogos');
        $tables = ['provincias' => 'provincias', 'cantones' => 'cantones', 'entidades' => 'catastro_entidades_publicas'];
        $pk = ['provincias' => 'id_provincia', 'cantones' => 'id_canton', 'entidades' => 'id_entidad'];
        if (isset($tables[$tipo])) {
            $this->db->prepare("DELETE FROM {$tables[$tipo]} WHERE {$pk[$tipo]} = ?")->execute([$id]);
        }
        $this->redirect('/catalogo/' . $tipo);
    }
}
