<?php
declare(strict_types=1);

function aisRoleRoutes(): array {
    return [
        'Admin' => [
            'path' => '/ais-system-ru/admin/dashboard.php',
            'label' => 'Администратор',
            'css' => 'admin',
        ],
        'Методист' => [
            'path' => '/ais-system-ru/methodist/dashboard.php',
            'label' => 'Методист',
            'css' => 'methodist',
        ],
        'Преподаватель' => [
            'path' => '/ais-system-ru/teacher/dashboard.php',
            'label' => 'Преподаватель',
            'css' => 'teacher',
        ],
        'Студент' => [
            'path' => '/ais-system-ru/student/dashboard.php',
            'label' => 'Студент',
            'css' => 'student',
        ],
        'Куратор' => [
            'path' => '/ais-system-ru/curator/dashboard.php',
            'label' => 'Куратор',
            'css' => 'curator',
        ],
    ];
}

function aisNormalizeNavigationRows($data): array {
    if (!is_array($data)) {
        return [];
    }

    if (isset($data[0]) && is_array($data[0]) && isset($data[0][0]) && is_array($data[0][0])) {
        $rows = [];
        foreach ($data as $set) {
            foreach ($set as $row) {
                if (is_array($row)) {
                    $rows[] = $row;
                }
            }
        }
        return $rows;
    }

    return array_values(array_filter($data, static fn($row) => is_array($row)));
}

function aisNavigationPath(array $row): string {
    return (string)($row['Путь'] ?? $row['path'] ?? '');
}

function aisDynamicDashboardPath(array $navigationRows): ?string {
    $fallback = null;
    foreach ($navigationRows as $row) {
        $path = aisNavigationPath($row);
        if ($path === '') {
            continue;
        }
        if ($fallback === null) {
            $fallback = $path;
        }
        if ((int)($row['По_Умолчанию'] ?? 0) === 1) {
            return $path;
        }
    }
    return $fallback;
}

function aisDynamicProfilePath(array $navigationRows): ?string {
    foreach ($navigationRows as $row) {
        $path = aisNavigationPath($row);
        if ($path !== '' && str_ends_with($path, '/profile.php')) {
            return $path;
        }
    }
    return null;
}

function aisRoutedRoles(): array {
    return array_keys(aisRoleRoutes());
}

function aisIsRoutedRole(?string $role): bool {
    if (!is_string($role) || trim($role) === '') {
        return false;
    }
    return array_key_exists($role, aisRoleRoutes());
}

function aisRoleDashboardPath(?string $role): ?string {
    if (!aisIsRoutedRole($role)) {
        return null;
    }

    return aisRoleRoutes()[$role]['path'];
}

function aisRoleProfilePath(?string $role): ?string {
    if (!aisIsRoutedRole($role)) {
        return null;
    }

    return match ($role) {
        'Admin' => '/ais-system-ru/admin/profile.php',
        'Методист' => '/ais-system-ru/methodist/profile.php',
        'Преподаватель' => '/ais-system-ru/teacher/profile.php',
        'Студент' => '/ais-system-ru/student/profile.php',
        'Куратор' => '/ais-system-ru/curator/profile.php',
        default => null,
    };
}

function aisNotificationsPath(): string {
    return '/ais-system-ru/notifications.php';
}

function aisRoleDisplayLabel(?string $role): string {
    if (!aisIsRoutedRole($role)) {
        $role = is_string($role) ? trim($role) : '';
        return $role !== '' ? $role : 'Пользователь';
    }

    return aisRoleRoutes()[$role]['label'];
}

function aisRoleCssClass(?string $role): string {
    if (!aisIsRoutedRole($role)) {
        return 'custom';
    }

    return aisRoleRoutes()[$role]['css'];
}

