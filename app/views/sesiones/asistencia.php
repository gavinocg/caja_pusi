<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h4>Gestion de Asistencia — Sesion #<?= $sesion['numero_sesion'] ?></h4>
            <small class="text-muted"><?= htmlspecialchars($sesion['titulo'] ?? '') ?> — <?= date('d/m/Y', strtotime($sesion['fecha_sesion'])) ?></small>
        </div>
        <div class="d-flex gap-2">
            <a href="<?= BASE_URL ?>/sesion/dashboard/<?= $sesion['id_sesion'] ?>" class="btn btn-outline-info"><i class="bi bi-speedometer2"></i> Panel de Sesion</a>
            <a href="<?= BASE_URL ?>/sesion/listar" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
        </div>
    </div>

    <?php if (isset($_SESSION['error'])): ?>
    <div class="alert alert-danger"><?= $_SESSION['error']; unset($_SESSION['error']); ?></div>
    <?php endif; ?>

    <form method="GET" class="row g-2 mb-3">
        <div class="col-auto" style="min-width:300px">
            <div class="input-group">
                <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre o cedula..." value="<?= htmlspecialchars($buscar) ?>">
                <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i></button>
                <?php if ($buscar): ?>
                <a href="<?= BASE_URL ?>/sesion/asistencia/<?= $sesion['id_sesion'] ?>" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i></a>
                <?php endif; ?>
            </div>
        </div>
    </form>

    <div class="card card-dashboard">
        <div class="card-header"><strong><i class="bi bi-person-check"></i> Registro de asistencia</strong></div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Cedula</th>
                            <th>Socio</th>
                            <th>Asistencia</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($socios)): ?>
                        <tr><td colspan="4" class="text-center text-muted py-3">No se encontraron socios</td></tr>
                        <?php else: foreach ($socios as $s):
                            $asis = $asistencias[$s['id_socio']] ?? null;
                            $filaColor = $asis ? ($asis['tipo'] === 'a_tiempo' ? 'table-success' : ($asis['tipo'] === 'falta' ? 'table-danger' : 'table-warning')) : '';
                        ?>
                        <tr class="<?= $filaColor ?>">
                            <td><?= htmlspecialchars($s['cedula']) ?></td>
                            <td><strong><?= htmlspecialchars($s['nombre_completo']) ?></strong></td>
                            <td>
                                <form method="POST" class="d-flex gap-1">
                                    <?= CSRFMiddleware::campoHTML() ?>
                                    <input type="hidden" name="accion" value="asistencia">
                                    <input type="hidden" name="id_socio" value="<?= $s['id_socio'] ?>">
                                    <select name="tipo" class="form-select form-select-sm" style="width:auto">
                                        <option value="a_tiempo" <?= $asis && $asis['tipo'] === 'a_tiempo' ? 'selected' : '' ?>>A tiempo</option>
                                        <option value="retraso_10min" <?= $asis && $asis['tipo'] === 'retraso_10min' ? 'selected' : '' ?>>Retraso 10min</option>
                                        <option value="retraso_30min" <?= $asis && $asis['tipo'] === 'retraso_30min' ? 'selected' : '' ?>>Retraso 30min</option>
                                        <option value="falta" <?= $asis && $asis['tipo'] === 'falta' ? 'selected' : '' ?>>Falta</option>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-outline-success"><i class="bi bi-check"></i></button>
                                </form>
                            </td>
                            <td>
                                <?php if ($asis): ?>
                                <span class="badge bg-<?= $asis['tipo'] === 'a_tiempo' ? 'success' : ($asis['tipo'] === 'falta' ? 'danger' : 'warning') ?>">
                                    <?= str_replace('_', ' ', $asis['tipo']) ?>
                                </span>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <?php if ($totalPaginas > 1): ?>
    <nav class="mt-3">
        <ul class="pagination pagination-sm justify-content-center">
            <?php for ($i = 1; $i <= $totalPaginas; $i++): ?>
            <li class="page-item <?= $i === $pagina ? 'active' : '' ?>">
                <a class="page-link" href="?pagina=<?= $i ?>&buscar=<?= urlencode($buscar) ?>"><?= $i ?></a>
            </li>
            <?php endfor; ?>
        </ul>
    </nav>
    <?php endif; ?>
</div>