<?php
declare(strict_types=1);

function csv_strip_utf8_bom(string $content): string {
    return preg_replace('/^\xEF\xBB\xBF/', '', $content) ?? $content;
}

function csv_normalize_content(string $content): string {
    $content = csv_strip_utf8_bom($content);
    $content = preg_replace("/\r\n|\r|\n/", "\n", $content) ?? $content;
    $content = str_replace("\t", ' ', $content);
    return $content;
}

function csv_normalized_lines(string $content): array {
    $content = csv_normalize_content($content);
    $lines = preg_split('/\n/', trim($content));
    return is_array($lines) ? array_values(array_filter($lines, static function ($line) {
        return trim((string)$line) !== '';
    })) : [];
}

function csv_detect_delimiter(string $content): string {
    $lines = csv_normalized_lines($content);
    $sample = $lines[0] ?? '';
    $semicolonCount = substr_count($sample, ';');
    $commaCount = substr_count($sample, ',');
    return $semicolonCount >= $commaCount ? ';' : ',';
}

function csv_expected_headers(string $mode): array {
    if ($mode === 'students') {
        return ['ФИО', 'Группа', 'Логин', 'Пароль', 'Email'];
    }

    if ($mode === 'groups') {
        return ['Название', 'Год_Поступления', 'Код_Специальности'];
    }

    return [];
}

function csv_row_has_expected_header(string $line, array $expectedHeaders): bool {
    $delimiter = csv_detect_delimiter($line);
    $normalized = array_map(static function ($value) {
        return mb_strtolower(trim((string)$value), 'UTF-8');
    }, str_getcsv($line, $delimiter));

    foreach ($expectedHeaders as $header) {
        if (in_array(mb_strtolower($header, 'UTF-8'), $normalized, true)) {
            return true;
        }
    }

    return false;
}

function csv_parse_minimal_students(string $content): array {
    $lines = csv_normalized_lines($content);
    $rows = [];
    foreach ($lines as $line) {
        if (trim($line) === '') continue;
        $cols = str_getcsv($line, ';');
        $rows[] = $cols;
    }
    return $rows;
}

