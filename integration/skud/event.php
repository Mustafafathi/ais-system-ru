<?php
declare(strict_types=1);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/auth_ip_hmac.php';
require_once __DIR__ . '/../common/error_response.php';
require_once __DIR__ . '/../common/request_parser.php';
require_once __DIR__ . '/../common/procedure_gateway.php';
require_once __DIR__ . '/../common/integration_audit.php';

$allowlist = [
    '127.0.0.1',
    '::1',
];
$allowlist = defined('INTEGRATION_ALLOWLIST') ? skud_parse_allowlist((string)INTEGRATION_ALLOWLIST) : $allowlist;
$sharedSecret = defined('SKUD_SHARED_SECRET') ? (string)SKUD_SHARED_SECRET : '';

try {
    $start = microtime(true);
    $clientIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $raw = (string)file_get_contents('php://input');
    $body = json_decode($raw, true);
    if (!is_array($body) || json_last_error() !== JSON_ERROR_NONE) {
        throw new InvalidArgumentException('Invalid JSON body', 400);
    }

    $headers = getallheaders() ?: [];
    if (trim($sharedSecret) === '' || hash_equals('change-me', $sharedSecret)) {
        throw new RuntimeException('SKUD shared secret is not configured', 503);
    }

    $auth = skud_verify_request($allowlist, $sharedSecret, $headers, $clientIp, $raw);
    if (!empty($auth['duplicate'])) {
        integration_audit_log(null, '/integration/skud/event.php', $clientIp, 'POST', $headers, 200, (microtime(true) - $start) * 1000.0, 'duplicate nonce ignored');
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => true,
            'data' => null,
            'message' => 'Дубликат события СКУД проигнорирован',
            'error_code' => null,
            'duplicate' => true,
        ], JSON_UNESCAPED_UNICODE);
        exit(0);
    }

    [$eventType, $direction] = skud_normalize_event_type((string)($body['event_type'] ?? ''), (string)($body['direction'] ?? ''));
    $deviceId = skud_positive_int($body['device_id'] ?? null, 'device_id');
    $cardNumber = trim((string)($body['card_number'] ?? ''));
    if ($cardNumber === '') {
        throw new InvalidArgumentException('card_number is required', 400);
    }
    $eventTimestamp = empty($body['timestamp']) ? false : strtotime((string)$body['timestamp']);
    if ($eventTimestamp === false) {
        throw new InvalidArgumentException('timestamp is required', 400);
    }

    $sensorData = [
        'webhook_timestamp' => (string)$body['timestamp'],
        'source_event_type' => (string)($body['event_type'] ?? ''),
        'source_student_id' => $body['student_id'] ?? null,
        'nonce' => $auth['nonce'] ?? null,
    ];

    $named = [
        'Устройство_ID' => $deviceId,
        'Номер_Карты' => $cardNumber,
        'Тип_События' => $eventType,
        'Направление' => $direction,
        'Время_События' => date('Y-m-d H:i:s', $eventTimestamp),
        'Температура' => array_key_exists('temperature', $body) ? $body['temperature'] : null,
        'Фото_URL' => $body['photo_url'] ?? null,
        'Данные_Датчиков' => json_encode($sensorData, JSON_UNESCAPED_UNICODE),
        'Зона_Доступа' => $body['zone'] ?? $body['access_zone'] ?? null,
    ];

    $conn = getDBConnection();
    $result = gateway_call_procedure($conn, 'dbo', 'ПринятьСобытиеСКУД', $named, []);
    $lat = (microtime(true) - $start) * 1000.0;
    $note = skud_result_note($result);
    integration_audit_log($conn, '/integration/skud/event.php', $clientIp, 'POST', $headers, 200, $lat, $note);
    closeDBConnection($conn);

    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => true,
        'data' => $result,
        'message' => 'Событие СКУД принято',
        'error_code' => null,
        'duplicate' => false,
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    $lat = isset($start) ? (microtime(true) - $start) * 1000.0 : 0.0;
    $headers = $headers ?? [];
    $clientIp = $clientIp ?? 'unknown';
    $status = $e->getCode();
    if (!is_int($status) || $status < 400 || $status > 599) {
        $status = $e instanceof InvalidArgumentException ? 400 : 500;
    }

    integration_audit_log($conn ?? null, '/integration/skud/event.php', $clientIp, 'POST', $headers, $status, $lat, 'error: ' . $e->getMessage());
    if (isset($conn) && $conn !== null) {
        closeDBConnection($conn);
    }
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => false,
        'data' => null,
        'message' => $e->getMessage(),
        'error_code' => $status,
    ], JSON_UNESCAPED_UNICODE);
}

function skud_positive_int($value, string $field): int {
    if (is_int($value) && $value > 0) {
        return $value;
    }
    if (is_string($value) && ctype_digit($value) && (int)$value > 0) {
        return (int)$value;
    }
    throw new InvalidArgumentException($field . ' must be a positive integer', 400);
}

function skud_normalize_event_type(string $eventType, string $direction): array {
    $normalized = strtolower(trim($eventType));
    $normalizedDirection = strtolower(trim($direction));

    $entryValues = ['entry', 'enter', 'in', 'access_granted', 'вход', 'вход_разрешен'];
    $exitValues = ['exit', 'leave', 'out', 'выход', 'выход_разрешен'];
    $entryDeniedValues = ['entry_denied', 'denied', 'access_denied', 'вход_запрещен'];
    $exitDeniedValues = ['exit_denied', 'выход_запрещен'];

    if (in_array($normalized, $entryValues, true) || $normalizedDirection === 'entry') {
        return ['Вход_разрешен', 'Вход'];
    }
    if (in_array($normalized, $exitValues, true) || $normalizedDirection === 'exit') {
        return ['Выход_разрешен', 'Выход'];
    }
    if (in_array($normalized, $entryDeniedValues, true)) {
        return ['Вход_запрещен', 'Вход'];
    }
    if (in_array($normalized, $exitDeniedValues, true)) {
        return ['Выход_запрещен', 'Выход'];
    }
    if ($normalized === 'unknown_card' || $normalized === 'неизвестная_карта') {
        return ['Неизвестная_карта', 'Неизвестно'];
    }

    throw new InvalidArgumentException('Unsupported event_type', 400);
}

function skud_result_note($result): string {
    $row = is_array($result) ? ($result[0] ?? $result) : [];
    $status = is_array($row) ? (string)($row['Результат'] ?? '') : '';
    if ($status !== '') {
        return 'skud webhook: ' . $status;
    }
    return 'skud webhook';
}

