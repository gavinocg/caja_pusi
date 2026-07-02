<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
            <h4>Sesion #<?= $sesion['numero_sesion'] ?> — Dashboard</h4>
            <small class="text-muted">
                <?= htmlspecialchars($sesion['titulo'] ?? '') ?>
                &mdash; <span class="badge bg-<?= ($sesion['tipo'] ?? 'ordinaria') === 'ordinaria' ? 'primary' : (($sesion['tipo'] ?? '') === 'extraordinaria' ? 'warning' : 'info') ?>"><?= ucfirst($sesion['tipo'] ?? 'Ordinaria') ?></span>
                &mdash; <?= date('d/m/Y H:i', strtotime($sesion['fecha_sesion'])) ?>
                &mdash; <span class="badge <?= $sesion['estado'] === 'abierta' ? 'bg-success' : 'bg-secondary' ?>"><?= $sesion['estado'] === 'abierta' ? 'Abierta' : 'Cerrada' ?></span>
            </small>
        </div>
        <div class="d-flex gap-2 flex-wrap">
            <?php if ($sesion['estado'] === 'abierta'): ?>
            <a href="<?= BASE_URL ?>/sesion/checkin/<?= $sesion['id_sesion'] ?>" class="btn btn-primary"><i class="bi bi-cash-coin"></i> Cobros</a>
            <a href="<?= BASE_URL ?>/sesion/asistencia/<?= $sesion['id_sesion'] ?>" class="btn btn-outline-primary"><i class="bi bi-person-check"></i> Asistencia</a>
            <?php endif; ?>
            <a href="<?= BASE_URL ?>/sesion/listar" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
        </div>
    </div>

    <!-- Cards metricas -->
    <div class="row row-cols-2 row-cols-md-4 g-3 mb-4">
        <div class="col">
            <div class="card card-dashboard text-center h-100 border-success">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <small class="text-muted">En caja (recaudado)</small>
                        <h3 class="text-success mb-0 mt-1">$<?= number_format($recaudado['total'], 2) ?></h3>
                    </div>
                    <a href="<?= BASE_URL ?>/caja/estadoCuenta?from_sesion=<?= $sesion['id_sesion'] ?>" class="btn btn-success mt-2">Ver movimientos</a>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card card-dashboard text-center h-100 border-warning">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <small class="text-muted">Pendiente recaudacion</small>
                        <h3 class="text-warning mb-0 mt-1">$<?= number_format($pendienteRecaudar['total'], 2) ?></h3>
                    </div>
                    <a href="<?= BASE_URL ?>/sesion/checkin/<?= $sesion['id_sesion'] ?>" class="btn btn-warning mt-2">Ver detalle</a>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card card-dashboard text-center h-100 border-info">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <small class="text-muted">Creditos Aprobados</small>
                        <h3 class="text-info mb-0 mt-1">$<?= number_format($credADesembolsar['total'], 2) ?></h3>
                    </div>
                    <a href="<?= BASE_URL ?>/credito/bandejaAprobados?from_sesion=<?= $sesion['id_sesion'] ?>" class="btn btn-info mt-2">Ver solicitudes</a>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card card-dashboard text-center h-100 border-primary">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <small class="text-muted">Asistencia</small>
                        <h3 class="text-primary mb-0 mt-1"><?= $asistRegistrada ?>/<?= $totalSocios ?> socios</h3>
                    </div>
                    <?php if ($sesion['estado'] === 'abierta'): ?>
                    <a href="<?= BASE_URL ?>/sesion/asistencia/<?= $sesion['id_sesion'] ?>" class="btn btn-primary mt-2">Gestionar</a>
                    <?php else: ?>
                    <a class="btn btn-primary mt-2 disabled">Gestionar</a>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <!-- Asistencia detalle -->
        <div class="col-md-6">
            <div class="card card-dashboard h-100">
                <div class="card-body">
                    <h5><i class="bi bi-person-check"></i> Asistencia</h5>
                    <?php
                    $tiposAsistencia = ['a_tiempo' => 'A tiempo', 'retraso_10min' => 'Retraso 10\'', 'retraso_30min' => 'Retraso 30\'', 'falta' => 'Falta'];
                    $coloresAsistencia = ['a_tiempo' => 'success', 'retraso_10min' => 'warning', 'retraso_30min' => 'danger', 'falta' => 'dark'];
                    $asistMap = [];
                    foreach ($asistenciaResumen as $a) { $asistMap[$a['tipo']] = $a['total']; }
                    ?>
                    <?php foreach ($tiposAsistencia as $key => $label): $count = $asistMap[$key] ?? 0; ?>
                    <div class="d-flex justify-content-between align-items-center mb-1">
                        <span><span class="badge bg-<?= $coloresAsistencia[$key] ?> me-1">&nbsp;</span> <?= $label ?></span>
                        <strong><?= $count ?> (<?= $totalSocios > 0 ? round($count / $totalSocios * 100) : 0 ?>%)</strong>
                    </div>
                    <?php endforeach; ?>
                    <hr class="my-2">
                    <div class="d-flex justify-content-between">
                        <span>Registrados: <strong><?= $asistRegistrada ?>/<?= $totalSocios ?></strong></span>
                        <?php if ($sesion['estado'] === 'abierta'): ?>
                        <a href="<?= BASE_URL ?>/sesion/asistencia/<?= $sesion['id_sesion'] ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i> Gestionar</a>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
        <!-- Solicitudes activas -->
        <div class="col-md-6">
            <div class="card card-dashboard h-100">
                <div class="card-body">
                    <h5><i class="bi bi-inbox"></i> Solicitudes activas</h5>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span><i class="bi bi-credit-card text-info me-1"></i> Creditos ingresados</span>
                        <div class="text-end">
                            <strong><?= $credIngresados['count'] ?></strong> <small class="text-muted">($<?= number_format($credIngresados['total'], 2) ?>)</small>
                            <a href="<?= BASE_URL ?>/credito/bandejaAprobados" class="btn btn-info btn-sm ms-2">Ver</a>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span><i class="bi bi-cash-stack text-warning me-1"></i> Retiros pendientes</span>
                        <div class="text-end">
                            <strong><?= $retirosPendientes['count'] ?></strong> <small class="text-muted">($<?= number_format($retirosPendientes['total'], 2) ?>)</small>
                            <a href="<?= BASE_URL ?>/retiro/listar?from_sesion=<?= $sesion['id_sesion'] ?>" class="btn btn-warning btn-sm ms-2">Ver</a>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span><i class="bi bi-graph-up text-secondary me-1"></i> Inversiones pendientes</span>
                        <div class="text-end">
                            <strong><?= $invPendientes['count'] ?></strong>
                            <a href="<?= BASE_URL ?>/inversion/pendientes?from_sesion=<?= $sesion['id_sesion'] ?>" class="btn btn-secondary btn-sm ms-2">Ver</a>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-exclamation-triangle text-danger me-1"></i> Multas en impugnacion</span>
                        <div class="text-end">
                            <strong><?= $multasImpugnacion ?></strong>
                            <a href="<?= BASE_URL ?>/multa/listar?from_sesion=<?= $sesion['id_sesion'] ?>" class="btn btn-danger btn-sm ms-2">Ver</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
