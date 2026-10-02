<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'Главная';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Кабинет преподавателя</div>
        <div class="page-sub" id="teacher-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" onclick="loadDashboard()">Обновить</button>
    </div>
</div>

<div class="stats-grid">
    <div class="stat-card blue"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-groups">—</div><div class="stat-lbl">Групп</div><div class="stat-sub">В нагрузке</div></div>
    <div class="stat-card green"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-subjects">—</div><div class="stat-lbl">Дисциплины</div></div>
    <div class="stat-card yellow"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-today">—</div><div class="stat-lbl">Занятий сегодня</div></div>
    <div class="stat-card purple"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val">QR/СКУД</div><div class="stat-lbl">Автоотметка</div><div class="stat-sub">Источник виден в журнале</div></div>
</div>

<div class="analytics-grid dashboard-analytics" id="teacher-analytics" aria-live="polite"></div>

<div class="grid-2">
    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Сегодняшние занятия</span>
            <span class="badge b-primary" id="today-date"></span>
        </div>
        <div class="card-body panel-flush">
            <div class="alert alert-info panel-loading" id="today-loading">Загрузка...</div>
            <table style="display:none" id="today-table">
                <tbody id="today-tbody"></tbody>
            </table>
            <div class="empty-state" id="today-empty" style="display:none">
                <div class="empty-icon">OK</div>
                <div class="empty-title">Нет занятий сегодня</div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-hdr"><span class="card-title">Посещаемость по группам</span></div>
        <div class="card-body" id="groups-body">
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
    function show(v) { return v === null || v === undefined || v === '' ? '—' : v; }

    function renderTeacherAnalytics(groups, subjects, today, groupRows) {
        if (!window.AISCharts) return;
        var groupBars = (groupRows || []).slice(0, 6).map(function(row) {
            var name = pick(row,'Группа','Название_Группы') || '—';
            var pct = num(pick(row,'Процент','Посещаемость_Процент'));
            return { label: name, value: pct, unit: '%', tone: window.AISCharts.tone(pct) };
        });
        var avg = groupBars.length
            ? groupBars.reduce(function(sum, item){ return sum + num(item.value); }, 0) / groupBars.length
            : 0;

        window.AISCharts.render('teacher-analytics', [
            {
                type: 'ring',
                title: 'Посещаемость групп',
                subtitle: 'Средний показатель по доступным группам',
                badge: 'среднее',
                ring: { value: avg, label: 'по группам', tone: window.AISCharts.tone(avg) },
                metrics: [
                    { label: 'групп в нагрузке', value: show(groups), tone: 'primary' },
                    { label: 'дисциплин', value: show(subjects), tone: 'teacher' },
                    { label: 'занятий сегодня', value: show(today), tone: 'warn' },
                    { label: 'канал отметки', value: 'QR/СКУД', tone: 'info' }
                ]
            },
            {
                type: 'bars',
                title: 'Группы по посещаемости',
                subtitle: 'График повторяет данные текущего дашборда',
                badge: 'до 6',
                unit: '%',
                max: 100,
                items: groupBars
            }
        ]);
    }

    function statusBadge(s) {
        s = String(s||'').toLowerCase();
        if (s.includes('идёт') || s.includes('active') || s.includes('актив')) return '<span class="badge b-warn">Идёт сейчас</span>';
        if (s.includes('провед') || s.includes('заверш') || s.includes('completed')) return '<span class="badge b-ok">Завершено</span>';
        if (s.includes('заплан') || s.includes('scheduled')) return '<span class="badge b-muted">Запланировано</span>';
        if (s.includes('отмен') || s.includes('cancel')) return '<span class="badge b-err">Отменено</span>';
        if (s.includes('перенес') || s.includes('перемещ') || s.includes('moved')) return '<span class="badge b-warn">Перенесено</span>';
        return '<span class="badge b-muted">' + esc(s) + '</span>';
    }

    async function loadDashboard() {
        try {
            var teacherId = parseInt(localStorage.getItem('ais_teacher_id')||'0', 10);
            if (!teacherId) {
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    teacherId = pick(sess.data[0], 'Преподаватель_ID', 'teacher_id') || 0;
                    if (teacherId) localStorage.setItem('ais_teacher_id', teacherId);
                }
            }

            var params = teacherId ? { Преподаватель_ID: teacherId } : {};
            var r = await callAPI('ПолучитьДашбордПреподавателя', params);

            if (!r || !r.success) return;

            // Разбор multi-result-set: [[statRow], [schedRows...], [groupRows...]]
            var sets       = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var d          = (sets[0] && sets[0][0]) ? sets[0][0] : {};
            var schedule   = sets[1] || [];
            var groupsData = sets[2] || [];

            var name = pick(d,'ФИО','Имя','ФИО_Преподавателя') || localStorage.getItem('ais_user_name') || '';
            document.getElementById('teacher-sub').textContent = name || 'Информация загружена';

            var groups   = pick(d,'Количество_Групп','Группы_Кол','groups_count');
            var subjects = pick(d,'Количество_Дисциплин','Дисциплины_Кол');
            var today    = pick(d,'Занятий_Сегодня','today_count');

            if (groups   !== null) document.getElementById('stat-groups').textContent   = groups;
            if (subjects !== null) document.getElementById('stat-subjects').textContent = subjects;
            if (today    !== null) document.getElementById('stat-today').textContent    = today;

            // Date label
            var now = new Date();
            document.getElementById('today-date').textContent = now.toLocaleDateString('ru-RU', {day:'numeric', month:'long'});

            renderTeacherAnalytics(groups, subjects, today, groupsData);
            renderTodaySchedule(schedule);
            renderGroups(groupsData);

        } catch(err) { console.error(err); }
    }

    function renderTodaySchedule(rows) {
        var loading = document.getElementById('today-loading');
        var table   = document.getElementById('today-table');
        var tbody   = document.getElementById('today-tbody');
        var empty   = document.getElementById('today-empty');

        loading.style.display = 'none';
        if (!rows || rows.length === 0) { empty.style.display = 'block'; return; }

        var html = '';
        rows.forEach(function(row) {
            var time   = pick(row,'Время_Начала','Время') || '';
            var subj   = pick(row,'Дисциплина','Название_Дисциплины') || '';
            var group  = pick(row,'Группа','Название_Группы','Название') || '';
            var room   = pick(row,'Аудитория','Кабинет') || '';
            var status = pick(row,'Статус','status') || '';
            var zid    = pick(row,'Занятие_ID','id') || '';
            var gid    = pick(row,'Группа_ID','group_id') || '';
            var today  = new Date().toISOString().slice(0, 10);

            html += '<tr>';
            html += '<td><strong>' + esc(time) + '</strong></td>';
            html += '<td><strong>' + esc(subj) + '</strong>' + (group ? ' · ' + esc(group) : '') + (room ? '<br><span class="text-muted text-sm">ауд. ' + esc(room) + '</span>' : '') + '</td>';
            html += '<td>' + statusBadge(status) + '</td>';
            html += '<td>';
            if (zid) {
                var statusText = status.toLowerCase();
                var isScheduled = status && (statusText.includes('заплан') || statusText.includes('active') || statusText.includes('актив') || statusText.includes('идёт'));
                if (isScheduled) {
                    html += '<a href="/ais-system-ru/teacher/qr-generator.php?z=' + esc(zid) + '" class="btn btn-primary btn-sm">QR</a> ';
                    html += '<a href="/ais-system-ru/teacher/attendance-journal.php?z=' + esc(zid) + '" class="btn btn-ghost btn-sm">Журнал</a>';
                } else {
                    html += '<a href="/ais-system-ru/teacher/attendance-journal.php?z=' + esc(zid) + '" class="btn btn-ghost btn-sm">Журнал</a>';
                }
                html += ' <a href="/ais-system-ru/teacher/reports.php' + (gid ? '?group=' + esc(gid) + '&from=' + today + '&to=' + today : '') + '" class="btn btn-outline btn-sm">Отчёт</a>';
            }
            html += '</td></tr>';
        });

        tbody.innerHTML = html;
        table.style.display = '';
    }

    function renderGroups(rows) {
        var body = document.getElementById('groups-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="empty-state"><div class="empty-icon">G</div><div class="empty-title">Нет данных о группах</div></div>';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var name = pick(row,'Группа','Название_Группы') || '';
            var pct  = parseFloat(pick(row,'Процент','Посещаемость_Процент') || 0);
            var color = attendanceColor(pct);
            var textClass = window.AIS && typeof window.AIS.attendanceTextClass === 'function' ? window.AIS.attendanceTextClass(pct) : '';
            html += '<div class="prog-wrap">';
            html += '<div class="prog-row"><span>' + esc(name) + '</span><span class="font-semibold ' + textClass + '">' + Math.round(pct) + '%</span></div>';
            html += '<div class="prog"><div class="prog-bar ' + color + '" style="width:' + Math.min(pct,100) + '%"></div></div>';
            html += '</div>';
        });
        body.innerHTML = html;
    }

    window.loadDashboard = loadDashboard;
    window.addEventListener('storage', function(event) {
        if (event.key === 'ais_schedule_changed_at') {
            loadDashboard();
        }
    });
    window.addEventListener('focus', function() {
        var changedAt = parseInt(localStorage.getItem('ais_schedule_changed_at') || '0', 10);
        if (changedAt && Date.now() - changedAt < 5 * 60 * 1000) {
            loadDashboard();
        }
    });

    loadDashboard();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

