<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Методист');
$page_title = 'Главная';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Кабинет методиста</div>
        <div class="page-sub" id="meth-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" onclick="loadDashboard()">Обновить</button>
    </div>
</div>

<div class="stats-grid">
    <div class="stat-card blue">  <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-groups">—</div>  <div class="stat-lbl">Групп</div></div>
    <div class="stat-card green"> <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-subjects">—</div><div class="stat-lbl">Дисциплин</div></div>
    <div class="stat-card yellow"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-teachers">—</div><div class="stat-lbl">Преподавателей</div></div>
    <div class="stat-card purple"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-schedules">—</div><div class="stat-lbl">Записей расписания</div></div>
</div>

<div class="analytics-grid dashboard-analytics" id="methodist-analytics" aria-live="polite"></div>

<div class="grid-2">
    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Учебные группы</span>
            <a href="/ais-system-ru/methodist/groups.php" class="btn btn-ghost btn-sm">Все</a>
        </div>
        <div class="card-body" id="groups-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>

    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Преподаватели</span>
            <a href="/ais-system-ru/methodist/teachers.php" class="btn btn-ghost btn-sm">Все</a>
        </div>
        <div class="card-body" id="teachers-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }
    function num(v) { return window.AISCharts ? window.AISCharts.toNumber(v, 0) : (parseFloat(String(v||0).replace('%','').replace(',','.')) || 0); }

    function renderMethodistAnalytics(groups, subjects, teachers, schedules, topGroups) {
        if (!window.AISCharts) return;
        var groupBars = (topGroups || []).slice(0, 6).map(function(row) {
            var name = pick(row,'Группа','Название_Группы','Название') || '—';
            var count = pick(row,'Студентов','Кол_Студентов','КоличествоСтудентов') || 0;
            return { label: name, value: count, tone: 'student' };
        });

        window.AISCharts.render('methodist-analytics', [
            {
                type: 'bars',
                title: 'Учебная структура',
                subtitle: 'Соотношение справочников и расписания',
                badge: 'обзор',
                items: [
                    { label: 'Группы', value: groups, tone: 'methodist' },
                    { label: 'Дисциплины', value: subjects, tone: 'ok' },
                    { label: 'Преподаватели', value: teachers, tone: 'teacher' },
                    { label: 'Записи расписания', value: schedules, tone: 'warn' }
                ]
            },
            {
                type: 'bars',
                title: 'Группы по численности',
                subtitle: 'График использует текущую выборку дашборда',
                badge: 'до 6',
                items: groupBars
            }
        ]);
    }

    async function loadDashboard() {
        try {
            var sess = await callAPI('ПроверитьСессию', {});
            if (sess && sess.success && sess.data && sess.data[0]) {
                var name = pick(sess.data[0],'ФИО','Имя','ФИО_Преподавателя','Логин') || localStorage.getItem('ais_user_name') || '';
                document.getElementById('meth-sub').textContent = name || 'Информация загружена';
            }

            var r = await callAPI('ПолучитьДашбордМетодиста', {});
            if (!r || !r.success) return;

            // Разбор multi-result-set: [[summaryRow], [todayRows...], [topGroupRows...]]
            var sets        = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var summary     = (sets[0] && sets[0][0]) ? sets[0][0] : {};
            var todayClasses = sets[1] || [];
            var topGroups    = sets[2] || [];

            var groups    = pick(summary,'Групп','Кол_Групп','groups_count');
            var subjects  = pick(summary,'Дисциплин','Кол_Дисциплин','subjects_count');
            var teachers  = pick(summary,'Преподавателей','Кол_Преподавателей','teachers_count');
            var schedules = pick(summary,'Занятий_Сегодня','Расписаний','Кол_Расписаний','schedule_count');

            if (groups    !== null) document.getElementById('stat-groups').textContent    = groups;
            if (subjects  !== null) document.getElementById('stat-subjects').textContent  = subjects;
            if (teachers  !== null) document.getElementById('stat-teachers').textContent  = teachers;
            if (schedules !== null) document.getElementById('stat-schedules').textContent = schedules;

            // RS3 = топ групп (Группа + Процент), RS2 = занятия сегодня (Преподаватель + Дисциплина)
            renderMethodistAnalytics(groups, subjects, teachers, schedules, topGroups);
            renderGroups(topGroups.slice(0, 5));
            renderTeachers(todayClasses.slice(0, 5));

        } catch(e) { console.error(e); }
    }

    function renderGroups(rows) {
        var body = document.getElementById('groups-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="empty-state"><div class="empty-icon">G</div><div class="empty-title">Нет групп</div></div>';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var name  = pick(row,'Группа','Название_Группы','Название') || '—';
            var count = pick(row,'Студентов','Кол_Студентов','КоличествоСтудентов') || 0;
            html += '<div class="list-row">';
            html += '<div class="list-main"><strong>' + esc(name) + '</strong></div>';
            html += '<span class="tag">' + count + ' студ.</span></div>';
        });
        body.innerHTML = html;
    }

    function renderTeachers(rows) {
        var body = document.getElementById('teachers-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="empty-state"><div class="empty-icon">T</div><div class="empty-title">Нет данных</div></div>';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var fio  = pick(row,'ФИО','Имя','Преподаватель','ФИО_Преподавателя') || '—';
            var dept = pick(row,'Кафедра','Подразделение') || '';
            html += '<div class="list-row">';
            html += '<div class="list-main"><strong>' + esc(fio) + '</strong>' + (dept ? '<div class="list-meta">' + esc(dept) + '</div>' : '') + '</div>';
            html += '</div>';
        });
        body.innerHTML = html;
    }

    loadDashboard();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

