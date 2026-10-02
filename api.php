<?php
declare(strict_types=1);

/**
 * Единая API-точка входа.
 * PHP слой остаётся thin: только валидация транспорта + вызов хранимых процедур.
 */

require_once __DIR__ . '/config.php';

ini_set('display_errors', '0');
error_reporting(E_ALL);

final class ApiException extends RuntimeException {
    private int $httpStatus;
    private ?int $apiErrorCode;

    public function __construct(string $message, int $httpStatus = 400, ?int $apiErrorCode = null, ?Throwable $previous = null) {
        parent::__construct($message, 0, $previous);
        $this->httpStatus = $httpStatus;
        $this->apiErrorCode = $apiErrorCode;
    }

    public function getHttpStatus(): int {
        return $this->httpStatus;
    }

    public function getApiErrorCode(): ?int {
        return $this->apiErrorCode;
    }
}

function readRequestPayload(string $method): array {
    $rawBody = file_get_contents('php://input');
    if ($rawBody === false) {
        throw new ApiException('Не удалось прочитать тело запроса.', 400, 400);
    }

    if ($method === 'GET' && trim($rawBody) === '') {
        return $_GET;
    }

    $contentType = strtolower((string)($_SERVER['CONTENT_TYPE'] ?? $_SERVER['HTTP_CONTENT_TYPE'] ?? ''));
    if (strpos($contentType, 'multipart/form-data') !== false) {
        return is_array($_POST) ? $_POST : [];
    }

    if (trim($rawBody) === '') {
        return [];
    }

    $decoded = json_decode($rawBody, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new ApiException('Некорректный JSON: ' . json_last_error_msg(), 400, 400);
    }

    if (!is_array($decoded)) {
        throw new ApiException('Тело запроса должно быть JSON-объектом.', 400, 400);
    }

    return $decoded;
}

function getRequestHeadersSafe(): array {
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        return is_array($headers) ? $headers : [];
    }

    $headers = [];
    foreach ($_SERVER as $key => $value) {
        if (strpos($key, 'HTTP_') === 0) {
            $headerName = str_replace('_', '-', substr($key, 5));
            $headers[$headerName] = $value;
        }
    }

    return $headers;
}

// -----------------------------
// Idempotency file cache (lightweight, filesystem-based)
// -----------------------------
if (!defined('IDEMPOTENCY_DIR')) {
    define('IDEMPOTENCY_DIR', __DIR__ . DIRECTORY_SEPARATOR . 'runtime' . DIRECTORY_SEPARATOR . 'idempotency');
}

if (!defined('IDEMPOTENCY_TTL')) {
    // seconds, default 24 hours
    define('IDEMPOTENCY_TTL', 24 * 3600);
}

function ensureIdempotencyDir(): void {
    $dir = IDEMPOTENCY_DIR;
    if (!is_dir($dir)) {
        @mkdir($dir, 0700, true);
    }
}

function idempotencyFilename(string $key): string {
    $hash = hash('sha256', $key);
    return IDEMPOTENCY_DIR . DIRECTORY_SEPARATOR . $hash . '.json';
}

function idempotencyCacheGet(string $key): ?array {
    ensureIdempotencyDir();
    $file = idempotencyFilename($key);
    if (!is_file($file)) return null;
    $content = @file_get_contents($file);
    if ($content === false) return null;
    $decoded = json_decode($content, true);
    if (!is_array($decoded) || !isset($decoded['timestamp']) || !isset($decoded['payload'])) return null;
    if (time() - (int)$decoded['timestamp'] > IDEMPOTENCY_TTL) {
        @unlink($file);
        return null;
    }
    return $decoded['payload'];
}

function idempotencyCacheSave(string $key, $payload): bool {
    ensureIdempotencyDir();
    $file = idempotencyFilename($key);
    $data = [
        'timestamp' => time(),
        'payload' => $payload,
    ];
    $encoded = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($encoded === false) return false;
    return (@file_put_contents($file, $encoded, LOCK_EX) !== false);
}

