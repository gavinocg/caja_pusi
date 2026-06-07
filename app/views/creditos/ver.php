<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Crédito #<?= substr($credito['id_credito'], 0, 8) ?></h4>
        <div>
            <?php if (in_array($credito['estado'], ['ingresado','pendiente']) && RBAC::tienePermiso($_SESSION['usuario_id'], 'credito.aprobar')): ?>
            <button class="btn btn-success" onclick="aprobarModal()"><i class="bi bi-check-lg"></i> Aprobar</button>
            <button class="btn btn-danger" onclick="rechazarModal()"><i class="bi bi-x-lg"></i> Rechazar</button>
            <?php elseif ($credito['estado'] === 'aprobado'): ?>
            <a href="<?= BASE_URL ?>/credito/generarSolicitudPdf/<?= $credito['id_credito'] ?>" class="btn btn-outline-info" target="_blank"><i class="bi bi-file-pdf"></i> Solicitud PDF</a>
            <?php if (!empty($credito['requiere_documento_firmado'])): ?>
            <button class="btn btn-primary" onclick="subirActa()"><i class="bi bi-upload"></i> Subir acta firmada</button>
            <?php endif; ?>
            <button class="btn btn-success" onclick="desembolsar()"><i class="bi bi-cash"></i> Desembolsar</button>
            <?php elseif ($credito['estado'] === 'legalizado'): ?>
            <button class="btn btn-success" onclick="desembolsar()"><i class="bi bi-cash"></i> Desembolsar</button>
            <?php endif; ?>
            <a href="<?= BASE_URL ?>/credito/listar" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
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

    <div class="row g-3 mb-3">
        <div class="col-md-3">
            <div class="card card-dashboard"><div class="card-body">
                <small class="text-muted">Socio</small>
                <p class="mb-0"><strong><?= htmlspecialchars($credito['socio']) ?></strong><br><?= $credito['cedula'] ?></p>
            </div></div>
        </div>
        <div class="col-md-2">
            <div class="card card-dashboard"><div class="card-body">
                <small class="text-muted">Producto</small>
                <p class="mb-0"><?= htmlspecialchars($credito['producto']) ?></p>
            </div></div>
        </div>
        <div class="col-md-2">
            <div class="card card-dashboard"><div class="card-body">
                <small class="text-muted">Solicitado</small>
                <p class="mb-0"><strong>$<?= number_format($credito['monto_solicitado'], 2) ?></strong></p>
            </div></div>
        </div>
        <div class="col-md-2">
            <div class="card card-dashboard"><div class="card-body">
                <small class="text-muted">Aprobado</small>
                <p class="mb-0"><strong>$<?= number_format($credito['monto_aprobado'] ?? 0, 2) ?></strong></p>
            </div></div>
        </div>
        <div class="col-md-2">
            <div class="card card-dashboard"><div class="card-body">
                <small class="text-muted">Estado</small>
                <p class="mb-0"><span class="badge <?= $badges[$credito['estado']] ?? 'bg-secondary' ?>"><?= ucfirst($credito['estado']) ?></span></p>
            </div></div>
        </div>
        <div class="col-12">
            <div class="card card-dashboard"><div class="card-body">
                <div class="row">
                    <div class="col-md-3"><small class="text-muted">Plazo</small><p class="mb-0"><?= $credito['plazo_meses'] ?> meses</p></div>
                    <div class="col-md-3"><small class="text-muted">Tasa interes</small><p class="mb-0"><?= number_format($credito['tasa_interes_anual'] ?? $credito['tasa_interes'], 2) ?>% anual</p></div>
                    <div class="col-md-3"><small class="text-muted">Método</small><p class="mb-0"><?= ucfirst($credito['metodo_interes']) ?></p></div>
                    <div class="col-md-3"><small class="text-muted">Destino</small><p class="mb-0"><?= htmlspecialchars($credito['destino'] ?? '-') ?></p></div>
                </div>
            </div></div>
        </div>
    </div>

    <?php if (!empty($credito['justificacion'])): ?>
    <div class="alert alert-info">
        <strong>Justificación:</strong> <?= htmlspecialchars($credito['justificacion']) ?>
    </div>
    <?php endif; ?>

    <?php if (!empty($garantes)): ?>
    <div class="card card-dashboard mb-3">
        <div class="card-body">
            <h6>Garantes</h6>
            <div class="table-responsive"><table class="table table-sm mb-0">
                <thead><tr><th>Socio</th><th>Cédula</th><th>Tipo</th><th>Monto garantizado</th></tr></thead>
                <tbody>
                <?php foreach ($garantes as $g): ?>
                <tr>
                    <td><?= htmlspecialchars($g['nombre']) ?></td>
                    <td><?= $g['cedula'] ?></td>
                    <td><?= str_replace('_', ' ', $g['tipo_garante']) ?></td>
                    <td>$<?= number_format($g['monto_garantizado'], 2) ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table></div>
        </div>
    </div>
    <?php endif; ?>

    <?php if (!empty($archivos)): ?>
    <div class="card card-dashboard mb-3">
        <div class="card-body">
            <h6>Documentos firmados</h6>
            <?php foreach ($archivos as $a): ?>
            <p class="mb-1"><i class="bi bi-file-pdf"></i> <a href="<?= BASE_URL ?>/archivo/ver/<?= $a['id_archivo'] ?>" target="_blank"><?= htmlspecialchars($a['nombre_original']) ?></a></p>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

    <?php if (!empty($amortizaciones)): ?>
    <div class="card card-dashboard">
        <div class="card-body p-0">
            <div class="table-responsive"><table class="table table-sm table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Vencimiento</th>
                        <th class="text-end">Capital</th>
                        <th class="text-end">Interés</th>
                        <th class="text-end">Cuota</th>
                        <th class="text-end">Saldo</th>
                        <th>Estado</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($amortizaciones as $a): ?>
                    <tr class="<?= $a['estado'] === 'pagada' ? 'table-success' : ($a['estado'] === 'vencida' ? 'table-danger' : '') ?>">
                        <td><?= $a['numero_cuota'] ?></td>
                        <td><?= $a['fecha_vencimiento'] ?></td>
                        <td class="text-end">$<?= number_format($a['capital'], 2) ?></td>
                        <td class="text-end">$<?= number_format($a['interes'], 2) ?></td>
                        <td class="text-end"><strong>$<?= number_format($a['total'], 2) ?></strong></td>
                        <td class="text-end">$<?= number_format($a['saldo_restante'], 2) ?></td>
                        <td><?= ucfirst($a['estado']) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table></div>
        </div>
    </div>
    <?php endif; ?>
