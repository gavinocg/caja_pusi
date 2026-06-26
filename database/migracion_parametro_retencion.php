<?php
// Migration: add retencion_papelera_dias parameter if missing
$db = Database::getInstance();
$stmt = $db->query("SELECT COUNT(*) FROM parametros WHERE codigo = 'retencion_papelera_dias'");
if ($stmt->fetchColumn() == 0) {
    $db->query("INSERT INTO parametros (codigo, nombre, valor, tipo, modulo) VALUES ('retencion_papelera_dias', 'Dias de retencion en papelera', '30', 'numero', 'general')");
    echo "Migration OK: parametro retencion_papelera_dias creado\n";
} else {
    echo "Migration SKIP: parametro retencion_papelera_dias ya existe\n";
}
