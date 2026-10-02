<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'QR-сканер';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">QR-сканер</div>
        <div class="page-sub">Отметьте своё присутствие через QR-код</div>
    </div>
</div>

<div class="page-shell narrow centered">

    <div class="alert alert-ok"  id="scan-success" style="display:none"></div>
    <div class="alert alert-err" id="scan-error"   style="display:none"></div>
    <div class="alert alert-info" id="scan-context">Проверяем ближайшее занятие и доступность QR-сессии...</div>

    <div class="qr-box" id="qr-box">
        <div class="scanner-icon" aria-hidden="true">QR</div>
        <div class="scanner-copy">Направьте камеру на QR-код</div>
        <div class="scanner-hint">QR-код показывает преподаватель в начале занятия.<br>Код действителен 15 минут.</div>
        <div class="scanner-frame">
            <div id="reader" style="display:none"></div>
        </div>
        <div class="action-row">
            <button class="btn btn-primary btn-lg" id="start-btn">Открыть камеру</button>
            <button class="btn btn-outline" id="stop-btn" style="display:none">Остановить</button>
        </div>
    </div>

    <div class="card mt-4" id="next-lesson-card" style="display:none">
        <div class="card-hdr"><span class="card-title">Ближайшее занятие</span></div>
        <div class="card-body" id="next-lesson-body"></div>
    </div>

    <div id="offline-info" class="alert alert-warn mt-4" style="display:none">
        Нет соединения. Отметка будет сохранена и отправлена при восстановлении связи.
        <br><small id="queue-count"></small>
    </div>

</div>

