<?php
declare(strict_types=1);

/**
 * Конфигурация backend-слоя AIS.
 * Только инфраструктурные настройки и вспомогательные функции.
 */

date_default_timezone_set('Europe/Moscow');

if (!defined('SITE_NAME')) {
    define('SITE_NAME', 'АИС учёта посещаемости');
}
if (!defined('SITE_URL')) {
    define('SITE_URL', rtrim((string)(getenv('AIS_SITE_URL') ?: 'http://localhost/ais-system-ru/'), '/') . '/');
}
if (!defined('API_URL')) {
    define('API_URL', SITE_URL . 'api.php');
}
if (!defined('SESSION_LIFETIME_MINUTES')) {
    define('SESSION_LIFETIME_MINUTES', 480);
}
if (!defined('DEBUG_MODE')) {
    define('DEBUG_MODE', filter_var(getenv('AIS_DEBUG') ?: 'false', FILTER_VALIDATE_BOOL));
}

// Integration secrets and settings (override via environment variables in production)
if (!defined('SKUD_SHARED_SECRET')) {
    define('SKUD_SHARED_SECRET', getenv('AIS_SKUD_SECRET') ?: '');
}
if (!defined('INTEGRATION_HEALTH_SECRET')) {
    define('INTEGRATION_HEALTH_SECRET', getenv('AIS_HEALTH_SECRET') ?: null);
}
if (!defined('INTEGRATION_ALLOWLIST')) {
    // Comma-separated IPs
    $raw = getenv('AIS_INTEGRATION_ALLOWLIST') ?: '127.0.0.1,::1';
    define('INTEGRATION_ALLOWLIST', $raw);
}

/**
 * Получение значения переменной окружения с дефолтом.
 */
function getEnvValue(string $name, string $default = ''): string {
    $value = getenv($name);
    if ($value === false || $value === '') {
        return $default;
    }
    return (string)$value;
}

/**
 * Получение булевого значения из переменной окружения.
 */
function getEnvBool(string $name, bool $default): bool {
    $value = getenv($name);
    if ($value === false || $value === '') {
        return $default;
    }

    $parsed = filter_var($value, FILTER_VALIDATE_BOOL, FILTER_NULL_ON_FAILURE);
    return $parsed === null ? $default : $parsed;
}

// --- Настройки подключения к SQL Server ---
$serverName = sprintf('%s,%s',
    getEnvValue('AIS_DB_HOST', 'localhost'),
    getEnvValue('AIS_DB_PORT', '15432')
);

$connectionOptions = [
    'Database' => getEnvValue('AIS_DB_NAME', 'Улучшенная'),
    'Uid' => getEnvValue('AIS_DB_USER', 'php_user'),
    'PWD' => getEnvValue('AIS_DB_PASSWORD', 'Dev_656'),
    'CharacterSet' => 'UTF-8',
    'ReturnDatesAsStrings' => true,
    // Для локальной разработки можно отключить шифрование,
    // если сервер не настроен на TLS.
    'Encrypt' => getEnvBool('AIS_DB_ENCRYPT', false),
    'TrustServerCertificate' => getEnvBool('AIS_DB_TRUST_SERVER_CERT', true),
];

/**
 * Подготовка директории сессий (fallback при недоступном системном пути).
 */
function ensureSessionStorageReady(): void {
    if (session_status() !== PHP_SESSION_NONE) {
        return;
    }

    $currentPath = (string)ini_get('session.save_path');
    if ($currentPath !== '' && is_dir($currentPath) && is_writable($currentPath)) {
        return;
    }

    $fallbackPath = __DIR__ . DIRECTORY_SEPARATOR . 'runtime' . DIRECTORY_SEPARATOR . 'sessions';
    if (!is_dir($fallbackPath)) {
        @mkdir($fallbackPath, 0777, true);
    }

    if (is_dir($fallbackPath) && is_writable($fallbackPath)) {
        session_save_path($fallbackPath);
    }
}

/**
 * Безопасный запуск сессии.
 */
function startSessionIfNeeded(): void {
    if (session_status() === PHP_SESSION_NONE) {
        ensureSessionStorageReady();
        session_start();
    }
}

/**
 * Проверка доступности расширения sqlsrv.
 */
function ensureSqlsrvExtensionLoaded(): void {
    if (!extension_loaded('sqlsrv')) {
        throw new RuntimeException('Расширение PHP "sqlsrv" не загружено.');
    }
}

/**
 * Формирование человекочитаемого текста ошибок SQLSRV.
 */
function getSqlsrvErrorsText(): string {
    $errors = sqlsrv_errors(SQLSRV_ERR_ERRORS);
    if (!is_array($errors) || empty($errors)) {
        return 'Неизвестная ошибка SQLSRV.';
    }

    $messages = [];
    foreach ($errors as $error) {
        $state = isset($error['SQLSTATE']) ? (string)$error['SQLSTATE'] : 'N/A';
        $code = isset($error['code']) ? (string)$error['code'] : 'N/A';
        $message = isset($error['message']) ? trim((string)$error['message']) : 'Без сообщения';
        $messages[] = sprintf('[%s/%s] %s', $state, $code, $message);
    }

    return implode(' | ', $messages);
}

/**
 * Подключение к БД.
 */
function getDBConnection() {
    global $serverName, $connectionOptions;

    ensureSqlsrvExtensionLoaded();

    $conn = sqlsrv_connect($serverName, $connectionOptions);
    if ($conn === false) {
        throw new RuntimeException('Ошибка подключения к базе данных: ' . getSqlsrvErrorsText());
    }

    return $conn;
}

/**
 * Закрытие соединения с БД.
 */
function closeDBConnection($conn): void {
    if (is_resource($conn) || $conn !== null) {
        @sqlsrv_close($conn);
    }
}

/**
 * Нормализация значений datetime для JSON.
 */
function normalizeScalarValue($value) {
    if ($value instanceof DateTimeInterface) {
        return $value->format('Y-m-d H:i:s');
    }
    return $value;
}

/**
 * Унифицированный JSON-ответ.
 */
function jsonResponse(bool $success, $data = null, string $message = '', ?int $errorCode = null, int $httpStatus = 200): void {
    if (!headers_sent()) {
        http_response_code($httpStatus);
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    }

    $response = [
        'success' => $success,
        'data' => $data,
        'message' => $message,
    ];

    if ($errorCode !== null) {
        $response['error_code'] = $errorCode;
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}


