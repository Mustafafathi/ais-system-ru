<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Куратор');
$page_title = 'Главная';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Кабинет куратора</div>
        <div class="page-sub" id="curator-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-auto" id="group-select">
            <option value="">Все группы</option>
        </select>
        <button class="btn btn-outline btn-sm" onclick="loadDashboard()">Обновить</button>
    </div>
</div>

<div class="stats-grid">
    <div class="stat-card blue">  <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-total">—</div><div class="stat-lbl">Студентов</div><div class="stat-sub">В группе</div></div>
    <div class="stat-card green"> <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-avg">—</div>  <div class="stat-lbl">Средняя посещаемость</div></div>
    <div class="stat-card yellow"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-risk">—</div> <div class="stat-lbl">В зоне риска</div><div class="stat-sub">Ниже 70%</div></div>
    <div class="stat-card red">   <div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-crit">—</div> <div class="stat-lbl">Критично</div><div class="stat-sub">Ниже 50%</div></div>
</div>

<div class="analytics-grid dashboard-analytics" id="curator-analytics" aria-live="polite"></div>

<div class="card mb-4">
    <div class="card-hdr"><span class="card-title">Переходы по выбранной группе</span></div>
    <div class="card-body">
        <div class="quick-action-list">
            <a class="quick-action" href="/ais-system-ru/curator/students.php" id="quick-students-link">Студенты</a>
            <a class="quick-action" href="/ais-system-ru/curator/excuses.php" id="quick-excuses-link">Обоснования</a>
            <a class="quick-action" href="/ais-system-ru/curator/schedule.php" id="quick-schedule-link">Расписание</a>
            <a class="quick-action" href="/ais-system-ru/curator/reports.php" id="quick-reports-link">Отчёты</a>
        </div>
    </div>
</div>

