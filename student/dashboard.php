<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'Главная';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="alert alert-warn" id="threshold-alert" style="display:none"></div>

<div class="page-hdr">
    <div>
        <div class="page-title" id="greeting">Добрый день!</div>
        <div class="page-sub" id="page-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" id="refresh-btn" onclick="loadDashboard()">Обновить</button>
    </div>
</div>

<div class="stats-grid" id="stats-grid">
    <div class="stat-card blue"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-pct">—</div><div class="stat-lbl">Посещаемость</div><div class="stat-sub">За текущий семестр</div></div>
    <div class="stat-card green"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-present">—</div><div class="stat-lbl">Присутствовал</div><div class="stat-sub" id="stat-total-sub">из — занятий</div></div>
    <div class="stat-card yellow"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-missed">—</div><div class="stat-lbl">Пропущено (ч)</div><div class="stat-sub" id="stat-threshold-sub">Порог: — часов</div></div>
    <div class="stat-card red"><div class="stat-icon" aria-hidden="true"></div><div class="stat-val" id="stat-pending">—</div><div class="stat-lbl">Ожидают</div><div class="stat-sub">Обоснования на рассмотрении</div></div>
</div>

<div class="analytics-grid dashboard-analytics" id="student-analytics" aria-live="polite"></div>

<div class="card mb-4">
    <div class="card-hdr">
        <span class="card-title">Быстрые действия</span>
        <span class="badge b-info">Студент</span>
    </div>
    <div class="card-body">
        <div class="quick-action-list">
            <a class="quick-action" href="/ais-system-ru/student/qr-scanner.php">Сканировать QR</a>
            <a class="quick-action" href="/ais-system-ru/student/attendance.php">История посещаемости</a>
            <a class="quick-action" href="/ais-system-ru/student/excuse-form.php">Подать обоснование</a>
            <a class="quick-action" href="/ais-system-ru/student/notifications.php">Уведомления</a>
        </div>
    </div>
</div>

