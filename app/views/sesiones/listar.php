<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Sesiones mensuales</h4>
        <a href="<?= BASE_URL ?>/sesion/abrir" class="btn btn-primary"><i class="bi bi-plus-circle"></i> Abrir sesión</a>
    </div>

    <div class="card card-dashboard">
        <div class="card-body p-0">
            <div class="table-responsive"><table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Fecha</th>
                        <th>Título</th>
                        <th>Tipo</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($sesiones as $s): ?>
                    <tr>
                        <td><?= $s['numero_sesion'] ?></td>
                        <td><?= date('d/m/Y H:i', strtotime($s['fecha_sesion'])) ?></td>
                        <td><?= htmlspecialchars($s['titulo'] ?? 'Sesion #' . $s['numero_sesion']) ?></td>
                        <td><span class="badge bg-<?= ($s['tipo'] ?? 'ordinaria') === 'ordinaria' ? 'primary' : (($s['tipo'] ?? '') === 'extraordinaria' ? 'warning' : 'info') ?>"><?= ucfirst($s['tipo'] ?? 'Ordinaria') ?></span></td>
                        <td>
                            <span class="badge <?= $s['estado'] === 'abierta' ? 'bg-success' : 'bg-secondary' ?>">
                                <?= $s['estado'] === 'abierta' ? 'Abierta' : 'Cerrada' ?>
                            </span>
                        </td>
                        <td>
                            <a href="<?= BASE_URL ?>/sesion/editar/<?= $s['id_sesion'] ?>" class="btn btn-sm btn-outline-primary" title="Editar"><i class="bi bi-pencil"></i></a>
                            <?php if ($s['estado'] === 'abierta'): ?>
                            <a href="<?= BASE_URL ?>/sesion/dashboard/<?= $s['id_sesion'] ?>" class="btn btn-sm btn-outline-success"><i class="bi bi-speedometer2"></i> Gestionar</a>
                            <form method="POST" action="<?= BASE_URL ?>/sesion/checkin/<?= $s['id_sesion'] ?>" style="display:inline" onsubmit="return confirm('¿Cerrar la sesion? No se podran registrar mas cobros.')">
                                <?= CSRFMiddleware::campoHTML() ?>
                                <input type="hidden" name="accion" value="cierre">
                                <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-lock"></i> Cerrar</button>
                            </form>
                            <?php else: ?>
                            <form method="POST" action="<?= BASE_URL ?>/sesion/reaperturar/<?= $s['id_sesion'] ?>" style="display:inline" onsubmit="return confirm('¿Reaperturar esta sesion para registrar nuevos cobros?')">
                                <?= CSRFMiddleware::campoHTML() ?>
                                <button type="submit" class="btn btn-sm btn-outline-warning" <?= $hayAbierta ? 'disabled title="Ya hay una sesion abierta. Cierrela primero."' : '' ?>>
                                    <i class="bi bi-unlock"></i> Reaperturar
                                </button>
                            </form>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table></div>
        </div>
    </div>
</div>
