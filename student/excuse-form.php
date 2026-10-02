<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'Подать обоснование';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Подать обоснование</div>
        <div class="page-sub">Укажите причину отсутствия на занятии</div>
    </div>
    <a href="/ais-system-ru/student/excuses.php" class="btn btn-outline">← Назад</a>
</div>

<div class="alert alert-ok"  id="form-success" style="display:none"></div>
<div class="alert alert-err" id="form-error"   style="display:none"></div>

<div class="card" style="max-width:640px">
    <div class="card-hdr"><span class="card-title">Новое обоснование отсутствия</span></div>
    <div class="card-body">

        <div class="form-row">
            <div class="form-group">
                <label class="form-label" for="session-select">Занятие</label>
                <select class="form-ctrl" id="session-select">
                    <option value="">Загрузка занятий...</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label" for="category-select">Категория причины</label>
                <select class="form-ctrl" id="category-select">
                    <option value="Болезнь">Болезнь</option>
                    <option value="Медосмотр">Медосмотр</option>
                    <option value="Спортивные соревнования">Спортивные соревнования</option>
                    <option value="Семейные обстоятельства">Семейные обстоятельства</option>
                    <option value="Иное">Иное</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" for="reason-text">Подробное описание</label>
            <textarea class="form-ctrl" id="reason-text" rows="4" placeholder="Опишите причину отсутствия..."></textarea>
        </div>

        <div class="form-group">
            <label class="form-label" for="file-input">Документ (справка, грамота и т.п.)</label>
            <input type="file" class="form-ctrl" id="file-input" accept=".pdf,.jpg,.jpeg,.png">
            <div class="form-hint">Необязательно. Поддерживаются форматы PDF, JPG, PNG (до 5 МБ)</div>
            <div id="file-info" class="text-sm text-muted mt-2" style="display:none"></div>
        </div>

        <div style="display:flex;gap:10px;justify-content:flex-end">
            <a href="/ais-system-ru/student/excuses.php" class="btn btn-outline">Отмена</a>
            <button class="btn btn-primary" id="submit-btn">Отправить обоснование</button>
        </div>

    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var urlParams = new URLSearchParams(window.location.search);
    var preZid = urlParams.get('z');
    var currentStudentId = 0;

    function showFeedback(kind, message) {
        var successEl = document.getElementById('form-success');
        var errorEl   = document.getElementById('form-error');
        successEl.style.display = 'none';
        errorEl.style.display = 'none';
        if (kind === 'ok') {
            successEl.textContent = message;
            successEl.style.display = 'flex';
        } else {
            errorEl.textContent = message;
            errorEl.style.display = 'flex';
        }
    }

    // File preview
    document.getElementById('file-input').addEventListener('change', function () {
        var file = this.files[0];
        var info = document.getElementById('file-info');
        if (file) {
            var sizeMb = (file.size / 1024 / 1024).toFixed(2);
            info.textContent = esc(file.name) + ' (' + sizeMb + ' МБ)';
            info.style.display = '';
            if (file.size > 5 * 1024 * 1024) {
                info.textContent += ' — файл слишком большой!';
                info.style.color = 'var(--c-err)';
            }
        } else {
            info.style.display = 'none';
        }
    });

    // Load absent sessions
    async function loadSessions() {
        try {
            var studentId = parseInt(localStorage.getItem('ais_student_id')||'0', 10);
            if (!studentId) {
                var sess = await callAPI('ПроверитьСессию', {});
                if (sess && sess.success && sess.data && sess.data[0]) {
                    studentId = pick(sess.data[0], 'Студент_ID', 'student_id') || 0;
                    if (studentId) localStorage.setItem('ais_student_id', studentId);
                }
            }
            currentStudentId = studentId;
            if (!studentId) {
                showFeedback('err', 'Не удалось определить студента. Проверьте привязку профиля или войдите заново.');
            }

            // ПолучитьДетальныйОтчетПоСтуденту: Студент_ID, ДатаНачала, ДатаКонца
            var r = await callAPI('ПолучитьДетальныйОтчетПоСтуденту', {
                Студент_ID: studentId
            });

            var sel = document.getElementById('session-select');
            sel.innerHTML = '<option value="">— Выберите занятие —</option>';

            if (r && r.success && r.data && r.data.length > 0) {
                var added = 0;
                r.data.forEach(function(row) {
                    var zid  = pick(row,'Занятие_ID') || '';
                    var date = pick(row,'Дата_Занятия','Дата') || '';
                    var subj = pick(row,'Дисциплина','Название_Дисциплины') || '';
                    var status = String(pick(row,'СтатусПосещения','Статус') || '').toLowerCase();
                    var excuseStatus = pick(row,'СтатусОбоснования','Статус_Обоснования') || '';
                    if (!zid) return;
                    if (!(status.includes('отсутств') || status.includes('опозда'))) return;
                    if (excuseStatus) return;
                    var opt = document.createElement('option');
                    opt.value = zid;
                    opt.textContent = (date ? date + ' — ' : '') + subj;
                    if (preZid && String(zid) === String(preZid)) opt.selected = true;
                    sel.appendChild(opt);
                    added++;
                });
                if (added === 0) {
                    sel.innerHTML = '<option value="">Нет занятий, доступных для обоснования</option>';
                    showFeedback('err', 'Нет занятий, по которым backend разрешает подать обоснование.');
                }
            } else {
                sel.innerHTML = '<option value="">Нет занятий с отсутствием</option>';
                showFeedback('err', 'Backend не вернул занятия с отсутствием для подачи обоснования.');
            }
        } catch(e) {
            document.getElementById('session-select').innerHTML = '<option value="">Ошибка загрузки</option>';
            showFeedback('err', 'Занятия для обоснования недоступны. Повторите запрос позже.');
        }
    }

    // Submit
    document.getElementById('submit-btn').addEventListener('click', async function () {
        var btn = this;
        var successEl = document.getElementById('form-success');
        var errorEl   = document.getElementById('form-error');
        successEl.style.display = 'none';
        errorEl.style.display   = 'none';

        var zid      = document.getElementById('session-select').value;
        var category = document.getElementById('category-select').value;
        var reason   = document.getElementById('reason-text').value.trim();
        var fileEl   = document.getElementById('file-input');

        if (!zid)    { showFeedback('err', 'Выберите занятие.'); return; }
        if (!reason) { showFeedback('err', 'Введите описание.'); return; }
        if (!currentStudentId && !parseInt(localStorage.getItem('ais_student_id')||'0', 10)) {
            showFeedback('err', 'Не удалось определить студента. Войдите заново.');
            return;
        }

        btn.disabled    = true;
        btn.textContent = 'Отправляем...';

        try {
            var params = {
                Занятие_ID: parseInt(zid, 10),
                Причина:    category + ': ' + reason,
                Категория:  category,
            };

            // File: read as base64
            if (fileEl.files && fileEl.files[0]) {
                var file = fileEl.files[0];
                if (file.size > 5 * 1024 * 1024) {
                    showFeedback('err', 'Файл слишком большой (максимум 5 МБ).');
                    btn.disabled = false;
                    btn.textContent = 'Отправить обоснование';
                    return;
                }
                if (!/^(application\/pdf|image\/jpeg|image\/png)$/.test(file.type)) {
                    showFeedback('err', 'Поддерживаются только PDF, JPG и PNG.');
                    btn.disabled = false;
                    btn.textContent = 'Отправить обоснование';
                    return;
                }
                params['Файл'] = file.name;
            }

            params['Студент_ID'] = currentStudentId || parseInt(localStorage.getItem('ais_student_id')||'0', 10);

            var r = await callAPIOfflineSupport('СоздатьОбоснование', params);

            if (r && (r.success || r.offline)) {
                var backendMessage = r && r.data && r.data[0] && r.data[0].Сообщение ? r.data[0].Сообщение : 'Обоснование отправлено на рассмотрение.';
                showFeedback('ok', r.offline
                    ? 'Обоснование сохранено офлайн и будет отправлено при восстановлении связи.'
                    : backendMessage + ' Ожидайте решения куратора.');
                document.getElementById('reason-text').value = '';
                document.getElementById('file-input').value  = '';
                document.getElementById('file-info').style.display = 'none';
                document.getElementById('session-select').value = '';
            } else {
                showFeedback('err', r && r.message ? r.message : 'Ошибка при отправке.');
            }
        } catch(err) {
            showFeedback('err', 'Ошибка соединения.');
        } finally {
            btn.disabled    = false;
            btn.textContent = 'Отправить обоснование';
        }
    });

    loadSessions();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