</div>

<!-- Modal Aprobar -->
<div class="modal fade" id="modalAprobar" tabindex="-1">
    <div class="modal-dialog"><div class="modal-content">
        <form id="formAprobar" method="POST">
            <?= CSRFMiddleware::campoHTML() ?>
            <div class="modal-header"><h5>Aprobar crédito</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label">Monto aprobado $</label><input type="number" step="0.01" name="monto_aprobado" class="form-control" value="<?= $credito['monto_solicitado'] ?>" required></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-success"><i class="bi bi-check-lg"></i> Aprobar</button>
            </div>
        </form>
    </div></div>
</div>

<!-- Modal Rechazar -->
<div class="modal fade" id="modalRechazar" tabindex="-1">
    <div class="modal-dialog"><div class="modal-content">
        <form id="formRechazar" method="POST">
            <?= CSRFMiddleware::campoHTML() ?>
            <div class="modal-header"><h5>Rechazar crédito</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label">Justificación *</label><textarea name="justificacion" class="form-control" rows="3" required placeholder="Indique el motivo del rechazo..."></textarea></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-danger"><i class="bi bi-x-lg"></i> Rechazar</button>
            </div>
        </form>
    </div></div>
</div>

<!-- Modal Subir acta -->
<div class="modal fade" id="modalSubirActa" tabindex="-1">
    <div class="modal-dialog"><div class="modal-content">
        <form id="formSubirActa" method="POST" enctype="multipart/form-data">
            <?= CSRFMiddleware::campoHTML() ?>
            <div class="modal-header"><h5>Subir documento firmado</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <p>Suba el PDF de la solicitud y tabla de amortización <strong>firmada</strong> por el comité y el socio.</p>
                <div class="mb-3"><label class="form-label">Archivo PDF *</label><input type="file" name="archivo" class="form-control" accept=".pdf" required></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary"><i class="bi bi-upload"></i> Subir y legalizar</button>
            </div>
        </form>
    </div></div>
</div>

<script>
function aprobarModal() {
    document.getElementById('formAprobar').action = '<?= BASE_URL ?>/credito/aprobar/<?= $credito['id_credito'] ?>';
    new bootstrap.Modal(document.getElementById('modalAprobar')).show();
}
function rechazarModal() {
    document.getElementById('formRechazar').action = '<?= BASE_URL ?>/credito/rechazar/<?= $credito['id_credito'] ?>';
    new bootstrap.Modal(document.getElementById('modalRechazar')).show();
}
function subirActa() {
    document.getElementById('formSubirActa').action = '<?= BASE_URL ?>/credito/subirActaFirmada/<?= $credito['id_credito'] ?>';
    new bootstrap.Modal(document.getElementById('modalSubirActa')).show();
}

document.querySelectorAll('.modal form').forEach(function(f) {
    f.addEventListener('submit', function(e) {
        e.preventDefault();
        var form = this;
        var data = new FormData(form);
        var url = form.action;
        if (form.getAttribute('enctype') === 'multipart/form-data') {
            fetch(url, { method: 'POST', body: data }).then(r=>r.json()).then(d => { if(d.error)alert(d.error);else location.reload(); });
        } else {
            var p = new URLSearchParams(data);
            fetch(url, { method: 'POST', body: p, headers: {'Content-Type': 'application/x-www-form-urlencoded'} }).then(r=>r.json()).then(d => { if(d.error)alert(d.error);else location.reload(); });
        }
    });
});

function desembolsar() {
    if (!confirm('¿Confirmar desembolso?')) return;
    fetch('<?= BASE_URL ?>/credito/desembolsar/<?= $credito['id_credito'] ?>', { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: 'csrf_token=<?= CSRFMiddleware::generarToken() ?>' })
    .then(function(r) { return r.json(); }).then(function(d) { if (d.error) { alert(d.error); } else { location.reload(); } });
}
</script>