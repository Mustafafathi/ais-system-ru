<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'QR-генератор';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">QR-генератор</div>
        <div class="page-sub">Создайте QR-код для занятия</div>
    </div>
</div>

<div class="page-shell">
<div class="qr-layout">

    <!-- Settings card -->
    <div class="card qr-panel">
        <div class="card-hdr"><span class="card-title">Настройки QR-сессии</span></div>
        <div class="card-body">
            <div class="form-group">
                <label class="form-label">Дата занятия</label>
                <input class="form-ctrl" type="date" id="session-date">
            </div>
            <div class="form-group">
                <label class="form-label">Занятие</label>
                <select class="form-ctrl" id="session-select">
                    <option value="">Загрузка занятий...</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Название сессии (опционально)</label>
                <input class="form-ctrl" id="session-name" placeholder="Лекция №15 — Индексы">
            </div>
            <div class="form-group">
                <label class="form-label">Срок действия (минуты)</label>
                <input class="form-ctrl" type="number" id="session-ttl" value="15" min="1" max="120">
            </div>
            <button class="btn btn-primary btn-block btn-lg" id="generate-btn">Сгенерировать QR</button>
        </div>
    </div>

    <!-- QR display card -->
    <div class="card qr-panel" id="qr-display-card" style="display:none">
        <div class="card-hdr">
            <span class="card-title">QR-код</span>
            <span class="badge b-ok" id="qr-status-badge">Активен</span>
        </div>
        <div class="card-body qr-display">
            <div class="qr-frame" id="qr-canvas-wrap"></div>
            <div class="qr-meta">
                Действителен до <strong id="qr-expires"></strong>
            </div>
            <div class="prog qr-progress">
                <div class="prog-bar prog-blue" id="qr-timer-bar" style="width:100%"></div>
            </div>
            <div class="qr-actions">
                <button class="btn btn-outline btn-sm" id="copy-btn">Скопировать код</button>
                <button class="btn btn-danger btn-sm"  id="stop-btn">Остановить</button>
            </div>
        </div>
    </div>

    <!-- Empty state for QR -->
    <div class="card qr-panel" id="qr-empty-card">
        <div class="card-hdr"><span class="card-title">QR-код</span></div>
        <div class="card-body">
            <div class="qr-box">
                <div class="qr-empty-icon">QR</div>
                <div class="qr-empty-text">Нажмите «Сгенерировать QR»<br>чтобы создать код для занятия</div>
            </div>
        </div>
    </div>

</div>
</div>

<div class="alert alert-err page-shell mt-4" id="gen-error" style="display:none"></div>
<div class="page-shell mt-4">
    <div class="grid-2">
        <section class="card">
            <div class="card-hdr">
                <span class="card-title">Состояние QR-сессии</span>
                <span id="active-session-badge" class="badge b-muted">Не выбрано</span>
            </div>
            <div class="card-body" id="active-session-body">
                <div class="alert alert-info">Выберите занятие для проверки активной QR-сессии.</div>
            </div>
        </section>
        <section class="card">
            <div class="card-hdr">
                <span class="card-title">Последние сканирования</span>
                <span id="scan-history-badge" class="badge b-muted">—</span>
            </div>
            <div class="card-body" id="scan-history-body">
                <div class="alert alert-info">История появится после выбора занятия.</div>
            </div>
        </section>
    </div>
</div>

<script>
window.AIS_QR_CONTEXT = {
    userId: <?= (int)($currentUser['Пользователь_ID'] ?? 0) ?>,
    teacherId: <?= (int)($currentUser['Преподаватель_ID'] ?? 0) ?>
};

