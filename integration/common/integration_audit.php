<?php
declare(strict_types=1);

function integration_safe_headers(array $headers): array {
    $safe = [];
    foreach ($headers as $name => $value) {
        $key = (string)$name;
        $lower = strtolower($key);
        if (in_array($lower, ['authorization', 'x-skud-signature', 'cookie'], true)) {
            $safe[$key] = '[redacted]';
            continue;
        }
        $safe[$key] = is_array($value) ? implode(',', $value) : (string)$value;
    }
    return $safe;
}

function integration_file_audit_log(string $endpoint, string $clientIp, string $method, array $headers, int $httpStatus, float $latencyMs, string $note = ''): void {
    $path = rtrim(sys_get_temp_dir(), DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . 'ais_integration_audit.log';
    $entry = [
        'ts' => date('c'),
        'endpoint' => $endpoint,
        'client_ip' => $clientIp,
        'method' => $method,
        'http_status' => $httpStatus,
        'latency_ms' => round($latencyMs, 2),
        'headers' => integration_safe_headers($headers),
        'note' => $note,
    ];

    @file_put_contents($path, json_encode($entry, JSON_UNESCAPED_UNICODE) . PHP_EOL, FILE_APPEND | LOCK_EX);
}

function integration_audit_log($conn, string $endpoint, string $clientIp, string $method, array $headers, int $httpStatus, float $latencyMs, string $note = ''): void {
    integration_file_audit_log($endpoint, $clientIp, $method, $headers, $httpStatus, $latencyMs, $note);

    if ($conn === null) {
        return;
    }

    // Minimal transport-level audit. Tries to call stored proc dbo.ЗаписатьЛогИнтеграции if available.
    try {
        $proc = 'ЗаписатьЛогИнтеграции';
        $exists = true;
        $checkSql = "SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = ? AND ROUTINE_TYPE='PROCEDURE'";
        $stmt = sqlsrv_query($conn, $checkSql, [$proc]);
        if ($stmt === false) {
            $exists = false;
        } else {
            $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_NUMERIC);
            sqlsrv_free_stmt($stmt);
            if (!$row) {
                $exists = false;
            }
        }

        if ($exists) {
            $payload = json_encode(['headers' => integration_safe_headers($headers), 'note' => $note], JSON_UNESCAPED_UNICODE);
            $bindings = [
                [$endpoint, SQLSRV_PARAM_IN],
                [$clientIp, SQLSRV_PARAM_IN],
                [$method, SQLSRV_PARAM_IN],
                [$httpStatus, SQLSRV_PARAM_IN],
                [$latencyMs, SQLSRV_PARAM_IN],
                [$payload, SQLSRV_PARAM_IN],
            ];
            $call = '{CALL dbo.ЗаписатьЛогИнтеграции(?,?,?,?,?,?)}';
            $s = sqlsrv_prepare($conn, $call, $bindings);
            if ($s !== false) {
                sqlsrv_execute($s);
                sqlsrv_free_stmt($s);
            }
        }
    } catch (Throwable $e) {
        // Audit must not break main flow.
    }
}