function isAssociativeArray(array $value): bool {
    return array_keys($value) !== range(0, count($value) - 1);
}

function normalizeParamKey(string $name): string {
    $name = ltrim(trim($name), '@');
    if ($name === '') {
        return '';
    }

    if (function_exists('mb_strtolower')) {
        return mb_strtolower($name, 'UTF-8');
    }

    return strtolower($name);
}

function normalizeNamedParams(array $params): array {
    $normalized = [];
    foreach ($params as $key => $value) {
        if (!is_string($key)) {
            continue;
        }
        $normalized[normalizeParamKey($key)] = $value;
    }

    // Алиасы совместимости для клиентов с англоязычными ключами.
    $sessionRu = normalizeParamKey('Сессия_ID');
    $tokenRu = normalizeParamKey('Токен');

    if (array_key_exists('session_id', $normalized) && !array_key_exists($sessionRu, $normalized)) {
        $normalized[$sessionRu] = $normalized['session_id'];
    }

    if (array_key_exists('token', $normalized) && !array_key_exists($tokenRu, $normalized)) {
        $normalized[$tokenRu] = $normalized['token'];
    }

    return $normalized;
}

function mergeTopLevelParams(array $namedParams, array $input): array {
    $sessionRu = normalizeParamKey('Сессия_ID');
    $tokenRu = normalizeParamKey('Токен');

    $sessionCandidates = [
        $input['session_id'] ?? null,
        $input['Сессия_ID'] ?? null,
        $input['сессия_id'] ?? null,
    ];

    foreach ($sessionCandidates as $candidate) {
        if (is_string($candidate) && $candidate !== '' && !array_key_exists($sessionRu, $namedParams)) {
            $namedParams[$sessionRu] = $candidate;
            break;
        }
    }

    $tokenCandidates = [
        $input['token'] ?? null,
        $input['Токен'] ?? null,
        $input['токен'] ?? null,
    ];

    foreach ($tokenCandidates as $candidate) {
        if (is_string($candidate) && $candidate !== '' && !array_key_exists($tokenRu, $namedParams)) {
            $namedParams[$tokenRu] = $candidate;
            break;
        }
    }

    return $namedParams;
}

function findFirstParamValue(array $sources, array $aliases) {
    $normalizedAliases = array_map(static function ($alias) {
        return normalizeParamKey((string)$alias);
    }, $aliases);

    foreach ($sources as $source) {
        if (!is_array($source)) {
            continue;
        }

        foreach ($aliases as $alias) {
            if (is_string($alias) && array_key_exists($alias, $source)) {
                $value = $source[$alias];
                if ($value !== null && $value !== '') {
                    return $value;
                }
            }
        }

        foreach ($normalizedAliases as $alias) {
            if (array_key_exists($alias, $source)) {
                $value = $source[$alias];
                if ($value !== null && $value !== '') {
                    return $value;
                }
            }
        }
    }

    return null;
}

function extractAuthContext(array $input, array $namedParams): array {
    $headers = getRequestHeadersSafe();

    $token = null;
    foreach ($headers as $headerName => $headerValue) {
        if (strcasecmp($headerName, 'Authorization') === 0 && is_string($headerValue)) {
            if (preg_match('/Bearer\s+(\S+)/i', $headerValue, $matches)) {
                $token = $matches[1];
                break;
            }
        }
    }

    if ($token === null || $token === '') {
        $token = $input['token'] ?? $input['Токен'] ?? $namedParams['token'] ?? $namedParams[normalizeParamKey('Токен')] ?? null;
    }

    $sessionId = $input['session_id'] ?? $input['Сессия_ID'] ?? $namedParams['session_id'] ?? $namedParams[normalizeParamKey('Сессия_ID')] ?? null;

    if (!is_string($token) || $token === '') {
        throw new ApiException('Требуется токен авторизации.', 401, 401);
    }

    if (!is_string($sessionId) || $sessionId === '') {
        throw new ApiException('Требуется session_id для проверки сессии.', 401, 401);
    }

    return [$sessionId, $token];
}

