<?php
declare(strict_types=1);

/**
 * Обработчик офлайн-очереди.
 * Пересылает накопленные запросы в api.php и возвращает результат по каждому элементу.
 */

require_once __DIR__ . '/config.php';

$input = json_decode((string)file_get_contents('php://input'), true);
if (!is_array($input) || !isset($input['requests']) || !is_array($input['requests'])) {
    jsonResponse(false, null, 'Неверный формат: ожидается массив requests.', 400, 400);
}

/**
 * Внутренний вызов API.
 */
function callAPI(string $action, array $params, ?string $sessionId = null, ?string $token = null, ?string $idempotencyKey = null, array $paramsOrdered = []): array {
    $payload = [
        'action' => $action,
        'params' => $params,
    ];

    if ($sessionId !== null && $sessionId !== '') {
        $payload['session_id'] = $sessionId;
    }

    if ($token !== null && $token !== '') {
        $payload['token'] = $token;
    }

    if ($idempotencyKey !== null && $idempotencyKey !== '') {
        // include idempotency in body for visibility and in header for servers that read it
        $payload['idempotency_key'] = $idempotencyKey;
    }

    if (!empty($paramsOrdered)) {
        $payload['params_ordered'] = array_values($paramsOrdered);
    }

    $headers = "Content-Type: application/json\r\n";
    if ($idempotencyKey !== null && $idempotencyKey !== '') {
        $headers .= "Idempotency-Key: " . $idempotencyKey . "\r\n";
    }
    if ($token !== null && $token !== '') {
        $headers .= "Authorization: Bearer " . $token . "\r\n";
    }

    $options = [
        'http' => [
            'method' => 'POST',
            'header' => $headers,
            'content' => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'ignore_errors' => true,
            'timeout' => 30,
        ],
    ];

    $context = stream_context_create($options);
    $response = @file_get_contents(API_URL, false, $context);

    if ($response === false) {
        return [
            'success' => false,
            'message' => 'Ошибка соединения с API',
            'error_code' => 503,
            'data' => null,
        ];
    }

    $decoded = json_decode($response, true);
    if (!is_array($decoded)) {
        return [
            'success' => false,
            'message' => 'Некорректный JSON-ответ API',
            'error_code' => 500,
            'data' => null,
        ];
    }

    return $decoded;
}

$results = [];
foreach ($input['requests'] as $index => $request) {
    if (!is_array($request) || !isset($request['action']) || !is_string($request['action']) || trim($request['action']) === '') {
        $results[] = [
            'original_index' => $index,
            'success' => false,
            'data' => null,
            'message' => 'Отсутствует корректный action в запросе.',
            'error_code' => 400,
        ];
        continue;
    }

    $action = trim($request['action']);
    $params = isset($request['params']) && is_array($request['params']) ? $request['params'] : [];
    $paramsOrdered = isset($request['params_ordered']) && is_array($request['params_ordered'])
        ? array_values($request['params_ordered'])
        : [];

    $sessionId = isset($request['session_id']) && is_string($request['session_id'])
        ? $request['session_id']
        : null;

    $token = isset($request['token']) && is_string($request['token'])
        ? $request['token']
        : null;

    $idempotency = isset($request['idempotency_key']) ? (is_string($request['idempotency_key']) ? $request['idempotency_key'] : null) : null;
    $apiResult = callAPI($action, $params, $sessionId, $token, $idempotency, $paramsOrdered);

    $results[] = [
        'original_index' => $index,
        'success' => (bool)($apiResult['success'] ?? false),
        'data' => $apiResult['data'] ?? null,
        'message' => (string)($apiResult['message'] ?? ''),
        'error_code' => isset($apiResult['error_code']) ? (int)$apiResult['error_code'] : null,
    ];
}

if (!headers_sent()) {
    http_response_code(200);
    header('Content-Type: application/json; charset=utf-8');
}

echo json_encode([
    'success' => true,
    'data' => $results,
    'results' => $results,
    'message' => 'OK',
], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
exit;

