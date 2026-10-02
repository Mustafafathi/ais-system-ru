<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'Посещаемость';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">История посещаемости</div>
        <div class="page-sub" id="att-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <input type="date" id="date-from" class="form-ctrl control-auto">
        <input type="date" id="date-to"   class="form-ctrl control-auto">
        <button class="btn btn-primary btn-sm" id="filter-btn">Применить</button>
    </div>
</div>

<div class="alert alert-info" id="att-loading">Загрузка данных...</div>
<div class="alert alert-err"  id="att-error"   style="display:none"></div>

<div class="tbl-wrap" id="att-wrap" style="display:none">
    <table>
        <thead>
            <tr>
                <th>Дата</th>
                <th>Дисциплина</th>
                <th>Преподаватель</th>
                <th>Статус</th>
                <th>Тип отметки</th>
                <th>Действие</th>
            </tr>
        </thead>
        <tbody id="att-tbody"></tbody>
    </table>
</div>

<div class="pagination-row" id="att-footer" style="display:none">
    <span class="text-sm text-muted" id="att-count"></span>
    <div class="pagination-actions">
        <button class="btn btn-outline btn-sm" id="prev-page">Назад</button>
        <span class="text-sm page-counter" id="att-page-info"></span>
        <button class="btn btn-outline btn-sm" id="next-page">Вперёд</button>
    </div>
</div>

