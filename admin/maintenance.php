<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Обслуживание';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Обслуживание системы</div>
        <div class="page-sub">Административные операции с подтверждением</div>
    </div>
</div>

<div class="alert alert-warn">
    Операции ниже используют только существующие серверные процедуры. Действия с высоким риском оставлены как плановые или требуют явного подтверждения.
</div>

<div id="maintenance-result" class="alert alert-info" style="display:none"></div>

<div class="cap-grid" id="maintenance-grid"></div>

<script>
(function () {
    'use strict';
    var UI = window.AISRoleUI;
    var operations = [];
    var currentUserIdCache = parseInt(localStorage.getItem('ais_user_id') || '0', 10);

    function pick(obj) {
        return UI.pick.apply(UI, arguments);
    }

    async function currentUserId() {
        if (currentUserIdCache) return currentUserIdCache;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        currentUserIdCache = parseInt(pick(row, 'Пользователь_ID', 'user_id') || '0', 10);
        if (currentUserIdCache) localStorage.setItem('ais_user_id', String(currentUserIdCache));
        return currentUserIdCache;
    }

    function card(op, idx) {
        return '<section class="cap-card"><div class="cap-card-hdr"><span class="cap-card-title">' + UI.esc(pick(op, 'Название') || pick(op, 'Код')) + '</span>' + UI.badge(pick(op, 'Риск') || 'Средний') + '</div>' +
            '<div class="cap-card-body"><p class="text-muted">' + UI.esc(pick(op, 'Описание') || '') + '</p><div class="list-meta">Процедура: ' + UI.esc(pick(op, 'Процедура') || '—') + '</div><div class="cap-actions"><button class="btn btn-danger btn-sm maint-run" data-i="' + idx + '">Запустить</button></div></div></section>';
    }

    async function loadOperations() {
        document.getElementById('maintenance-grid').innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьАдминОперации', { КтоЗапросил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            operations = UI.rows(response.data);
            document.getElementById('maintenance-grid').innerHTML = operations.length ? operations.map(card).join('') : UI.stateBlock('info', 'Нет операций', 'Реестр административных операций пуст.');
        } catch (error) {
            document.getElementById('maintenance-grid').innerHTML = UI.stateBlock('error', 'Операции недоступны', error.message || 'Ошибка соединения.');
        }
    }

    document.getElementById('maintenance-grid').addEventListener('click', async function (event) {
        var btn = event.target.closest('.maint-run');
        if (!btn) return;
        var op = operations[parseInt(btn.dataset.i, 10)];
        var code = pick(op, 'Код') || '';
        var reason = window.prompt('Укажите причину выполнения операции "' + code + '".');
        if (!reason) return;
        var payload = {};
        if (Number(pick(op, 'Требует_Параметры') || 0) === 1) {
            var raw = window.prompt('Параметры JSON. Оставьте пустым для значений по умолчанию.', '{}');
            if (raw) {
                try { payload = JSON.parse(raw); }
                catch (e) { UI.setAlert('maintenance-result', 'err', 'Некорректный JSON параметров.'); return; }
            }
        }
        UI.runGuarded(btn, {
            action: 'ВыполнитьАдминОперацию',
            params: {
                Код: code,
                КтоЗапустил: await currentUserId(),
                Подтверждение: 'ВЫПОЛНИТЬ',
                Причина: reason,
                ПараметрыJSON: JSON.stringify(payload || {})
            },
            resultEl: 'maintenance-result',
            busyText: 'Выполняется...',
            confirmText: 'Запустить операцию "' + (pick(op, 'Название') || code) + '"? Изменения будут выполнены серверной процедурой и записаны в аудит.'
        });
    });

    loadOperations();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

