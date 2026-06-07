USE caja_ahorro_pujota;

-- 1. Tabla de reglas de notificacion
CREATE TABLE IF NOT EXISTS reglas_notificacion (
    id_regla INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    titulo_evento VARCHAR(200) DEFAULT NULL,
    canal VARCHAR(20) NOT NULL DEFAULT 'push',
    para_todos BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_reglas_evento (tipo_evento, activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabla de destinatarios por regla
CREATE TABLE IF NOT EXISTS reglas_notificacion_destinatarios (
    id_regla INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_regla, id_rol),
    FOREIGN KEY (id_regla) REFERENCES reglas_notificacion(id_regla) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Nuevo permiso: notificacion.configurar
INSERT IGNORE INTO permisos (codigo, nombre, descripcion) VALUES
('notificacion.configurar', 'Configurar reglas de notificacion', 'Gestionar las reglas de notificacion del sistema (canal y destinatarios)');

SET @perm_id = (SELECT id_permiso FROM permisos WHERE codigo = 'notificacion.configurar');

-- Asignar a Admin Tecnico (1), Presidente (2), Analista Financiero (3)
INSERT IGNORE INTO roles_permisos (id_rol, id_permiso, permitir) VALUES
(1, @perm_id, TRUE),
(2, @perm_id, TRUE),
(3, @perm_id, TRUE);

-- 4. Reglas por defecto
INSERT INTO reglas_notificacion (codigo, nombre, tipo_evento, titulo_evento, canal, para_todos, activo) VALUES
('solicitud_credito', 'Solicitud de credito', 'credito', 'Nueva solicitud de credito', 'push', FALSE, TRUE),
('credito_aprobado', 'Credito aprobado', 'credito', 'Credito aprobado', 'push', FALSE, TRUE),
('credito_rechazado', 'Credito rechazado', 'credito', 'Credito rechazado', 'push', FALSE, TRUE),
('credito_desembolsado', 'Credito desembolsado', 'credito', 'Credito desembolsado', 'push', FALSE, TRUE),
('credito_mora', 'Credito en mora', 'credito', NULL, 'ambos', TRUE, TRUE),
('solicitud_retiro', 'Solicitud de retiro', 'cobro', 'Solicitud de retiro', 'push', FALSE, TRUE),
('sesion_cerrada', 'Sesion cerrada', 'sesion', 'Sesion cerrada', 'ambos', TRUE, TRUE);

-- 5. Destinatarios por defecto
-- solicitud_credito -> Presidente (2)
INSERT INTO reglas_notificacion_destinatarios (id_regla, id_rol)
SELECT id_regla, 2 FROM reglas_notificacion WHERE codigo = 'solicitud_credito';

-- credito_aprobado -> Tesorero (4)
INSERT INTO reglas_notificacion_destinatarios (id_regla, id_rol)
SELECT id_regla, 4 FROM reglas_notificacion WHERE codigo = 'credito_aprobado';

-- credito_rechazado -> Ningun rol admin (solo se notifica al socio afectado)
-- (sin destinatarios admin)

-- credito_desembolsado -> Socio afectado (notificacion directa desde controller)
-- (sin destinatarios admin)

-- solicitud_retiro -> Presidente (2), Tesorero (4)
INSERT INTO reglas_notificacion_destinatarios (id_regla, id_rol)
SELECT id_regla, 2 FROM reglas_notificacion WHERE codigo = 'solicitud_retiro';
INSERT INTO reglas_notificacion_destinatarios (id_regla, id_rol)
SELECT id_regla, 4 FROM reglas_notificacion WHERE codigo = 'solicitud_retiro';