<script>
(function () {
    'use strict';

    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var PAGE_SIZE = 20;
    var currentPage = 1;
    var totalRows = 0;

    // Default dates: current month
    var now = new Date();
    var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    var lastDay  = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    function toInputDate(d) {
        return d.toISOString().slice(0,10);
    }

    document.getElementById('date-from').value = toInputDate(firstDay);
    document.getElementById('date-to').value   = toInputDate(lastDay);

    // Pre-select session from URL
    var urlParams = new URLSearchParams(window.location.search);
    var preSessionId = urlParams.get('z');

    function statusBadge(status) {
        var s = String(status||'').toLowerCase();
        if (s.includes('присутств'))  return '<span class="badge b-ok">Присутствовал</span>';
        if (s.includes('отсутств'))   return '<span class="badge b-err">Отсутствовал</span>';
        if (s.includes('опозда'))     return '<span class="badge b-warn">Опоздал</span>';
        if (s.includes('уважит') || s.includes('обоснов')) return '<span class="badge b-info">Уважительная</span>';
        return '<span class="badge b-muted">' + esc(status) + '</span>';
    }

    function markTypeBadge(type) {
        if (window.AISRoleUI && typeof window.AISRoleUI.sourceBadge === 'function') {
            return window.AISRoleUI.sourceBadge(type);
        }
        if (!type) return '—';
        return '<span class="tag">' + esc(type) + '</span>';
    }

    function syncBadge(status) {
        var s = String(status || '').toLowerCase();
        if (!s) return '';
        if (s.includes('очеред') || s.includes('queued')) return '<div class="text-sm mt-1"><span class="badge b-warn">В очереди</span></div>';
        if (s.includes('синх') || s.includes('synced')) return '<div class="text-sm mt-1"><span class="badge b-ok">Синхронизировано</span></div>';
        if (s.includes('offline') || s.includes('офлайн')) return '<div class="text-sm mt-1"><span class="badge b-warn">Офлайн</span></div>';
        return '<div class="text-sm mt-1"><span class="tag">' + esc(status) + '</span></div>';
    }

    function formatRuDate(value) {
        if (!value) return '';
        var d = new Date(value);
        if (Number.isNaN(d.getTime())) return value;
        return d.toLocaleDateString('ru-RU');
    }

    async function load(page) {
        currentPage = page || 1;
        var loading = document.getElementById('att-loading');
        var error   = document.getElementById('att-error');
        var wrap    = document.getElementById('att-wrap');
        var footer  = document.getElementById('att-footer');
        var tbody   = document.getElementById('att-tbody');

        loading.style.display = 'flex';
        error.style.display   = 'none';
        wrap.style.display    = 'none';
        footer.style.display  = 'none';

        try {
            var studentId = parseInt(localStorage.getItem('ais_student_id')||'0', 10);
            if (!studentId) {
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    studentId = pick(sess.data[0], 'Студент_ID', 'student_id') || 0;
                    if (studentId) localStorage.setItem('ais_student_id', studentId);
                }
            }

            var dateFrom = document.getElementById('date-from').value;
            var dateTo   = document.getElementById('date-to').value;

            var params = {
                Дата_Начала: dateFrom,
                Дата_Конца:  dateTo,
                Страница:    currentPage,
                Лимит:       PAGE_SIZE,
            };
            if (studentId) params['Студент_ID'] = studentId;
            if (preSessionId) { params['Занятие_ID'] = parseInt(preSessionId, 10); preSessionId = null; }

            // ПолучитьДетальныйОтчетПоСтуденту: Студент_ID, ДатаНачала, ДатаКонца
            var detailParams = { Студент_ID: params['Студент_ID'] || studentId };
            if (params['Дата_Начала']) detailParams['ДатаНачала'] = params['Дата_Начала'];
            if (params['Дата_Конца'])  detailParams['ДатаКонца']  = params['Дата_Конца'];
            var r = await callAPI('ПолучитьДетальныйОтчетПоСтуденту', detailParams);

            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = (r && r.message ? r.message : 'Ошибка загрузки');
                error.style.display = 'flex';
                return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];
            if (preSessionId) {
                rows = rows.filter(function(row) {
                    var zid = pick(row, 'Занятие_ID', 'id');
                    return !zid || String(zid) === String(preSessionId);
                });
                preSessionId = null;
            }
            totalRows = (r.total !== undefined) ? r.total : rows.length;

            document.getElementById('att-sub').textContent = 'Записей: ' + totalRows;

            if (rows.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="table-empty">Нет записей за выбранный период</td></tr>';
            } else {
                var html = '';
                rows.forEach(function(row) {
                    var date   = pick(row,'Дата_Занятия','Дата','date') || '';
                    var subj   = pick(row,'Дисциплина','Название_Дисциплины') || '';
                    var teach  = pick(row,'Преподаватель','ФИО_Преподавателя') || '';
                    var status = pick(row,'СтатусПосещения','Статус_Посещения','Статус','status') || '';
                    var mtype  = pick(row,'Тип_Отметки','Способ') || '';
                    var sync   = pick(row,'Статус_Синхронизации','Синхронизация','Очередь','offline_status') || '';
                    var zid    = pick(row,'Занятие_ID') || '';
                    var excuse = pick(row,'СтатусОбоснования','Статус_Обоснования') || '';

                    html += '<tr>';
                    html += '<td>' + esc(formatRuDate(date)) + '</td>';
                    html += '<td>' + esc(subj) + '</td>';
                    html += '<td class="text-muted">' + esc(teach) + '</td>';
                    html += '<td>' + statusBadge(status) + (excuse ? '<div class="text-muted text-sm">' + esc(excuse) + '</div>' : '') + '</td>';
                    html += '<td>' + markTypeBadge(mtype) + syncBadge(sync) + '</td>';
                    html += '<td>';
                    if (status && status.toLowerCase().includes('отсутств') && !excuse) {
                        html += '<a href="/ais-system-ru/student/excuse-form.php' + (zid ? '?z='+esc(zid) : '') + '" class="btn btn-sm btn-outline">Подать обоснование</a>';
                    } else {
                        html += '—';
                    }
                    html += '</td>';
                    html += '</tr>';
                });
                tbody.innerHTML = html;
            }

            wrap.style.display   = '';
            footer.style.display = 'flex';

            var totalPages = Math.max(1, Math.ceil(totalRows / PAGE_SIZE));
            document.getElementById('att-count').textContent = 'Показано ' + rows.length + ' из ' + totalRows + ' записей';
            document.getElementById('att-page-info').textContent = 'Стр. ' + currentPage + ' / ' + totalPages;
            document.getElementById('prev-page').disabled = (currentPage <= 1);
            document.getElementById('next-page').disabled = (currentPage >= totalPages);

        } catch (err) {
            console.error(err);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.';
            error.style.display = 'flex';
        }
    }

    document.getElementById('filter-btn').addEventListener('click', function() { load(1); });
    document.getElementById('prev-page').addEventListener('click', function() { if (currentPage > 1) load(currentPage - 1); });
    document.getElementById('next-page').addEventListener('click', function() { load(currentPage + 1); });

    load(1);
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

