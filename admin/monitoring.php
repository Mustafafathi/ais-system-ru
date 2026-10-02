<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Мониторинг';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Мониторинг системы</div>
        <div class="page-sub">Состояние, целостность, QR и интеграции</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" id="refresh-btn">Обновить</button>
    </div>
</div>

<div class="cap-grid">
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Состояние системы</span><span id="health-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body" id="health-body"><div class="alert alert-info">Загрузка...</div></div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Целостность данных</span><span id="integrity-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body" id="integrity-body"><div class="alert alert-info">Загрузка...</div></div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Последние QR-сканирования</span><span id="qr-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body">
            <div class="page-actions mb-3">
                <input class="form-ctrl control-auto" type="date" id="qr-from">
                <input class="form-ctrl control-auto" type="date" id="qr-to">
                <button class="btn btn-outline btn-sm" id="qr-load-btn">Показать</button>
            </div>
            <div id="qr-body"><div class="alert alert-info">Загрузка...</div></div>
        </div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">СКУД</span><span class="badge b-info">Интеграция</span></div>
        <div class="cap-card-body" id="skud-body"></div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Резервные копии</span><span id="backup-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body" id="backup-body"><div class="alert alert-info">Загрузка...</div></div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Дашборд администратора</span><span id="dash-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body" id="dash-body"><div class="alert alert-info">Загрузка...</div></div>
    </section>
    <section class="cap-card">
        <div class="cap-card-hdr"><span class="cap-card-title">Последние ошибки</span><span id="errors-badge" class="badge b-muted">—</span></div>
        <div class="cap-card-body" id="errors-body"><div class="alert alert-info">Загрузка...</div></div>
    </section>
</div>

