<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Solicitar crédito</h4>
        <a href="<?= BASE_URL ?>/portal" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver</a>
    </div>

    <?php if (!empty($errors['general'])): ?>
    <div class="alert alert-danger"><?= htmlspecialchars($errors['general']) ?></div>
    <?php endif; ?>

    <?php if (!empty($exito)): ?>
    <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle"></i> <?= htmlspecialchars($exito) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php else: ?>

    <!-- Steps progress -->
    <ul class="nav nav-pills nav-justified step-wizard mb-4">
        <li class="nav-item" id="step1Indicator">
            <span class="nav-link active">
                <span class="step-circle">1</span>
                <span class="step-label d-none d-sm-inline">Simular</span>
            </span>
        </li>
        <li class="nav-item" id="step2Indicator">
            <span class="nav-link disabled">
                <span class="step-circle">2</span>
                <span class="step-label d-none d-sm-inline">Condiciones</span>
            </span>
        </li>
        <li class="nav-item" id="step3Indicator">
            <span class="nav-link disabled">
                <span class="step-circle">3</span>
                <span class="step-label d-none d-sm-inline">Confirmar</span>
            </span>
        </li>
    </ul>

    <form method="POST" id="creditoForm">
        <?= CSRFMiddleware::campoHTML() ?>

        <!-- STEP 1: Simulador -->
        <div class="card card-dashboard" id="step1">
            <div class="card-body">
                <h5>Paso 1: Simular mi crédito</h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Producto *</label>
                        <select name="id_producto" id="selProducto" class="form-select <?= isset($errors['id_producto']) ? 'is-invalid' : '' ?>" required onchange="onProductChange()">
                            <option value="">Seleccione...</option>
                            <?php foreach ($productos as $p): ?>
                            <option value="<?= $p['id_producto'] ?>"
                                data-tasa="<?= $p['tasa_interes_anual'] ?>"
                                data-metodo="<?= $p['metodo_interes'] ?>"
                                data-plazo_min="<?= $p['plazo_min_meses'] ?>"
                                data-plazo_max="<?= $p['plazo_max_meses'] ?>"
                                data-monto_min="<?= $p['monto_min'] ?>"
                                data-monto_max="<?= $p['monto_max'] ?>"
                                data-condiciones="<?= htmlspecialchars($p['condiciones_html'] ?? '') ?>"
                                data-min_permanencia="<?= intval($p['min_permanencia_meses'] ?? 0) ?>"
                                data-min_ahorro="<?= floatval($p['min_ahorro'] ?? 0) ?>"
                                data-requiere_garante="<?= !empty($p['requiere_garante']) ? 1 : 0 ?>"
                                data-garante_nombre="<?= htmlspecialchars($p['nombre']) ?>"
                                <?= ($_POST['id_producto'] ?? '') === $p['id_producto'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($p['nombre']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                        <div class="invalid-feedback"><?= $errors['id_producto'] ?? '' ?></div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Monto $ *</label>
                        <input type="number" step="0.01" min="0" name="monto" id="inpMonto"
                               class="form-control <?= isset($errors['monto']) ? 'is-invalid' : '' ?>"
                               value="<?= htmlspecialchars($_POST['monto'] ?? '') ?>" required oninput="onSimParamsChange()">
                        <div class="invalid-feedback"><?= $errors['monto'] ?? '' ?></div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Plazo (meses) *</label>
                        <input type="number" min="1" name="plazo" id="inpPlazo"
                               class="form-control <?= isset($errors['plazo']) ? 'is-invalid' : '' ?>"
                               value="<?= htmlspecialchars($_POST['plazo'] ?? '') ?>" required oninput="onSimParamsChange()">
                        <div class="invalid-feedback"><?= $errors['plazo'] ?? '' ?></div>
                    </div>
                </div>

                <div class="mt-3">
                    <button type="button" class="btn btn-primary" onclick="simular()"><i class="bi bi-calculator"></i> Simular</button>
                </div>
            </div>
        </div>

        <!-- Simulation result (hidden until Simular is clicked) -->
        <div id="simResult" class="card card-dashboard mt-3" style="display:none">
            <div class="card-body">
                <h6 class="fw-semibold">Tabla de amortización estimada</h6>
                <div class="table-responsive">
                    <table class="table table-sm table-bordered mb-0" id="tablaAmort">
                        <thead class="table-light"><tr><th>#</th><th>Capital</th><th>Interés</th><th>Total</th><th>Saldo</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
                <p class="mt-2 mb-0"><strong>Total a pagar:</strong> $<span id="totalPagar">0.00</span></p>
                <div class="mt-2" id="elegibilidadMsg" class="d-none"></div>
            </div>
        </div>

        <!-- STEP 2: Condiciones -->
        <div class="card card-dashboard mt-3" id="step2" style="display:none">
            <div class="card-body">
                <h5>Paso 2: Condiciones del crédito</h5>
                <div id="condicionesDisplay" class="p-3 bg-light rounded mb-3"></div>

                <div class="form-check mb-3">
                    <input type="checkbox" name="acepta_condiciones" class="form-check-input" value="1" id="aceptaCheck" required onchange="checkStep2Ready()">
                    <label class="form-check-label" for="aceptaCheck">Acepto las condiciones del crédito</label>
                    <div class="invalid-feedback"><?= $errors['acepta'] ?? '' ?></div>
                </div>

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Destino del crédito</label>
                        <textarea name="destino" id="destinoInput" class="form-control" rows="2" placeholder="Propósito del crédito (mín. 10 caracteres)..." oninput="checkStep2Ready()"><?= htmlspecialchars($_POST['destino'] ?? '') ?></textarea>
                    </div>
                    <div class="col-md-6" id="garantesGroup" style="display:none">
                        <label class="form-label">Seleccionar garante(s)</label>
                        <select name="garantes[]" class="form-select" multiple size="4">
                            <?php foreach ($sociosActivos as $sa): ?>
                            <option value="<?= $sa['id_socio'] ?>" <?= in_array($sa['id_socio'], $_POST['garantes'] ?? []) ? 'selected' : '' ?>><?= htmlspecialchars($sa['nombre']) ?> (<?= htmlspecialchars($sa['cedula']) ?>)</option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- STEP 3: Confirmar -->
        <div class="card card-dashboard mt-3" id="step3" style="display:none">
            <div class="card-body">
                <h5>Paso 3: Confirmar y enviar</h5>
                <div class="p-3 bg-light rounded mb-3">
                    <div class="row">
                        <div class="col-md-3"><strong>Producto:</strong> <span id="resProducto"></span></div>
                        <div class="col-md-3"><strong>Monto:</strong> $<span id="resMonto"></span></div>
                        <div class="col-md-3"><strong>Plazo:</strong> <span id="resPlazo"></span> meses</div>
                        <div class="col-md-3"><strong>Cuota mensual:</strong> $<span id="resCuota"></span></div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-3"><strong>Tasa interes:</strong> <span id="resTasa"></span>% anual</div>
                        <div class="col-md-3"><strong>Método:</strong> <span id="resMetodo"></span></div>
                        <div class="col-md-3"><strong>Total a pagar:</strong> $<span id="resTotal"></span></div>
                    </div>
                </div>

                <?php if (isset($errors['elegibilidad'])): ?>
                <div class="alert alert-warning"><?= htmlspecialchars($errors['elegibilidad']) ?></div>
                <?php endif; ?>

                <button type="submit" class="btn btn-success btn-lg"><i class="bi bi-send"></i> Enviar solicitud</button>
            </div>
        </div>

        <!-- Nav buttons -->
        <div class="mt-3 d-flex justify-content-between">
            <div>
                <button type="button" class="btn btn-outline-secondary" id="btnPrev" style="display:none" onclick="prevStep()"><i class="bi bi-chevron-left"></i> Anterior</button>
            </div>
            <div>
                <button type="button" class="btn btn-primary" id="btnNext" onclick="nextStep()">Siguiente <i class="bi bi-chevron-right"></i></button>
            </div>
        </div>
    </form>

    <script>
    var step = 1;
    var totalSteps = 3;
    var simData = null;
    var elegible = false;

    function onProductChange() {
        var sel = document.getElementById('selProducto');
        var opt = sel.options[sel.selectedIndex];
        if (opt && opt.value) {
            document.getElementById('inpMonto').min = opt.dataset.monto_min;
            document.getElementById('inpMonto').max = opt.dataset.monto_max;
            document.getElementById('inpPlazo').min = opt.dataset.plazo_min;
            document.getElementById('inpPlazo').max = opt.dataset.plazo_max;
            document.getElementById('inpPlazo').placeholder = opt.dataset.plazo_min + '-' + opt.dataset.plazo_max;
            document.getElementById('inpMonto').placeholder = '$' + parseFloat(opt.dataset.monto_min).toFixed(0) + ' - $' + parseFloat(opt.dataset.monto_max).toFixed(0);
        }
    }

    function onSimParamsChange() {
        document.getElementById('simResult').style.display = 'none';
    }

    function simular() {
        var sel = document.getElementById('selProducto');
        var opt = sel.options[sel.selectedIndex];
        var monto = parseFloat(document.getElementById('inpMonto').value);
        var plazo = parseInt(document.getElementById('inpPlazo').value);

        if (!opt || !opt.value) { alert('Seleccione un producto'); return; }
        if (!monto || monto <= 0) { alert('Ingrese un monto válido'); return; }
        if (!plazo || plazo < parseInt(opt.dataset.plazo_min) || plazo > parseInt(opt.dataset.plazo_max)) {
            alert('Plazo debe ser entre ' + opt.dataset.plazo_min + ' y ' + opt.dataset.plazo_max + ' meses');
            return;
        }
        if (monto < parseFloat(opt.dataset.monto_min) || monto > parseFloat(opt.dataset.monto_max)) {
            alert('Monto debe ser entre $' + parseFloat(opt.dataset.monto_min).toFixed(2) + ' y $' + parseFloat(opt.dataset.monto_max).toFixed(2));
            return;
        }

        var tasa = parseFloat(opt.dataset.tasa);
        var metodo = opt.dataset.metodo;

        fetch('<?= BASE_URL ?>/portal/simularCredito', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'csrf_token=<?= CSRFMiddleware::generarToken() ?>&monto=' + monto + '&tasa=' + tasa + '&plazo=' + plazo + '&metodo=' + encodeURIComponent(metodo)
        })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.error) { alert(d.error); return; }
            simData = d;
            renderTable(d);
            document.getElementById('simResult').style.display = 'block';

            var permanencia = parseInt(opt.dataset.min_permanencia);
            var ahorroReq = parseFloat(opt.dataset.min_ahorro);
            elegible = true;
            var msgs = [];

            <?php if ($tieneSolicitudActiva): ?>
            elegible = false;
            msgs.push('Ya tiene una solicitud de crédito activa — espere a que sea procesada');
            <?php endif; ?>

            <?php if ($socio): ?>
            var fechaIngreso = new Date('<?= $socio['fecha_ingreso'] ?>');
            var hoy = new Date();
            var mesesActivo = (hoy.getFullYear() - fechaIngreso.getFullYear()) * 12 + (hoy.getMonth() - fechaIngreso.getMonth());
            if (permanencia > 0 && mesesActivo < permanencia) {
                elegible = false;
                msgs.push('Requiere ' + permanencia + ' meses de permanencia (tiene ' + mesesActivo + ')');
            }
            <?php $ahorroTotal = floatval($socio['saldo_obligatorio'] ?? 0) + floatval($socio['saldo_excedente'] ?? 0); ?>
            var ahorroTotal = <?= $ahorroTotal ?>;
            if (ahorroReq > 0 && ahorroTotal < ahorroReq) {
                elegible = false;
                msgs.push('Requiere $' + ahorroReq.toFixed(2) + ' de ahorro (tiene $' + ahorroTotal.toFixed(2) + ')');
            }
            <?php endif; ?>

            var elMsg = document.getElementById('elegibilidadMsg');
            if (msgs.length > 0) {
                elMsg.className = 'alert alert-warning';
                elMsg.innerHTML = '<i class="bi bi-exclamation-triangle"></i> No cumple: ' + msgs.join('. ');
            } else {
                elMsg.className = 'alert alert-success';
                elMsg.innerHTML = '<i class="bi bi-check-circle"></i> Cumple con los requisitos de elegibilidad';
            }
            elMsg.classList.remove('d-none');
        });
    }

    function renderTable(d) {
        var tbody = document.querySelector('#tablaAmort tbody');
        tbody.innerHTML = '';
        var total = 0;
        d.forEach(function(c) {
            var tr = document.createElement('tr');
            tr.innerHTML = '<td>' + c.numero + '</td><td>$' + c.capital.toFixed(2) + '</td><td>$' + c.interes.toFixed(2) + '</td><td>$' + c.total.toFixed(2) + '</td><td>$' + c.saldo.toFixed(2) + '</td>';
            tbody.appendChild(tr);
            total += c.total;
        });
        document.getElementById('totalPagar').textContent = total.toFixed(2);
        document.getElementById('resCuota').textContent = d.length > 0 ? d[0].total.toFixed(2) : '0.00';
        document.getElementById('resTotal').textContent = total.toFixed(2);
    }

    function checkStep2Ready() {
        var checked = document.getElementById('aceptaCheck').checked;
        var destino = document.getElementById('destinoInput').value.trim().length >= 10;
        var btn = document.getElementById('btnNext');
        if (checked && destino) {
            btn.removeAttribute('disabled');
        } else {
            btn.setAttribute('disabled', 'disabled');
        }
    }

    function updateStepUI() {
        for (var i = 1; i <= totalSteps; i++) {
            var indicator = document.getElementById('step' + i + 'Indicator');
            var link = indicator.querySelector('.nav-link');
            var circle = indicator.querySelector('.step-circle');
            var card = document.getElementById('step' + i);
            card.style.display = i === step ? 'block' : 'none';
            link.className = 'nav-link';
            circle.className = 'step-circle';
            if (i < step) {
                link.classList.add('completed');
                circle.classList.add('bg-success', 'text-white');
                circle.innerHTML = '<i class="bi bi-check"></i>';
            } else if (i === step) {
                link.classList.add('active');
                circle.classList.add('bg-primary', 'text-white');
                circle.textContent = i;
            } else {
                link.classList.add('disabled');
                circle.classList.add('bg-light', 'border', 'text-secondary');
                circle.textContent = i;
            }
        }
        document.getElementById('btnPrev').style.display = step > 1 ? 'inline-block' : 'none';
        document.getElementById('btnNext').style.display = step < totalSteps ? 'inline-block' : 'none';

        if (step === 2) {
            checkStep2Ready();
        } else {
            document.getElementById('btnNext').removeAttribute('disabled');
        }

        // When viewing step 2 or 3, hide simResult
        if (step > 1) document.getElementById('simResult').style.display = 'none';
    }

    function nextStep() {
        if (step === 1) {
            <?php if ($tieneSolicitudActiva): ?>
            alert('Ya tiene una solicitud de crédito activa. Espere a que sea procesada.');
            return;
            <?php endif; ?>

            var sel = document.getElementById('selProducto');
            var opt = sel.options[sel.selectedIndex];
            if (!opt || !opt.value) { alert('Seleccione un producto'); return; }
            if (!simData) { alert('Ejecute la simulación primero'); return; }

            document.getElementById('condicionesDisplay').innerHTML = opt.dataset.condiciones || '<p class="text-muted">El producto no tiene condiciones específicas.</p>';

            if (opt.dataset.requiere_garante == 1) {
                document.getElementById('garantesGroup').style.display = 'block';
            } else {
                document.getElementById('garantesGroup').style.display = 'none';
            }

            document.getElementById('resProducto').textContent = opt.textContent;
            document.getElementById('resMonto').textContent = document.getElementById('inpMonto').value;
            document.getElementById('resPlazo').textContent = document.getElementById('inpPlazo').value;
            document.getElementById('resTasa').textContent = opt.dataset.tasa;
            document.getElementById('resMetodo').textContent = opt.dataset.metodo.charAt(0).toUpperCase() + opt.dataset.metodo.slice(1);
        }

        if (step === 2) {
            if (!document.getElementById('aceptaCheck').checked) {
                alert('Debe aceptar las condiciones del crédito para continuar');
                return;
            }
            if (!elegible) {
                if (!confirm('No cumple todos los requisitos de elegibilidad. ¿Desea continuar de todos modos?')) return;
            }
        }

        if (step < totalSteps) { step++; updateStepUI(); }
    }

    function prevStep() {
        if (step > 1) { step--; updateStepUI(); }
    }
    </script>
    <?php endif; ?>
</div>
