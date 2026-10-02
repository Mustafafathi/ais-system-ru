<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Импорт / Экспорт';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Импорт / Экспорт данных</div>
        <div class="page-sub">Загрузка и выгрузка данных из системы</div>
    </div>
</div>

<div class="grid-2" style="max-width:900px">

    <!-- Import card -->
    <div class="card">
        <div class="card-hdr"><span class="card-title">Импорт из CSV</span></div>
        <div class="card-body">
            <div class="form-group">
                <label class="form-label">Тип импорта</label>
                <select class="form-ctrl" id="import-type">
                    <option value="groups">Группы</option>
                    <option value="students">Студенты</option>
                </select>
            </div>
            <div class="alert alert-info" id="import-format" style="margin-bottom:16px"></div>
            <div class="form-group">
                <label class="form-label">Файл CSV</label>
                <input type="file" class="form-ctrl" id="import-file" accept=".csv">
            </div>
            <div class="alert alert-ok"  id="import-ok"  style="display:none"></div>
            <div class="alert alert-err" id="import-err" style="display:none"></div>
            <button class="btn btn-primary btn-block" id="import-btn">Загрузить</button>
        </div>
    </div>

    <!-- Export card -->
    <div class="card">
        <div class="card-hdr"><span class="card-title">Экспорт данных</span></div>
        <div class="card-body" style="display:flex;flex-direction:column;gap:12px">
            <button class="btn btn-outline btn-block" id="exp-students-btn">Экспорт студентов</button>
            <button class="btn btn-outline btn-block" id="exp-teachers-btn">Экспорт преподавателей</button>
            <button class="btn btn-outline btn-block" id="exp-groups-btn">Экспорт групп</button>
            <button class="btn btn-outline btn-block" id="exp-attendance-btn">Экспорт посещаемости</button>
            <div class="alert alert-info">Большие выгрузки ограничиваются безопасным лимитом строк. Если данных нет или backend-экспорт недоступен, появится отдельное сообщение.</div>
            <div class="alert alert-err" id="export-err" style="display:none"></div>
        </div>
    </div>

</div>

