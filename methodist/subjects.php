<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Методист');
$page_title = 'Дисциплины';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Дисциплины</div>
        <div class="page-sub">Учебные предметы и их преподаватели</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск дисциплины..." style="width:220px">
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка дисциплин...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>
<div class="alert alert-ok" id="success" style="display:none"></div>

<div class="card" style="margin-bottom:16px">
    <div class="card-hdr"><span class="card-title">Новая дисциплина</span></div>
    <div class="card-body">
        <div class="form-grid">
            <input type="text" class="form-ctrl" id="new-name" placeholder="Название">
            <input type="text" class="form-ctrl" id="new-code" placeholder="Код">
            <select class="form-ctrl" id="new-teacher"><option value="">Преподаватель</option></select>
            <input type="number" min="1" max="12" class="form-ctrl" id="new-semester" value="1" placeholder="Семестр">
            <button class="btn btn-primary" id="create-btn">Создать</button>
        </div>
    </div>
</div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Дисциплина</th>
                    <th>Преподаватель</th>
                    <th>Кредиты / Часы</th>
                    <th>Тип</th>
                    <th>Статус</th>
                </tr>
            </thead>
            <tbody id="subjects-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">D</div>
    <div class="empty-title">Нет дисциплин</div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var allRows = [];

    async function currentUserId() {
        var id = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        if (id) return id;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        id = pick(row, 'Пользователь_ID', 'user_id') || 0;
        if (id) localStorage.setItem('ais_user_id', id);
        return id;
    }

    async function loadTeachers() {
        var r = await callAPI('ПолучитьПреподавателей', {});
        if (!r || !r.success) return;
        var sel = document.getElementById('new-teacher');
        (Array.isArray(r.data) ? r.data : []).forEach(function(row) {
            var id = pick(row,'Преподаватель_ID','id');
            var fio = pick(row,'ФИО','Имя','Преподаватель');
            if (!id || !fio) return;
            var opt = document.createElement('option');
            opt.value = id;
            opt.textContent = fio;
            sel.appendChild(opt);
        });
    }

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        loading.style.display = 'flex'; error.style.display = 'none';

        try {
            var r = await callAPI('ПолучитьДисциплиныПреподавателя', {});
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка загрузки';
                error.style.display = 'flex'; return;
            }

            allRows = Array.isArray(r.data) ? r.data : [];
            render(allRows);

        } catch(e) {
            console.error(e);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.'; error.style.display = 'flex';
        }
    }

    function render(rows) {
        var wrap  = document.getElementById('list-wrap');
        var empty = document.getElementById('empty');

        wrap.style.display = 'none';
        empty.style.display = 'none';
        if (!rows || rows.length === 0) { empty.style.display = 'flex'; return; }

        var html = '';
        rows.forEach(function(row, idx) {
            var name    = pick(row,'Дисциплина','Название_Дисциплины','Предмет') || '—';
            var teacher = pick(row,'Преподаватель','ФИО_Преподавателя') || '—';
            var credits = pick(row,'Кредиты','Часы','hours') || '—';
            var type    = pick(row,'Тип','Тип_Занятия') || '—';
            var status  = pick(row,'Статус','Активна') || 'Активна';

            html += '<tr>';
            html += '<td>' + (idx+1) + '</td>';
            html += '<td><strong>' + esc(name) + '</strong></td>';
            html += '<td>' + esc(teacher) + '</td>';
            html += '<td>' + esc(String(credits)) + '</td>';
            html += '<td><span class="tag">' + esc(type) + '</span></td>';
            html += '<td>' + (window.AISRoleUI ? window.AISRoleUI.badge(status) : '<span class="badge b-muted">' + esc(status) + '</span>') + '</td>';
            html += '</tr>';
        });

        document.getElementById('subjects-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    document.getElementById('search-input').addEventListener('input', function() {
        var q = this.value.toLowerCase();
        var filtered = allRows.filter(function(row) {
            var name = String(pick(row,'Дисциплина','Название_Дисциплины','Предмет') || '').toLowerCase();
            return name.includes(q);
        });
        render(filtered);
    });

    document.getElementById('create-btn').addEventListener('click', async function() {
        var error = document.getElementById('error');
        var success = document.getElementById('success');
        error.style.display = 'none'; success.style.display = 'none';

        var name = document.getElementById('new-name').value.trim();
        var code = document.getElementById('new-code').value.trim();
        var teacher = parseInt(document.getElementById('new-teacher').value || '0', 10);
        var semester = parseInt(document.getElementById('new-semester').value || '1', 10);
        if (!name || !teacher) {
            error.textContent = 'Укажите название и преподавателя.';
            error.style.display = 'flex';
            return;
        }

        try {
            var params = {
                Название: name,
                Преподаватель_ID: teacher,
                Семестр: semester,
                КтоСоздал: await currentUserId()
            };
            if (code) params['Код_Дисциплины'] = code;
            var r = await callAPI('СоздатьДисциплину', params);
            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка создания';
                error.style.display = 'flex';
                return;
            }
            var row = Array.isArray(r.data) ? r.data[0] : null;
            success.textContent = row && row.Сообщение ? row.Сообщение : 'Дисциплина создана.';
            success.style.display = 'flex';
            document.getElementById('new-name').value = '';
            document.getElementById('new-code').value = '';
            await load();
        } catch(e) {
            error.textContent = 'Ошибка соединения.';
            error.style.display = 'flex';
        }
    });

    loadTeachers();
    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

