<?php
// Migration: add missing columns to usuarios table
// Safe to run multiple times (idempotent)

$db = Database::getInstance();

// Check if token_activacion column exists
$stmt = $db->query("SHOW COLUMNS FROM usuarios LIKE 'token_activacion'");
if (!$stmt->fetch()) {
    $db->query("ALTER TABLE usuarios
        ADD COLUMN token_activacion VARCHAR(64) DEFAULT NULL AFTER fecha_ultimo_acceso,
        ADD COLUMN token_activacion_expira DATETIME DEFAULT NULL AFTER token_activacion,
        ADD COLUMN fecha_contrasena DATETIME DEFAULT NULL AFTER token_activacion_expira,
        ADD COLUMN reset_token_hash VARCHAR(64) DEFAULT NULL AFTER fecha_contrasena,
        ADD COLUMN reset_token_expira DATETIME DEFAULT NULL AFTER reset_token_hash,
        ADD COLUMN reset_token_usos INT DEFAULT 0 AFTER reset_token_expira");
    echo "Migration OK: columnas agregadas a usuarios\n";
} else {
    echo "Migration SKIP: columnas ya existen en usuarios\n";
}

// Check if notificaciones has buzon column
$stmt = $db->query("SHOW COLUMNS FROM notificaciones LIKE 'buzon'");
if (!$stmt->fetch()) {
    $db->query("ALTER TABLE notificaciones
        ADD COLUMN buzon ENUM('entrada','archivadas','papelera') DEFAULT 'entrada' AFTER leida,
        ADD COLUMN fecha_eliminacion DATETIME DEFAULT NULL AFTER fecha_lectura");
    echo "Migration OK: columnas agregadas a notificaciones\n";
} else {
    echo "Migration SKIP: columnas ya existen en notificaciones\n";
}

// Check if multas has estado column
$stmt = $db->query("SHOW COLUMNS FROM multas LIKE 'estado'");
if (!$stmt->fetch()) {
    $db->query("ALTER TABLE multas
        ADD COLUMN estado ENUM('activa','impugnada','anulada') DEFAULT 'activa' AFTER motivo");
    echo "Migration OK: columna estado agregada a multas\n";
} else {
    echo "Migration SKIP: columna estado ya existe en multas\n";
}