function validateActionName(string $action): void {
    if ($action === '') {
        throw new ApiException('Параметр action не может быть пустым.', 400, 400);
    }

    if (mb_strlen($action, 'UTF-8') > 128) {
        throw new ApiException('Слишком длинное имя action.', 400, 400);
    }

    if (!preg_match('/^[\p{L}\p{N}_]+$/u', $action)) {
        throw new ApiException('Недопустимое имя action.', 400, 400);
    }
}

function ensureProcedureExists($conn, string $schema, string $procedureName): void {
    $sql = "
        SELECT 1
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_SCHEMA = ?
          AND ROUTINE_NAME = ?
          AND ROUTINE_TYPE = 'PROCEDURE'
    ";

    $stmt = sqlsrv_query($conn, $sql, [$schema, $procedureName]);
    if ($stmt === false) {
        throw new RuntimeException('Ошибка проверки процедуры: ' . getSqlsrvErrorsText());
    }

    $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
    sqlsrv_free_stmt($stmt);

    if (!$row) {
        throw new ApiException('Процедура не найдена: ' . $procedureName, 404, 404);
    }
}

function getProcedureParameters($conn, string $schema, string $procedureName): array {
    $sql = "
        SELECT
            PARAMETER_NAME,
            ORDINAL_POSITION,
            PARAMETER_MODE,
            DATA_TYPE,
            CHARACTER_MAXIMUM_LENGTH,
            NUMERIC_PRECISION,
            NUMERIC_SCALE
        FROM INFORMATION_SCHEMA.PARAMETERS
        WHERE SPECIFIC_SCHEMA = ?
          AND SPECIFIC_NAME = ?
        ORDER BY ORDINAL_POSITION
    ";

    $stmt = sqlsrv_query($conn, $sql, [$schema, $procedureName]);
    if ($stmt === false) {
        throw new RuntimeException('Ошибка чтения параметров процедуры: ' . getSqlsrvErrorsText());
    }

    $rows = [];
    while (true) {
        $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
        if ($row === null) {
            break;
        }
        if ($row === false) {
            sqlsrv_free_stmt($stmt);
            throw new RuntimeException('Ошибка чтения параметров процедуры: ' . getSqlsrvErrorsText());
        }
        $rows[] = $row;
    }

    sqlsrv_free_stmt($stmt);
    return $rows;
}

function resolveOutputSqlType(array $paramMeta) {
    $type = strtolower((string)($paramMeta['DATA_TYPE'] ?? ''));
    $charLength = $paramMeta['CHARACTER_MAXIMUM_LENGTH'] ?? null;
    $precision = $paramMeta['NUMERIC_PRECISION'] ?? null;
    $scale = $paramMeta['NUMERIC_SCALE'] ?? null;

    switch ($type) {
        case 'nvarchar':
        case 'nchar':
            $length = ($charLength === null || (int)$charLength === -1) ? 'max' : (string)((int)$charLength);
            return SQLSRV_SQLTYPE_NVARCHAR($length);

        case 'varchar':
        case 'char':
            $length = ($charLength === null || (int)$charLength === -1) ? 'max' : (string)((int)$charLength);
            return SQLSRV_SQLTYPE_VARCHAR($length);

        case 'int':
            return SQLSRV_SQLTYPE_INT;
        case 'bigint':
            return SQLSRV_SQLTYPE_BIGINT;
        case 'smallint':
            return SQLSRV_SQLTYPE_SMALLINT;
        case 'tinyint':
            return SQLSRV_SQLTYPE_TINYINT;
        case 'bit':
            return SQLSRV_SQLTYPE_BIT;
        case 'decimal':
        case 'numeric':
            return SQLSRV_SQLTYPE_DECIMAL((int)($precision ?? 18), (int)($scale ?? 0));
        case 'float':
            return SQLSRV_SQLTYPE_FLOAT;
        case 'real':
            return SQLSRV_SQLTYPE_REAL;
        case 'uniqueidentifier':
            return SQLSRV_SQLTYPE_UNIQUEIDENTIFIER;
        default:
            return null;
    }
}

