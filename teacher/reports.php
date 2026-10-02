<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'Отчёты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Отчёты по посещаемости</div>
        <div class="page-sub">Выберите группу и период</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-auto" id="report-type">
            <option value="group">По группе</option>
            <option value="teacher">По преподавателю</option>
            <option value="day">За день</option>
            <option value="week">За неделю</option>
            <option value="month">За месяц</option>
            <option value="custom">Произвольный</option>
        </select>
        <select class="form-ctrl control-auto" id="group-select">
            <option value="">Загрузка групп...</option>
        </select>
        <input type="date" id="date-from" class="form-ctrl control-auto">
        <input type="date" id="date-to"   class="form-ctrl control-auto">
        <button class="btn btn-primary" id="build-btn">Сформировать</button>
        <button class="btn btn-outline"  id="export-csv-btn" style="display:none">CSV</button>
        <button class="btn btn-outline"  id="export-excel-btn" style="display:none">Excel</button>
    </div>
</div>

<div class="alert alert-info" id="hint">Выберите группу и нажмите «Сформировать».</div>
<div class="alert alert-info" id="loading" style="display:none">Загрузка отчёта...</div>
<div class="alert alert-err"  id="error"   style="display:none"></div>

<div id="report-wrap" style="display:none">
    <div class="stats-grid stats-grid-4">
        <div class="stat-card green"><div class="stat-val" id="r-avg">—</div><div class="stat-lbl">Средняя посещаемость</div></div>
        <div class="stat-card blue"><div class="stat-val" id="r-total">—</div><div class="stat-lbl">Студентов в группе</div></div>
        <div class="stat-card yellow"><div class="stat-val" id="r-risk">—</div><div class="stat-lbl">В зоне риска</div></div>
        <div class="stat-card red"><div class="stat-val" id="r-crit">—</div><div class="stat-lbl">Превышен порог</div></div>
    </div>

    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th id="primary-col">Студент</th>
                    <th>Всего занятий</th>
                    <th>Присутствовал</th>
                    <th>Отсутствовал</th>
                    <th>Опоздал</th>
                    <th>Уважительных</th>
                    <th>%</th>
                    <th>Статус</th>
                </tr>
            </thead>
            <tbody id="report-tbody"></tbody>
        </table>
    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }
    var teacherIdCache = 0;
    var urlParams = new URLSearchParams(window.location.search);
    var preGroup = urlParams.get('group') || '';

    var now = new Date();
    var first = new Date(now.getFullYear(), now.getMonth(), 1);
    var last  = new Date(now.getFullYear(), now.getMonth()+1, 0);
    document.getElementById('date-from').value = urlParams.get('from') || first.toISOString().slice(0,10);
    document.getElementById('date-to').value   = urlParams.get('to') || last.toISOString().slice(0,10);

    function toInputDate(d) {
        return d.toISOString().slice(0, 10);
    }

    function rangeForType(type, dateFrom, dateTo) {
        var start = new Date(dateFrom || toInputDate(new Date()));
        if (Number.isNaN(start.getTime())) start = new Date();
        if (type === 'day') return { from: toInputDate(start), to: toInputDate(start) };
        if (type === 'week') {
            var endWeek = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6);
            return { from: toInputDate(start), to: toInputDate(endWeek) };
        }
        if (type === 'month') {
            var firstDay = new Date(start.getFullYear(), start.getMonth(), 1);
            var lastDay = new Date(start.getFullYear(), start.getMonth() + 1, 0);
            return { from: toInputDate(firstDay), to: toInputDate(lastDay) };
        }
        return { from: dateFrom, to: dateTo };
    }

    async function loadGroups() {
        var teacherId = parseInt(localStorage.getItem('ais_teacher_id')||'0', 10);
        if (!teacherId) {
            var sess = await callAPI('ПроверитьСессию', {});
            if (sess && sess.success && sess.data && sess.data[0]) {
                teacherId = pick(sess.data[0], 'Преподаватель_ID', 'teacher_id') || 0;
                if (teacherId) localStorage.setItem('ais_teacher_id', teacherId);
            }
        }
        teacherIdCache = teacherId || 0;

        var r = await callAPI('ПолучитьДашбордПреподавателя', teacherId ? {Преподаватель_ID: teacherId} : {});
        var sel = document.getElementById('group-select');
        sel.innerHTML = '<option value="">— Выберите группу —</option>';

        var groups = [];
        if (r && r.success && r.data) {
            // Try to find groups in response
            var d = r.data;
            if (Array.isArray(d) && Array.isArray(d[2])) groups = d[2];
            else if (Array.isArray(d) && d.length > 2) groups = d.slice(2);
            else if (Array.isArray(d)) {
                var item = d[0] || {};
                var arr = pick(item,'Группы') || [];
                if (Array.isArray(arr)) groups = arr;
            }
        }

        groups.forEach(function(row) {
            var gid  = pick(row,'Группа_ID','group_id') || '';
            var name = pick(row,'Группа','Название_Группы') || '';
            if (!name) return;
            var opt = document.createElement('option');
            opt.value = gid || name;
            opt.textContent = name;
            sel.appendChild(opt);
        });

        if (preGroup) sel.value = preGroup;
        if (sel.options.length === 1) sel.innerHTML = '<option value="">Загрузите из расписания</option>';
    }

    document.getElementById('build-btn').addEventListener('click', async function() {
        var groupVal = document.getElementById('group-select').value;
        var reportType = document.getElementById('report-type').value;
        var dateFrom = document.getElementById('date-from').value;
        var dateTo   = document.getElementById('date-to').value;
        var hint     = document.getElementById('hint');
        var loading  = document.getElementById('loading');
        var error    = document.getElementById('error');
        var wrap     = document.getElementById('report-wrap');
        var csvBtn   = document.getElementById('export-csv-btn');
        var excelBtn = document.getElementById('export-excel-btn');

        hint.style.display = 'none'; error.style.display = 'none'; wrap.style.display = 'none';
        csvBtn.style.display = 'none'; excelBtn.style.display = 'none';
        loading.style.display = 'flex';

        try {
            var range = rangeForType(reportType, dateFrom, dateTo);
            var params = { Дата_Начала: range.from, Дата_Конца: range.to };
            var groupId = parseInt(groupVal, 10);
            if (groupId) params['Группа_ID'] = groupId;
            else if (groupVal) params['Группа'] = groupVal;

            var reportParams = {};
            var action = 'СформироватьОтчетПоГруппе';
            if (reportType === 'group' && params['Группа_ID']) {
                reportParams['Группа_ID'] = params['Группа_ID'];
                reportParams['НачалоПериода'] = params['Дата_Начала'];
                reportParams['КонецПериода'] = params['Дата_Конца'];
                document.getElementById('primary-col').textContent = 'Студент';
            } else if (reportType === 'teacher') {
                action = 'СформироватьОтчетПоПреподавателю';
                reportParams['Преподаватель_ID'] = teacherIdCache || parseInt(localStorage.getItem('ais_teacher_id')||'0', 10);
                reportParams['НачалоПериода'] = params['Дата_Начала'];
                reportParams['КонецПериода'] = params['Дата_Конца'];
                document.getElementById('primary-col').textContent = 'Дисциплина / дата';
            } else {
                action = 'СформироватьПроизвольныйОтчет';
                reportParams['Преподаватель_ID'] = teacherIdCache || parseInt(localStorage.getItem('ais_teacher_id')||'0', 10);
                reportParams['ДатаНачала'] = params['Дата_Начала'];
                reportParams['ДатаКонца'] = params['Дата_Конца'];
                reportParams['Лимит'] = 1000;
                if (params['Группа_ID']) reportParams['Группа_ID'] = params['Группа_ID'];
                document.getElementById('primary-col').textContent = 'Дисциплина / дата';
            }

            if (!reportParams['Преподаватель_ID'] && reportType !== 'group') {
                throw new Error('Не удалось определить преподавателя для ограниченного отчёта.');
            }
            if (reportType === 'group' && !params['Группа_ID']) {
                throw new Error('Выберите группу или переключите тип отчёта.');
            }
            var r = await callAPI(action, reportParams);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = (r && r.message ? r.message : 'Ошибка'); error.style.display = 'flex'; return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];

            // Summary stats
            var avg = 0, risk = 0, crit = 0;
            rows.forEach(function(row) {
                var pct = parseFloat(pick(row,'Процент','ПроцентПосещаемости','СреднийПроцентПосещаемости','Посещаемость_Процент') || 0);
                avg += pct;
                if (pct < window.AIS.riskThresh && pct >= window.AIS.critThresh) risk++;
                if (pct < window.AIS.critThresh) crit++;
            });
            if (rows.length) avg = Math.round(avg / rows.length);

            document.getElementById('r-avg').textContent   = avg + '%';
            document.getElementById('r-total').textContent = rows.length;
            document.getElementById('r-risk').textContent  = risk;
            document.getElementById('r-crit').textContent  = crit;

            var html = '';
            rows.forEach(function(row) {
                var fio       = pick(row,'ФИО_Студента','ФИО','Студент','Имя') || (pick(row,'Дисциплина') ? (pick(row,'Дисциплина') + ' / ' + (pick(row,'Дата_Занятия', 'Дата') || '')) : '—');
                var total     = pick(row,'Всего_Занятий','Всего','ВсегоЗанятий','ВсегоСтудентовВГруппе') || '—';
                var present   = pick(row,'Присутствовал','Кол_Присутствий') || '—';
                var absent    = pick(row,'Отсутствовал','Кол_Отсутствий') || '—';
                var late      = pick(row,'Опоздал','Кол_Опозданий') || '—';
                var justified = pick(row,'Уважительных','Уважительные','УважительнаяПричина') || '—';
                var pct       = parseFloat(pick(row,'Процент','ПроцентПосещаемости','СреднийПроцентПосещаемости','Посещаемость_Процент') || 0);
                var statusBadge = pct >= window.AIS.riskThresh ? '<span class="badge b-ok">Норма</span>' : pct >= window.AIS.critThresh ? '<span class="badge b-warn">Риск</span>' : '<span class="badge b-err">Критично</span>';
                var pctClass = pct < window.AIS.critThresh ? 'status-text-err' : pct < window.AIS.riskThresh ? 'status-text-warn' : 'status-text-ok';

                html += '<tr><td>' + esc(fio) + '</td><td>' + esc(total) + '</td><td>' + esc(present) + '</td><td>' + esc(absent) + '</td><td>' + esc(late) + '</td><td>' + esc(justified) + '</td>';
                html += '<td><strong class="' + pctClass + '">' + Math.round(pct) + '%</strong></td>';
                html += '<td>' + statusBadge + '</td></tr>';
            });

            document.getElementById('report-tbody').innerHTML = html || '<tr><td colspan="8" class="table-empty-sm">Нет данных</td></tr>';
            wrap.style.display = '';
            csvBtn.style.display = '';
            excelBtn.style.display = '';

        } catch(err) {
            console.error(err);
            loading.style.display = 'none';
            error.textContent = err && err.message ? err.message : 'Ошибка соединения.'; error.style.display = 'flex';
        }
    });

    function exportPayload(r) {
        var out = r && r.data && r.data._output ? r.data._output : null;
        var csvData = out ? (out['CSV_Содержимое'] || '') : '';
        if (!csvData && r && Array.isArray(r.data) && r.data[0]) {
            csvData = r.data[0]['CSV_Содержимое'] || r.data[0]['CSV_Данные'] || r.data[0]['csv'] || '';
        }
        return csvData;
    }

    async function exportAttendance(format) {
        var error = document.getElementById('error');
        error.style.display = 'none';

        var params = {
            ДатаНачала: document.getElementById('date-from').value,
            ДатаКонца: document.getElementById('date-to').value
        };

        try {
            var r = await callAPI('ЭкспортПосещаемостиВCSV', params);
            var csvData = exportPayload(r);
            if (!r || !r.success || !csvData) {
                error.textContent = (r && r.message ? r.message : 'Нет данных для экспорта.');
                error.style.display = 'flex';
                return;
            }

            var blob = new Blob(['\ufeff' + csvData], {type:'text/csv;charset=utf-8;'});
            var url  = URL.createObjectURL(blob);
            var a    = document.createElement('a');
            a.href   = url;
            a.download = format === 'excel' ? 'attendance_report.xls' : 'attendance_report.csv';
            a.click();
            URL.revokeObjectURL(url);
        } catch (err) {
            error.textContent = 'Ошибка экспорта.';
            error.style.display = 'flex';
        }
    }

    document.getElementById('export-csv-btn').addEventListener('click', function() { exportAttendance('csv'); });
    document.getElementById('export-excel-btn').addEventListener('click', function() { exportAttendance('excel'); });

    loadGroups();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

