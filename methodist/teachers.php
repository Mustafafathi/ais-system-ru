<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Методист');
$page_title = 'Преподаватели';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Преподаватели</div>
        <div class="page-sub">Каталог преподавателей факультета</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск по имени..." style="width:220px">
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка преподавателей...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Преподаватель</th>
                    <th>Кафедра</th>
                    <th>Должность</th>
                    <th>Email</th>
                    <th>Дисциплин</th>
                    <th>Статус</th>
                </tr>
            </thead>
            <tbody id="teachers-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">T</div>
    <div class="empty-title">Нет преподавателей</div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var allRows = [];

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        loading.style.display = 'flex'; error.style.display = 'none';

        try {
            var r = await callAPI('ПолучитьПреподавателей', {});
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
            var fio      = pick(row,'ФИО','Имя','Преподаватель') || '—';
            var dept     = pick(row,'Кафедра','Подразделение') || '—';
            var position = pick(row,'Должность','position') || '—';
            var email    = pick(row,'Email_Рабочий','Email','email') || '—';
            var subjects = pick(row,'Дисциплин','Кол_Дисциплин','КоличествоДисциплин') || 0;
            var active   = pick(row,'Активен','АктивенПользователь');
            var status   = active === 0 || active === false || String(active) === '0' ? 'Неактивен' : 'Активен';
            var ini = fio.split(' ').map(function(p){return p?p[0].toUpperCase():''}).join('').slice(0,2);

            html += '<tr>';
            html += '<td>' + (idx+1) + '</td>';
            html += '<td><div class="flex gap-2 items-center"><div class="avatar">' + esc(ini) + '</div><strong>' + esc(fio) + '</strong></div></td>';
            html += '<td>' + esc(dept) + '</td>';
            html += '<td>' + esc(position) + '</td>';
            html += '<td><span style="font-size:13px">' + esc(email) + '</span></td>';
            html += '<td><span class="tag">' + esc(String(subjects)) + '</span></td>';
            html += '<td>' + (window.AISRoleUI ? window.AISRoleUI.badge(status) : '<span class="badge b-muted">' + esc(status) + '</span>') + '</td>';
            html += '</tr>';
        });

        document.getElementById('teachers-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    document.getElementById('search-input').addEventListener('input', function() {
        var q = this.value.toLowerCase();
        var filtered = allRows.filter(function(row) {
            var fio = String(pick(row,'ФИО','Имя','Преподаватель') || '').toLowerCase();
            return fio.includes(q);
        });
        render(filtered);
    });

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

