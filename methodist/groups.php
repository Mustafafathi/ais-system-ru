<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Методист');
$page_title = 'Учебные группы';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Учебные группы</div>
        <div class="page-sub">Управление группами факультета</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск группы..." style="width:200px">
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка групп...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>
<div class="alert alert-ok" id="success" style="display:none"></div>

<div class="card" style="margin-bottom:16px">
    <div class="card-hdr"><span class="card-title">Новая группа</span></div>
    <div class="card-body">
        <div class="form-grid">
            <input type="text" class="form-ctrl" id="new-name" placeholder="Название">
            <input type="number" class="form-ctrl" id="new-year" placeholder="Год поступления">
            <select class="form-ctrl" id="new-curator"><option value="">Куратор</option></select>
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
                    <th>Название группы</th>
                    <th>Специальность</th>
                    <th>Курс</th>
                    <th>Студентов</th>
                    <th>Куратор</th>
                    <th>Статус</th>
                </tr>
            </thead>
            <tbody id="groups-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">G</div>
    <div class="empty-title">Нет групп</div>
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

    async function loadCurators() {
        var r = await callAPI('ПолучитьПреподавателей', {});
        if (!r || !r.success) return;
        var sel = document.getElementById('new-curator');
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
            var r = await callAPI('ПолучитьУчебныеГруппы', {});
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
            var name     = pick(row,'Группа','Название_Группы','Название') || '—';
            var spec     = pick(row,'Специальность','Направление') || '—';
            var course   = pick(row,'Курс','course','Год_Поступления') || '—';
            var students = pick(row,'Студентов','Кол_Студентов','КоличествоСтудентов') || 0;
            var curator  = pick(row,'Куратор','ФИО_Куратора') || '—';
            var rawStatus = pick(row,'Статус');
            var status;
            if (rawStatus === null || rawStatus === undefined || rawStatus === '') {
                status = 'Активна';
            } else if (typeof rawStatus === 'number' || typeof rawStatus === 'boolean') {
                status = (rawStatus ? 'Активна' : 'Неактивна');
            } else {
                status = String(rawStatus);
            }

            html += '<tr>';
            html += '<td>' + (idx+1) + '</td>';
            html += '<td><strong>' + esc(name) + '</strong></td>';
            html += '<td>' + esc(spec) + '</td>';
            html += '<td><span class="tag">' + esc(String(course)) + ' курс</span></td>';
            html += '<td>' + esc(String(students)) + '</td>';
            html += '<td>' + esc(curator) + '</td>';
            html += '<td>' + (window.AISRoleUI ? window.AISRoleUI.badge(status) : '<span class="badge b-muted">' + esc(status) + '</span>') + '</td>';
            html += '</tr>';
        });

        document.getElementById('groups-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    document.getElementById('search-input').addEventListener('input', function() {
        var q = this.value.toLowerCase();
        var filtered = allRows.filter(function(row) {
            var name = String(pick(row,'Группа','Название_Группы','Название') || '').toLowerCase();
            return name.includes(q);
        });
        render(filtered);
    });

    document.getElementById('create-btn').addEventListener('click', async function() {
        var error = document.getElementById('error');
        var success = document.getElementById('success');
        error.style.display = 'none'; success.style.display = 'none';

        var name = document.getElementById('new-name').value.trim();
        var year = parseInt(document.getElementById('new-year').value || '0', 10);
        var curator = parseInt(document.getElementById('new-curator').value || '0', 10);
        if (!name || !year) {
            error.textContent = 'Укажите название и год поступления.';
            error.style.display = 'flex';
            return;
        }

        try {
            var params = { Название: name, Год_Поступления: year, КтоСоздал: await currentUserId() };
            if (curator) params['Куратор_ID'] = curator;
            var r = await callAPI('СоздатьУчебнуюГруппу', params);
            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка создания';
                error.style.display = 'flex';
                return;
            }
            var row = Array.isArray(r.data) ? r.data[0] : null;
            success.textContent = row && row.Сообщение ? row.Сообщение : 'Группа создана.';
            success.style.display = 'flex';
            document.getElementById('new-name').value = '';
            await load();
        } catch(e) {
            error.textContent = 'Ошибка соединения.';
            error.style.display = 'flex';
        }
    });

    loadCurators();
    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