<script>
(function () {
    'use strict';
    var UI = window.AISRoleUI;
    function pick(obj) { return UI.pick.apply(UI, arguments); }

    function pluralizeRussian(count, forms) {
        // forms = [one, few, many]
        count = Math.abs(Number(count) || 0);
        var mod100 = count % 100;
        var mod10 = count % 10;
        if (count === 0) return forms[2];
        if (mod100 >= 11 && mod100 <= 14) return forms[2];
        if (mod10 === 1) return forms[0];
        if (mod10 >= 2 && mod10 <= 4) return forms[1];
        return forms[2];
    }

    function setBadge(id, label) {
        var el = document.getElementById(id);
        if (!el) return;
        var wrap = document.createElement('div');
        wrap.innerHTML = UI.badge(label);
        var badge = wrap.firstChild;
        el.className = badge.className;
        el.textContent = badge.textContent;
    }

    function iso(d) { return d.toISOString().slice(0, 10); }
    var now = new Date();
    document.getElementById('qr-from').value = iso(new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7));
    document.getElementById('qr-to').value = iso(now);

    async function loadHealth() {
        var body = document.getElementById('health-body');
        try {
            var r = await callAPI('ПроверитьСостояниеСистемы', {});
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = UI.rows(r.data);
            body.innerHTML = UI.renderKeyValueList(rows);
            setBadge('health-badge', 'OK');
        } catch (e) {
            body.innerHTML = UI.stateBlock('error', 'Недоступно', e.message || 'Ошибка соединения.');
            setBadge('health-badge', 'Ошибка');
        }
    }

    async function loadIntegrity() {
        var body = document.getElementById('integrity-body');
        try {
            var r = await callAPI('ПроверитьЦелостностьДанных', {});
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = UI.rows(r.data);
            body.innerHTML = UI.renderKeyValueList(rows);
            var failed = rows.filter(function(row){ return String(pick(row,'Статус') || '').toLowerCase() !== 'ok'; }).length;
            setBadge('integrity-badge', failed ? 'Внимание' : 'OK');
        } catch (e) {
            body.innerHTML = UI.stateBlock('error', 'Недоступно', e.message || 'Ошибка соединения.');
            setBadge('integrity-badge', 'Ошибка');
        }
    }

    async function loadQr() {
        var body = document.getElementById('qr-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var r = await callAPI('ПолучитьИсториюQRСканирований', {
                НачалоПериода: document.getElementById('qr-from').value,
                КонецПериода: document.getElementById('qr-to').value,
                РазмерСтраницы: 10
            });
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = UI.rows(r.data);
            setBadge('qr-badge', rows.length ? 'Активность' : 'Нет данных');
            if (!rows.length) { body.innerHTML = UI.stateBlock('info', 'Нет сканирований', 'За выбранный период записей не найдено.'); return; }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Время</th><th>Студент</th><th>Занятие</th><th>Статус</th></tr></thead><tbody>' +
                rows.map(function(row){
                    return '<tr><td>' + UI.esc(pick(row,'Время_Сканирования') || '') + '</td><td>' + UI.esc(pick(row,'ФИО_Студента') || '—') + '</td><td>' + UI.esc(pick(row,'Дисциплина') || '—') + '</td><td>' + UI.badge(pick(row,'Статус') || '—') + '</td></tr>';
                }).join('') + '</tbody></table></div>';
        } catch (e) {
            body.innerHTML = UI.stateBlock('error', 'QR-история недоступна', e.message || 'Ошибка соединения.');
            setBadge('qr-badge', 'Ошибка');
        }
    }

    async function loadBackups() {
        var body = document.getElementById('backup-body');
        try {
            var r = await callAPI('ПолучитьСписокБэкапов', { Лимит: 5 });
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = UI.rows(r.data);
            setBadge('backup-badge', rows.length ? 'Есть данные' : 'Нет данных');
            if (!rows.length) { body.innerHTML = UI.stateBlock('warning', 'Нет резервных копий', 'Успешные копии не найдены.'); return; }
            body.innerHTML = '<div class="cap-list">' + rows.map(function(row){
                return '<div class="cap-list-row"><div class="cap-list-main"><strong>' + UI.esc(pick(row,'Имя','Название_Файла') || 'Копия') + '</strong><div class="list-meta">' + UI.esc(pick(row,'Дата') || '') + '</div></div>' + UI.badge(pick(row,'Статус') || '—') + '</div>';
            }).join('') + '</div>';
        } catch (e) {
            body.innerHTML = UI.stateBlock('error', 'Бэкапы недоступны', e.message || 'Ошибка соединения.');
            setBadge('backup-badge', 'Ошибка');
        }
    }

    async function loadDash() {
        var body = document.getElementById('dash-body');
        try {
            var r = await callAPI('ПолучитьДашбордАдмина', {});
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var sets = Array.isArray(r.data) && Array.isArray(r.data[0]) ? r.data : [r.data];
            var row = sets[0] && sets[0][0] ? sets[0][0] : {};
            body.innerHTML = '<div class="cap-list">' +
                ['Пользователей_Активных','Студентов','Преподавателей','Групп_Активных','Занятий_Сегодня','Активных_Сессий'].map(function(key){
                    return '<div class="cap-list-row"><div class="cap-list-main"><strong>' + UI.esc(key.replace(/_/g, ' ')) + '</strong></div><span class="tag">' + UI.esc(row[key] !== undefined ? row[key] : '—') + '</span></div>';
                }).join('') + '</div>';
            setBadge('dash-badge', 'OK');
        } catch (e) {
            body.innerHTML = UI.stateBlock('error', 'Дашборд недоступен', e.message || 'Ошибка соединения.');
            setBadge('dash-badge', 'Ошибка');
        }
    }

    async function loadLatestErrors() {
        var body = document.getElementById('errors-body');
        try {
            var r = await callAPI('ПолучитьЛогДействий', { Статус: 'Ошибка', РазмерСтраницы: 5 });
            if (!r || !r.success) throw new Error(r && r.message ? r.message : 'Ошибка загрузки');
            var rows = UI.rows(r.data);
            setBadge('errors-badge', rows.length ? rows.length + ' ' + pluralizeRussian(rows.length, ['ошибка','ошибки','ошибок']) : 'Нет ошибок');
            if (!rows.length) { body.innerHTML = UI.stateBlock('success', 'Ошибок не найдено', 'В последних записях журнала нет ошибок.'); return; }
            body.innerHTML = '<div class="cap-list">' + rows.map(function(row) {
                return '<div class="cap-list-row"><div class="cap-list-main"><strong>' + UI.esc(pick(row,'Действие') || 'Ошибка') + '</strong><div class="list-meta">' + UI.esc(pick(row,'Время_Действия','Время') || '') + '</div></div>' + UI.badge(pick(row,'Статус') || 'Ошибка') + '</div>';
            }).join('') + '</div>';
        } catch (e) {
            setBadge('errors-badge', 'Недоступно');
            body.innerHTML = UI.stateBlock('error', 'Ошибки недоступны', e.message || 'Ошибка соединения.');
        }
    }

    function loadAll() {
        document.getElementById('skud-body').innerHTML = UI.stateBlock('warning', 'Просмотр событий СКУД отложен', 'Приём событий выполняет интеграционный webhook. Безопасный список событий не подтверждён в текущем backend-контракте.');
        loadHealth(); loadIntegrity(); loadQr(); loadBackups(); loadDash(); loadLatestErrors();
    }

    document.getElementById('refresh-btn').addEventListener('click', loadAll);
    document.getElementById('qr-load-btn').addEventListener('click', loadQr);
    loadAll();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

