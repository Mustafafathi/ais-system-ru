<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'Обоснования';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Обоснования отсутствий</div>
        <div class="page-sub">Заявки от студентов ваших групп</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl" id="status-filter" style="width:auto">
            <option value="">Все статусы</option>
            <option value="Ожидает">Ожидает</option>
            <option value="Одобрено">Одобрено</option>
            <option value="Отклонено">Отклонено</option>
        </select>
        <button class="btn btn-outline btn-sm" id="refresh-btn">Обновить</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка обоснований...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>
<div class="alert alert-ok" id="result" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>Студент</th>
                    <th>Занятие / Дата</th>
                    <th>Причина</th>
                    <th>Документ</th>
                    <th>Подано</th>
                    <th>Статус</th>
                    <th>Действие</th>
                </tr>
            </thead>
            <tbody id="excuses-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">E</div>
    <div class="empty-title">Нет обоснований</div>
    <div class="empty-sub">Студенты ещё не подавали заявок</div>
</div>

<!-- Modal: review -->
<div class="modal-overlay" id="review-modal" style="display:none">
    <div class="modal" style="max-width:520px">
        <div class="modal-hdr">
            <span class="modal-title">Рассмотреть обоснование</span>
            <button class="modal-close" id="modal-close">✕</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label">Студент</label>
                <div id="m-student" class="form-static"></div>
            </div>
            <div class="form-group">
                <label class="form-label">Занятие</label>
                <div id="m-lesson" class="form-static"></div>
            </div>
            <div class="form-group">
                <label class="form-label">Причина обращения</label>
                <div id="m-reason" class="form-static" style="white-space:pre-wrap"></div>
            </div>
            <div class="form-group" id="m-doc-wrap" style="display:none">
                <label class="form-label">Документ</label>
                <span class="tag">Прикреплён</span>
            </div>
            <div class="form-group">
                <label class="form-label">Комментарий (необязательно)</label>
                <textarea class="form-ctrl" id="m-comment" rows="3" placeholder="Укажите причину решения..."></textarea>
            </div>
            <div class="alert alert-err" id="m-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="modal-close2">Отмена</button>
            <button class="btn btn-danger"  id="reject-btn">✗ Отклонить</button>
            <button class="btn btn-primary" id="approve-btn">✓ Одобрить</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var currentExcuseId = null;

    function statusBadge(s) {
        s = String(s || '');
        if (s === 'Одобрено')  return '<span class="badge b-ok">Одобрено</span>';
        if (s === 'Отклонено') return '<span class="badge b-err">Отклонено</span>';
        return '<span class="badge b-warn">Ожидает</span>';
    }

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        var wrap    = document.getElementById('list-wrap');
        var empty   = document.getElementById('empty');

        loading.style.display = 'flex';
        error.style.display   = 'none';
        document.getElementById('result').style.display = 'none';
        wrap.style.display    = 'none';
        empty.style.display   = 'none';

        try {
            var teacherId = parseInt(localStorage.getItem('ais_teacher_id')||'0', 10);
            if (!teacherId) {
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    teacherId = pick(sess.data[0], 'Преподаватель_ID', 'teacher_id') || 0;
                    if (teacherId) localStorage.setItem('ais_teacher_id', teacherId);
                }
            }

            if (!teacherId) {
                loading.style.display = 'none';
                error.textContent = 'Не удалось определить преподавателя. Войдите заново или проверьте привязку профиля.';
                error.style.display = 'flex';
                return;
            }

            var params = teacherId ? { Преподаватель_ID: teacherId } : {};
            var statusVal = document.getElementById('status-filter').value;
            if (statusVal) params['Статус'] = statusVal;

            var r = await callAPI('ПолучитьСписокОбоснований', params);
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка загрузки';
                error.style.display = 'flex'; return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];
            if (rows.length === 0) { empty.style.display = 'flex'; return; }

            var html = '';
            rows.forEach(function(row) {
                var eid      = pick(row,'Обоснование_ID','excuse_id','id') || '';
                var student  = pick(row,'ФИО','Студент','Имя') || '—';
                var subj     = pick(row,'Дисциплина','Предмет') || '';
                var date     = pick(row,'Дата_Занятия','Дата') || '';
                var reason   = pick(row,'Причина','Текст') || '—';
                var hasDoc   = pick(row,'Документ','Файл','has_doc') || false;
                var submitted= pick(row,'Дата_Подачи','created_at') || '';
                var status   = pick(row,'Статус') || 'Ожидает';
                var lessonStr = [subj, date].filter(Boolean).join(' / ');

                html += '<tr>';
                html += '<td><strong>' + esc(student) + '</strong></td>';
                html += '<td>' + esc(lessonStr || '—') + '</td>';
                html += '<td style="max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis" title="' + esc(reason) + '">' + esc(reason) + '</td>';
                html += '<td>' + (hasDoc ? '<span class="tag">Есть</span>' : '<span style="color:var(--c-muted)">—</span>') + '</td>';
                html += '<td><span style="color:var(--c-muted);font-size:13px">' + esc(submitted) + '</span></td>';
                html += '<td>' + statusBadge(status) + '</td>';
                html += '<td>';
                if (status === 'Ожидает') {
                    html += '<button class="btn btn-ghost btn-sm" onclick="openReview(\'' + esc(String(eid)) + '\',\'' + esc(student) + '\',\'' + esc(lessonStr) + '\',\'' + esc(reason) + '\',' + (hasDoc ? 'true' : 'false') + ')">Рассмотреть</button>';
                } else {
                    html += '<span style="color:var(--c-muted);font-size:12px">Обработано</span>';
                }
                html += '</td></tr>';
            });

            document.getElementById('excuses-tbody').innerHTML = html;
            wrap.style.display = '';

        } catch(e) {
            console.error(e);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.'; error.style.display = 'flex';
        }
    }

    window.openReview = function(eid, student, lesson, reason, hasDoc) {
        currentExcuseId = eid;
        document.getElementById('m-student').textContent = student || '—';
        document.getElementById('m-lesson').textContent  = lesson  || '—';
        document.getElementById('m-reason').textContent  = reason  || '—';
        document.getElementById('m-comment').value = '';
        document.getElementById('m-error').style.display = 'none';
        document.getElementById('m-doc-wrap').style.display = hasDoc ? '' : 'none';
        document.getElementById('review-modal').style.display = 'flex';
    };

    function closeModal() {
        document.getElementById('review-modal').style.display = 'none';
        currentExcuseId = null;
    }
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('modal-close2').addEventListener('click', closeModal);

    async function submitDecision(decision) {
        if (!currentExcuseId) return;
        var comment = document.getElementById('m-comment').value.trim();
        var errEl   = document.getElementById('m-error');
        errEl.style.display = 'none';

        document.getElementById('approve-btn').disabled = true;
        document.getElementById('reject-btn').disabled  = true;

        try {
            // ИзменитьСтатусОбоснования: Обоснование_ID, НовыйСтатус, КтоИзменил, Комментарий
            var whoReviewed = parseInt(localStorage.getItem('ais_user_id')||'0', 10);
            var r = await callAPI('ИзменитьСтатусОбоснования', {
                Обоснование_ID: currentExcuseId,
                НовыйСтатус:    decision,
                КтоИзменил:     whoReviewed,
                Комментарий:    comment || null
            });
            if (r && r.success) {
                closeModal();
                await load();
                document.getElementById('result').textContent = 'Решение сохранено: ' + decision + '.';
                document.getElementById('result').style.display = 'flex';
            } else {
                errEl.textContent = r && r.message ? r.message : 'Ошибка';
                errEl.style.display = 'flex';
            }
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.'; errEl.style.display = 'flex';
        } finally {
            document.getElementById('approve-btn').disabled = false;
            document.getElementById('reject-btn').disabled  = false;
        }
    }

    document.getElementById('approve-btn').addEventListener('click', function() { submitDecision('Одобрено'); });
    document.getElementById('reject-btn').addEventListener('click',  function() { submitDecision('Отклонено'); });
    document.getElementById('refresh-btn').addEventListener('click', load);
    document.getElementById('status-filter').addEventListener('change', load);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

