<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Главная';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Панель администратора</div>
        <div class="page-sub" id="admin-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" onclick="loadDashboard()">Обновить</button>
    </div>
</div>

<div class="stats-grid stats-grid-admin dashboard-stats">
    <div class="stat-card blue">  <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-users">—</div>    <div class="stat-lbl">Пользователей</div></div>
    <div class="stat-card green"> <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-students">—</div> <div class="stat-lbl">Студентов</div></div>
    <div class="stat-card yellow"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-teachers">—</div> <div class="stat-lbl">Преподавателей</div></div>
    <div class="stat-card purple"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-groups">—</div>   <div class="stat-lbl">Групп</div></div>
    <div class="stat-card red">   <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-lessons">—</div>  <div class="stat-lbl">Занятий сегодня</div></div>
    <div class="stat-card blue">  <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-avg">—</div>      <div class="stat-lbl">Средняя посещаемость</div></div>
</div>

<div class="analytics-grid dashboard-analytics" id="admin-analytics" aria-live="polite"></div>

<div class="grid-2 dashboard-panels">
    <div class="card">
        <div class="card-hdr"><span class="card-title">Журнал действий</span><a href="/ais-system-ru/admin/logs.php" class="btn btn-ghost btn-sm">Все</a></div>
        <div class="card-body" id="logs-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>

    <div class="card">
        <div class="card-hdr"><span class="card-title">Быстрые действия</span></div>
        <div class="card-body quick-action-list">
            <a href="/ais-system-ru/admin/users.php"         class="quick-action">Управление пользователями</a>
            <a href="/ais-system-ru/admin/import-export.php" class="quick-action">Импорт / Экспорт данных</a>
            <a href="/ais-system-ru/admin/reports.php"       class="quick-action">Отчёты системы</a>
            <a href="/ais-system-ru/admin/scheduled-reports.php" class="quick-action">Плановые отчёты</a>
            <a href="/ais-system-ru/admin/backup.php"        class="quick-action">Резервные копии</a>
            <a href="/ais-system-ru/admin/monitoring.php"    class="quick-action">Мониторинг системы</a>
            <a href="/ais-system-ru/admin/maintenance.php"   class="quick-action">Обслуживание</a>
            <a href="/ais-system-ru/admin/reference-data.php" class="quick-action">Справочники</a>
            <a href="/ais-system-ru/admin/settings.php"      class="quick-action">Настройки системы</a>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }
    function num(v) { return window.AISCharts ? window.AISCharts.toNumber(v, 0) : (parseFloat(String(v||0).replace('%','').replace(',','.')) || 0); }
    function show(v) { return v === null || v === undefined || v === '' ? '—' : v; }

    function renderAdminAnalytics(users, students, teachers, groups, lessons, avg) {
        if (!window.AISCharts) return;
        var attendance = num(avg);
        window.AISCharts.render('admin-analytics', [
            {
                type: 'bars',
                title: 'Структура системы',
                subtitle: 'Ключевые объекты без изменения текущих карточек',
                badge: 'обзор',
                unit: '',
                items: [
                    { label: 'Активные пользователи', value: users, tone: 'primary' },
                    { label: 'Студенты', value: students, tone: 'student' },
                    { label: 'Преподаватели', value: teachers, tone: 'teacher' },
                    { label: 'Группы', value: groups, tone: 'methodist' },
                    { label: 'Занятия сегодня', value: lessons, tone: 'warn' }
                ]
            },
            {
                type: 'ring',
                title: 'Операционный индекс',
                subtitle: 'Посещаемость и дневная нагрузка',
                badge: 'сегодня',
                ring: { value: attendance, label: 'посещаемость', tone: window.AISCharts.tone(attendance) },
                metrics: [
                    { label: 'занятий сегодня', value: show(lessons), tone: 'warn' },
                    { label: 'активных групп', value: show(groups), tone: 'methodist' },
                    { label: 'студентов', value: show(students), tone: 'student' },
                    { label: 'преподавателей', value: show(teachers), tone: 'teacher' }
                ]
            }
        ]);
    }

    async function loadDashboard() {
        try {
            document.getElementById('admin-sub').textContent = localStorage.getItem('ais_user_name') || 'Администратор';

            var r = await callAPI('ПолучитьДашбордАдмина', {});
            if (!r || !r.success) return;

            // Разбор multi-result-set: [[summaryRow], [todayStatsRow], [logRows...], [backupRows...]]
            var sets       = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var summary    = (sets[0] && sets[0][0]) ? sets[0][0] : {};
            var todayStats = (sets[1] && sets[1][0]) ? sets[1][0] : {};
            var logsData   = sets[2] || [];
            // sets[3] = резервные копии (не отображается на дашборде)

            var users    = pick(summary,'Пользователей_Активных','Пользователей','users_count');
            var students = pick(summary,'Студентов','students_count');
            var teachers = pick(summary,'Преподавателей','teachers_count');
            var groups   = pick(summary,'Групп_Активных','Групп','groups_count');
            var lessons  = pick(summary,'Занятий_Сегодня','lessons_today');
            var avg      = pick(todayStats,'Процент','Средняя_Посещаемость','avg_attendance');

            if (users    !== null) document.getElementById('stat-users').textContent    = users;
            if (students !== null) document.getElementById('stat-students').textContent = students;
            if (teachers !== null) document.getElementById('stat-teachers').textContent = teachers;
            if (groups   !== null) document.getElementById('stat-groups').textContent   = groups;
            if (lessons  !== null) document.getElementById('stat-lessons').textContent  = lessons;
            if (avg      !== null) document.getElementById('stat-avg').textContent      = Math.round(avg) + '%';

            renderAdminAnalytics(users, students, teachers, groups, lessons, avg);
            renderLogs(logsData.slice(0, 8));

        } catch(e) { console.error(e); }
    }

    function renderLogs(rows) {
        var body = document.getElementById('logs-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="table-empty-sm">Нет записей</div>';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var user   = pick(row,'Пользователь','Логин','user') || '—';
            var action = pick(row,'Действие','action') || '—';
            var time   = pick(row,'Время','Дата_Время','created_at') || '';
            html += '<div class="list-row">';
            html += '<div class="list-main"><strong>' + esc(user) + '</strong><div class="list-meta">' + esc(action) + '</div></div>';
            html += '<span class="list-time">' + esc(time) + '</span>';
            html += '</div>';
        });
        body.innerHTML = html;
    }

    window.loadDashboard = loadDashboard;
    loadDashboard();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

