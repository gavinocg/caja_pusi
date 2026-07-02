<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Bandeja de creditos</h4>
        <div class="d-flex gap-2">
            <?php if (!empty($fromSesion)): ?>
            <a href="<?= BASE_URL ?>/sesion/dashboard/<?= htmlspecialchars($fromSesion) ?>" class="btn btn-outline-info"><i class="bi bi-speedometer2"></i> Panel de Sesion</a>
            <?php endif; ?>
            <a href="<?= BASE_URL ?>/credito" class="btn btn-outline-secondary"><i class="bi bi-list"></i> Todos los creditos</a>
        </div>
    </div>

    <?php
    $badges = [
        'ingresado' => 'bg-primary',
        'pendiente' => 'bg-warning text-dark',
        'aprobado' => 'bg-success',
        'legalizado' => 'bg-info text-dark',
        'desembolsado' => 'bg-secondary',
        'rechazado' => 'bg-danger',
        'cancelado' => 'bg-dark',
    ];
    ?>

    <div class="card card-dashboard">
        <div class="card-body p-0">
            <div class="table-responsive"><table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Socio</th>
                        <th>Cédula</th>
                        <th>Producto</th>
                        <th>Monto</th>
                        <th>Plazo</th>
                        <th>Estado</th>
                        <th>Solicitud</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($creditos)): ?>
                    <tr><td colspan="8" class="text-center text-muted py-4">No hay creditos pendientes</td></tr>
                    <?php else: ?>
                    <?php foreach ($creditos as $c): ?>
                    <tr>
                        <td><?= htmlspecialchars($c['socio']) ?></td>
                        <td><?= htmlspecialchars($c['cedula']) ?></td>
                        <td><?= htmlspecialchars($c['producto']) ?>
                            <?php if (!empty($c['es_emergente'])): ?><span class="badge bg-danger ms-1">E</span><?php endif; ?>
                        </td>
                        <td>$<?= number_format($c['monto_solicitado'], 2) ?></td>
                        <td><?= $c['plazo_meses'] ?> meses</td>
                        <td><span class="badge <?= $badges[$c['estado']] ?? 'bg-secondary' ?>"><?= ucfirst($c['estado']) ?></span></td>
                        <td><?= date('d/m/Y', strtotime($c['fecha_solicitud'])) ?></td>
                        <td class="text-end">
                            <a href="<?= BASE_URL ?>/credito/ver/<?= $c['id_credito'] ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>

                            <?php if ($c['estado'] === 'ingresado' || $c['estado'] === 'pendiente'): ?>
                            <button class="btn btn-sm btn-success" onclick="aprobar('<?= $c['id_credito'] ?>', '<?= htmlspecialchars($c['socio'], ENT_QUOTES) ?>', <?= $c['monto_solicitado'] ?>)"><i class="bi bi-check-lg"></i></button>
                            <button class="btn btn-sm btn-warning" onclick="ponerEnEspera('<?= $c['id_credito'] ?>')" <?= $c['estado'] !== 'ingresado' ? 'disabled' : '' ?>><i class="bi bi-pause-circle"></i></button>
                            <button class="btn btn-sm btn-danger" onclick="rechazar('<?= $c['id_credito'] ?>')"><i class="bi bi-x-lg"></i></button>
                            <?php endif; ?>

                            <?php if ($c['estado'] === 'aprobado'): ?>
                            <a href="<?= BASE_URL ?>/credito/generarSolicitudPdf/<?= $c['id_credito'] ?>" class="btn btn-sm btn-outline-info" target="_blank"><i class="bi bi-file-pdf"></i> Solicitud</a>
                            <?php if (!empty($c['requiere_documento_firmado'])): ?>
                            <button class="btn btn-sm btn-primary" onclick="subirActa('<?= $c['id_credito'] ?>')"><i class="bi bi-upload"></i> Subir acta</button>
                            <?php endif; ?>
                            <button class="btn btn-sm btn-success" onclick="desembolsar('<?= $c['id_credito'] ?>')"><i class="bi bi-cash"></i> Desembolsar</button>
                            <?php endif; ?>

                            <?php if ($c['estado'] === 'legalizado'): ?>
                            <button class="btn btn-sm btn-success" onclick="desembolsar('<?= $c['id_credito'] ?>')"><i class="bi bi-cash"></i> Desembolsar</button>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table></div>
        </div>
    </div>
