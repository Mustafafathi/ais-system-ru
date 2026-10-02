<?php
declare(strict_types=1);

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/role_helpers.php';
startSessionIfNeeded();

function internalCallAPI(string $action, array $params, ?string $sessionId = null, ?string $token = null): array
{
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
            'method'        => 'POST',
            'header'        => "Content-Type: application/json\r\n",
            'content'       => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'ignore_errors' => true,
            'timeout'       => 30,
        ],
    ];

    $context  = stream_context_create($options);
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

function requireRole(string ...$allowedRoles): void
{
    global $currentUser;

    $role = $currentUser['Роль'] ?? null;
    if ($role !== null && in_array($role, $allowedRoles, true)) {
        return;
    }

    if (aisCurrentUserHasPageAccess()) {
        return;
    }

    http_response_code(403);
    echo '<!DOCTYPE html><html lang="ru"><head><meta charset="UTF-8"><title>403</title></head>';
    echo '<body style="font-family:sans-serif;text-align:center;padding:80px">';
    echo '<h1>403 — Доступ запрещён</h1>';
    echo '<p>У вас нет прав для просмотра этой страницы.</p>';
    echo '<a href="/ais-system-ru/">На главную</a></body></html>';
    exit;
}

$currentUser = null;
$currentNavigation = [];

function aisCurrentRequestPath(): string
{
    $path = (string)($_SERVER['PHP_SELF'] ?? '');
    $parsed = parse_url($path, PHP_URL_PATH);
    return is_string($parsed) ? $parsed : $path;
}

function aisCurrentUserHasPageAccess(?string $path = null): bool
{
    global $currentUser, $currentNavigation, $sessionId, $token;

    if (!is_array($currentUser) || empty($currentUser['Пользователь_ID'])) {
        return false;
    }

    $path = $path ?? aisCurrentRequestPath();
    foreach ($currentNavigation as $row) {
        if (is_array($row) && aisNavigationPath($row) === $path) {
            return true;
        }
    }

    $result = internalCallAPI(
        'ПроверитьДоступКСтранице',
        [
            'Пользователь_ID' => (int)$currentUser['Пользователь_ID'],
            'Путь' => $path,
        ],
        $sessionId,
        $token
    );

    $row = ($result['success'] ?? false) && !empty($result['data'][0]) && is_array($result['data'][0])
        ? $result['data'][0]
        : null;

    return is_array($row) && (int)($row['ДоступРазрешен'] ?? 0) === 1;
}

if (!isset($_SESSION['session_id'], $_SESSION['token'])) {
    header('Location: /ais-system-ru/login/index.php');
    exit;
}

$sessionId = (string)$_SESSION['session_id'];
$token     = (string)$_SESSION['token'];

$result   = internalCallAPI('ПроверитьСессию', [], $sessionId, $token);
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

$currentUser = $firstRow;

$currentRole = isset($currentUser['Роль']) ? (string)$currentUser['Роль'] : '';
$_SESSION['role'] = $currentRole;
if (isset($currentUser['Пользователь_ID'])) {
    $_SESSION['user_id'] = (int)$currentUser['Пользователь_ID'];
}
if (isset($currentUser['Студент_ID'])) {
    $_SESSION['student_id'] = (int)$currentUser['Студент_ID'];
}
if (isset($currentUser['Преподаватель_ID'])) {
    $_SESSION['teacher_id'] = (int)$currentUser['Преподаватель_ID'];
}
if (isset($currentUser['Группа_ID'])) {
    $_SESSION['group_id'] = (int)$currentUser['Группа_ID'];
}

// ПроверитьСессию не возвращает ФИО — добираем из ПолучитьПользователяПоID
if (isset($currentUser['Пользователь_ID'])) {
    $extra = internalCallAPI(
        'ПолучитьПользователяПоID',
        ['Пользователь_ID' => (int)$currentUser['Пользователь_ID']],
        $sessionId, $token
    );
    if (!empty($extra['data'][0])) {
        $u = $extra['data'][0];
        $currentUser['ФИО']   = $u['ФИО'] ?? $u['ФИО_Студента'] ?? $u['ФИО_Преподавателя'] ?? '';
        $currentUser['Логин'] = $u['Логин'] ?? '';
        $currentUser['Email'] = $u['Email'] ?? '';
    }
}

if (isset($currentUser['Пользователь_ID'])) {
    $nav = internalCallAPI(
        'ПолучитьНавигациюПользователя',
        ['Пользователь_ID' => (int)$currentUser['Пользователь_ID']],
        $sessionId,
        $token
    );
    if (($nav['success'] ?? false) && isset($nav['data'])) {
        $currentNavigation = aisNormalizeNavigationRows($nav['data']);
    }
}

