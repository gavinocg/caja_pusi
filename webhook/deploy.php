<?php
// Webhook receiver for GitHub push events
// Place at: /var/www/caja.sga-sp.com/webhook/deploy.php

$secret = getenv('GITHUB_WEBHOOK_SECRET') ?: '';

// Verify signature if secret is configured
if ($secret) {
    $sig = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';
    $payload = file_get_contents('php://input');
    $expected = 'sha256=' . hash_hmac('sha256', $payload, $secret);
    if (!hash_equals($expected, $sig)) {
        http_response_code(401);
        exit('Signature mismatch');
    }
}

// Only respond to push events on prod branch
$event = $_SERVER['HTTP_X_GITHUB_EVENT'] ?? '';
if ($event !== 'push') {
    http_response_code(200);
    exit('Ignored: ' . $event);
}

$body = json_decode(file_get_contents('php://input'), true);
$ref = $body['ref'] ?? '';
if ($ref !== 'refs/heads/prod') {
    http_response_code(200);
    exit('Ignored branch: ' . $ref);
}

// Execute deploy script
$output = [];
$returnCode = 0;
$scriptDir = __DIR__;
exec("cd $scriptDir && bash deploy-caja.sh 2>&1", $output, $returnCode);

http_response_code($returnCode === 0 ? 200 : 500);
echo json_encode([
    'status' => $returnCode === 0 ? 'ok' : 'error',
    'output' => implode("\n", $output),
]);