function isValidUniqueIdentifierValue($value): bool {
    if (!is_string($value)) {
        return false;
    }

    return (bool)preg_match('/^\{?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}?$/', trim($value));
}

function normalizeProcedureInputValue(array $paramMeta, $value, string $paramName) {
    $type = strtolower((string)($paramMeta['DATA_TYPE'] ?? ''));

    if ($type === 'uniqueidentifier') {
        if ($value === null) {
            return null;
        }

        if (!isValidUniqueIdentifierValue($value)) {
            throw new ApiException('Некорректный формат uniqueidentifier для параметра ' . $paramName . '.', 400, 400);
        }

        return trim((string)$value, '{} ');
    }

    return $value;
}

function buildProcedureBindings(array $procedureParams, array $namedParams, array $orderedParams): array {
    $bindings = [];
    $callArguments = [];
    $outputValues = [];
    $outputNameMap = [];

    $orderedIndex = 0;
    $orderedCount = count($orderedParams);

    foreach ($procedureParams as $paramMeta) {
        $rawName = (string)$paramMeta['PARAMETER_NAME'];
        $cleanName = ltrim($rawName, '@');
        $normName = normalizeParamKey($rawName);
        $callName = '@' . $cleanName;

        $mode = strtoupper((string)($paramMeta['PARAMETER_MODE'] ?? 'IN'));
        $isOutput = ($mode === 'OUT' || $mode === 'INOUT');

        if ($isOutput) {
            $initialValue = array_key_exists($normName, $namedParams) ? $namedParams[$normName] : null;
            $outputValues[$normName] = $initialValue;
            $outputNameMap[$normName] = $cleanName;

            $direction = ($mode === 'INOUT' && defined('SQLSRV_PARAM_INOUT')) ? SQLSRV_PARAM_INOUT : SQLSRV_PARAM_OUT;
            $binding = [&$outputValues[$normName], $direction];

            $sqlType = resolveOutputSqlType($paramMeta);
            if ($sqlType !== null) {
                $binding[] = null;
                $binding[] = $sqlType;
            }

            $bindings[] = $binding;
            $callArguments[] = $callName . ' = ? OUTPUT';
            continue;
        }

        if (array_key_exists($normName, $namedParams)) {
            // Named parameter explicitly provided (may be null) — bind it as IN
            $value = normalizeProcedureInputValue($paramMeta, $namedParams[$normName], $callName);
            $bindings[] = [$value, SQLSRV_PARAM_IN];
            $callArguments[] = $callName . ' = ?';
        } elseif ($orderedIndex < $orderedCount) {
            // Positional parameter provided by caller — bind it as IN
            $value = normalizeProcedureInputValue($paramMeta, $orderedParams[$orderedIndex++], $callName);
            $bindings[] = [$value, SQLSRV_PARAM_IN];
            $callArguments[] = $callName . ' = ?';
        } else {
            // No value provided for this IN parameter — skip binding so the stored
            // procedure can use its default value instead of being overridden with NULL.
            continue;
        }
    }

    return [$bindings, $outputValues, $outputNameMap, $callArguments];
}

function buildProcedureCallSql(string $schema, string $procedureName, array $callArguments = []): string {
    $safeSchema = str_replace(']', ']]', $schema);
    $safeProcedure = str_replace(']', ']]', $procedureName);
    $qualified = sprintf('[%s].[%s]', $safeSchema, $safeProcedure);

    if (empty($callArguments)) {
        return 'EXEC ' . $qualified;
    }

    return 'EXEC ' . $qualified . ' ' . implode(', ', $callArguments);
}

