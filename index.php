<?php
declare(strict_types=1);

/**
 * Точка входа в систему:
 * проверка сессии и redirect на дашборд по роли.
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/role_helpers.php';
startSessionIfNeeded();

/**
 * Внутренний вызов API.
 */
function callAPI(string $action, array $params, ?string $sessionId = null, ?string $token = null): array {
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

    $options = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/json\r\n",
            'content' => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'ignore_errors' => true,
            'timeout' => 30,
        ],
    ];

    $context = stream_context_create($options);
    $response = @file_get_contents(API_URL, false, $context);

    if ($response === false) {
        return ['success' => false, 'message' => 'Ошибка соединения с API'];
    }

    $decoded = json_decode($response, true);
    if (!is_array($decoded)) {
        return ['success' => false, 'message' => 'Некорректный ответ API'];
    }

    return $decoded;
}

if (!isset($_SESSION['session_id'], $_SESSION['token'])) {
    header('Location: /ais-system-ru/login/index.php');
    exit;
}

$sessionId = (string)$_SESSION['session_id'];
$token = (string)$_SESSION['token'];

$result = callAPI('ПроверитьСессию', [], $sessionId, $token);

$firstRow = null;
if (($result['success'] ?? false) && isset($result['data']) && is_array($result['data']) && isset($result['data'][0]) && is_array($result['data'][0])) {
    $firstRow = $result['data'][0];
}

$isValid = is_array($firstRow)
    && isset($firstRow['Действительна'])
    && (int)$firstRow['Действительна'] === 1;

if (!$isValid) {
    session_unset();
    session_destroy();
    header('Location: /ais-system-ru/login/index.php?error=session_expired');
    exit;
}

$role = $firstRow['Роль'] ?? null;
$userId = isset($firstRow['Пользователь_ID']) ? (int)$firstRow['Пользователь_ID'] : 0;

if ($userId > 0) {
    $nav = callAPI('ПолучитьНавигациюПользователя', ['Пользователь_ID' => $userId], $sessionId, $token);
    if (($nav['success'] ?? false) && isset($nav['data'])) {
        $path = aisDynamicDashboardPath(aisNormalizeNavigationRows($nav['data']));
        if ($path !== null) {
            header('Location: ' . $path);
            exit;
        }
    }
}

$redirectMap = [
    'Admin' => '/ais-system-ru/admin/dashboard.php',
    'Методист' => '/ais-system-ru/methodist/dashboard.php',
    'Куратор' => '/ais-system-ru/curator/dashboard.php',
    'Преподаватель' => '/ais-system-ru/teacher/dashboard.php',
    'Студент' => '/ais-system-ru/student/dashboard.php',
];

if (is_string($role) && isset($redirectMap[$role])) {
    header('Location: ' . $redirectMap[$role]);
    exit;
}

session_unset();
session_destroy();
header('Location: /ais-system-ru/login/index.php?error=no_navigation');
exit;

