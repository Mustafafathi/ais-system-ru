<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'Обоснования';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Обоснования отсутствия</div>
        <div class="page-sub">Мои заявки на рассмотрение</div>
    </div>
    <div class="page-actions">
        <a href="/ais-system-ru/student/excuse-form.php" class="btn btn-primary">+ Подать обоснование</a>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>

<div class="tbl-wrap" id="wrap" style="display:none">
    <table>
        <thead>
            <tr>
                <th>Дата занятия</th>
                <th>Дисциплина</th>
                <th>Причина</th>
                <th>Статус</th>
                <th>Комментарий куратора</th>
                <th>Файл</th>
            </tr>
        </thead>
        <tbody id="tbody"></tbody>
    </table>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">E</div>
    <div class="empty-title">Нет обоснований</div>
    <div class="empty-sub">Вы ещё не подавали обоснований отсутствия</div>
    <a href="/ais-system-ru/student/excuse-form.php" class="btn btn-primary" style="margin-top:16px">Подать обоснование</a>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    function statusBadge(s) {
        s = String(s||'').toLowerCase();
        if (s.includes('принят') || s.includes('одобр'))  return '<span class="badge b-ok">Одобрено</span>';
        if (s.includes('отклон'))                          return '<span class="badge b-err">Отклонено</span>';
        return '<span class="badge b-warn">На рассмотрении</span>';
    }

    async function load() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('error').style.display = 'none';
        document.getElementById('wrap').style.display = 'none';
        document.getElementById('empty').style.display = 'none';

        try {
            var studentId = parseInt(localStorage.getItem('ais_student_id')||'0', 10);
            if (!studentId) {
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    studentId = pick(sess.data[0], 'Студент_ID', 'student_id') || 0;
                    if (studentId) localStorage.setItem('ais_student_id', studentId);
                }
            }

            var r = await callAPI('ПолучитьСписокОбоснований', { Студент_ID: studentId });

            document.getElementById('loading').style.display = 'none';

            if (!r || !r.success) {
                document.getElementById('error').textContent = r && r.message ? r.message : 'Ошибка загрузки';
                document.getElementById('error').style.display = 'flex';
                return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];
            if (rows.length === 0) { document.getElementById('empty').style.display = 'block'; return; }

            var html = '';
            rows.forEach(function(row) {
                var date    = pick(row,'Дата','Дата_Заявления','Дата_Занятия') || '';
                var subj    = pick(row,'Дисциплина','Название_Дисциплины') || '—';
                var reason  = pick(row,'Причина','Категория','Описание') || '—';
                var status  = pick(row,'Статус') || 'На рассмотрении';
                var comment = pick(row,'Комментарий','Комментарий_Куратора') || '—';
                var file    = pick(row,'Файл','Имя_Файла','Вложение') || '';
                var hasDoc  = pick(row,'Документ','has_doc') || false;
                var reviewedAt = pick(row,'Дата_Рассмотрения','ДатаРассмотрения') || '';
                var reviewer = pick(row,'Кто_Рассмотрел','Модератор') || '';
                var finalInfo = reviewedAt || reviewer ? '<div class="text-muted text-sm">' + esc([reviewedAt, reviewer].filter(Boolean).join(' · ')) + '</div>' : '';

                html += '<tr>';
                html += '<td>' + esc(date) + '</td>';
                html += '<td>' + esc(subj) + '</td>';
                html += '<td>' + esc(reason) + '</td>';
                html += '<td>' + statusBadge(status) + finalInfo + '</td>';
                html += '<td class="text-muted text-sm">' + esc(comment) + '</td>';
                html += '<td>' + (file ? '<span class="tag">' + esc(file) + '</span>' : (hasDoc ? '<span class="tag">Документ есть</span>' : '—')) + '</td>';
                html += '</tr>';
            });

            document.getElementById('tbody').innerHTML = html;
            document.getElementById('wrap').style.display = '';

        } catch(err) {
            console.error(err);
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').textContent = 'Ошибка соединения.';
            document.getElementById('error').style.display = 'flex';
        }
    }

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

