<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Detalle de ahorro - Capital Ahorro</h4>
        <a href="<?= BASE_URL ?>/portal" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
    </div>

    <?php if (empty($pagos)): ?>
    <div class="alert alert-info">No se registran pagos de ahorro obligatorio.</div>
    <?php else: ?>
    <div class="card card-dashboard">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-sm mb-0 table-responsive-stack">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Fecha</th>
                            <th>Sesión</th>
                            <th>Monto</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($pagos as $i => $p): ?>
                        <tr>
                            <td data-label="#"><?= $i + 1 ?></td>
                            <td data-label="Fecha"><?= $p['fecha_registro'] ?></td>
                            <td data-label="Sesión"><?= $p['numero_sesion'] ? '#' . $p['numero_sesion'] : '-' ?></td>
                            <td data-label="Monto"><strong>$<?= number_format($p['monto'], 2) ?></strong></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <?php endif; ?>
</div>