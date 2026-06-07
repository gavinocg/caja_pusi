<?php
class ParametroController extends BaseController {

    public function listar() {
        $this->requirePermission('param.financiero');
        $stmt = $this->db->query("SELECT * FROM parametros ORDER BY modulo, codigo");
        $params = $stmt->fetchAll();

        $this->render('parametros/listar', [
            'titulo' => 'Parámetros del sistema',
            'params' => $params,
        ]);
    }

    public function editar($id) {
        $this->requirePermission('param.financiero');
        $stmt = $this->db->prepare("SELECT * FROM parametros WHERE id_parametro = ?");
        $stmt->execute([$id]);
        $param = $stmt->fetch();
        if (!$param) $this->redirect('/parametro/listar');

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            if (!$param['editable']) {
                $this->render('parametros/editar', [
                    'titulo' => 'Editar parámetro',
                    'param' => $param,
                    'error' => 'Este parámetro no es editable',
                ]);
                return;
            }
            $valor = $_POST['valor'] ?? '';
            $stmt = $this->db->prepare("UPDATE parametros SET valor = ? WHERE id_parametro = ?");
            $stmt->execute([$valor, $id]);
            $this->redirect('/parametro/listar');
        }

        $this->render('parametros/editar', [
            'titulo' => 'Editar parámetro',
            'param' => $param,
        ]);
    }

    public function modulo($modulo) {
        $this->requirePermission('param.financiero');
        $stmt = $this->db->prepare("SELECT * FROM parametros WHERE modulo = ? ORDER BY codigo");
        $stmt->execute([$modulo]);
        $params = $stmt->fetchAll();

        $this->render('parametros/listar', [
            'titulo' => "Parámetros - $modulo",
            'params' => $params,
        ]);
    }
}
