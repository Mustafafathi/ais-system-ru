<?php
declare(strict_types=1);

function integration_parse_json_or_multipart(): array {
    $result = ['params' => [], 'files' => []];

    $raw = file_get_contents('php://input');
    if ($raw !== false && trim($raw) !== '') {
        $decoded = json_decode($raw, true);
        if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
            $result['params'] = $decoded;
            return $result;
        }
    }

    // Fallback to $_POST/$_FILES for multipart form uploads (CSV file).
    $result['params'] = $_POST ?? [];
    $result['files'] = $_FILES ?? [];
    return $result;
}

