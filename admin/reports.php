<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Отчёты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Отчёты системы</div>
        <div class="page-sub">Статистика посещаемости по всем группам</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-auto" id="report-kind">
            <option value="group">Группа</option>
            <option value="student">Студент ID</option>
            <option value="teacher">Преподаватель ID</option>
            <option value="daily">За день</option>
            <option value="weekly">За неделю</option>
            <option value="monthly">За месяц</option>
            <option value="custom">Произвольный</option>
            <option value="full">Вся история</option>
            <option value="template">Шаблон отчёта</option>
        </select>
        <select class="form-ctrl control-auto" id="group-select">
            <option value="">Все группы</option>
        </select>
        <input type="number" min="1" id="entity-id" class="form-ctrl control-id" placeholder="ID" style="display:none">
        <input type="date" id="date-from" class="form-ctrl control-auto">
        <input type="date" id="date-to"   class="form-ctrl control-auto">
        <button class="btn btn-primary" id="build-btn">Сформировать</button>
        <button class="btn btn-outline"  id="export-csv-btn" style="display:none">CSV</button>
        <button class="btn btn-outline"  id="export-excel-btn" style="display:none">Excel</button>
    </div>
</div>

<div class="alert alert-info" id="hint">Выберите параметры и нажмите «Сформировать».</div>
<div class="alert alert-info" id="loading" style="display:none">Загрузка отчёта...</div>
<div class="alert alert-err"  id="error"   style="display:none"></div>