function textContains(string $haystack, string $needle): bool {
    if (function_exists('mb_stripos')) {
        return mb_stripos($haystack, $needle, 0, 'UTF-8') !== false;
    }

    return stripos($haystack, $needle) !== false;
}

function extractBusinessSqlServerMessage(string $errorText): ?string {
    if (!preg_match_all('/\[[0-9A-Z]{5}\/50000\].*?\[SQL Server\]([^|]+)/u', $errorText, $matches)) {
        return null;
    }

    $message = trim((string)end($matches[1]));
    return $message === '' ? null : $message;
}

function throwMappedProcedureException(string $errorText): void {
    $businessMessage = extractBusinessSqlServerMessage($errorText);
    if ($businessMessage === null) {
        throw new RuntimeException('Ошибка выполнения процедуры: ' . $errorText);
    }

    $status = 400;
    $code = 400;

    if (textContains($businessMessage, 'Неверный логин или пароль')) {
        $status = 401;
        $code = 401;
    } elseif (textContains($businessMessage, 'Недостаточно прав') || textContains($businessMessage, 'Доступ запрещ')) {
        $status = 403;
        $code = 403;
    } elseif (textContains($businessMessage, 'не найден') || textContains($businessMessage, 'не найдена')) {
        $status = 404;
        $code = 404;
    } elseif (textContains($businessMessage, 'дублик') || textContains($businessMessage, 'уже существует')) {
        $status = 409;
        $code = 409;
    }

    throw new ApiException($businessMessage, $status, $code);
}

function executeProcedure($conn, string $schema, string $procedureName, array &$bindings, array $callArguments = []) {
    $sql = buildProcedureCallSql($schema, $procedureName, $callArguments);

    $stmt = sqlsrv_prepare($conn, $sql, $bindings);
    if ($stmt === false) {
        throw new RuntimeException('Ошибка подготовки процедуры: ' . getSqlsrvErrorsText());
    }

    if (!sqlsrv_execute($stmt)) {
        $errorText = getSqlsrvErrorsText();
        sqlsrv_free_stmt($stmt);
        throwMappedProcedureException($errorText);
    }

    return $stmt;
}

function fetchAllResultSets($stmt): array {
    $allSets = [];

    while (true) {
        $rows = [];

        while (true) {
            $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
            if ($row === null) {
                break;
            }
            if ($row === false) {
                throw new RuntimeException('Ошибка чтения result set: ' . getSqlsrvErrorsText());
            }

            foreach ($row as $key => $value) {
                $row[$key] = normalizeScalarValue($value);
            }
            $rows[] = $row;
        }

        if (!empty($rows)) {
            $allSets[] = $rows;
        }

        $next = sqlsrv_next_result($stmt);
        if ($next === null) {
            break;
        }
        if ($next === false) {
            throw new RuntimeException('Ошибка перехода к следующему result set: ' . getSqlsrvErrorsText());
        }
    }

    return $allSets;
}

function validateSessionToken($conn, string $sessionId, string $token): array {
    $bindings = [
        [$sessionId, SQLSRV_PARAM_IN],
        [$token, SQLSRV_PARAM_IN],
    ];

    $stmt = executeProcedure($conn, 'dbo', 'ПроверитьСессию', $bindings, [
        '@Сессия_ID = ?',
        '@Токен = ?',
    ]);
    try {
        $sets = fetchAllResultSets($stmt);
    } finally {
        sqlsrv_free_stmt($stmt);
    }

    $firstRow = $sets[0][0] ?? null;
    $isValid = is_array($firstRow)
        && isset($firstRow['Действительна'])
        && (int)$firstRow['Действительна'] === 1;

    if (!$isValid) {
        throw new ApiException('Недействительная или просроченная сессия.', 401, 401);
    }

    return is_array($firstRow) ? $firstRow : [];
}

