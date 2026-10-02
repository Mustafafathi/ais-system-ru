<?php
declare(strict_types=1);

require_once __DIR__ . '/../config.php';
startSessionIfNeeded();

// Если сессии нет — просто перенаправляем
if (!isset($_SESSION['session_id'], $_SESSION['token'])) {
    header('Location: /ais-system-ru/login/index.php');
    exit;
}

$sessionId = (string)$_SESSION['session_id'];
$token     = (string)$_SESSION['token'];
$userId    = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : null;

// Вызвать SP ЗавершитьСессию — закрывает сессию в DB
// Ожидает: @Сессия_ID UNIQUEIDENTIFIER, @Причина NVARCHAR(100), @Пользователь_ID INT
try {
    $payload = [
        'action'     => 'ЗавершитьСессию',
        'params'     => [
            'Сессия_ID'       => $sessionId,
            'Причина'         => 'Выход пользователя',
            'Пользователь_ID' => $userId,
        ],
        'session_id' => $sessionId,
        'token'      => $token,
    ];

    $options = [
        'http' => [
            'method'        => 'POST',
            'header'        => "Content-Type: application/json\r\n",
            'content'       => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'ignore_errors' => true,
            'timeout'       => 5,
        ],
    ];
    @file_get_contents(API_URL, false, stream_context_create($options));
} catch (Throwable $e) {
    // Молча игнорируем — сессию в PHP всё равно уничтожаем
}

// Уничтожаем PHP-сессию
session_unset();
session_destroy();

// Если AJAX-запрос (POST или Accept: application/json) — возвращаем JSON
$isAjax = ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST'
       || stripos($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json') !== false;

if ($isAjax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => true, 'message' => 'Выход выполнен'], JSON_UNESCAPED_UNICODE);
    exit;
}

header('Location: /ais-system-ru/login/index.php');
exit;