<div class="grid-2">
    <div class="card">
        <div class="card-hdr">
            <span class="card-title">Занятия сегодня</span>
            <span class="badge b-primary" id="today-count">0 занятий</span>
        </div>
        <div class="card-body panel-flush">
            <div class="alert alert-info panel-loading" id="today-loading">Загрузка расписания...</div>
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
        <div class="card-hdr">
            <span class="card-title">Посещаемость по дисциплинам</span>
        </div>
        <div class="card-body" id="disciplines-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    function esc(s) { return typeof escapeHtml === 'function' ? escapeHtml(String(s||'')) : String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }

    function pick(obj) {
        for (var i = 1; i < arguments.length; i++) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) return obj[arguments[i]];
        }
        return null;
    }

    function num(v) {
        return window.AISCharts ? window.AISCharts.toNumber(v, 0) : (parseFloat(String(v||0).replace('%','').replace('ч','').replace(',','.')) || 0);
    }

    function show(v) {
        return v === null || v === undefined || v === '' ? '—' : v;
    }

    function hoursLabel(v) {
        if (v === null || v === undefined || v === '') return '—';
        return String(v).indexOf('ч') !== -1 ? v : v + 'ч';
    }

    function renderStudentAnalytics(pct, present, total, missedClasses, missedHours, pending, disciplines) {
        if (!window.AISCharts) return;
        var pctN = num(pct);
        var presentN = num(present);
        var totalN = num(total);
        var missedN = missedClasses !== null && missedClasses !== undefined ? num(missedClasses) : Math.max(totalN - presentN, 0);
        var otherN = Math.max(totalN - presentN - missedN, 0);
        var disciplineBars = (disciplines || []).slice(0, 6).map(function(row) {
            var name = pick(row, 'Дисциплина', 'Название_Дисциплины') || '—';
            var value = num(pick(row, 'Процент', 'Посещаемость_Процент'));
            return { label: name, value: value, unit: '%', tone: window.AISCharts.tone(value) };
        });
        var cards = [
            {
                type: 'ring',
                title: 'Индекс посещаемости',
                subtitle: 'Графическое представление текущего процента',
                badge: 'семестр',
                ring: { value: pctN, label: 'посещаемость', tone: window.AISCharts.tone(pctN) },
                metrics: [
                    { label: 'присутствовал', value: show(present), tone: 'ok' },
                    { label: 'всего занятий', value: show(total), tone: 'primary' },
                    { label: 'пропущено часов', value: hoursLabel(missedHours), tone: 'warn' },
                    { label: 'обоснования', value: show(pending), tone: 'err' }
                ]
            }
        ];
        if (totalN > 0) {
            cards.push({
                type: 'stack',
                title: 'Баланс занятий',
                subtitle: 'Доли присутствий и пропусков',
                badge: 'состав',
                segments: [
                    { label: 'Присутствовал', value: presentN, tone: 'ok' },
                    { label: 'Пропустил', value: missedN, tone: 'warn' },
                    { label: 'Другое', value: otherN, tone: 'muted' }
                ]
            });
        }
        cards.push({
            type: 'bars',
            title: 'Дисциплины',
            subtitle: 'Посещаемость по предметам из текущей выборки',
            badge: 'до 6',
            unit: '%',
            max: 100,
            items: disciplineBars
        });
        window.AISCharts.render('student-analytics', cards);
    }

    function getStudentId() {
        var sid = localStorage.getItem('ais_student_id');
        return sid ? parseInt(sid, 10) : null;
    }

    function showDashboardError(message) {
        document.getElementById('greeting').textContent = 'Ошибка загрузки данных';
        document.getElementById('page-sub').textContent = message || 'Проверьте соединение и повторите запрос.';
        document.getElementById('threshold-alert').style.display = 'none';
        document.getElementById('today-loading').style.display = 'none';
        document.getElementById('today-empty').style.display = 'block';
        document.getElementById('today-table').style.display = 'none';
        document.getElementById('disciplines-body').innerHTML = '<div class="alert alert-err">' + esc(message || 'Ошибка загрузки данных') + '</div>';
    }

    function showDashboardBlocked(message) {
        document.getElementById('greeting').textContent = 'Данные студента недоступны';
        document.getElementById('page-sub').textContent = 'Нужна привязка текущего пользователя к карточке студента.';
        document.getElementById('threshold-alert').className = 'alert alert-warn';
        document.getElementById('threshold-alert').innerHTML = '<strong>Недоступно.</strong> ' + esc(message);
        document.getElementById('threshold-alert').style.display = 'flex';
        document.getElementById('today-loading').style.display = 'none';
        document.getElementById('today-empty').style.display = 'block';
        document.getElementById('today-table').style.display = 'none';
        document.getElementById('disciplines-body').innerHTML = '<div class="alert alert-warn">' + esc(message) + '</div>';
    }

    function hasBackendRiskValue(row) {
        return pick(row, 'Превышен_Порог', 'Порог_Превышен', 'Нарушен_Порог', 'В_Зоне_Риска', 'Риск', 'Сообщение_Порога', 'Порог_Сообщение') !== null;
    }

    function renderThresholdState(row) {
        var alertEl = document.getElementById('threshold-alert');
        alertEl.style.display = 'none';
        alertEl.className = 'alert alert-warn';

        if (!hasBackendRiskValue(row)) {
            alertEl.className = 'alert alert-info';
            alertEl.innerHTML = '<strong>Порог посещаемости.</strong> Персональный результат порога не возвращён backend-ответом. Контроль риска отображается только по готовым уведомлениям и данным дашборда.';
            alertEl.style.display = 'flex';
            return;
        }

        var flag = pick(row, 'Превышен_Порог', 'Порог_Превышен', 'Нарушен_Порог', 'В_Зоне_Риска', 'Риск');
        var text = pick(row, 'Сообщение_Порога', 'Порог_Сообщение', 'Описание_Риска') || '';
        var normalized = String(flag || '').toLowerCase();
        var risky = flag === true || flag === 1 || normalized === '1' || normalized.indexOf('риск') !== -1 || normalized.indexOf('превыш') !== -1 || normalized.indexOf('да') !== -1;

        if (risky) {
            alertEl.innerHTML = '<strong>Внимание.</strong> ' + esc(text || 'Backend отметил риск по посещаемости.');
            alertEl.style.display = 'flex';
        } else {
            alertEl.className = 'alert alert-ok';
            alertEl.innerHTML = '<strong>Порог посещаемости.</strong> ' + esc(text || 'Backend не сообщил о превышении порога.');
            alertEl.style.display = 'flex';
        }
    }

    async function loadDashboard() {
        var btn = document.getElementById('refresh-btn');
        if (btn) { btn.disabled = true; btn.textContent = '...'; }

        try {
            var studentId = getStudentId();
            if (!studentId) {
                // Resolve via session
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    studentId = pick(sess.data[0], 'Студент_ID', 'student_id');
                    if (studentId) localStorage.setItem('ais_student_id', studentId);
                }
            }

            if (!studentId) {
                showDashboardBlocked('Сессия активна, но backend не вернул идентификатор студента. Откройте профиль или войдите под студенческой учётной записью с привязанной карточкой.');
                return;
            }

            var params = {};
            if (studentId) params['Студент_ID'] = studentId;

            var r = await callAPI('ПолучитьДашбордСтудента', params);

            if (!r || !r.success) {
                showDashboardError(r && r.message ? r.message : 'Ошибка загрузки данных');
                return;
            }

            // Разбор multi-result-set: [[statRow], [schedRows...], [disciplineRows...]]
            var sets        = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var d           = (sets[0] && sets[0][0]) ? sets[0][0] : {};
            var schedule    = sets[1] || [];
            var disciplines = sets[2] || [];

            if (!sets[0] || !sets[0][0]) {
                showDashboardBlocked('Процедура ПолучитьДашбордСтудента не вернула строку профиля. Проверьте привязку студента и группы в базе.');
                return;
            }

            // Header
            var name = localStorage.getItem('ais_user_name') || '';
            var firstName = name.split(' ')[1] || name.split(' ')[0] || '';
            document.getElementById('greeting').textContent = 'Добрый день, ' + (firstName || 'студент') + '!';

            var group = pick(d, 'Группа', 'Название_Группы') || '';
            var today = new Date().toLocaleDateString('ru-RU', {weekday:'long', day:'numeric', month:'long', year:'numeric'});
            document.getElementById('page-sub').textContent = today + (group ? ' · Группа ' + group : '');

            // Stats
            var pct     = pick(d, 'Процент_Посещаемости', 'Посещаемость_Процент', 'Процент');
            var present = pick(d, 'Присутствовал', 'Кол_Присутствий');
            var total   = pick(d, 'Всего_Занятий', 'Кол_Занятий');
            var missed  = pick(d, 'Пропущено_Часов', 'Пропущено');
            var missedClasses = pick(d, 'Пропустил', 'Отсутствовал');
            var thresh  = pick(d, 'Порог_Часов', 'Порог');
            var pending = pick(d, 'Обоснований_Ожидает', 'Ожидают_Обоснований', 'На_Рассмотрении');

            if (pct !== null)     document.getElementById('stat-pct').textContent     = Math.round(pct) + '%';
            if (present !== null) document.getElementById('stat-present').textContent = present;
            if (total !== null)   document.getElementById('stat-total-sub').textContent = 'из ' + total + ' занятий';
            if (missed !== null)  document.getElementById('stat-missed').textContent   = missed + 'ч';
            if (thresh !== null)  document.getElementById('stat-threshold-sub').textContent = 'Порог: ' + thresh + ' часов';
            if (pending !== null) document.getElementById('stat-pending').textContent  = pending;

            renderThresholdState(d);
            renderStudentAnalytics(pct, present, total, missedClasses, missed, pending, disciplines);

            renderTodaySchedule(schedule);
            renderDisciplines(disciplines);

        } catch (err) {
            console.error('Dashboard load error:', err);
            showDashboardError('Ошибка соединения.');
        } finally {
            if (btn) { btn.disabled = false; btn.textContent = 'Обновить'; }
        }
    }

    function statusBadge(status) {
        var s = String(status || '').toLowerCase();
        if (s.includes('присутств') || s.includes('present'))   return '<span class="badge b-ok">Присутствовал</span>';
        if (s.includes('отсутств') || s.includes('absent'))     return '<span class="badge b-err">Отсутствовал</span>';
        if (s.includes('опозда') || s.includes('late'))         return '<span class="badge b-warn">Опоздал</span>';
        if (s.includes('уважит') || s.includes('excuse'))       return '<span class="badge b-info">Уважительная</span>';
        if (s.includes('идёт') || s.includes('active'))         return '<span class="badge b-warn">Идёт сейчас</span>';
        if (s.includes('предст') || s.includes('upcoming'))     return '<span class="badge b-muted">Предстоит</span>';
        if (s.includes('завер') || s.includes('done'))          return '<span class="badge b-ok">Завершено</span>';
        return '<span class="badge b-muted">' + esc(status) + '</span>';
    }

    function renderTodaySchedule(rows) {
        var loading = document.getElementById('today-loading');
        var table   = document.getElementById('today-table');
        var tbody   = document.getElementById('today-tbody');
        var empty   = document.getElementById('today-empty');
        var count   = document.getElementById('today-count');

        loading.style.display = 'none';
        table.style.display = 'none';
        empty.style.display = 'none';

        if (!rows || rows.length === 0) {
            empty.style.display = 'block';
            count.textContent = '0 занятий';
            return;
        }

        count.textContent = rows.length + ' ' + (rows.length === 1 ? 'занятие' : rows.length < 5 ? 'занятия' : 'занятий');

        var html = '';
        rows.forEach(function(row) {
            var time   = pick(row, 'Время_Начала', 'Время', 'time') || '';
            var subj   = pick(row, 'Дисциплина', 'Название_Дисциплины', 'subject') || '';
            var room   = pick(row, 'Аудитория', 'Кабинет', 'room') || '';
            var status = pick(row, 'Статус', 'status') || '';
            var zid    = pick(row, 'Занятие_ID', 'id') || '';

            html += '<tr>';
            html += '<td><strong>' + esc(time) + '</strong></td>';
            html += '<td><strong>' + esc(subj) + '</strong>' + (room ? '<br><span class="text-muted text-sm">ауд. ' + esc(room) + '</span>' : '') + '</td>';
            html += '<td>' + (status ? statusBadge(status) : '') + '</td>';
            html += '</tr>';
        });

        tbody.innerHTML = html;
        table.style.display = '';
    }

    function renderDisciplines(rows) {
        var body = document.getElementById('disciplines-body');
        if (!rows || rows.length === 0) {
            body.innerHTML = '<div class="empty-state"><div class="empty-icon">DATA</div><div class="empty-title">Нет данных</div></div>';
            return;
        }
        var html = '';
        rows.forEach(function(row) {
            var name = pick(row, 'Дисциплина', 'Название_Дисциплины') || '';
            var pct  = parseFloat(pick(row, 'Процент', 'Посещаемость_Процент') || 0);
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
    loadDashboard();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