// Integration helpers (kept modular)
require_once __DIR__ . '/integration/common/request_parser.php';
require_once __DIR__ . '/integration/common/procedure_gateway.php';
require_once __DIR__ . '/integration/common/error_response.php';
require_once __DIR__ . '/integration/common/integration_audit.php';
// CSV normalizers
if (file_exists(__DIR__ . '/integration/csv/normalizers.php')) {
    require_once __DIR__ . '/integration/csv/normalizers.php';
}

$conn = null;

try {
    $method = strtoupper((string)($_SERVER['REQUEST_METHOD'] ?? 'GET'));
    $input = readRequestPayload($method);

    if (!isset($input['action']) || !is_string($input['action'])) {
        throw new ApiException('Отсутствует параметр action.', 400, 400);
    }

    $action = trim($input['action']);
    validateActionName($action);

    $params = $input['params'] ?? [];
    if (!is_array($params)) {
        throw new ApiException('Параметр params должен быть массивом.', 400, 400);
    }

    $paramsOrdered = $input['params_ordered'] ?? [];
    if (!is_array($paramsOrdered)) {
        throw new ApiException('Параметр params_ordered должен быть массивом.', 400, 400);
    }

    $namedParams = isAssociativeArray($params) ? normalizeNamedParams($params) : [];
    $namedParams = mergeTopLevelParams($namedParams, $input);

    // Extract idempotency key (from header or body) to support replay dedupe
    $requestHeaders = getRequestHeadersSafe();
    $idempotencyKey = null;
    foreach ($requestHeaders as $hName => $hValue) {
        if (strcasecmp($hName, 'Idempotency-Key') === 0) {
            $idempotencyKey = is_array($hValue) ? $hValue[0] : $hValue;
            break;
        }
    }
    if (( $idempotencyKey === null || $idempotencyKey === '' ) && isset($input['idempotency_key'])) {
        $idempotencyKey = is_string($input['idempotency_key']) ? $input['idempotency_key'] : null;
    }
    if ($idempotencyKey !== null) {
        $idempotencyKey = trim((string)$idempotencyKey);
        if ($idempotencyKey === '') $idempotencyKey = null;
    }

    // If a cached response exists for this idempotency key, return it without re-executing
    if ($idempotencyKey !== null) {
        $cached = idempotencyCacheGet($idempotencyKey);
        if (is_array($cached)) {
            header('X-Idempotency-Status: replay');
            jsonResponse(true, $cached, 'OK (replayed from idempotency cache)', null, 200);
        }
    }

    $orderedParams = [];
    if (!empty($paramsOrdered)) {
        $orderedParams = array_values($paramsOrdered);
    } elseif (!isAssociativeArray($params)) {
        $orderedParams = array_values($params);
    }

    $publicProcedures = [
        'Авторизация',
        'ВосстановитьПароль',
        'ПодтвердитьВосстановлениеПароля',
        'ПроверитьСессию',
    ];

    $conn = getDBConnection();
    // Special handling for CSV import actions routed through api.php.
    // CSV export actions continue through the generic procedure path.
    $csvImportActions = ['ИмпортГруппИзCSV', 'ИмпортСтудентовИзCSV'];
    if (in_array($action, $csvImportActions, true)) {
        // parse JSON or multipart
        $parsed = integration_parse_json_or_multipart();
        $map = require __DIR__ . '/integration/csv/mapping.php';
        $entry = $map[$action] ?? null;
        if ($entry === null) {
            throw new ApiException('CSV mapping not configured for action: ' . $action, 500, 500);
        }

        // Ensure session validated for non-public actions
        if (!in_array($action, $publicProcedures, true)) {
            [$sessionId, $token] = extractAuthContext($input, $namedParams);
            $sessionRow = validateSessionToken($conn, $sessionId, $token);
        } else {
            $sessionRow = [];
        }

        // Resolve CSV content: prefer uploaded file, then named param
        $csvContent = null;
        $fileName = findFirstParamValue([
            $namedParams,
            is_array($input) ? $input : [],
            is_array($parsed['params'] ?? null) ? $parsed['params'] : [],
        ], ['Имя_Файла', 'file_name', 'filename']) ?? 'upload.csv';

        if (!empty($parsed['files']['file']['tmp_name']) && is_uploaded_file($parsed['files']['file']['tmp_name'])) {
            $csvContent = file_get_contents($parsed['files']['file']['tmp_name']);
            $fileName = $parsed['files']['file']['name'] ?? $fileName;
        } else {
            $csvContent = findFirstParamValue([
                $namedParams,
                is_array($input) ? $input : [],
                is_array($parsed['params'] ?? null) ? $parsed['params'] : [],
            ], ['CSV_Содержимое', 'CSV_Данные', 'csv']);
        }

        if ($csvContent === null) {
            throw new ApiException('CSV content not provided for ' . $action, 400, 400);
        }

        if (function_exists('csv_normalize_content')) {
            $csvContent = csv_normalize_content($csvContent);
        }

        $userId = (int)($sessionRow['Пользователь_ID'] ?? 0);
        if ($userId <= 0) {
            $fallbackUserId = findFirstParamValue([
                $namedParams,
                is_array($input) ? $input : [],
            ], ['Пользователь_ID', 'user_id']);
            $userId = (int)($fallbackUserId ?? 0);
        }
        $ipAddr = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

        $procNamed = [
            'CSV_Содержимое' => $csvContent,
            'Имя_Файла' => $fileName,
            'Пользователь_ID' => $userId,
            'IP_Адрес' => $ipAddr,
        ];

        $res = gateway_call_procedure($conn, 'dbo', $entry['procedure'], $procNamed, []);
        closeDBConnection($conn);
        jsonResponse(true, $res, 'OK', null, 200);
        exit(0);
    }
    ensureProcedureExists($conn, 'dbo', $action);

    if (!in_array($action, $publicProcedures, true)) {
        [$sessionId, $token] = extractAuthContext($input, $namedParams);
        validateSessionToken($conn, $sessionId, $token);
    }

    $procedureParams = getProcedureParameters($conn, 'dbo', $action);
    [$bindings, $outputValues, $outputNameMap, $callArguments] = buildProcedureBindings($procedureParams, $namedParams, $orderedParams);

    $stmt = executeProcedure($conn, 'dbo', $action, $bindings, $callArguments);
    try {
        $allResultSets = fetchAllResultSets($stmt);
    } finally {
        sqlsrv_free_stmt($stmt);
    }

    $responseData = null;
    if (count($allResultSets) === 1) {
        $responseData = $allResultSets[0];
    } elseif (count($allResultSets) > 1) {
        $responseData = $allResultSets;
    }

    if (!empty($outputNameMap)) {
        $outputPayload = [];
        foreach ($outputNameMap as $normalized => $originalName) {
            $outputPayload[$originalName] = normalizeScalarValue($outputValues[$normalized] ?? null);
        }

        if ($responseData === null) {
            $responseData = [];
        }

        $responseData['_output'] = $outputPayload;
    }

    // Save idempotency cache for this response if requested
    if (isset($idempotencyKey) && $idempotencyKey !== null) {
        // try to save cache; ignore failures
        @idempotencyCacheSave($idempotencyKey, $responseData ?? []);
        header('X-Idempotency-Status: stored');
    }

    closeDBConnection($conn);
    $conn = null;

    jsonResponse(true, $responseData, 'OK', null, 200);
} catch (ApiException $e) {
    if ($conn !== null) {
        closeDBConnection($conn);
    }

    jsonResponse(false, null, $e->getMessage(), $e->getApiErrorCode(), $e->getHttpStatus());
} catch (Throwable $e) {
    if ($conn !== null) {
        closeDBConnection($conn);
    }

    $message = DEBUG_MODE
        ? $e->getMessage()
        : 'Внутренняя ошибка сервера. Обратитесь к администратору.';

    jsonResponse(false, null, $message, 500, 500);
}

