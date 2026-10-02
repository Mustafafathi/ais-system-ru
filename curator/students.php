<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Куратор');
$page_title = 'Студенты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Мои студенты</div>
        <div class="page-sub" id="group-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-auto" id="group-filter">
            <option value="">Все группы</option>
        </select>
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск по имени..." style="width:220px">
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка студентов...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Студент</th>
                    <th>Группа</th>
                    <th>Посещаемость</th>
                    <th>Пропуски</th>
                    <th>Статус</th>
                    <th>Детали</th>
                </tr>
            </thead>
            <tbody id="students-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">S</div>
    <div class="empty-title">Нет студентов</div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var allRows = [];
    var groupMap = {};
    var urlParams = new URLSearchParams(window.location.search);

    async function resolveCuratorId() {
        var curatorId = parseInt(localStorage.getItem('ais_curator_id') || localStorage.getItem('ais_teacher_id') || '0', 10);
        if (curatorId) return curatorId;

        var sess = await callAPI('ПроверитьСессию', {});
        if (sess && sess.success && sess.data && sess.data[0]) {
            curatorId = pick(sess.data[0], 'Куратор_ID', 'curator_id', 'Преподаватель_ID', 'teacher_id') || 0;
            if (curatorId) {
                localStorage.setItem('ais_curator_id', curatorId);
                localStorage.setItem('ais_teacher_id', curatorId);
            }
            var grp = pick(sess.data[0],'Группа','Название_Группы') || '';
            if (grp) document.getElementById('group-sub').textContent = grp;
        }
        return parseInt(curatorId || '0', 10);
    }

    async function loadGroups(curatorId) {
        var select = document.getElementById('group-filter');
        if (!curatorId) return;
        var r = await callAPI('ПолучитьГруппыКуратора', { Куратор_ID: curatorId }).catch(function(){ return null; });
        var rows = r && r.success && Array.isArray(r.data) ? r.data : [];
        groupMap = {};
        select.innerHTML = '<option value="">Все группы</option>' + rows.map(function(row) {
            var id = pick(row,'Группа_ID') || '';
            var name = pick(row,'Название','Группа','Название_Группы') || id;
            if (id) groupMap[String(id)] = name;
            return '<option value="' + esc(id) + '">' + esc(name) + '</option>';
        }).join('');
        if (urlParams.get('group')) select.value = urlParams.get('group');
    }

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        loading.style.display = 'flex'; error.style.display = 'none';
        document.getElementById('list-wrap').style.display = 'none';
        document.getElementById('empty').style.display = 'none';

        try {
            var curatorId = await resolveCuratorId();
            if (!curatorId) {
                loading.style.display = 'none';
                error.textContent = 'Не удалось определить куратора. Войдите заново или проверьте привязку профиля.';
                error.style.display = 'flex';
                return;
            }
            await loadGroups(curatorId);
            var params = curatorId ? { Куратор_ID: curatorId } : {};
            var r = await callAPI('ПолучитьСтудентовПоКуратору', params);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка загрузки';
                error.style.display = 'flex'; return;
            }

            allRows = Array.isArray(r.data) ? r.data : [];
            applyFilters();

        } catch(e) {
            console.error(e);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.'; error.style.display = 'flex';
        }
    }

    function riskBadge(row) {
        var status = pick(row,'Серьёзность','Статус_Риска','Статус_Посещаемости','Статус');
        if (status) return window.AISRoleUI ? window.AISRoleUI.badge(status) : '<span class="badge b-muted">' + esc(status) + '</span>';
        var pctRaw = pick(row,'Процент','Посещаемость_Процент');
        if (pctRaw === null) return '<span class="badge b-muted">Нет оценки</span>';
        var pct = parseFloat(pctRaw);
        if (pct >= window.AIS.riskThresh) return '<span class="badge b-ok">Норма</span>';
        if (pct >= window.AIS.critThresh) return '<span class="badge b-warn">Риск</span>';
        return '<span class="badge b-err">Критично</span>';
    }

    function applyFilters() {
        var q = document.getElementById('search-input').value.toLowerCase();
        var group = document.getElementById('group-filter').value;
        var filtered = allRows.filter(function(row) {
            var fio = String(pick(row,'ФИО','Студент','Имя') || '').toLowerCase();
            var groupId = String(pick(row,'Группа_ID') || '');
            return fio.includes(q) && (!group || groupId === String(group));
        });
        render(filtered);
    }

    function render(rows) {
        var wrap  = document.getElementById('list-wrap');
        var empty = document.getElementById('empty');

        wrap.style.display = 'none';
        empty.style.display = 'none';
        if (!rows || rows.length === 0) { empty.style.display = 'flex'; return; }

        var html = '';
        rows.forEach(function(row, idx) {
            var fio    = pick(row,'ФИО','Студент','Имя') || '—';
            var groupId = pick(row,'Группа_ID') || '';
            var group  = pick(row,'Группа','Название_Группы') || groupMap[String(groupId)] || groupId || '—';
            var sid    = pick(row,'Студент_ID') || '';
            var pctRaw = pick(row,'Процент','Посещаемость_Процент');
            var pct    = pctRaw !== null ? parseFloat(pctRaw) : null;
            var absent = pick(row,'Пропуски','Кол_Отсутствий') || '—';
            var color  = pct === null ? '' : pct < window.AIS.critThresh ? 'color:var(--c-err)' : pct < window.AIS.riskThresh ? 'color:var(--c-warn)' : '';
            var badge  = riskBadge(row);

            html += '<tr>';
            html += '<td>' + (idx+1) + '</td>';
            html += '<td><strong>' + esc(fio) + '</strong></td>';
            html += '<td><span class="tag">' + esc(group) + '</span></td>';
            html += '<td><strong style="' + color + '">' + (pct === null ? '—' : Math.round(pct) + '%') + '</strong></td>';
            html += '<td>' + esc(String(absent)) + '</td>';
            html += '<td>' + badge + '</td>';
            html += '<td><a class="btn btn-outline btn-sm" href="/ais-system-ru/curator/reports.php' + (sid ? '?student=' + esc(sid) : '') + '">Отчёт</a></td>';
            html += '</tr>';
        });

        document.getElementById('students-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    document.getElementById('search-input').addEventListener('input', function() {
        applyFilters();
    });
    document.getElementById('group-filter').addEventListener('change', applyFilters);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

