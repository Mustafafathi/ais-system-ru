<?php
declare(strict_types=1);
require_once __DIR__ . '/role_helpers.php';

// $currentUser is set by auth_check.php
$role     = $currentUser['Роль'] ?? '';
$fullName = $currentUser['ФИО'] ?? ($currentUser['Имя'] ?? '');
$roleSlug = aisRoleCssClass($role);
$navigationRows = isset($currentNavigation) && is_array($currentNavigation)
    ? aisNormalizeNavigationRows($currentNavigation)
    : [];
$dashboardPath = aisDynamicDashboardPath($navigationRows) ?? aisRoleDashboardPath($role) ?? '/ais-system-ru/';
$profilePath = aisDynamicProfilePath($navigationRows) ?? aisRoleProfilePath($role) ?? $dashboardPath;
$notificationsPath = aisNotificationsPath();

// Build avatar initials (up to 2 chars)
$initials = '';
foreach (explode(' ', trim($fullName)) as $part) {
    if ($part === '') continue;
    $initials .= mb_strtoupper(mb_substr($part, 0, 1, 'UTF-8'), 'UTF-8');
    if (mb_strlen($initials, 'UTF-8') >= 2) break;
}
if ($initials === '') {
    $initials = mb_strtoupper(mb_substr($role, 0, 1, 'UTF-8'), 'UTF-8');
}

