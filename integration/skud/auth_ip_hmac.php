<?php
declare(strict_types=1);

class SkudAuthException extends RuntimeException {}

function skud_normalize_headers(array $headers): array {
    $normalized = [];
    foreach ($headers as $name => $value) {
        $normalized[strtolower((string)$name)] = is_array($value) ? implode(',', $value) : (string)$value;
    }
    return $normalized;
}

function skud_parse_allowlist(string $rawAllowlist): array {
    $items = array_map('trim', explode(',', $rawAllowlist));
    return array_values(array_filter($items, static fn($ip) => $ip !== ''));
}

function skud_client_ip_allowed(array $allowlistIps, string $clientIp): bool {
    if (in_array('*', $allowlistIps, true)) {
        return true;
    }

    return in_array($clientIp, $allowlistIps, true);
}

function skud_nonce_cache_path(): string {
    return rtrim(sys_get_temp_dir(), DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . 'ais_skud_nonce_cache.json';
}

function skud_register_nonce(string $nonce, int $timestamp, int $ttlSeconds = 300): bool {
    $path = skud_nonce_cache_path();
    $now = time();
    $key = hash('sha256', $nonce);

    $handle = fopen($path, 'c+');
    if ($handle === false) {
        throw new SkudAuthException('Nonce cache unavailable', 500);
    }

    try {
        if (!flock($handle, LOCK_EX)) {
            throw new SkudAuthException('Nonce cache lock failed', 500);
        }

        rewind($handle);
        $raw = stream_get_contents($handle);
        $cache = is_string($raw) && trim($raw) !== '' ? json_decode($raw, true) : [];
        if (!is_array($cache)) {
            $cache = [];
        }

        foreach ($cache as $cachedKey => $seenAt) {
            if (!is_int($seenAt) && !ctype_digit((string)$seenAt)) {
                unset($cache[$cachedKey]);
                continue;
            }
            if ((int)$seenAt + $ttlSeconds < $now) {
                unset($cache[$cachedKey]);
            }
        }

        if (isset($cache[$key])) {
            return false;
        }

        $cache[$key] = max($timestamp, $now);
        ftruncate($handle, 0);
        rewind($handle);
        fwrite($handle, json_encode($cache, JSON_UNESCAPED_UNICODE));

        return true;
    } finally {
        flock($handle, LOCK_UN);
        fclose($handle);
    }
}

// Verifies allowlisted IP, HMAC signature over the exact raw body, timestamp, and nonce.
function skud_verify_request(array $allowlistIps, string $sharedSecret, array $headers, string $clientIp, string $rawBody): array {
    if (!skud_client_ip_allowed($allowlistIps, $clientIp)) {
        throw new SkudAuthException('IP not allowed', 403);
    }

    $headers = skud_normalize_headers($headers);
    $signature = $headers['x-skud-signature'] ?? null;
    $timestamp = $headers['x-skud-timestamp'] ?? null;
    $nonce = $headers['x-skud-nonce'] ?? null;

    if ($signature === null || $timestamp === null || $nonce === null) {
        throw new SkudAuthException('Missing signature headers', 401);
    }

    if (!ctype_digit((string)$timestamp)) {
        throw new SkudAuthException('Invalid timestamp', 401);
    }

    $timestampInt = (int)$timestamp;
    if (abs(time() - $timestampInt) > 60) {
        throw new SkudAuthException('Stale timestamp', 401);
    }

    $signature = preg_replace('/^sha256=/i', '', trim((string)$signature));
    $expected = hash_hmac('sha256', $timestamp . '.' . $nonce . '.' . $rawBody, $sharedSecret);
    if (!is_string($signature) || !hash_equals($expected, $signature)) {
        throw new SkudAuthException('Invalid signature', 401);
    }

    $isFreshNonce = skud_register_nonce((string)$nonce, $timestampInt);

    return [
        'duplicate' => !$isFreshNonce,
        'nonce' => (string)$nonce,
        'timestamp' => $timestampInt,
    ];
}

