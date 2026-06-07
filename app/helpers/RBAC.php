<?php
class RBAC {
    public static function tienePermiso($usuarioId, $codigoPermiso) {
        $db = Database::getInstance();
        $permisos = self::obtenerPermisosUsuario($usuarioId);
        return in_array($codigoPermiso, $permisos);
    }

    public static function obtenerRolesUsuario($usuarioId) {
        $db = Database::getInstance();
        $stmt = $db->prepare("SELECT r.id_rol, r.nombre, r.descripcion, r.endosable
                               FROM roles_usuarios ru
                               JOIN roles r ON ru.id_rol = r.id_rol
                               WHERE ru.id_usuario = ?");
        $stmt->execute([$usuarioId]);
        return $stmt->fetchAll();
    }

    public static function obtenerUsuariosPorRol($idRol) {
        $db = Database::getInstance();
        $stmt = $db->prepare("SELECT u.id_usuario FROM roles_usuarios ru JOIN usuarios u ON ru.id_usuario = u.id_usuario WHERE ru.id_rol = ? AND u.activo = TRUE");
        $stmt->execute([$idRol]);
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    public static function obtenerUsuariosAdmin() {
        $db = Database::getInstance();
        $stmt = $db->query("SELECT u.id_usuario FROM usuarios u JOIN roles_usuarios ru ON u.id_usuario = ru.id_usuario JOIN roles r ON ru.id_rol = r.id_rol WHERE u.activo = TRUE AND r.nombre != 'Socio' GROUP BY u.id_usuario");
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    public static function obtenerPermisosUsuario($usuarioId) {
        $db = Database::getInstance();
        $roles = self::obtenerRolesUsuario($usuarioId);
        $endosable = false;
        foreach ($roles as $r) {
            if ($r['endosable']) { $endosable = true; break; }
        }

        if ($endosable) {
            $stmt = $db->query("SELECT DISTINCT p.codigo FROM permisos p
                                 JOIN roles_permisos rp ON p.id_permiso = rp.id_permiso
                                 WHERE rp.permitir = TRUE");
            return $stmt->fetchAll(PDO::FETCH_COLUMN);
        }

        $sql = "SELECT DISTINCT p.codigo
                FROM roles_usuarios ru
                JOIN roles_permisos rp ON ru.id_rol = rp.id_rol
                JOIN permisos p ON rp.id_permiso = p.id_permiso
                WHERE ru.id_usuario = ? AND rp.permitir = TRUE";
        $stmt = $db->prepare($sql);
        $stmt->execute([$usuarioId]);
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }
}
