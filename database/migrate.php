#!/usr/bin/env php
<?php
// Migration runner - executed automatically on deploy

require_once __DIR__ . '/../config/app.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance();

$migrationsDir = __DIR__;
$migrations = glob($migrationsDir . '/migracion_*.php');
sort($migrations);

foreach ($migrations as $file) {
    echo basename($file) . "... ";
    try {
        include $file;
        echo "OK\n";
    } catch (Throwable $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}