(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }
    function localDateValue(d) {
        var y = d.getFullYear();
        var m = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return y + '-' + m + '-' + day;
    }

    var qrData = null;
    var qrSessionId = null;
    var timerInterval = null;
    var expiresAt = null;
    var currentLessonId = 0;
    var context = {
        userId: (window.AIS_QR_CONTEXT && window.AIS_QR_CONTEXT.userId) || parseInt(localStorage.getItem('ais_user_id') || '0', 10) || 0,
        teacherId: (window.AIS_QR_CONTEXT && window.AIS_QR_CONTEXT.teacherId) || parseInt(localStorage.getItem('ais_teacher_id') || '0', 10) || 0
    };

    if (context.userId) localStorage.setItem('ais_user_id', context.userId);
    if (context.teacherId) localStorage.setItem('ais_teacher_id', context.teacherId);

    async function ensureContext() {
        if (context.userId && context.teacherId) return context;

        var sess = await callAPI('ПроверитьСессию', {});
        if (sess && sess.success && sess.data && sess.data[0]) {
            context.userId = pick(sess.data[0], 'Пользователь_ID', 'user_id') || context.userId || 0;
            context.teacherId = pick(sess.data[0], 'Преподаватель_ID', 'teacher_id') || context.teacherId || 0;
            if (context.userId) localStorage.setItem('ais_user_id', context.userId);
            if (context.teacherId) localStorage.setItem('ais_teacher_id', context.teacherId);
        }

        return context;
    }

    function buildOptionText(row) {
        var time = pick(row,'Время','Время_Начала_План','Время_Начала') || '';
        var subj = pick(row,'Дисциплина','Название_Дисциплины') || '';
        var grp  = pick(row,'Группа','Название_Группы') || '';
        var kind = pick(row,'Тип_Занятия') || '';
        var room = pick(row,'Кабинет','Аудитория','Номер_Аудитории') || '';
        return [time, kind, subj, grp, room].filter(Boolean).join(' — ');
    }

    function setBadge(id, label) {
        var el = document.getElementById(id);
        if (!el || !window.AISRoleUI) {
            if (el) el.textContent = label || '—';
            return;
        }
        var wrap = document.createElement('div');
        wrap.innerHTML = window.AISRoleUI.badge(label);
        var badge = wrap.firstChild;
        el.className = badge.className;
        el.textContent = badge.textContent;
    }

    function renderState(type, title, text) {
        if (window.AISRoleUI && typeof window.AISRoleUI.stateBlock === 'function') {
            return window.AISRoleUI.stateBlock(type, title, text);
        }
        return '<div class="alert alert-info"><strong>' + esc(title) + '</strong>' + (text ? '<br>' + esc(text) : '') + '</div>';
    }

    function startTimer(ttlMinutes) {
        clearInterval(timerInterval);
        timerInterval = setInterval(function() {
            if (!expiresAt) return;
            var now = Date.now();
            var remaining = expiresAt.getTime() - now;
            var total = (ttlMinutes || 15) * 60 * 1000;
            var pct = Math.max(0, Math.min(100, (remaining / total) * 100));
            document.getElementById('qr-timer-bar').style.width = pct + '%';
            if (pct < 20) document.getElementById('qr-timer-bar').className = 'prog-bar prog-red';
            else if (pct < 50) document.getElementById('qr-timer-bar').className = 'prog-bar prog-yellow';
            else document.getElementById('qr-timer-bar').className = 'prog-bar prog-blue';
            if (remaining <= 0) {
                clearInterval(timerInterval);
                document.getElementById('qr-status-badge').textContent = 'Истёк';
                document.getElementById('qr-status-badge').className = 'badge b-err';
                setBadge('active-session-badge', 'Истёк');
                document.getElementById('active-session-body').innerHTML = renderState('warning', 'QR-сессия истекла', 'Создайте новую сессию, если отметка ещё нужна.');
            }
        }, 1000);
    }

    function renderQrSession(row, sourceLabel) {
        qrData = pick(row,'QR_Код','QR_Данные','qr_data') || '';
        qrSessionId = pick(row,'QR_Сессия_ID','id') || '';
        var expiresStr = pick(row,'Время_Истечения','Истекает','expires_at','Время_Действия_Конец') || '';
        var ttl = parseInt(pick(row,'Срок_Действия_Минут','ttl') || document.getElementById('session-ttl').value || '15', 10);

        document.getElementById('qr-status-badge').textContent = sourceLabel || 'Активен';
        document.getElementById('qr-status-badge').className = 'badge b-ok';
        document.getElementById('qr-timer-bar').className = 'prog-bar prog-blue';
        document.getElementById('qr-timer-bar').style.width = '100%';

        if (expiresStr) {
            expiresAt = new Date(expiresStr);
            document.getElementById('qr-expires').textContent = Number.isNaN(expiresAt.getTime()) ? String(expiresStr) : expiresAt.toLocaleTimeString('ru-RU', {hour:'2-digit',minute:'2-digit'});
        }

        var wrap = document.getElementById('qr-canvas-wrap');
        wrap.innerHTML = '';
        if (typeof QRCode !== 'undefined' && qrData) {
            var canvas = document.createElement('canvas');
            wrap.appendChild(canvas);
            QRCode.toCanvas(canvas, qrData, { width: 240, margin: 1 }, function(err) {
                if (err) wrap.innerHTML = '<div class="qr-fallback">' + esc(qrData) + '</div>';
            });
        } else {
            wrap.innerHTML = '<div class="qr-fallback">' + esc(qrData || 'QR-код недоступен') + '</div>';
        }

        document.getElementById('qr-empty-card').style.display = 'none';
        document.getElementById('qr-display-card').style.display = '';
        if (expiresAt && !Number.isNaN(expiresAt.getTime())) startTimer(ttl);
    }

    async function loadScanHistory(lessonId) {
        var body = document.getElementById('scan-history-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        setBadge('scan-history-badge', 'Загрузка');
        if (!lessonId) {
            setBadge('scan-history-badge', 'Нет занятия');
            body.innerHTML = renderState('info', 'Занятие не выбрано', 'История сканирований доступна после выбора занятия.');
            return;
        }
        try {
            var r = await callAPI('ПолучитьИсториюQRСканирований', { Занятие_ID: lessonId, РазмерСтраницы: 8 });
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = window.AISRoleUI ? window.AISRoleUI.rows(r.data) : (Array.isArray(r.data) ? r.data : []);
            setBadge('scan-history-badge', rows.length ? rows.length + ' записей' : 'Нет данных');
            if (!rows.length) {
                body.innerHTML = renderState('info', 'Сканирований нет', 'Для выбранного занятия ещё нет QR-событий.');
                return;
            }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Время</th><th>Студент</th><th>Статус</th></tr></thead><tbody>' +
                rows.map(function(row) {
                    return '<tr><td>' + esc(pick(row,'Время_Сканирования') || '') + '</td><td>' + esc(pick(row,'ФИО_Студента') || '—') + '</td><td>' + (window.AISRoleUI ? window.AISRoleUI.badge(pick(row,'Статус') || '—') : esc(pick(row,'Статус') || '—')) + '</td></tr>';
                }).join('') + '</tbody></table></div>';
        } catch (e) {
            setBadge('scan-history-badge', 'Недоступно');
            body.innerHTML = renderState('error', 'История сканирований недоступна', e.message || 'Backend не вернул список.');
        }
    }

    async function loadActiveSessionForLesson(lessonId) {
        var body = document.getElementById('active-session-body');
        currentLessonId = parseInt(lessonId || '0', 10) || 0;
        if (!currentLessonId) {
            setBadge('active-session-badge', 'Нет занятия');
            body.innerHTML = renderState('warning', 'QR-сессия недоступна', 'Для строки расписания без занятия сначала будет создано занятие при генерации QR.');
            document.getElementById('qr-display-card').style.display = 'none';
            document.getElementById('qr-empty-card').style.display = '';
            await loadScanHistory(0);
            return;
        }

        body.innerHTML = '<div class="alert alert-info">Проверяем активную сессию...</div>';
        setBadge('active-session-badge', 'Проверка');
        try {
            var r = await callAPI('ПолучитьАктивнуюQRСессию', { Занятие_ID: currentLessonId });
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = Array.isArray(r.data) ? r.data : [];
            if (!rows.length) {
                setBadge('active-session-badge', 'Нет активной');
                body.innerHTML = renderState('info', 'Активной QR-сессии нет', 'Можно создать новую сессию для выбранного занятия.');
                qrSessionId = null;
                document.getElementById('qr-display-card').style.display = 'none';
                document.getElementById('qr-empty-card').style.display = '';
            } else {
                setBadge('active-session-badge', 'Активна');
                renderQrSession(rows[0], 'Активен');
                body.innerHTML = renderState('success', 'QR-сессия активна', 'Код уже создан. Можно показывать его студентам или остановить сессию.');
            }
            await loadScanHistory(currentLessonId);
        } catch (e) {
            setBadge('active-session-badge', 'Недоступно');
            body.innerHTML = renderState('error', 'Проверка QR-сессии недоступна', e.message || 'Backend не вернул состояние.');
            await loadScanHistory(currentLessonId);
        }
    }

    // Load sessions
    async function loadSessions() {
        var sel = document.getElementById('session-select');
        sel.innerHTML = '<option value="">Загрузка занятий...</option>';

        try {
            await ensureContext();
            var selectedDate = document.getElementById('session-date').value || localDateValue(new Date());
            var r = await callAPI('ПолучитьРасписаниеОбзор', {
                Преподаватель_ID: context.teacherId,
                Дата_Начала: selectedDate,
                Дата_Конца: selectedDate,
                Размер_Страницы: 100
            });

            sel.innerHTML = '<option value="">— Выберите занятие —</option>';

            var urlZ = new URLSearchParams(window.location.search).get('z');

            if (r && r.success && r.data && r.data.length > 0) {
                r.data.forEach(function(row) {
                    var zid  = pick(row,'Занятие_ID') || '';
                    var rid  = pick(row,'Расписание_ID') || '';
                    if (!zid && !rid) return;

                    var opt = document.createElement('option');
                    opt.value = zid ? ('lesson:' + zid) : ('schedule:' + rid);
                    opt.dataset.lessonId = zid;
                    opt.dataset.scheduleId = rid;
                    opt.dataset.lessonDate = pick(row,'Дата_Занятия','Дата') || selectedDate;
                    opt.dataset.cabinet = pick(row,'Кабинет','Аудитория','Номер_Аудитории') || '';
                    opt.dataset.topic = [pick(row,'Тип_Занятия') || 'Занятие', pick(row,'Дисциплина','Название_Дисциплины')].filter(Boolean).join(': ');
                    opt.textContent = buildOptionText(row) + (zid ? '' : ' — занятие будет создано');
                    if (urlZ && String(zid) === String(urlZ)) opt.selected = true;
                    sel.appendChild(opt);
                });
                if (sel.value) {
                    var selected = sel.options[sel.selectedIndex];
                    loadActiveSessionForLesson(selected ? selected.dataset.lessonId : 0);
                }
            } else {
                sel.innerHTML = '<option value="">Нет занятий на выбранную дату</option>';
                setBadge('active-session-badge', 'Нет занятий');
                document.getElementById('active-session-body').innerHTML = renderState('info', 'Нет занятий', 'На выбранную дату занятия не найдены.');
            }
        } catch(e) {
            console.error(e);
            sel.innerHTML = '<option value="">Ошибка загрузки занятий</option>';
            setBadge('active-session-badge', 'Ошибка');
            document.getElementById('active-session-body').innerHTML = renderState('error', 'Занятия недоступны', 'Не удалось загрузить список занятий.');
        }
    }

    async function findGeneratedLesson(scheduleId, lessonDate) {
        var r = await callAPI('ПолучитьРасписаниеОбзор', {
            Преподаватель_ID: context.teacherId,
            Дата_Начала: lessonDate,
            Дата_Конца: lessonDate,
            Размер_Страницы: 100
        });

        if (r && r.success && Array.isArray(r.data)) {
            for (var i = 0; i < r.data.length; i++) {
                if (String(pick(r.data[i], 'Расписание_ID') || '') === String(scheduleId)) {
                    var found = parseInt(pick(r.data[i], 'Занятие_ID') || '0', 10);
                    if (found) return found;
                }
            }
        }

        return 0;
    }

    async function resolveLessonId() {
        var sel = document.getElementById('session-select');
        var opt = sel.options[sel.selectedIndex];
        if (!opt || !opt.value) return 0;

        var existingLessonId = parseInt(opt.dataset.lessonId || opt.value.replace('lesson:', '') || '0', 10);
        if (existingLessonId) return existingLessonId;

        var scheduleId = parseInt(opt.dataset.scheduleId || opt.value.replace('schedule:', '') || '0', 10);
        var lessonDate = opt.dataset.lessonDate || document.getElementById('session-date').value;
        if (!scheduleId || !lessonDate) return 0;

        await ensureContext();
        var created = await callAPI('СоздатьЗанятие', {
            Расписание_ID: scheduleId,
            Дата_Занятия: lessonDate,
            Тема_Занятия: opt.dataset.topic || null,
            Кабинет: opt.dataset.cabinet || null,
            КтоСоздал: context.userId
        });

        if (created && created.success && created.data && created.data[0]) {
            var newId = parseInt(pick(created.data[0], 'Занятие_ID') || '0', 10);
            if (newId) {
                opt.dataset.lessonId = newId;
                opt.value = 'lesson:' + newId;
                return newId;
            }
        }

        var msg = created && created.message ? created.message : '';
        if (msg.indexOf('уже существует') !== -1) {
            var foundId = await findGeneratedLesson(scheduleId, lessonDate);
            if (foundId) return foundId;
        }

        throw new Error(msg || 'Не удалось создать занятие для QR.');
    }

    document.getElementById('generate-btn').addEventListener('click', async function () {
        var btn   = this;
        var errEl = document.getElementById('gen-error');
        errEl.style.display = 'none';

        var name = document.getElementById('session-name').value.trim();
        var ttl  = parseInt(document.getElementById('session-ttl').value, 10) || 15;

        btn.disabled = true; btn.textContent = 'Создаём...';

        try {
            var sessionId = await resolveLessonId();
            if (!sessionId) { errEl.textContent = 'Выберите занятие.'; errEl.style.display = 'flex'; return; }

            // Stop existing session
            if (qrSessionId) {
                await callAPI('ЗавершитьQRСессию', { QR_Сессия_ID: qrSessionId, КтоЗавершил: context.userId }).catch(function(){});
                clearInterval(timerInterval);
            }
            document.getElementById('qr-status-badge').textContent = 'Активен';
            document.getElementById('qr-status-badge').className = 'badge b-ok';
            document.getElementById('qr-timer-bar').className = 'prog-bar prog-blue';
            document.getElementById('qr-timer-bar').style.width = '100%';

            var r = await callAPI('СгенерироватьQRДляЗанятия', {
                Занятие_ID:          sessionId,
                Название_Сессии:     name || null,
                Срок_Действия_Минут: ttl,
                КтоСоздал:           context.userId,
            });

            if (!r || !r.success) {
                errEl.textContent = (r && r.message ? r.message : 'Ошибка создания QR'); errEl.style.display = 'flex'; return;
            }

            var d = Array.isArray(r.data) && r.data[0] ? r.data[0] : {};
            currentLessonId = sessionId;
            renderQrSession(d, 'Активен');
            setBadge('active-session-badge', 'Активна');
            document.getElementById('active-session-body').innerHTML = renderState('success', 'QR-сессия создана', 'Код активен до указанного времени.');
            await loadScanHistory(sessionId);

        } catch(err) {
            errEl.textContent = err && err.message ? err.message : 'Ошибка соединения.'; errEl.style.display = 'flex';
        } finally {
            btn.disabled = false; btn.textContent = 'Сгенерировать QR';
        }
    });

    document.getElementById('copy-btn').addEventListener('click', function() {
        if (!qrData) return;
        navigator.clipboard.writeText(qrData).then(function(){
            var btn = document.getElementById('copy-btn');
            btn.textContent = 'Скопировано!';
            setTimeout(function(){ btn.textContent = 'Скопировать код'; }, 2000);
        }).catch(function(){});
    });

    document.getElementById('stop-btn').addEventListener('click', async function() {
        if (qrSessionId) {
            await callAPI('ЗавершитьQRСессию', { QR_Сессия_ID: qrSessionId, КтоЗавершил: context.userId }).catch(function(){});
            qrSessionId = null;
        }
        clearInterval(timerInterval);
        document.getElementById('qr-display-card').style.display = 'none';
        document.getElementById('qr-empty-card').style.display = '';
        setBadge('active-session-badge', 'Завершена');
        document.getElementById('active-session-body').innerHTML = renderState('warning', 'QR-сессия завершена', 'Новые сканирования по этому коду будут отклонены backend-процедурой.');
        if (currentLessonId) loadScanHistory(currentLessonId);
    });

    document.getElementById('session-date').value = localDateValue(new Date());
    document.getElementById('session-date').addEventListener('change', loadSessions);
    document.getElementById('session-select').addEventListener('change', function () {
        var opt = this.options[this.selectedIndex];
        loadActiveSessionForLesson(opt ? opt.dataset.lessonId : 0);
    });
    loadSessions();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

