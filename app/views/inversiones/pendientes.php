<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Aprobacion de inversiones</h4>
        <div class="d-flex gap-2">
            <?php if (!empty($fromSesion)): ?>
            <a href="<?= BASE_URL ?>/sesion/dashboard/<?= htmlspecialchars($fromSesion) ?>" class="btn btn-outline-info"><i class="bi bi-speedometer2"></i> Panel de Sesion</a>
            <?php endif; ?>
            <a href="<?= BASE_URL ?>/inversion/listar" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
        </div>
    </div>

    <div class="card card-dashboard">
        <div class="card-body p-0">
            <div class="table-responsive"><table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Solicitud</th>
                        <th>Socio</th>
                        <th>Producto</th>
                        <th class="text-end">Monto</th>
                        <th>Plazo</th>
                        <th class="text-end">Rendimiento</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($pendientes as $i): ?>
                    <tr>
                        <td><?= $i['fecha_registro'] ?></td>
                        <td><?= htmlspecialchars($i['socio']) ?></td>
                        <td><?= htmlspecialchars($i['producto']) ?></td>
                        <td class="text-end fw-bold">$<?= number_format($i['monto'], 2) ?></td>
                        <td><?= $i['plazo_meses'] ?> meses</td>
                        <td class="text-end text-success">$<?= number_format($i['rendimiento_proyectado'] ?? 0, 2) ?></td>
                        <td class="text-end">
                            <button class="btn btn-success btn-sm" onclick="aprobar('<?= $i['id_inversion'] ?>')"><i class="bi bi-check-lg"></i></button>
                            <button class="btn btn-danger btn-sm" onclick="rechazar('<?= $i['id_inversion'] ?>')"><i class="bi bi-x-lg"></i></button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($pendientes) === 0): ?>
                    <tr><td colspan="7" class="text-center text-muted py-4">No hay solicitudes de inversión pendientes</td></tr>
                    <?php endif; ?>
                </tbody>
            </table></div>
        </div>
    </div>
</div>

<script>
function aprobar(id) {
    if (!confirm('¿Aprobar esta inversión? Se descontará del capital de inversión del socio.')) return;
    fetch('<?= BASE_URL ?>/inversion/aprobar/' + id, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'csrf_token=<?= CSRFMiddleware::generarToken() ?>'
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.error) { mostrarNotificacion('error','Error',d.error,false); } else { mostrarNotificacion('success','Exito',d.mensaje,true); location.reload(); }
    });
}

function rechazar(id) {
    var motivo = prompt('Motivo del rechazo (opcional):');
    if (motivo === null) return;
    fetch('<?= BASE_URL ?>/inversion/rechazar/' + id, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'csrf_token=<?= CSRFMiddleware::generarToken() ?>&motivo=' + encodeURIComponent(motivo || 'Sin motivo especificado')
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.error) { mostrarNotificacion('error','Error',d.error,false); } else { mostrarNotificacion('success','Exito',d.mensaje,true); location.reload(); }
    });
}
</script>