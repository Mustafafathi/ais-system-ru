<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../includes/role_helpers.php';
startSessionIfNeeded();

// Only accept JSON POST
$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    jsonResponse(false, null, 'Invalid payload', null, 400);
}

$sid = isset($input['session_id']) ? (string)$input['session_id'] : null;
$token = isset($input['token']) ? (string)$input['token'] : null;
$role = isset($input['role']) ? trim((string)$input['role']) : '';

if (!$sid || !$token) {
    jsonResponse(false, null, 'Missing session_id or token', null, 400);
}

// Save into PHP session so include/auth_check.php can use it
$_SESSION['session_id'] = $sid;
$_SESSION['token'] = $token;
if ($role !== '') {
    $_SESSION['role'] = $role;
} else {
    unset($_SESSION['role']);
}

function sessionStoreInt(string $key, array $input, string $field): void {
    if (isset($input[$field]) && is_numeric($input[$field]) && (int)$input[$field] > 0) {
        $_SESSION[$key] = (int)$input[$field];
    } else {
        unset($_SESSION[$key]);
    }
}

sessionStoreInt('user_id', $input, 'user_id');
sessionStoreInt('student_id', $input, 'student_id');
sessionStoreInt('teacher_id', $input, 'teacher_id');
sessionStoreInt('group_id', $input, 'group_id');

// Optionally set a server-side expiry timestamp
$_SESSION['created_at'] = time();

jsonResponse(true, ['session_id' => $sid, 'role' => $role ?: null], 'Session synced');

