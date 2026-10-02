<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Куратор');
$page_title = 'Отчёты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Отчёты по посещаемости</div>
        <div class="page-sub">Статистика по вашей группе</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-auto" id="report-type">
            <option value="group">По группе</option>
            <option value="student">По студенту</option>
            <option value="custom">Произвольный</option>
        </select>
        <select class="form-ctrl control-auto" id="group-select">
            <option value="">Загрузка групп...</option>
        </select>
        <select class="form-ctrl control-auto" id="student-select">
            <option value="">Все студенты</option>
        </select>
        <input type="date" id="date-from" class="form-ctrl control-auto">
        <input type="date" id="date-to"   class="form-ctrl control-auto">
        <button class="btn btn-primary" id="build-btn">Сформировать</button>
        <button class="btn btn-outline"  id="export-btn" style="display:none">Экспорт CSV</button>
    </div>
</div>

<div class="alert alert-info" id="hint">Выберите период и нажмите «Сформировать».</div>
<div class="alert alert-info" id="loading" style="display:none">Загрузка отчёта...</div>
<div class="alert alert-err"  id="error"   style="display:none"></div>

<div id="report-wrap" style="display:none">
    <div class="stats-grid stats-grid-4">
        <div class="stat-card green"> <div class="stat-val" id="r-avg">—</div>  <div class="stat-lbl">Средняя посещаемость</div></div>
        <div class="stat-card blue">  <div class="stat-val" id="r-total">—</div><div class="stat-lbl">Студентов в группе</div></div>
        <div class="stat-card yellow"><div class="stat-val" id="r-risk">—</div> <div class="stat-lbl">В зоне риска</div></div>
        <div class="stat-card red">   <div class="stat-val" id="r-crit">—</div> <div class="stat-lbl">Превышен порог</div></div>
    </div>

    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>Студент</th>
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
    function rows(data) { return Array.isArray(data) && Array.isArray(data[0]) ? data.reduce(function(a,b){ return a.concat(b); }, []) : (Array.isArray(data) ? data : []); }
    var urlParams = new URLSearchParams(window.location.search);

    var now = new Date();
    var first = new Date(now.getFullYear(), now.getMonth(), 1);
    var last  = new Date(now.getFullYear(), now.getMonth()+1, 0);
    document.getElementById('date-from').value = urlParams.get('from') || first.toISOString().slice(0,10);
    document.getElementById('date-to').value   = urlParams.get('to') || last.toISOString().slice(0,10);

    var curatorGroupId = null;
    var curatorIdCache = 0;
    var studentsCache = [];

    async function resolveCuratorId() {
        var curatorId = parseInt(localStorage.getItem('ais_curator_id')||'0', 10);
        if (!curatorId) {
            var sess = await callAPI('ПроверитьСессию', {});
            if (sess && sess.success && sess.data && sess.data[0]) {
                curatorId = pick(sess.data[0],'Куратор_ID','curator_id','Преподаватель_ID','teacher_id') || 0;
                if (curatorId) localStorage.setItem('ais_curator_id', curatorId);
            }
        }
        curatorIdCache = parseInt(curatorId || '0', 10);
        return curatorIdCache;
    }

    async function loadGroupsAndStudents() {
        var curatorId = await resolveCuratorId();
        var groupSelect = document.getElementById('group-select');
        var studentSelect = document.getElementById('student-select');
        if (!curatorId) {
            groupSelect.innerHTML = '<option value="">Куратор не определён</option>';
            return;
        }

        var groups = await callAPI('ПолучитьГруппыКуратора', { Куратор_ID: curatorId }).catch(function(){ return null; });
        var groupRows = groups && groups.success && Array.isArray(groups.data) ? groups.data : [];
        groupSelect.innerHTML = '<option value="">— Выберите группу —</option>' + groupRows.map(function(row) {
            var id = pick(row,'Группа_ID') || '';
            var name = pick(row,'Название','Группа','Название_Группы') || id;
            return '<option value="' + esc(id) + '">' + esc(name) + '</option>';
        }).join('');
        if (urlParams.get('group')) groupSelect.value = urlParams.get('group');
        if (!groupSelect.value && groupRows[0]) groupSelect.value = pick(groupRows[0], 'Группа_ID') || '';
        return curatorGroupId;
    }

    async function loadStudents() {
        var studentSelect = document.getElementById('student-select');
        var curatorId = curatorIdCache || await resolveCuratorId();
        if (!curatorId) return;
        var r = await callAPI('ПолучитьСтудентовПоКуратору', { Куратор_ID: curatorId }).catch(function(){ return null; });
        studentsCache = r && r.success && Array.isArray(r.data) ? r.data : [];
        var group = document.getElementById('group-select').value;
        var rows = group ? studentsCache.filter(function(row){ return String(pick(row,'Группа_ID') || '') === String(group); }) : studentsCache;
        studentSelect.innerHTML = '<option value="">Все студенты</option>' + rows.map(function(row) {
            var id = pick(row,'Студент_ID') || '';
            var fio = pick(row,'ФИО','Студент','Имя') || id;
            return '<option value="' + esc(id) + '">' + esc(fio) + '</option>';
        }).join('');
        if (urlParams.get('student')) {
            document.getElementById('report-type').value = 'student';
            studentSelect.value = urlParams.get('student');
        }
    }

    document.getElementById('build-btn').addEventListener('click', async function() {
        var dateFrom = document.getElementById('date-from').value;
        var dateTo   = document.getElementById('date-to').value;
        var hint     = document.getElementById('hint');
        var loading  = document.getElementById('loading');
        var error    = document.getElementById('error');
        var wrap     = document.getElementById('report-wrap');
        var expBtn   = document.getElementById('export-btn');

        hint.style.display = 'none'; error.style.display = 'none'; wrap.style.display = 'none';
        loading.style.display = 'flex';

        try {
            var reportType = document.getElementById('report-type').value;
            var groupId = document.getElementById('group-select').value;
            var studentId = document.getElementById('student-select').value;
            var action = 'СформироватьОтчетПоГруппе';
            var reportParams = {};

            if (reportType === 'student') {
                if (!studentId) throw new Error('Выберите студента для отчёта.');
                action = 'СформироватьОтчетПоСтуденту';
                reportParams = { Студент_ID: parseInt(studentId, 10), НачалоПериода: dateFrom, КонецПериода: dateTo };
            } else if (reportType === 'custom') {
                action = 'СформироватьПроизвольныйОтчет';
                reportParams = { ДатаНачала: dateFrom, ДатаКонца: dateTo, Лимит: 1000 };
                if (groupId) reportParams['Группа_ID'] = parseInt(groupId, 10);
                if (studentId) reportParams['Студент_ID'] = parseInt(studentId, 10);
                if (!groupId && !studentId) throw new Error('Для произвольного отчёта выберите группу или студента.');
            } else {
                if (!groupId) throw new Error('Выберите группу для отчёта.');
                reportParams = { Группа_ID: parseInt(groupId, 10), НачалоПериода: dateFrom, КонецПериода: dateTo };
            }

            var r = await callAPI(action, reportParams);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = (r && r.message ? r.message : 'Ошибка'); error.style.display = 'flex'; return;
            }

            var rowsData = rows(r.data);
            var avg = 0, risk = 0, crit = 0;
            rowsData.forEach(function(row) {
                var pct = parseFloat(pick(row,'Процент','ПроцентПосещаемости','ОбщийПроцентПосещаемости','СреднийПроцентПосещаемости','Посещаемость_Процент') || 0);
                avg += pct;
                if (pct < window.AIS.riskThresh && pct >= window.AIS.critThresh) risk++;
                if (pct < window.AIS.critThresh) crit++;
            });
            if (rowsData.length) avg = Math.round(avg / rowsData.length);

            document.getElementById('r-avg').textContent   = avg + '%';
            document.getElementById('r-total').textContent = rowsData.length;
            document.getElementById('r-risk').textContent  = risk;
            document.getElementById('r-crit').textContent  = crit;

            var html = '';
            rowsData.forEach(function(row) {
                var fio       = pick(row,'ФИО_Студента','ФИО','Студент','Имя') || (pick(row,'Дисциплина') ? (pick(row,'Дисциплина') + ' / ' + (pick(row,'Дата_Занятия','Дата') || '')) : '—');
                var total     = pick(row,'Всего_Занятий','Всего','ВсегоЗанятий','ВсегоСтудентовВГруппе') || '—';
                var present   = pick(row,'Присутствовал','Кол_Присутствий') || '—';
                var absent    = pick(row,'Отсутствовал','Кол_Отсутствий') || '—';
                var late      = pick(row,'Опоздал','Кол_Опозданий') || '—';
                var justified = pick(row,'Уважительных','Уважительные','УважительнаяПричина') || '—';
                var pct       = parseFloat(pick(row,'Процент','ПроцентПосещаемости','ОбщийПроцентПосещаемости','СреднийПроцентПосещаемости','Посещаемость_Процент') || 0);
                var badge     = pct >= window.AIS.riskThresh ? '<span class="badge b-ok">Норма</span>' : pct >= window.AIS.critThresh ? '<span class="badge b-warn">Риск</span>' : '<span class="badge b-err">Критично</span>';
                var pctClass  = pct < window.AIS.critThresh ? 'status-text-err' : pct < window.AIS.riskThresh ? 'status-text-warn' : 'status-text-ok';

                html += '<tr><td>' + esc(fio) + '</td><td>' + esc(String(total)) + '</td><td>' + esc(String(present)) + '</td><td>' + esc(String(absent)) + '</td><td>' + esc(String(late)) + '</td><td>' + esc(String(justified)) + '</td>';
                html += '<td><strong class="' + pctClass + '">' + Math.round(pct) + '%</strong></td>';
                html += '<td>' + badge + '</td></tr>';
            });

            document.getElementById('report-tbody').innerHTML = html || '<tr><td colspan="8" class="table-empty-sm">Нет данных</td></tr>';
            wrap.style.display = '';
            expBtn.style.display = '';

        } catch(err) {
            console.error(err);
            loading.style.display = 'none';
            error.textContent = err && err.message ? err.message : 'Ошибка соединения.'; error.style.display = 'flex';
        }
    });

    document.getElementById('export-btn').addEventListener('click', async function() {
        var dateFrom = document.getElementById('date-from').value;
        var dateTo   = document.getElementById('date-to').value;
        var params   = { Дата_Начала: dateFrom, Дата_Конца: dateTo };
        var groupId  = document.getElementById('group-select').value;
        if (groupId) params['Группа_ID'] = parseInt(groupId, 10);

        var r = await callAPI('ЭкспортОтчетаВCSV', params);
        if (r && r.success && r.data) {
            var csvData = r.data[0] ? (r.data[0]['csv'] || r.data[0]['CSV_Данные'] || '') : '';
            if (csvData) {
                var blob = new Blob([csvData], {type:'text/csv;charset=utf-8;'});
                var url  = URL.createObjectURL(blob);
                var a    = document.createElement('a');
                a.href = url; a.download = 'group_report.csv'; a.click();
                URL.revokeObjectURL(url);
            }
        }
    });
    document.getElementById('group-select').addEventListener('change', loadStudents);
    loadGroupsAndStudents().then(loadStudents);
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