<script>
(function () {
    'use strict';

    var importConfigs = {
        groups: {
            action: 'ИмпортГруппИзCSV',
            title: 'групп',
            format: 'Ожидаемый формат: <code>Название;Год_Поступления;Код_Специальности</code>. Первый ряд может быть заголовком.'
        },
        students: {
            action: 'ИмпортСтудентовИзCSV',
            title: 'студентов',
            format: 'Ожидаемый формат: <code>ФИО;Группа;Логин;Пароль;Email</code>. Дополнительные поля после Email допускаются.'
        }
    };

    function currentImportConfig() {
        var type = document.getElementById('import-type').value || 'groups';
        return importConfigs[type] || importConfigs.groups;
    }

    function updateImportFormat() {
        document.getElementById('import-format').innerHTML = currentImportConfig().format;
    }

    async function currentUserId() {
        var id = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        if (id) return id;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        id = row['Пользователь_ID'] || row['user_id'] || 0;
        if (id) localStorage.setItem('ais_user_id', id);
        return id;
    }

    updateImportFormat();
    document.getElementById('import-type').addEventListener('change', updateImportFormat);

    function renderImportSummary(kind, r) {
        var firstSet = r && r.data && r.data[0] ? r.data[0] : null;
        var row = Array.isArray(firstSet) ? (firstSet[0] || null) : firstSet;
        if (!row) {
            return 'Импорт ' + kind + ' завершён.';
        }

        var added   = row['Добавлено'] || row['Imported'] || row['Импортировано'] || 0;
        var skipped = row['Пропущено'] || row['Skipped'] || 0;
        var errors  = row['Ошибок'] || row['ErrorCount'] || 0;
        var msg     = row['Сообщение'] || row['Message'] || '';
        var parts   = ['Импорт ' + kind + ' завершён.'];

        if (added)   parts.push('Добавлено: ' + added);
        if (skipped) parts.push('Пропущено: ' + skipped);
        if (errors)  parts.push('Ошибок: ' + errors);
        if (msg)     parts.push(msg);

        return parts.join(' ');
    }

    document.getElementById('import-btn').addEventListener('click', async function() {
        var btn   = this;
        var file  = document.getElementById('import-file').files[0];
        var okEl  = document.getElementById('import-ok');
        var errEl = document.getElementById('import-err');
        okEl.style.display = 'none'; errEl.style.display = 'none';

        if (!file) { errEl.textContent = 'Выберите файл.'; errEl.style.display = 'flex'; return; }

        var config = currentImportConfig();
        var reader = new FileReader();
        reader.onload = async function(e) {
            var csvContent = e.target.result;
            btn.disabled = true; btn.textContent = 'Загрузка...';
            try {
                var params = {
                    CSV_Содержимое: csvContent,
                    CSV_Данные: csvContent,
                    Имя_Файла: file.name,
                    Пользователь_ID: await currentUserId()
                };
                var r = await callAPI(config.action, params);
                if (r && r.success) {
                    okEl.textContent = renderImportSummary(config.title, r);
                    okEl.style.display = 'flex';
                    document.getElementById('import-file').value = '';
                } else {
                    errEl.textContent = r && r.message ? r.message : 'Ошибка импорта.';
                    errEl.style.display = 'flex';
                }
            } catch(e) {
                errEl.textContent = 'Ошибка соединения.'; errEl.style.display = 'flex';
            } finally {
                btn.disabled = false; btn.textContent = 'Загрузить';
            }
        };
        reader.readAsText(file, 'utf-8');
    });

    async function exportData(action, filename) {
        var errEl = document.getElementById('export-err');
        errEl.style.display = 'none';
        try {
            var r = await callAPI(action, {});
            if (r && r.success && r.data) {
                var csvData = r.data[0] ? (r.data[0]['csv'] || r.data[0]['CSV_Данные'] || '') : '';
                if (csvData) {
                    var blob = new Blob([csvData], {type:'text/csv;charset=utf-8;'});
                    var url  = URL.createObjectURL(blob);
                    var a    = document.createElement('a');
                    a.href = url; a.download = filename; a.click();
                    URL.revokeObjectURL(url);
                } else {
                    errEl.textContent = 'Нет данных для экспорта.'; errEl.style.display = 'flex';
                }
            } else {
                errEl.textContent = r && r.message ? r.message : 'Ошибка экспорта.';
                errEl.style.display = 'flex';
            }
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.'; errEl.style.display = 'flex';
        }
    }

    function rowsFromResponse(r) {
        if (!r || !r.data) return [];
        if (Array.isArray(r.data) && Array.isArray(r.data[0])) return r.data[0];
        if (Array.isArray(r.data)) return r.data;
        return [];
    }

    function csvEscape(value) {
        var s = String(value == null ? '' : value);
        return /[;"\r\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
    }

    function downloadCsv(rows, columns, filename) {
        if (!rows.length) {
            var errEl = document.getElementById('export-err');
            errEl.textContent = 'Нет данных для экспорта.';
            errEl.style.display = 'flex';
            return;
        }
        var csv = columns.map(function(c){ return csvEscape(c.label); }).join(';') + '\r\n';
        rows.forEach(function(row) {
            csv += columns.map(function(c){ return csvEscape(row[c.key]); }).join(';') + '\r\n';
        });
        var blob = new Blob(['\ufeff' + csv], {type:'text/csv;charset=utf-8;'});
        var url  = URL.createObjectURL(blob);
        var a    = document.createElement('a');
        a.href = url; a.download = filename; a.click();
        URL.revokeObjectURL(url);
    }

    async function exportRows(action, params, columns, filename) {
        var errEl = document.getElementById('export-err');
        errEl.style.display = 'none';
        try {
            var r = await callAPI(action, params || {});
            if (!r || !r.success) {
                errEl.textContent = r && r.message ? r.message : 'Ошибка экспорта.';
                errEl.style.display = 'flex';
                return;
            }
            downloadCsv(rowsFromResponse(r), columns, filename);
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.';
            errEl.style.display = 'flex';
        }
    }

    async function exportAttendance() {
        var errEl = document.getElementById('export-err');
        errEl.style.display = 'none';
        try {
            var now = new Date();
            var from = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0,10);
            var to = now.toISOString().slice(0,10);
            var r = await callAPI('ЭкспортПосещаемостиВCSV', { ДатаНачала: from, ДатаКонца: to });
            var out = r && r.data && r.data._output ? r.data._output : null;
            var csvData = out ? (out['CSV_Содержимое'] || '') : '';
            if (!csvData && r && Array.isArray(r.data) && r.data[0]) {
                csvData = r.data[0]['CSV_Содержимое'] || r.data[0]['CSV_Данные'] || '';
            }
            if (!r || !r.success || !csvData) {
                errEl.textContent = r && r.message ? r.message : 'Нет данных для экспорта.';
                errEl.style.display = 'flex';
                return;
            }
            var blob = new Blob(['\ufeff' + csvData], {type:'text/csv;charset=utf-8;'});
            var url  = URL.createObjectURL(blob);
            var a    = document.createElement('a');
            a.href = url; a.download = 'attendance.csv'; a.click();
            URL.revokeObjectURL(url);
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.';
            errEl.style.display = 'flex';
        }
    }

    document.getElementById('exp-students-btn').addEventListener('click', function() {
        exportRows('ПоискСтудентов', { ТолькоАктивные: 0, РазмерСтраницы: 1000 }, [
            {key:'Студент_ID', label:'ID'}, {key:'ФИО', label:'ФИО'}, {key:'Название_Группы', label:'Группа'},
            {key:'Логин', label:'Логин'}, {key:'Email', label:'Email'}, {key:'Активен', label:'Активен'}
        ], 'students.csv');
    });
    document.getElementById('exp-teachers-btn').addEventListener('click', function() {
        exportRows('ПолучитьПреподавателей', { ТолькоАктивные: 0 }, [
            {key:'Преподаватель_ID', label:'ID'}, {key:'ФИО', label:'ФИО'}, {key:'Кафедра', label:'Кафедра'},
            {key:'Должность', label:'Должность'}, {key:'Email', label:'Email'}, {key:'Активен', label:'Активен'}
        ], 'teachers.csv');
    });
    document.getElementById('exp-groups-btn').addEventListener('click', function() {
        exportRows('ПолучитьУчебныеГруппы', {}, [
            {key:'Группа_ID', label:'ID'}, {key:'Название', label:'Группа'}, {key:'Год_Поступления', label:'Год поступления'},
            {key:'Статус', label:'Статус'}, {key:'ФИО_Куратора', label:'Куратор'}, {key:'КоличествоСтудентов', label:'Студентов'}
        ], 'groups.csv');
    });
    document.getElementById('exp-attendance-btn').addEventListener('click', exportAttendance);
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

