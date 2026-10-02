<?php
/**
 * apply_trigger_fix.php — Исправление триггера TRG_УведомленияОПропусках
 *
 * Проблема: CTE ПропускиСтудента используется двумя INSERT, но CTE
 * в T-SQL валидна только для одного оператора.
 *
 * Решение: Дублирование CTE для второго INSERT.
 *
 * Запуск: http://localhost/ais-system-ru/Database/apply_trigger_fix.php
 */
declare(strict_types=1);
require_once __DIR__ . '/../config.php';

header('Content-Type: text/html; charset=utf-8');
echo '<!DOCTYPE html><html lang="ru"><head><meta charset="utf-8"><title>Fix Trigger</title></head><body style="font-family:monospace;background:#0f172a;color:#e2e8f0;padding:24px">';
echo '<h1 style="color:#7c3aed">🔧 Fix: TRG_УведомленияОПропусках</h1>';

try {
    $conn = getDBConnection();
    echo '<p style="color:#4ade80">✅ Подключение к БД</p>';

    $sql = file_get_contents(__DIR__ . '/fix_trigger_notifications.sql');
    if ($sql === false) {
        throw new RuntimeException('Не удалось прочитать fix_trigger_notifications.sql');
    }

    $stmt = sqlsrv_query($conn, $sql);
    if ($stmt === false) {
        $errors = sqlsrv_errors();
        $msg = '';
        foreach ($errors as $e) {
            $msg .= '[' . ($e['code'] ?? '') . '] ' . ($e['message'] ?? '') . '<br>';
        }
        throw new RuntimeException('Ошибка выполнения: ' . $msg);
    }
    sqlsrv_free_stmt($stmt);

    echo '<p style="color:#4ade80">✅ Триггер TRG_УведомленияОПропусках исправлен!</p>';
    echo '<p style="color:#94a3b8">Теперь INSERT в Посещаемость не будет вызывать ошибку "Invalid object name ПропускиСтудента".</p>';

    closeDBConnection($conn);
} catch (Throwable $e) {
    echo '<p style="color:#f87171">❌ ' . htmlspecialchars($e->getMessage()) . '</p>';
}

echo '</body></html>';