<script>
(function () {
    'use strict';

    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }
    var UI = window.AISRoleUI || null;

    var scanner = null;
    var lastScan = '';
    var lastScanTime = 0;

    function showMsg(type, msg) {
        var success = document.getElementById('scan-success');
        var error   = document.getElementById('scan-error');
        success.style.display = 'none';
        error.style.display   = 'none';
        if (type === 'ok')  { success.textContent = msg; success.style.display = 'flex'; }
        if (type === 'err') { error.textContent   = msg; error.style.display   = 'flex'; }
    }

    function setContext(type, title, text) {
        var el = document.getElementById('scan-context');
        el.className = 'alert alert-' + (type || 'info');
        if (UI && typeof UI.stateBlock === 'function') {
            el.innerHTML = UI.stateBlock(type === 'err' ? 'error' : type === 'warn' ? 'warning' : type === 'ok' ? 'success' : 'info', title, text);
        } else {
            el.textContent = title + (text ? ': ' + text : '');
        }
        el.style.display = 'flex';
    }

    async function onScan(qrData) {
        var now = Date.now();
        if (qrData === lastScan && (now - lastScanTime) < 5000) return;
        lastScan = qrData;
        lastScanTime = now;

        showMsg('ok', 'QR прочитан, отмечаем...');

        var studentId = parseInt(localStorage.getItem('ais_student_id')||'0', 10);
        var params = {
            QR_Код:      qrData,
            Студент_ID:  studentId || 0,
        };

        try {
            var r = await callAPIOfflineSupport('ПроверитьQRИОтметить', params);
            if (r && r.success) {
                showMsg('ok', 'Посещаемость отмечена.');
                if (scanner) { scanner.stop().catch(function(){}); scanner = null; }
                document.getElementById('start-btn').style.display = '';
                document.getElementById('stop-btn').style.display  = 'none';
                document.getElementById('reader').style.display    = 'none';
            } else if (r && r.offline) {
                showMsg('ok', 'Сохранено офлайн. Будет отправлено при восстановлении связи.');
                updateQueueInfo();
            } else {
                showMsg('err', r && r.message ? r.message : 'Ошибка отметки посещаемости.');
            }
        } catch (err) {
            showMsg('err', 'Ошибка: ' + err.message);
        }
    }

    document.getElementById('start-btn').addEventListener('click', async function () {
        var readerEl = document.getElementById('reader');
        readerEl.style.display = '';
        document.getElementById('start-btn').style.display = 'none';
        document.getElementById('stop-btn').style.display  = '';

        if (typeof initQrScanner === 'function') {
            try {
                scanner = await initQrScanner('reader', onScan);
            } catch (err) {
                showMsg('err', 'Не удалось открыть камеру. Проверьте разрешения браузера.');
                readerEl.style.display = 'none';
                document.getElementById('start-btn').style.display = '';
                document.getElementById('stop-btn').style.display  = 'none';
            }
        } else {
            showMsg('err', 'QR-сканер недоступен. Обновите страницу.');
            readerEl.style.display = 'none';
            document.getElementById('start-btn').style.display = '';
            document.getElementById('stop-btn').style.display  = 'none';
        }
    });

    document.getElementById('stop-btn').addEventListener('click', function () {
        if (scanner) { scanner.stop().catch(function(){}); scanner = null; }
        document.getElementById('reader').style.display    = 'none';
        document.getElementById('start-btn').style.display = '';
        document.getElementById('stop-btn').style.display  = 'none';
    });

    // Load next lesson
    async function loadNextLesson() {
        try {
            var studentId = parseInt(localStorage.getItem('ais_student_id')||'0', 10);
            var groupId   = parseInt(localStorage.getItem('ais_group_id')||'0', 10);
            if (!groupId && !studentId) {
                setContext('warn', 'Профиль студента не найден', 'QR-отметка будет заблокирована, пока сессия не связана с карточкой студента.');
                return;
            }

            var r = await callAPI('ПолучитьДашбордСтудента', {
                Студент_ID: studentId || null
            });

            var sets = (r && r.success && Array.isArray(r.data) && Array.isArray(r.data[0])) ? r.data : [r && r.data ? r.data : []];
            var schedule = Array.isArray(sets[1]) ? sets[1] : (Array.isArray(sets[0]) ? sets[0] : []);

            if (schedule.length > 0) {
                var row = schedule[0];
                var subj  = pick(row,'Дисциплина','Название_Дисциплины') || '';
                var time  = pick(row,'Время_Начала_Факт','Время_Начала_План','Время_Начала','Время') || '';
                var room  = pick(row,'Аудитория','Кабинет') || '';
                var teach = pick(row,'Преподаватель','ФИО_Преподавателя') || '';
                var status = pick(row,'Статус') || '';

                var statusHtml = '';
                var statusText = String(status || '').toLowerCase();
                if (statusText.includes('идёт') || statusText.includes('актив')) {
                    statusHtml = '<span class="badge b-warn">Идёт сейчас</span>';
                    setContext('ok', 'QR можно сканировать', 'Если преподаватель уже показал код, откройте камеру. Истечение и повторная отметка проверяются backend-процедурой.');
                } else if (statusText.includes('заплан')) {
                    statusHtml = '<span class="badge b-muted">Запланировано</span>';
                    setContext('info', 'QR-сессия ещё не активна', 'Сканирование станет доступно после запуска QR преподавателем.');
                } else if (statusText.includes('провед') || statusText.includes('заверш')) {
                    statusHtml = '<span class="badge b-ok">Проведено</span>';
                    setContext('warn', 'Занятие завершено', 'Если QR-код истёк или сессия закрыта, backend отклонит отметку и покажет причину.');
                } else if (time) {
                    statusHtml = '<span class="badge b-muted">Ожидается</span>';
                    setContext('info', 'Ожидается занятие', 'QR-код действителен только для активной сессии, созданной преподавателем.');
                }

                document.getElementById('next-lesson-body').innerHTML =
                    '<div class="lesson-card-row">' +
                    '<div class="lesson-icon" aria-hidden="true">S</div>' +
                    '<div class="lesson-card-main"><div class="font-semibold">' + esc(subj) + '</div>' +
                    '<div class="text-muted text-sm">' + esc(time) + (room ? ' · ауд. ' + esc(room) : '') + (teach ? ' · ' + esc(teach) : '') + '</div></div>' +
                    (statusHtml ? '<div class="lesson-card-status">' + statusHtml + '</div>' : '') +
                    '</div>';
                document.getElementById('next-lesson-card').style.display = '';
            } else {
                setContext('info', 'Нет ближайшего занятия', 'В расписании на сегодня нет занятия, к которому можно привязать QR-отметку.');
            }
        } catch(e) {
            setContext('err', 'Контекст QR недоступен', 'Не удалось загрузить расписание. Можно повторить позже или обратиться к преподавателю.');
        }
    }

    async function updateQueueInfo() {
        if (typeof OfflineQueue === 'undefined') return;
        try {
            var n = await OfflineQueue.count();
            if (n > 0) {
                document.getElementById('offline-info').style.display = 'flex';
                document.getElementById('queue-count').textContent = 'В очереди: ' + n + ' запрос(ов)';
            } else if (navigator.onLine) {
                document.getElementById('queue-count').textContent = '';
                document.getElementById('offline-info').style.display = 'none';
            }
        } catch(e) {}
    }
    updateQueueInfo();

    // Network detection
    if (typeof addNetworkListener === 'function') {
        addNetworkListener(function() {
            if (!navigator.onLine) {
                document.getElementById('offline-info').style.display = 'flex';
            } else {
                updateQueueInfo();
            }
        });
    }

    loadNextLesson();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

