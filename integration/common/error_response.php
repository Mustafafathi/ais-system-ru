<?php
declare(strict_types=1);

function integration_error_response(bool $ok, ?array $data = null, string $message = '', ?string $correlation = null, int $httpStatus = 400) {
    http_response_code($httpStatus);
    header('Content-Type: application/json; charset=utf-8');
    $envelope = [
        'ok' => $ok,
        'message' => $message,
        'correlation_id' => $correlation ?? bin2hex(random_bytes(8)),
    ];
    if ($data !== null) {
        $envelope['data'] = $data;
    }

    echo json_encode($envelope, JSON_UNESCAPED_UNICODE);
    exit(0);
}

