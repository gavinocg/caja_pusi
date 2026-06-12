<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h4><?= $titulo ?></h4>
        <a href="<?= $ruta_csv ?>" class="btn btn-outline-success"><i class="bi bi-download"></i> CSV</a>
    </div>

    <?php if (isset($desde) || isset($hasta)): ?>
    <form method="GET" class="row g-2 mb-3">
        <div class="col-auto">
            <input type="date" name="desde" class="form-control form-control-sm" value="<?= htmlspecialchars($desde ?? '') ?>" placeholder="Desde">
        </div>
        <div class="col-auto">
            <input type="date" name="hasta" class="form-control form-control-sm" value="<?= htmlspecialchars($hasta ?? '') ?>" placeholder="Hasta">
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-sm btn-primary"><i class="bi bi-filter"></i> Filtrar</button>
            <a href="?" class="btn btn-sm btn-outline-secondary"><i class="bi bi-x-circle"></i></a>
        </div>
    </form>
    <?php endif; ?>

    <div class="card card-dashboard">
        <div class="card-body p-0 table-responsive">
            <table class="table table-hover table-sm mb-0">
                <thead class="table-light">
                    <tr>
                        <?php foreach ($encabezados as $e): ?>
                        <th><?= $e ?></th>
                        <?php endforeach; ?>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($filas as $f): ?>
                    <tr>
                        <?php foreach ($campos as $c):
                            $v = $f[$c] ?? '-';
                            if (is_numeric($v) && $c !== 'cedula' && $c !== 'telefono' && strpos($c, 'saldo') !== false):
                        ?>
                        <td class="text-end">$<?= number_format($v, 2) ?></td>
                        <?php elseif ($c === 'anulado'): ?>
                        <td><?= $v ? 'Sí' : 'No' ?></td>
                        <?php else: ?>
                        <td><?= htmlspecialchars($v) ?></td>
                        <?php endif; endforeach; ?>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <?php if (isset($totalPaginas) && $totalPaginas > 1): ?>
    <nav class="mt-3"><ul class="pagination pagination-sm">
        <?php for ($i = 1; $i <= $totalPaginas; $i++): ?>
        <li class="page-item <?= $i === $page ? 'active' : '' ?>">
            <a class="page-link" href="?p=<?= $i ?><?= isset($desde) && $desde ? '&desde=' . urlencode($desde) : '' ?><?= isset($hasta) && $hasta ? '&hasta=' . urlencode($hasta) : '' ?>"><?= $i ?></a>
        </li>
        <?php endfor; ?>
    </ul></nav>
    <?php endif; ?>
</div>