// Active link helper
function navItem(string $href, string $iconClass, string $label, ?string $badge = null): void
{
    $current = $_SERVER['PHP_SELF'] ?? '';
    $currentPath = parse_url($current, PHP_URL_PATH) ?: $current;
    $hrefPath = parse_url($href, PHP_URL_PATH) ?: $href;
    $active  = ($currentPath === $hrefPath) ? ' active' : '';
    $safeHref = htmlspecialchars($href, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $safeLabel = htmlspecialchars($label, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $safeBadgeText = $badge !== null ? htmlspecialchars($badge, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') : null;
    $badgeHtml = $safeBadgeText !== null ? "<span class=\"nav-badge\">{$safeBadgeText}</span>" : '';
    $safeIcon = preg_replace('/[^a-zA-Z0-9_-]/', '', $iconClass) ?: 'settings';
    echo "<a class=\"nav-item{$active}\" href=\"{$safeHref}\"><span class=\"nav-icon icon-{$safeIcon}\" aria-hidden=\"true\"></span>{$safeLabel}{$badgeHtml}</a>\n";
}
?>
<nav class="navbar">
    <a class="brand-icon" href="<?= htmlspecialchars($dashboardPath) ?>" title="На главную" aria-label="На главную">
        <img src="/ais-system-ru/assets/images/misis-logo.png" alt="МИСИС">
    </a>
    <a class="navbar-brand" href="<?= htmlspecialchars($dashboardPath) ?>" title="На главную">
        <div>
            <span class="brand-title">Система посещаемости</span>
            <span class="brand-sub">СТИ НИТУ «МИСИС»</span>
        </div>
    </a>
    <div class="navbar-spacer"></div>
    <div class="navbar-right">
        <a href="<?= htmlspecialchars($notificationsPath) ?>" class="notif-btn" title="Уведомления" aria-label="Уведомления"><span class="notif-dot" id="notif-dot" style="display:none"></span></a>
        <a class="user-chip" href="<?= htmlspecialchars($profilePath) ?>" title="Профиль" aria-label="Открыть профиль">
            <div class="avatar" id="nav-avatar"><?= htmlspecialchars($initials) ?></div>
            <div>
                <div class="user-name" id="nav-username"><?= htmlspecialchars($fullName ?: 'Пользователь') ?></div>
                <span class="role-tag role-<?= htmlspecialchars($roleSlug) ?>"><?= htmlspecialchars(aisRoleDisplayLabel($role)) ?></span>
            </div>
        </a>
    </div>
</nav>

<div class="app-body">
<aside class="sidebar">

<?php if (!empty($navigationRows)): ?>
    <?php
    $groupedNavigation = [];
    foreach ($navigationRows as $row) {
        $group = (string)($row['Группа'] ?? $row['Группа_Меню'] ?? 'Навигация');
        $groupedNavigation[$group][] = $row;
    }
    ?>
    <?php foreach ($groupedNavigation as $group => $items): ?>
        <div class="sidebar-section">
            <div class="sidebar-section-label"><?= htmlspecialchars($group) ?></div>
            <?php foreach ($items as $item): ?>
                <?php
                $href = aisNavigationPath($item);
                if ($href === '') {
                    continue;
                }
                navItem(
                    $href,
                    (string)($item['Иконка'] ?? 'settings'),
                    (string)($item['Заголовок'] ?? $href)
                );
                ?>
            <?php endforeach; ?>
        </div>
    <?php endforeach; ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Сеанс</div>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>

<?php elseif ($role === 'Студент'): ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Главное</div>
        <?php navItem('/ais-system-ru/student/dashboard.php',       'home', 'Главная'); ?>
        <?php navItem('/ais-system-ru/student/schedule.php',        'calendar', 'Расписание'); ?>
        <?php navItem('/ais-system-ru/student/attendance.php',      'attendance', 'Посещаемость'); ?>
        <?php navItem('/ais-system-ru/student/qr-scanner.php',      'qr', 'QR-сканер'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Заявки</div>
        <?php navItem('/ais-system-ru/student/excuses.php',         'note', 'Мои обоснования'); ?>
        <?php navItem('/ais-system-ru/student/notifications.php',   'bell', 'Уведомления'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Аккаунт</div>
        <?php navItem('/ais-system-ru/student/profile.php',         'user', 'Профиль'); ?>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>

<?php elseif ($role === 'Преподаватель'): ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Главное</div>
        <?php navItem('/ais-system-ru/teacher/dashboard.php',            'home', 'Главная'); ?>
        <?php navItem('/ais-system-ru/teacher/schedule.php',             'calendar', 'Моё расписание'); ?>
        <?php navItem('/ais-system-ru/teacher/attendance-journal.php',   'attendance', 'Отметить посещаемость'); ?>
        <?php navItem('/ais-system-ru/teacher/qr-generator.php',        'qr', 'QR-генератор'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Отчёты</div>
        <?php navItem('/ais-system-ru/teacher/reports.php',  'report', 'Отчёты по группам'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Аккаунт</div>
        <?php navItem('/ais-system-ru/teacher/profile.php',  'user', 'Профиль'); ?>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>

<?php elseif ($role === 'Куратор'): ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Мониторинг</div>
        <?php navItem('/ais-system-ru/curator/dashboard.php',  'home', 'Главная'); ?>
        <?php navItem('/ais-system-ru/curator/students.php',   'group', 'Студенты группы'); ?>
        <?php navItem('/ais-system-ru/curator/schedule.php',   'calendar', 'Расписание'); ?>
        <?php navItem('/ais-system-ru/curator/excuses.php',    'note', 'Обоснования'); ?>
        <?php navItem('/ais-system-ru/curator/reports.php',    'report', 'Отчёты'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Аккаунт</div>
        <?php navItem('/ais-system-ru/curator/profile.php',    'user', 'Профиль'); ?>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>

<?php elseif ($role === 'Методист'): ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Управление</div>
        <?php navItem('/ais-system-ru/methodist/dashboard.php',  'home', 'Главная'); ?>
        <?php navItem('/ais-system-ru/methodist/groups.php',     'group', 'Группы'); ?>
        <?php navItem('/ais-system-ru/methodist/subjects.php',   'book', 'Дисциплины'); ?>
        <?php navItem('/ais-system-ru/methodist/schedule.php',   'calendar', 'Расписание'); ?>
        <?php navItem('/ais-system-ru/methodist/teachers.php',   'user', 'Преподаватели'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Аккаунт</div>
        <?php navItem('/ais-system-ru/methodist/profile.php',    'user', 'Профиль'); ?>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>

<?php elseif ($role === 'Admin'): ?>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Дашборд</div>
        <?php navItem('/ais-system-ru/admin/dashboard.php',      'home', 'Главная'); ?>
        <?php navItem('/ais-system-ru/admin/control-plane.php',  'monitoring', 'Центр управления'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Пользователи</div>
        <?php navItem('/ais-system-ru/admin/users.php',          'user', 'Пользователи'); ?>
        <?php navItem('/ais-system-ru/admin/students.php',       'group', 'Студенты'); ?>
        <?php navItem('/ais-system-ru/admin/teachers.php',       'user', 'Преподаватели'); ?>
        <?php navItem('/ais-system-ru/admin/groups.php',         'group', 'Группы'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Отчёты и данные</div>
        <?php navItem('/ais-system-ru/admin/schedule.php',      'calendar', 'Расписание'); ?>
        <?php navItem('/ais-system-ru/admin/reports.php',        'report', 'Отчёты'); ?>
        <?php navItem('/ais-system-ru/admin/scheduled-reports.php', 'report', 'Плановые отчёты'); ?>
        <?php navItem('/ais-system-ru/admin/import-export.php',  'import', 'Импорт / Экспорт'); ?>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-label">Система</div>
        <?php navItem('/ais-system-ru/admin/monitoring.php',     'monitoring', 'Мониторинг'); ?>
        <?php navItem('/ais-system-ru/admin/maintenance.php',    'settings', 'Обслуживание'); ?>
        <?php navItem('/ais-system-ru/admin/reference-data.php', 'book', 'Справочники'); ?>
        <?php navItem('/ais-system-ru/admin/settings.php',       'settings', 'Настройки'); ?>
        <?php navItem('/ais-system-ru/admin/logs.php',           'log', 'Журнал действий'); ?>
        <?php navItem('/ais-system-ru/admin/backup.php',         'backup', 'Резервные копии'); ?>
        <?php navItem('/ais-system-ru/admin/profile.php',        'user', 'Профиль'); ?>
        <a class="nav-item" href="/ais-system-ru/login/index.php" onclick="if(typeof logout==='function'){logout();return false;}"><span class="nav-icon icon-logout" aria-hidden="true"></span>Выйти</a>
    </div>
<?php endif; ?>

</aside>
<main class="app-main" id="main">

