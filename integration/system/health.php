<?php
declare(strict_types=1);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../common/error_response.php';
require_once __DIR__ . '/../common/procedure_gateway.php';

// Protect with a strict shared secret header for system read-only operations.
$secret = defined('INTEGRATION_HEALTH_SECRET') ? INTEGRATION_HEALTH_SECRET : null;
$provided = $_SERVER['HTTP_X_SYSTEM_SECRET'] ?? null;
if ($secret === null || trim((string)$secret) === '') {
    integration_error_response(false, null, 'Health secret is not configured', null, 503);
}
if ($provided === null || !hash_equals((string)$secret, (string)$provided)) {
    integration_error_response(false, null, 'Unauthorized', null, 401);
}

try {
    $conn = getDBConnection();
    $res = gateway_call_procedure($conn, 'dbo', 'ПроверитьСостояниеСистемы', [], []);
    closeDBConnection($conn);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => true, 'status' => $res], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    if (isset($conn) && $conn !== null) closeDBConnection($conn);
    integration_error_response(false, null, $e->getMessage(), null, 500);
}

