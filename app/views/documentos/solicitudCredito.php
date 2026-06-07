<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Solicitud de crédito</title>
<style>
    @page { size: letter; margin: 2cm; }
    body { font-family: 'Times New Roman', Times, serif; font-size: 14pt; line-height: 1.5; }
    .header { text-align: center; margin-bottom: 30px; }
    .header h2 { font-size: 16pt; margin-bottom: 5px; text-transform: uppercase; }
    .header h3 { font-size: 14pt; margin: 0; }
    .header .numero { font-size: 12pt; margin-top: 10px; }
    .content { text-align: justify; }
    .content p { margin-bottom: 12px; }
    .field { display: inline-block; border-bottom: 1px solid #000; min-width: 200px; padding: 0 5px; }
    .field-sm { min-width: 120px; }
    .firmas { margin-top: 60px; }
    .firma { display: inline-block; width: 45%; text-align: center; }
    .firma .linea { border-top: 1px solid #000; width: 80%; margin: 40px auto 5px; padding-top: 5px; }
    .firma .cargo { font-size: 11pt; font-style: italic; }
    .tabla { width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 11pt; }
    .tabla th, .tabla td { border: 1px solid #000; padding: 4px 8px; text-align: center; }
    .tabla th { background: #f0f0f0; font-weight: bold; }
    .resumen { margin: 20px 0; font-size: 12pt; }
    .resumen td { padding: 2px 10px; }
    @media print { .no-print { display: none; } }
</style>
</head>
<body>
    <div class="no-print" style="text-align:center;margin-bottom:20px">
        <button onclick="window.print()" class="btn btn-primary"><i class="bi bi-printer"></i> Imprimir</button>
        <button onclick="window.close()" class="btn btn-secondary">Cerrar</button>
    </div>

    <div class="header">
        <h2>Caja de Ahorro y Crédito Solidaria Familiar Pujota-Simbaña</h2>
        <h3>SOLICITUD DE CRÉDITO N° <?= htmlspecialchars(substr($credito['id_credito'], 0, 8)) ?></h3>
    </div>

    <div class="content">
        <p>La Caja de Ahorro y Crédito Solidaria Familiar concede la siguiente solicitud de crédito:</p>

        <p>
            A FAVOR DE: <span class="field"><?= htmlspecialchars($credito['socio']) ?></span>
            CON CÉDULA DE IDENTIDAD N°: <span class="field"><?= htmlspecialchars($credito['cedula']) ?></span>
        </p>

        <p>
            La misma que será cancelada con un interes del
            <span class="field field-sm"><?= number_format($credito['tasa_interes_anual'], 2) ?>%</span>
            anual la cantidad de
            <span class="field">$<?= number_format($credito['monto_aprobado'], 2) ?></span>
            dólares americanos.
        </p>

        <p>La persona beneficiada está en la obligación de cancelar la letra correspondiente más el interes.</p>
        <p>La persona beneficiada se compromete a pagar el crédito en las cuotas que aquella viera conveniente.</p>

        <table class="resumen">
            <tr><td><strong>PLAZO EN MESES:</strong></td><td><?= $credito['plazo_meses'] ?> meses</td></tr>
            <tr><td><strong>INTERÉS:</strong></td><td><?= number_format($credito['tasa_interes_anual'], 2) ?>% ANUAL</td></tr>
            <tr><td><strong>MÉTODO:</strong></td><td><?= ucfirst($credito['metodo_interes']) ?></td></tr>
            <tr><td><strong>TOTAL A PAGAR:</strong></td><td>$<?= number_format($totalPagar, 2) ?></td></tr>
        </table>

        <table class="tabla">
            <thead>
                <tr>
                    <th>N°</th>
                    <th>Capital</th>
                    <th>Interés</th>
                    <th>Total cuota</th>
                    <th>Saldo</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($cuotas as $c): ?>
                <tr>
                    <td><?= $c['numero'] ?></td>
                    <td>$<?= number_format($c['capital'], 2) ?></td>
                    <td>$<?= number_format($c['interes'], 2) ?></td>
                    <td>$<?= number_format($c['total'], 2) ?></td>
                    <td>$<?= number_format($c['saldo'], 2) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <p>
            Para constancia de esta solicitud de crédito, la asamblea se ratifica y firma su representante
            y oficial de creditos autorizado por la Caja de Ahorro y Crédito Solidaria Familiar Pujota-Simbaña.
        </p>
    </div>

    <div class="firmas">
        <div class="firma">
            <div class="linea">SOLICITANTE</div>
            <div class="cargo">CI: <?= htmlspecialchars($credito['cedula']) ?></div>
        </div>
        <div class="firma">
            <div class="linea">OFICIAL DE CRÉDITOS</div>
            <div class="cargo">Caja de Ahorro y Crédito Solidaria Familiar</div>
        </div>
    </div>
</body>
</html>