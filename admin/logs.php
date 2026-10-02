<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Журнал действий';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Журнал действий</div>
        <div class="page-sub">Аудит действий пользователей</div>
    </div>
    <div class="page-actions">
        <input type="text"  class="form-ctrl" id="search-input" placeholder="Поиск по действию / пользователю..." style="width:260px">
        <select class="form-ctrl" id="status-filter" style="width:auto">
            <option value="">Все статусы</option>
            <option value="Успешно">Успешно</option>
            <option value="Предупреждение">Предупреждение</option>
            <option value="Ошибка">Ошибка</option>
        </select>
        <select class="form-ctrl" id="level-filter" style="width:auto">
            <option value="">Все уровни</option>
            <option value="Информация">Информация</option>
            <option value="Предупреждение">Предупреждение</option>
            <option value="Ошибка">Ошибка</option>
        </select>
        <input type="date"  class="form-ctrl" id="date-from" style="width:auto">
        <input type="date"  class="form-ctrl" id="date-to"   style="width:auto">
        <button class="btn btn-outline btn-sm" id="refresh-btn">Обновить</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка журнала...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Время</th>
                    <th>Пользователь</th>
                    <th>Роль</th>
                    <th>Действие</th>
                    <th>IP</th>
                    <th>Статус</th>
                </tr>
            </thead>
            <tbody id="logs-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">LOG</div>
    <div class="empty-title">Записей не найдено</div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var allRows = [];

    var now = new Date();
    document.getElementById('date-from').value = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0,10);
    document.getElementById('date-to').value   = now.toISOString().slice(0,10);

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        loading.style.display = 'flex'; error.style.display = 'none';
        document.getElementById('list-wrap').style.display = 'none';
        document.getElementById('empty').style.display = 'none';

        try {
            var params = {
                НачалоПериода: document.getElementById('date-from').value,
                КонецПериода:  document.getElementById('date-to').value
            };
            if (document.getElementById('status-filter').value) params['Статус'] = document.getElementById('status-filter').value;
            if (document.getElementById('level-filter').value) params['Уровень_Лога'] = document.getElementById('level-filter').value;
            var r = await callAPI('ПолучитьЛогДействий', params);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка загрузки';
                error.style.display = 'flex'; return;
            }

            allRows = Array.isArray(r.data) ? r.data : [];
            applyFilter();

        } catch(e) {
            console.error(e);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.'; error.style.display = 'flex';
        }
    }

    function applyFilter() {
        var q = document.getElementById('search-input').value.toLowerCase();
        var statusFilter = document.getElementById('status-filter').value;
        var levelFilter = document.getElementById('level-filter').value;
        var filtered = allRows.filter(function(row) {
            var user   = String(pick(row,'Пользователь','ФИОПользователя','ЛогинПользователя','Логин','user') || '').toLowerCase();
            var action = String(pick(row,'Действие','action') || '').toLowerCase();
            var status = String(pick(row,'Статус') || '');
            var level = String(pick(row,'Уровень_Лога') || '');
            return (user.includes(q) || action.includes(q)) && (!statusFilter || status === statusFilter) && (!levelFilter || level === levelFilter);
        });
        render(filtered);
    }

    function render(rows) {
        var wrap  = document.getElementById('list-wrap');
        var empty = document.getElementById('empty');

        if (!rows || rows.length === 0) { empty.style.display = 'flex'; return; }

        var html = '';
        rows.forEach(function(row, idx) {
            var time   = pick(row,'Время','Дата_Время','Время_Действия','created_at') || '—';
            var user   = pick(row,'Пользователь','ФИОПользователя','ЛогинПользователя','Логин','user') || '—';
            var role   = pick(row,'Роль','Уровень_Лога','role') || '—';
            var action = pick(row,'Действие','action') || '—';
            var ip     = pick(row,'IP','IP_Адрес','ip_address') || '—';
            var status = pick(row,'Статус','Успех','success','is_success');
            var isError = (status === false || status === 0 || status === '0' || status === 'Ошибка');
            var badge  = window.AISRoleUI ? window.AISRoleUI.badge(status || 'Успех') : (isError ? '<span class="badge b-err">Ошибка</span>' : '<span class="badge b-ok">' + esc(status || 'Успех') + '</span>');

            html += '<tr>';
            html += '<td style="color:var(--c-muted)">' + (idx+1) + '</td>';
            html += '<td><span style="font-size:12px;color:var(--c-muted)">' + esc(time) + '</span></td>';
            html += '<td><strong>' + esc(user) + '</strong></td>';
            html += '<td><span class="tag">' + esc(role) + '</span></td>';
            html += '<td>' + esc(action) + '</td>';
            html += '<td><code style="font-size:11px">' + esc(ip) + '</code></td>';
            html += '<td>' + badge + '</td>';
            html += '</tr>';
        });

        document.getElementById('logs-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    document.getElementById('search-input').addEventListener('input', applyFilter);
    document.getElementById('status-filter').addEventListener('change', load);
    document.getElementById('level-filter').addEventListener('change', load);
    document.getElementById('refresh-btn').addEventListener('click', load);
    document.getElementById('date-from').addEventListener('change', load);
    document.getElementById('date-to').addEventListener('change', load);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