<div id="report-wrap" style="display:none">
    <div class="stats-grid stats-grid-4">
        <div class="stat-card green"> <div class="stat-val" id="r-avg">—</div>  <div class="stat-lbl">Средняя посещаемость</div></div>
        <div class="stat-card blue">  <div class="stat-val" id="r-total">—</div><div class="stat-lbl">Студентов</div></div>
        <div class="stat-card yellow"><div class="stat-val" id="r-risk">—</div> <div class="stat-lbl">В зоне риска</div></div>
        <div class="stat-card red">   <div class="stat-val" id="r-crit">—</div> <div class="stat-lbl">Превышен порог</div></div>
    </div>

    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th id="primary-col">Студент</th>
                    <th>Группа</th>
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
    var urlParams = new URLSearchParams(window.location.search);

    var now = new Date();
    document.getElementById('date-from').value = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0,10);
    document.getElementById('date-to').value   = new Date(now.getFullYear(), now.getMonth()+1, 0).toISOString().slice(0,10);
    if (urlParams.get('student')) {
        document.getElementById('report-kind').value = 'student';
        document.getElementById('entity-id').value = urlParams.get('student');
    } else if (urlParams.get('teacher')) {
        document.getElementById('report-kind').value = 'teacher';
        document.getElementById('entity-id').value = urlParams.get('teacher');
    }

    document.getElementById('report-kind').addEventListener('change', function() {
        var kind = this.value;
        document.getElementById('group-select').style.display = (kind === 'group' || kind === 'custom') ? '' : 'none';
        document.getElementById('entity-id').style.display = (kind === 'student' || kind === 'teacher') ? '' : 'none';
        document.getElementById('primary-col').textContent = kind === 'teacher' ? 'Дисциплина / дата' : 'Студент';
    });
    document.getElementById('report-kind').dispatchEvent(new Event('change'));

    // Load groups for filter
    callAPI('ПолучитьУчебныеГруппы', {}).then(function(r) {
        if (!r || !r.success) return;
        var sel = document.getElementById('group-select');
        (Array.isArray(r.data) ? r.data : []).forEach(function(row) {
            var gid  = pick(row,'Группа_ID','id') || '';
            var name = pick(row,'Группа','Название_Группы','Название') || '';
            if (!name) return;
            var opt = document.createElement('option');
            opt.value = gid || name; opt.textContent = name;
            sel.appendChild(opt);
        });
    }).catch(function(){});

    document.getElementById('build-btn').addEventListener('click', async function() {
        var dateFrom   = document.getElementById('date-from').value;
        var dateTo     = document.getElementById('date-to').value;
        var groupVal   = document.getElementById('group-select').value;
        var reportKind = document.getElementById('report-kind').value;
        var entityId   = parseInt(document.getElementById('entity-id').value || '0', 10);
        var hint       = document.getElementById('hint');
        var loading    = document.getElementById('loading');
        var error      = document.getElementById('error');
        var wrap       = document.getElementById('report-wrap');
        var csvBtn     = document.getElementById('export-csv-btn');
        var excelBtn   = document.getElementById('export-excel-btn');

        hint.style.display = 'none'; error.style.display = 'none'; wrap.style.display = 'none';
        csvBtn.style.display = 'none'; excelBtn.style.display = 'none';
        loading.style.display = 'flex';

        try {
            var params = { Дата_Начала: dateFrom, Дата_Конца: dateTo };
            var groupId = parseInt(groupVal, 10);
            if (groupId) params['Группа_ID'] = groupId;
            else if (groupVal) params['Группа'] = groupVal;

            var action = 'СформироватьОтчетПоГруппе';
            var reportParams = { НачалоПериода: params['Дата_Начала'], КонецПериода: params['Дата_Конца'] };

            if (reportKind === 'template') {
                loading.style.display = 'none';
                error.textContent = 'Выполнение шаблонов отчётов отключено: backend возвращает SQL-текст, а безопасная политика исполнения не подтверждена.';
                error.style.display = 'flex';
                return;
            }

            if (reportKind === 'group' && !params['Группа_ID']) {
                loading.style.display = 'none';
                error.textContent = 'Выберите конкретную группу для детального отчёта.';
                error.style.display = 'flex';
                return;
            }

            if (reportKind === 'group') {
                reportParams['Группа_ID'] = params['Группа_ID'];
                document.getElementById('primary-col').textContent = 'Студент';
            } else if (reportKind === 'student') {
                if (!entityId) {
                    loading.style.display = 'none';
                    error.textContent = 'Укажите ID студента.';
                    error.style.display = 'flex';
                    return;
                }
                action = 'СформироватьОтчетПоСтуденту';
                reportParams['Студент_ID'] = entityId;
                document.getElementById('primary-col').textContent = 'Студент / дисциплина';
            } else if (reportKind === 'teacher') {
                if (!entityId) {
                    loading.style.display = 'none';
                    error.textContent = 'Укажите ID преподавателя.';
                    error.style.display = 'flex';
                    return;
                }
                action = 'СформироватьОтчетПоПреподавателю';
                reportParams['Преподаватель_ID'] = entityId;
                document.getElementById('primary-col').textContent = 'Дисциплина / дата';
            } else if (reportKind === 'daily') {
                action = 'СформироватьОтчетПоДням';
                reportParams = { Дата: dateFrom };
                document.getElementById('primary-col').textContent = 'Группа / дисциплина';
            } else if (reportKind === 'weekly') {
                action = 'СформироватьОтчетПоНеделям';
                reportParams = { НачалоНедели: dateFrom };
                document.getElementById('primary-col').textContent = 'Группа / дисциплина';
            } else if (reportKind === 'monthly') {
                // Parse YYYY-MM-DD deterministically to avoid timezone issues
                var parts = String(dateFrom || '').split('-');
                var parsedYear = parseInt(parts[0], 10) || (new Date()).getFullYear();
                var parsedMonth = parseInt(parts[1], 10) || ((new Date()).getMonth() + 1);
                action = 'СформироватьОтчетПоМесяцам';
                reportParams = { Месяц: parsedMonth, Год: parsedYear };
                document.getElementById('primary-col').textContent = 'Группа';
            } else {
                action = 'СформироватьПроизвольныйОтчет';
                reportParams = { Лимит: reportKind === 'full' ? 5000 : 1000 };
                if (reportKind !== 'full') {
                    reportParams['ДатаНачала'] = dateFrom;
                    reportParams['ДатаКонца'] = dateTo;
                }
                if (params['Группа_ID']) reportParams['Группа_ID'] = params['Группа_ID'];
                document.getElementById('primary-col').textContent = 'Запись';
            }

            var r = await callAPI(action, reportParams);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = (r && r.message ? r.message : 'Ошибка'); error.style.display = 'flex'; return;
            }

            var rows = [];
            if (Array.isArray(r.data) && Array.isArray(r.data[0])) {
                rows = r.data.reduce(function(acc, set){ return acc.concat(set); }, []);
            } else {
                rows = Array.isArray(r.data) ? r.data : [];
            }
            var avg = 0, risk = 0, crit = 0;
            rows.forEach(function(row) {
                var pct = parseFloat(pick(row,'Процент','Посещаемость_Процент','ПроцентПосещаемости','СреднийПроцентПосещаемости','ОбщийПроцентПосещаемости') || 0);
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
                var fio       = pick(row,'ФИО','Студент','Имя','ФИО_Студента') || (pick(row,'Дисциплина') ? (pick(row,'Дисциплина') + ' / ' + (pick(row,'Дата_Занятия','Дата') || '')) : (pick(row,'Группа') || '—'));
                var group     = pick(row,'Группа','Название_Группы','Название') || '—';
                var total     = pick(row,'Всего_Занятий','Всего','ВсегоЗанятий','ВсегоСтудентовВГруппе') || '—';
                var present   = pick(row,'Присутствовал','Кол_Присутствий') || '—';
                var absent    = pick(row,'Отсутствовал','Кол_Отсутствий') || '—';
                var late      = pick(row,'Опоздал','Кол_Опозданий') || '—';
                var justified = pick(row,'Уважительных','Уважительные','УважительнаяПричина') || '—';
                var pct       = parseFloat(pick(row,'Процент','Посещаемость_Процент','ПроцентПосещаемости','СреднийПроцентПосещаемости','ОбщийПроцентПосещаемости') || 0);
                var badge     = pct >= window.AIS.riskThresh ? '<span class="badge b-ok">Норма</span>' : pct >= window.AIS.critThresh ? '<span class="badge b-warn">Риск</span>' : '<span class="badge b-err">Критично</span>';
                var pctClass  = pct < window.AIS.critThresh ? 'status-text-err' : pct < window.AIS.riskThresh ? 'status-text-warn' : 'status-text-ok';

                html += '<tr><td>' + esc(fio) + '</td><td><span class="tag">' + esc(group) + '</span></td>';
                html += '<td>' + esc(String(total)) + '</td><td>' + esc(String(present)) + '</td><td>' + esc(String(absent)) + '</td>';
                html += '<td>' + esc(String(late)) + '</td><td>' + esc(String(justified)) + '</td>';
                html += '<td><strong class="' + pctClass + '">' + Math.round(pct) + '%</strong></td>';
                html += '<td>' + badge + '</td></tr>';
            });

            document.getElementById('report-tbody').innerHTML = html || '<tr><td colspan="9" class="table-empty-sm">Нет данных</td></tr>';
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
            a.href = url;
            a.download = format === 'excel' ? 'system_attendance.xls' : 'system_attendance.csv';
            a.click();
            URL.revokeObjectURL(url);
        } catch (err) {
            error.textContent = 'Ошибка экспорта.';
            error.style.display = 'flex';
        }
    }

    document.getElementById('export-csv-btn').addEventListener('click', function() { exportAttendance('csv'); });
    document.getElementById('export-excel-btn').addEventListener('click', function() { exportAttendance('excel'); });
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