</div>

<!-- Modal Aprobar -->
<div class="modal fade" id="modalAprobar" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="formAprobar" method="POST">
                <?= CSRFMiddleware::campoHTML() ?>
                <div class="modal-header">
                    <h5 class="modal-title">Aprobar crédito</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p id="aprobacionSocio"></p>
                    <div class="mb-3">
                        <label class="form-label">Monto aprobado $</label>
                        <input type="number" step="0.01" name="monto_aprobado" id="montoAprobado" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-success"><i class="bi bi-check-lg"></i> Aprobar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Espera -->
<div class="modal fade" id="modalEspera" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="formEspera" method="POST">
                <?= CSRFMiddleware::campoHTML() ?>
                <div class="modal-header">
                    <h5 class="modal-title">Poner en espera</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Motivo de la espera *</label>
                        <textarea name="justificacion" class="form-control" rows="3" required placeholder="Ej: No hay liquidez en esta sesión..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning"><i class="bi bi-pause-circle"></i> Poner en espera</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Rechazar -->
<div class="modal fade" id="modalRechazar" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="formRechazar" method="POST">
                <?= CSRFMiddleware::campoHTML() ?>
                <div class="modal-header">
                    <h5 class="modal-title">Rechazar crédito</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Justificación del rechazo *</label>
                        <textarea name="justificacion" class="form-control" rows="3" required placeholder="Indique el motivo del rechazo..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-danger"><i class="bi bi-x-lg"></i> Rechazar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Subir acta -->
<div class="modal fade" id="modalSubirActa" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="formSubirActa" method="POST" enctype="multipart/form-data">
                <?= CSRFMiddleware::campoHTML() ?>
                <div class="modal-header">
                    <h5 class="modal-title">Subir documento firmado</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Suba el PDF de la solicitud de crédito y tabla de amortización <strong>firmada</strong> por el comité de crédito y el socio.</p>
                    <div class="mb-3">
                        <label class="form-label">Archivo PDF *</label>
                        <input type="file" name="archivo" class="form-control" accept=".pdf" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-upload"></i> Subir y legalizar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
var currentId = '';

function aprobar(id, socio, monto) {
    currentId = id;
    document.getElementById('aprobacionSocio').textContent = 'Aprobando crédito para: ' + socio;
    document.getElementById('montoAprobado').value = monto;
    document.getElementById('formAprobar').action = '<?= BASE_URL ?>/credito/aprobar/' + id;
    new bootstrap.Modal(document.getElementById('modalAprobar')).show();
}

function ponerEnEspera(id) {
    currentId = id;
    document.getElementById('formEspera').action = '<?= BASE_URL ?>/credito/ponerEnEspera/' + id;
    new bootstrap.Modal(document.getElementById('modalEspera')).show();
}

function rechazar(id) {
    currentId = id;
    document.getElementById('formRechazar').action = '<?= BASE_URL ?>/credito/rechazar/' + id;
    new bootstrap.Modal(document.getElementById('modalRechazar')).show();
}

function subirActa(id) {
    currentId = id;
    document.getElementById('formSubirActa').action = '<?= BASE_URL ?>/credito/subirActaFirmada/' + id;
    new bootstrap.Modal(document.getElementById('modalSubirActa')).show();
}

function desembolsar(id) {
    if (!confirm('¿Confirmar desembolso de este crédito?')) return;
    fetch('<?= BASE_URL ?>/credito/desembolsar/' + id, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'csrf_token=<?= CSRFMiddleware::generarToken() ?>'
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.error) { mostrarNotificacion('error','Error',d.error,false); } else { location.reload(); }
    });
}

document.querySelectorAll('.modal form').forEach(function(f) {
    f.addEventListener('submit', function(e) {
        e.preventDefault();
        var form = this;
        var formData = new FormData(form);
        if (form.getAttribute('enctype') === 'multipart/form-data') {
            fetch(form.action, { method: 'POST', body: formData })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.error) { mostrarNotificacion('error','Error',d.error,false); }
                else { location.reload(); }
            });
        } else {
            var params = new URLSearchParams(formData);
            fetch(form.action, { method: 'POST', body: params, headers: {'Content-Type': 'application/x-www-form-urlencoded'} })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.error) { mostrarNotificacion('error','Error',d.error,false); }
                else { location.reload(); }
            });
        }
    });
});
</script>