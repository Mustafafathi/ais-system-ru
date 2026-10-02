<?php
declare(strict_types=1);

// Lightweight procedure gateway used by integration endpoints.
// Keeps transport handling thin and maps HTTP inputs to DB procedure params.

function gateway_call_procedure($conn, string $schema, string $procedureName, array $namedParams = [], array $orderedParams = []) {
    // Reuse local helpers if available, otherwise reimplement minimal binding flow.
    if (function_exists('getProcedureParameters')) {
        $procedureParams = getProcedureParameters($conn, $schema, $procedureName);
        [$bindings, $outputValues, $outputNameMap, $callArguments] = buildProcedureBindings($procedureParams, $namedParams, $orderedParams);
        $stmt = executeProcedure($conn, $schema, $procedureName, $bindings, $callArguments);
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

        return $responseData;
    }

    $procedureParams = gateway_get_procedure_parameters($conn, $schema, $procedureName);
    [$bindings, $callArguments] = gateway_build_procedure_bindings($procedureParams, $namedParams, $orderedParams);

    $safeSchema = str_replace(']', ']]', $schema);
    $safeProcedure = str_replace(']', ']]', $procedureName);
    $qualified = sprintf('[%s].[%s]', $safeSchema, $safeProcedure);
    $sql = 'EXEC ' . $qualified . (empty($callArguments) ? '' : ' ' . implode(', ', $callArguments));

    if (empty($procedureParams) && !empty($orderedParams)) {
        $placeholders = implode(', ', array_fill(0, count($orderedParams), '?'));
        $sql = '{CALL ' . $qualified . ($placeholders ? "($placeholders)" : '') . '}';
        $bindings = [];
        foreach ($orderedParams as $p) {
            $bindings[] = [$p, SQLSRV_PARAM_IN];
        }
    }

    $stmt = sqlsrv_prepare($conn, $sql, $bindings);
    if ($stmt === false) {
        throw new RuntimeException('Gateway: prepare failed: ' . getSqlsrvErrorsText());
    }

    if (!sqlsrv_execute($stmt)) {
        $err = getSqlsrvErrorsText();
        sqlsrv_free_stmt($stmt);
        throw new RuntimeException('Gateway: execute failed: ' . $err);
    }

    try {
        $rows = [];
        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            foreach ($row as $k => $v) $row[$k] = normalizeScalarValue($v);
            $rows[] = $row;
        }
    } finally {
        sqlsrv_free_stmt($stmt);
    }

    return $rows;
}

function gateway_normalize_param_key(string $name): string {
    $name = ltrim(trim($name), '@');
    if ($name === '') {
        return '';
    }
    return function_exists('mb_strtolower') ? mb_strtolower($name, 'UTF-8') : strtolower($name);
}

function gateway_get_procedure_parameters($conn, string $schema, string $procedureName): array {
    $sql = "
        SELECT PARAMETER_NAME, ORDINAL_POSITION, PARAMETER_MODE
        FROM INFORMATION_SCHEMA.PARAMETERS
        WHERE SPECIFIC_SCHEMA = ?
          AND SPECIFIC_NAME = ?
        ORDER BY ORDINAL_POSITION
    ";

    $stmt = sqlsrv_query($conn, $sql, [$schema, $procedureName]);
    if ($stmt === false) {
        throw new RuntimeException('Gateway: parameter lookup failed: ' . getSqlsrvErrorsText());
    }

    $rows = [];
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $rows[] = $row;
    }
    sqlsrv_free_stmt($stmt);

    return $rows;
}

function gateway_build_procedure_bindings(array $procedureParams, array $namedParams, array $orderedParams): array {
    $normalized = [];
    foreach ($namedParams as $key => $value) {
        if (is_string($key)) {
            $normalized[gateway_normalize_param_key($key)] = $value;
        }
    }

    $bindings = [];
    $callArguments = [];
    $orderedIndex = 0;
    $orderedCount = count($orderedParams);

    foreach ($procedureParams as $paramMeta) {
        $rawName = (string)($paramMeta['PARAMETER_NAME'] ?? '');
        $cleanName = ltrim($rawName, '@');
        if ($cleanName === '') {
            continue;
        }

        $mode = strtoupper((string)($paramMeta['PARAMETER_MODE'] ?? 'IN'));
        if ($mode === 'OUT') {
            continue;
        }

        $normName = gateway_normalize_param_key($cleanName);
        if (array_key_exists($normName, $normalized)) {
            $bindings[] = [$normalized[$normName], SQLSRV_PARAM_IN];
            $callArguments[] = '@' . $cleanName . ' = ?';
            continue;
        }

        if ($orderedIndex < $orderedCount) {
            $bindings[] = [$orderedParams[$orderedIndex++], SQLSRV_PARAM_IN];
            $callArguments[] = '@' . $cleanName . ' = ?';
        }
    }

    return [$bindings, $callArguments];
}