<div class="grid-2">
    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Студенты в зоне риска</span>
            <a href="/ais-system-ru/curator/students.php" class="btn btn-ghost btn-sm" id="students-link">Все студенты</a>
        </div>
        <div class="card-body panel-flush">
            <div class="alert alert-info panel-loading" id="risk-loading">Загрузка...</div>
            <table style="display:none" id="risk-table">
                <thead><tr><th>Студент</th><th>Посещаемость</th><th>Статус</th></tr></thead>
                <tbody id="risk-tbody"></tbody>
            </table>
            <div class="empty-state" id="risk-empty" style="display:none">
                <div class="empty-icon">OK</div>
                <div class="empty-title">Все студенты в норме</div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Ожидающие обоснования</span>
            <a href="/ais-system-ru/curator/excuses.php" class="btn btn-ghost btn-sm" id="excuses-link">Все заявки</a>
        </div>
        <div class="card-body" id="excuses-body">
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
    var curatorGroups = [];

    function renderCuratorAnalytics(total, avg, risk, crit, groupsList) {
        if (!window.AISCharts) return;
        var totalN = num(total);
        var riskN = num(risk);
        var critN = num(crit);
        var normalN = Math.max(totalN - riskN, 0);
        var riskOnlyN = Math.max(riskN - critN, 0);
        var groupBars = (groupsList || []).slice(0, 6).map(function(row) {
            var name = pick(row,'Группа','Название_Группы','Название') || '—';
            var pct = num(pick(row,'Процент','Посещаемость_Процент'));
            return { label: name, value: pct, unit: '%', tone: window.AISCharts.tone(pct) };
        });

        var cards = [
            {
                type: 'ring',
                title: 'Индекс группы',
                subtitle: 'Средняя посещаемость по выбранному контексту',
                badge: 'контроль',
                ring: { value: avg || 0, label: 'средняя', tone: window.AISCharts.tone(avg || 0) },
                metrics: [
                    { label: 'студентов', value: show(total), tone: 'student' },
                    { label: 'в зоне риска', value: show(risk), tone: 'warn' },
                    { label: 'критично', value: show(crit), tone: 'err' },
                    { label: 'групп в срезе', value: (groupsList || []).length, tone: 'curator' }
                ]
            },
            {
                type: 'stack',
                title: 'Риск студентов',
                subtitle: 'Распределение по текущим карточкам',
                badge: 'статус',
                segments: [
                    { label: 'Норма', value: normalN, tone: 'ok' },
                    { label: 'Риск', value: riskOnlyN, tone: 'warn' },
                    { label: 'Критично', value: critN, tone: 'err' }
                ]
            }
        ];
        if (groupBars.length) {
            cards.push({
                type: 'bars',
                title: 'Группы по посещаемости',
                subtitle: 'Сравнение выбранных групп',
                badge: 'до 6',
                unit: '%',
                max: 100,
                items: groupBars
            });
        }
        window.AISCharts.render('curator-analytics', cards);
    }

    async function resolveCuratorId() {
        var curatorId = parseInt(localStorage.getItem('ais_curator_id') || localStorage.getItem('ais_teacher_id') || '0', 10);
        var sess = await callAPI('ПроверитьСессию', {});
        if (sess && sess.success && sess.data && sess.data[0]) {
            curatorId = pick(sess.data[0], 'Куратор_ID', 'curator_id', 'Преподаватель_ID', 'teacher_id') || curatorId || 0;
            var userId = pick(sess.data[0], 'Пользователь_ID', 'user_id');
            var name = pick(sess.data[0], 'ФИО', 'Имя') || localStorage.getItem('ais_user_name') || '';
            document.getElementById('curator-sub').textContent = name || 'Информация загружена';
            if (curatorId) {
                localStorage.setItem('ais_curator_id', curatorId);
                localStorage.setItem('ais_teacher_id', curatorId);
            }
            if (userId) localStorage.setItem('ais_user_id', userId);
        }
        return parseInt(curatorId || '0', 10);
    }

    async function loadGroups(curatorId) {
        var sel = document.getElementById('group-select');
        if (!curatorId) {
            sel.innerHTML = '<option value="">Группы недоступны</option>';
            return [];
        }
        var r = await callAPI('ПолучитьГруппыКуратора', { Куратор_ID: curatorId }).catch(function(){ return null; });
        curatorGroups = r && r.success && Array.isArray(r.data) ? r.data : [];
        var current = sel.value;
        sel.innerHTML = '<option value="">Все группы</option>' + curatorGroups.map(function(row) {
            var id = pick(row,'Группа_ID') || '';
            var name = pick(row,'Название','Группа','Название_Группы') || id;
            return '<option value="' + esc(id) + '">' + esc(name) + '</option>';
        }).join('');
        if (current) sel.value = current;
        return curatorGroups;
    }

    function selectedGroupId() {
        return document.getElementById('group-select').value || '';
    }

    function updateContextLinks() {
        var group = selectedGroupId();
        var suffix = group ? '?group=' + encodeURIComponent(group) : '';
        document.getElementById('students-link').href = '/ais-system-ru/curator/students.php' + suffix;
        document.getElementById('excuses-link').href = '/ais-system-ru/curator/excuses.php' + suffix;
        document.getElementById('quick-students-link').href = '/ais-system-ru/curator/students.php' + suffix;
        document.getElementById('quick-excuses-link').href = '/ais-system-ru/curator/excuses.php' + suffix;
        document.getElementById('quick-schedule-link').href = '/ais-system-ru/curator/schedule.php' + suffix;
        document.getElementById('quick-reports-link').href = '/ais-system-ru/curator/reports.php' + suffix;
    }

    function showBlocked(message) {
        document.getElementById('curator-sub').textContent = 'Профиль куратора недоступен';
        document.getElementById('risk-loading').style.display = 'none';
        document.getElementById('risk-empty').style.display = 'flex';
        document.getElementById('risk-table').style.display = 'none';
        document.getElementById('excuses-body').innerHTML = '<div class="alert alert-warn">' + esc(message) + '</div>';
    }

    async function loadDashboard() {
        try {
            document.getElementById('risk-loading').style.display = 'flex';
            document.getElementById('risk-empty').style.display = 'none';
            document.getElementById('risk-table').style.display = 'none';
            document.getElementById('excuses-body').innerHTML = '<div class="alert alert-info">Загрузка...</div>';

            var curatorId = await resolveCuratorId();
            if (!curatorId) {
                showBlocked('Сессия активна, но backend не вернул идентификатор куратора. Проверьте привязку пользователя к преподавателю-куратору.');
                return;
            }
            await loadGroups(curatorId);
            var params = curatorId ? { Куратор_ID: curatorId } : {};
            var r = await callAPI('ПолучитьДашбордКуратора', params);
            if (!r || !r.success) {
                document.getElementById('risk-loading').style.display = 'none';
                document.getElementById('excuses-body').innerHTML = '<div class="alert alert-err">' + esc(r && r.message ? r.message : 'Ошибка загрузки') + '</div>';
                return;
            }

            // Разбор multi-result-set: [[summaryRow], [groupRows...], [riskRows...], [excuseRows...]]
            var sets    = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var summary = (sets[0] && sets[0][0]) ? sets[0][0] : {};
            var groupsList = sets[1] || [];
            var riskArr    = sets[2] || [];
            var excData    = sets[3] || [];
            var groupFilter = selectedGroupId();
            if (groupFilter) {
                groupsList = groupsList.filter(function(row) { return String(pick(row,'Группа_ID') || '') === String(groupFilter); });
            }

            if (excData.length === 0 && curatorId) {
                var excuses = await callAPI('ПолучитьСписокОбоснований', { Куратор_ID: curatorId, Статус: 'На рассмотрении', Лимит: 5 });
                if (excuses && excuses.success && Array.isArray(excuses.data)) excData = excuses.data;
            }

            var total = pick(summary,'Количество_Студентов','Студентов','total_students');
            // Средняя посещаемость — вычисляем из списка групп (RS2)
            var avg = null;
            if (groupsList.length > 0) {
                var sumPct = groupsList.reduce(function(s,row){ return s + parseFloat(pick(row,'Процент','Посещаемость_Процент')||0); }, 0);
                avg = sumPct / groupsList.length;
            }
            // Студенты риска и критичные — из RS3
            var risk = riskArr.length ? riskArr.length : '—';
            var crit = riskArr.length ? riskArr.filter(function(row){ return String(pick(row,'Серьёзность','Статус_Риска','Статус') || '').toLowerCase().indexOf('крит') !== -1; }).length : '—';

            if (total !== null) document.getElementById('stat-total').textContent = total;
            if (avg   !== null) document.getElementById('stat-avg').textContent   = Math.round(avg) + '%';
            document.getElementById('stat-risk').textContent = risk;
            document.getElementById('stat-crit').textContent = crit;

            renderCuratorAnalytics(total, avg, risk, crit, groupsList);
            renderRisk(riskArr);
            renderExcuses(excData);
            updateContextLinks();

        } catch(e) {
            console.error(e);
            document.getElementById('risk-loading').style.display = 'none';
            document.getElementById('excuses-body').innerHTML = '<div class="alert alert-err">Ошибка соединения.</div>';
        }
    }

    function renderRisk(rows) {
        document.getElementById('risk-loading').style.display = 'none';
        if (!rows || rows.length === 0) {
            document.getElementById('risk-empty').style.display = 'flex';
            document.querySelector('#risk-empty .empty-title').textContent = 'Персональные риски не возвращены backend';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var fio = pick(row,'ФИО','Студент','Имя') || '—';
            var pctRaw = pick(row,'Процент','Посещаемость_Процент');
            var pct = pctRaw !== null ? parseFloat(pctRaw) : null;
            var severity = pick(row,'Серьёзность','Статус_Риска','Статус') || 'Риск';
            var badge = window.AISRoleUI ? window.AISRoleUI.badge(severity) : '<span class="badge b-warn">' + esc(severity) + '</span>';
            var colorClass = String(severity).toLowerCase().indexOf('крит') !== -1 ? 'metric-bad' : 'metric-warn';
            html += '<tr><td>' + esc(fio) + '</td>';
            html += '<td><strong class="' + colorClass + '">' + (pct !== null ? Math.round(pct) + '%' : '—') + '</strong></td>';
            html += '<td>' + badge + '</td></tr>';
        });
        document.getElementById('risk-tbody').innerHTML = html;
        document.getElementById('risk-table').style.display = '';
    }

    function renderExcuses(rows) {
        var body = document.getElementById('excuses-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="empty-state"><div class="empty-icon">E</div><div class="empty-title">Нет ожидающих заявок</div></div>';
            return;
        }
        var html = '';
        rows.slice(0,5).forEach(function(row) {
            var student = pick(row,'ФИО','Студент','Имя') || '—';
            var date    = pick(row,'Дата_Подачи','created_at') || '';
            html += '<div class="list-row">';
            html += '<div class="list-main"><strong>' + esc(student) + '</strong><div class="list-meta">' + esc(date) + '</div></div>';
            html += '<span class="badge b-warn">На рассмотрении</span></div>';
        });
        body.innerHTML = html;
    }

    window.loadDashboard = loadDashboard;
    document.getElementById('group-select').addEventListener('change', loadDashboard);
    loadDashboard();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

