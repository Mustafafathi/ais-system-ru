<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Центр управления';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Центр управления системой</div>
        <div class="page-sub">Инфраструктура, доступ, операции и контрольные панели администратора</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" id="refresh-btn" type="button">Обновить</button>
    </div>
</div>

<div class="alert alert-info">
    Все действия выполняются через утверждённые процедуры SQL Server. Произвольный SQL и команды операционной системы из интерфейса недоступны.
</div>

<div class="control-grid">
    <section class="cap-card">
        <div class="cap-card-hdr">
            <span class="cap-card-title">Инфраструктура</span>
            <span class="badge b-muted" id="infra-badge">—</span>
        </div>
        <div class="cap-card-body" id="infra-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </section>

    <section class="cap-card">
        <div class="cap-card-hdr">
            <span class="cap-card-title">Операции администратора</span>
            <span class="badge b-muted" id="ops-badge">—</span>
        </div>
        <div class="cap-card-body">
            <div id="operation-result" class="alert alert-info" style="display:none"></div>
            <div id="ops-body">
                <div class="alert alert-info">Загрузка...</div>
            </div>
        </div>
    </section>
</div>

<section class="cap-card mt-4">
    <div class="cap-card-hdr">
        <span class="cap-card-title">Доступ к разделам интерфейса</span>
        <div class="page-actions">
            <select class="form-ctrl control-auto" id="role-select">
                <option value="">Выберите роль</option>
            </select>
            <button class="btn btn-outline btn-sm" id="reload-access-btn" type="button">Показать</button>
        </div>
    </div>
    <div class="cap-card-body">
        <div id="access-result" class="alert alert-info" style="display:none"></div>
        <div id="access-body" class="cap-state">
            <strong>Роль не выбрана</strong>
            <span>Выберите роль, чтобы управлять видимостью разделов и динамической навигацией.</span>
        </div>
    </div>
</section>

<section class="cap-card mt-4">
    <div class="cap-card-hdr">
        <div>
            <span class="cap-card-title">Конструктор интерфейсов ролей</span>
            <div class="list-meta">Создание пунктов меню и рабочих поверхностей из утверждённых PHP-разделов</div>
        </div>
        <div class="page-actions">
            <button class="btn btn-primary btn-sm" id="add-section-btn" type="button">Добавить раздел</button>
            <button class="btn btn-outline btn-sm" id="reload-sections-btn" type="button">Обновить</button>
        </div>
    </div>
    <div class="cap-card-body">
        <div id="section-result" class="alert alert-info" style="display:none"></div>
        <div id="sections-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>
</section>

<section class="quick-actions-panel mt-4">
    <div class="section-title">Быстрые переходы</div>
    <div class="quick-actions">
        <a class="quick-action" href="/ais-system-ru/admin/users.php">Пользователи</a>
        <a class="quick-action" href="/ais-system-ru/admin/reference-data.php">Роли и справочники</a>
        <a class="quick-action" href="/ais-system-ru/admin/settings.php">Настройки</a>
        <a class="quick-action" href="/ais-system-ru/admin/monitoring.php">Мониторинг</a>
        <a class="quick-action" href="/ais-system-ru/admin/scheduled-reports.php">Плановые отчёты</a>
        <a class="quick-action" href="/ais-system-ru/admin/backup.php">Резервные копии</a>
    </div>
</section>

<div class="modal-overlay" id="section-modal" style="display:none">
    <div class="modal" style="max-width:760px">
        <div class="modal-hdr">
            <span class="modal-title" id="section-modal-title">Добавить раздел интерфейса</span>
            <button class="modal-close" id="section-modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="section-code">Код</label>
                    <input class="form-ctrl" id="section-code" placeholder="custom.dispatcher.dashboard">
                </div>
                <div class="form-group">
                    <label class="form-label" for="section-area">Область</label>
                    <select class="form-ctrl" id="section-area">
                        <option value="admin">admin</option>
                        <option value="student">student</option>
                        <option value="teacher">teacher</option>
                        <option value="curator">curator</option>
                        <option value="methodist">methodist</option>
                        <option value="common">common</option>
                        <option value="custom">custom</option>
                    </select>
                </div>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="section-group">Группа меню</label>
                    <input class="form-ctrl" id="section-group" placeholder="Управление">
                </div>
                <div class="form-group">
                    <label class="form-label" for="section-title">Название в меню</label>
                    <input class="form-ctrl" id="section-title" placeholder="Панель диспетчера">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="section-path">Путь существующей страницы</label>
                <input class="form-ctrl" id="section-path" placeholder="/ais-system-ru/admin/dashboard.php">
                <div class="form-hint">Разрешены только локальные PHP-страницы AIS. Интерфейс не создаёт новый PHP-код.</div>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="section-icon">Иконка</label>
                    <select class="form-ctrl" id="section-icon">
                        <option value="home">home</option>
                        <option value="user">user</option>
                        <option value="users">users</option>
                        <option value="group">group</option>
                        <option value="calendar">calendar</option>
                        <option value="book">book</option>
                        <option value="report">report</option>
                        <option value="settings">settings</option>
                        <option value="log">log</option>
                        <option value="backup">backup</option>
                        <option value="monitoring">monitoring</option>
                        <option value="import">import</option>
                        <option value="note">note</option>
                        <option value="qr">qr</option>
                    </select>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label class="form-label" for="section-group-sort">Сортировка группы</label>
                        <input class="form-ctrl" id="section-group-sort" type="number" value="100">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="section-sort">Сортировка</label>
                        <input class="form-ctrl" id="section-sort" type="number" value="100">
                    </div>
                </div>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="section-default">Страница по умолчанию</label>
                    <select class="form-ctrl" id="section-default">
                        <option value="0">Нет</option>
                        <option value="1">Да</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="section-active">Статус</label>
                    <select class="form-ctrl" id="section-active">
                        <option value="1">Активен</option>
                        <option value="0">Отключён</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="section-description">Описание</label>
                <textarea class="form-ctrl" id="section-description" rows="3"></textarea>
            </div>
            <label class="switch-row">
                <input id="section-grant-current-role" type="checkbox" checked>
                <span>Сразу разрешить выбранной роли</span>
            </label>
            <div id="section-modal-error" class="alert alert-err" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="section-modal-cancel" type="button">Отмена</button>
            <button class="btn btn-primary" id="section-modal-save" type="button">Сохранить раздел</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    var UI = window.AISRoleUI;
    var currentUserIdCache = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
    var roles = [];
    var sections = [];
    var editingSection = null;

    function pick(obj) {
        return UI.pick.apply(UI, arguments);
    }

    function setBadge(id, label) {
        var el = document.getElementById(id);
        if (!el) return;
        var wrap = document.createElement('div');
        wrap.innerHTML = UI.badge(label || '—');
        var badge = wrap.firstChild;
        el.className = badge.className;
        el.textContent = badge.textContent;
    }

    async function currentUserId() {
        if (currentUserIdCache) return currentUserIdCache;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        currentUserIdCache = parseInt(pick(row, 'Пользователь_ID', 'user_id') || '0', 10);
        if (currentUserIdCache) localStorage.setItem('ais_user_id', String(currentUserIdCache));
        return currentUserIdCache;
    }

    function normalizeRows(data) {
        return UI.rows(data);
    }

    function renderInfra(rows) {
        if (!rows.length) return UI.stateBlock('warning', 'Нет данных', 'Статус инфраструктуры недоступен.');
        return '<div class="tbl-wrap"><table><thead><tr><th>Компонент</th><th>Ключ</th><th>Значение</th><th>Статус</th><th>Описание</th></tr></thead><tbody>' +
            rows.map(function (row) {
                return '<tr>' +
                    '<td><strong>' + UI.esc(pick(row, 'Компонент') || '—') + '</strong></td>' +
                    '<td>' + UI.esc(pick(row, 'Ключ', 'Версия') || '—') + '</td>' +
                    '<td>' + UI.esc(pick(row, 'Значение') || pick(row, 'Версия') || '—') + '</td>' +
                    '<td>' + UI.badge(pick(row, 'Статус') || '—') + '</td>' +
                    '<td>' + UI.esc(pick(row, 'Описание') || '') + '</td>' +
                '</tr>';
            }).join('') +
            '</tbody></table></div>';
    }

    async function loadInfrastructure() {
        var body = document.getElementById('infra-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьИнфраструктурныйСтатус', { КтоЗапросил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var rows = normalizeRows(response.data);
            setBadge('infra-badge', rows.length ? rows.length + ' проверок' : 'Нет данных');
            body.innerHTML = renderInfra(rows);
        } catch (error) {
            setBadge('infra-badge', 'Ошибка');
            body.innerHTML = UI.stateBlock('error', 'Инфраструктура недоступна', error.message || 'Ошибка соединения.');
        }
    }

    function riskBadge(risk) {
        return UI.badge(risk || 'Средний');
    }

    function operationCard(row) {
        var code = pick(row, 'Код') || '';
        var needsParams = Number(pick(row, 'Требует_Параметры') || 0) === 1;
        return '<div class="operation-row">' +
            '<div class="operation-main">' +
                '<div><strong>' + UI.esc(pick(row, 'Название') || code) + '</strong> ' + riskBadge(pick(row, 'Риск')) + '</div>' +
                '<div class="list-meta">' + UI.esc(pick(row, 'Описание') || '') + '</div>' +
                '<div class="list-meta">Процедура: ' + UI.esc(pick(row, 'Процедура') || '—') + '</div>' +
            '</div>' +
            '<button class="btn btn-danger btn-sm run-operation" type="button" data-code="' + UI.esc(code) + '" data-needs-params="' + (needsParams ? '1' : '0') + '">Запустить</button>' +
        '</div>';
    }

    async function loadOperations() {
        var body = document.getElementById('ops-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьАдминОперации', { КтоЗапросил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var rows = normalizeRows(response.data);
            setBadge('ops-badge', rows.length ? rows.length + ' операций' : 'Нет операций');
            if (!rows.length) {
                body.innerHTML = UI.stateBlock('info', 'Операций нет', 'Реестр административных операций пуст.');
                return;
            }
            body.innerHTML = '<div class="operation-list">' + rows.map(operationCard).join('') + '</div>';
        } catch (error) {
            setBadge('ops-badge', 'Ошибка');
            body.innerHTML = UI.stateBlock('error', 'Операции недоступны', error.message || 'Ошибка соединения.');
        }
    }

    async function runOperation(button) {
        var code = button.getAttribute('data-code') || '';
        var reason = window.prompt('Укажите причину выполнения операции "' + code + '".');
        if (!reason) return;
        var params = {};
        if (button.getAttribute('data-needs-params') === '1') {
            var raw = window.prompt('Параметры JSON. Оставьте пустым для значений по умолчанию.', '{}');
            if (raw) {
                try {
                    params = JSON.parse(raw);
                } catch (error) {
                    UI.setAlert('operation-result', 'err', 'Некорректный JSON параметров.');
                    return;
                }
            }
        }
        if (!window.confirm('Подтвердите выполнение операции. Действие будет записано в журнал аудита.')) return;

        UI.setBusy(button, true, 'Выполняется...');
        try {
            var response = await callAPI('ВыполнитьАдминОперацию', {
                Код: code,
                КтоЗапустил: await currentUserId(),
                Подтверждение: 'ВЫПОЛНИТЬ',
                Причина: reason,
                ПараметрыJSON: JSON.stringify(params || {})
            });
            UI.setAlert('operation-result', response && response.success ? 'ok' : 'err', response && response.message ? response.message : (response && response.success ? 'Операция выполнена.' : 'Операция не выполнена.'));
            loadInfrastructure();
        } catch (error) {
            UI.setAlert('operation-result', 'err', error.message || 'Ошибка соединения.');
        } finally {
            UI.setBusy(button, false);
        }
    }

    function roleRows(data) {
        return normalizeRows(data);
    }

    async function loadRoles() {
        var response = await callAPI('ПолучитьРоли', { ТолькоАктивные: 0 });
        if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки ролей');
        roles = roleRows(response.data);
        document.getElementById('role-select').innerHTML = '<option value="">Выберите роль</option>' +
            roles.map(function (row) {
                return '<option value="' + UI.esc(pick(row, 'Роль_ID') || '') + '">' + UI.esc(pick(row, 'Название') || '—') + '</option>';
            }).join('');
    }

    function selectedRoleId() {
        return parseInt(document.getElementById('role-select').value || '0', 10);
    }

    function safeLocalPhpPath(path) {
        return /^\/ais-system\/[A-Za-z0-9_\-\/]+\.php$/.test(String(path || ''));
    }

    var sectionIconNames = ['home', 'user', 'users', 'group', 'calendar', 'book', 'report', 'settings', 'log', 'backup', 'monitoring', 'import', 'note', 'qr'];
    function safeSectionIcon(value) {
        var icon = String(value || 'settings').trim();
        return sectionIconNames.indexOf(icon) >= 0 ? icon : 'settings';
    }

    function sectionId(row) {
        return parseInt(pick(row, 'Раздел_ID') || '0', 10);
    }

    function sectionPayload() {
        return {
            Раздел_ID: editingSection ? sectionId(editingSection) : 0,
            Код: document.getElementById('section-code').value.trim(),
            Область: document.getElementById('section-area').value,
            Группа_Меню: document.getElementById('section-group').value.trim(),
            Группа_Сортировка: parseInt(document.getElementById('section-group-sort').value || '100', 10),
            Заголовок: document.getElementById('section-title').value.trim(),
            Путь: document.getElementById('section-path').value.trim(),
            Иконка: safeSectionIcon(document.getElementById('section-icon').value),
            Сортировка: parseInt(document.getElementById('section-sort').value || '100', 10),
            По_Умолчанию: parseInt(document.getElementById('section-default').value || '0', 10),
            Активен: parseInt(document.getElementById('section-active').value || '1', 10),
            Описание: document.getElementById('section-description').value.trim() || null
        };
    }

    function validateSectionPayload(payload) {
        if (!payload.Код) return 'Введите код раздела.';
        if (!/^[A-Za-z0-9_.-]+$/.test(payload.Код)) return 'Код может содержать латинские буквы, цифры, точку, дефис и подчёркивание.';
        if (!payload.Группа_Меню) return 'Введите группу меню.';
        if (!payload.Заголовок) return 'Введите название раздела.';
        if (!safeLocalPhpPath(payload.Путь)) return 'Путь должен быть локальной PHP-страницей AIS, например /ais-system-ru/admin/dashboard.php.';
        if (!payload.Иконка) return 'Выберите иконку.';
        return '';
    }

    function openSectionModal(row) {
        editingSection = row || null;
        var isEdit = !!row;
        document.getElementById('section-modal-title').textContent = isEdit ? 'Редактировать раздел интерфейса' : 'Добавить раздел интерфейса';
        document.getElementById('section-code').value = row ? (pick(row, 'Код') || '') : '';
        document.getElementById('section-area').value = row ? (pick(row, 'Область') || 'custom') : 'custom';
        document.getElementById('section-group').value = row ? (pick(row, 'Группа_Меню') || '') : '';
        document.getElementById('section-title').value = row ? (pick(row, 'Заголовок') || '') : '';
        document.getElementById('section-path').value = row ? (pick(row, 'Путь') || '') : '';
        document.getElementById('section-icon').value = row ? safeSectionIcon(pick(row, 'Иконка')) : 'settings';
        document.getElementById('section-group-sort').value = row ? (pick(row, 'Группа_Сортировка') || 100) : 100;
        document.getElementById('section-sort').value = row ? (pick(row, 'Сортировка') || 100) : 100;
        document.getElementById('section-default').value = Number(pick(row, 'По_Умолчанию') || 0) === 1 ? '1' : '0';
        document.getElementById('section-active').value = Number(pick(row, 'Активен') || 0) === 1 ? '1' : '0';
        document.getElementById('section-description').value = row ? (pick(row, 'Описание') || '') : '';
        document.getElementById('section-grant-current-role').checked = !isEdit && selectedRoleId() > 0;
        document.getElementById('section-grant-current-role').disabled = selectedRoleId() === 0;
        document.getElementById('section-modal-error').style.display = 'none';
        document.getElementById('section-modal').style.display = 'flex';
    }

    function closeSectionModal() {
        document.getElementById('section-modal').style.display = 'none';
        editingSection = null;
    }

    function renderSections() {
        var body = document.getElementById('sections-body');
        if (!sections.length) {
            body.innerHTML = UI.stateBlock('info', 'Разделы не найдены', 'Создайте первый раздел интерфейса для роли.');
            return;
        }
        body.innerHTML = '<div class="tbl-wrap"><table><thead><tr>' +
            '<th>Раздел</th><th>Область</th><th>Группа</th><th>Путь</th><th>Иконка</th><th>Статус</th><th>Ролей</th><th>Действия</th>' +
            '</tr></thead><tbody>' +
            sections.map(function(row) {
                var active = Number(pick(row, 'Активен') || 0) === 1;
                return '<tr data-section-row="' + sectionId(row) + '">' +
                    '<td><strong>' + UI.esc(pick(row, 'Заголовок') || '—') + '</strong><div class="list-meta">' + UI.esc(pick(row, 'Код') || '') + '</div></td>' +
                    '<td>' + UI.esc(pick(row, 'Область') || '—') + '</td>' +
                    '<td>' + UI.esc(pick(row, 'Группа_Меню') || '—') + '<div class="list-meta">Порядок: ' + UI.esc(pick(row, 'Группа_Сортировка') || '100') + ' / ' + UI.esc(pick(row, 'Сортировка') || '100') + '</div></td>' +
                    '<td><code>' + UI.esc(pick(row, 'Путь') || '—') + '</code></td>' +
                    '<td><span class="nav-icon icon-' + safeSectionIcon(pick(row, 'Иконка')) + '" aria-hidden="true"></span></td>' +
                    '<td>' + UI.badge(active ? 'Активен' : 'Отключён') + (Number(pick(row, 'По_Умолчанию') || 0) === 1 ? ' <span class="badge b-info">По умолчанию</span>' : '') + '</td>' +
                    '<td>' + UI.esc(pick(row, 'Разрешено_Ролей') || '0') + '</td>' +
                    '<td><button class="btn btn-ghost btn-sm edit-section" type="button">Изм.</button></td>' +
                '</tr>';
            }).join('') +
            '</tbody></table></div>';
    }

    async function loadSections() {
        var body = document.getElementById('sections-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьРазделыИнтерфейса', { КтоЗапросил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки разделов');
            sections = normalizeRows(response.data);
            renderSections();
        } catch (error) {
            body.innerHTML = UI.stateBlock('error', 'Разделы недоступны', error.message || 'Ошибка соединения.');
        }
    }

    async function saveSection() {
        var errorEl = document.getElementById('section-modal-error');
        var btn = document.getElementById('section-modal-save');
        var payload = sectionPayload();
        var error = validateSectionPayload(payload);
        errorEl.style.display = 'none';
        if (error) {
            errorEl.textContent = error;
            errorEl.style.display = 'flex';
            return;
        }

        payload.КтоОбновил = await currentUserId();
        UI.setBusy(btn, true, 'Сохранение...');
        try {
            var response = await callAPI('СохранитьРазделИнтерфейса', payload);
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка сохранения раздела');
            var rows = normalizeRows(response.data);
            var savedId = rows.length ? parseInt(pick(rows[0], 'Раздел_ID') || '0', 10) : 0;
            if (savedId && document.getElementById('section-grant-current-role').checked && selectedRoleId()) {
                await callAPI('СохранитьДоступРазделаРоли', {
                    Роль_ID: selectedRoleId(),
                    Раздел_ID: savedId,
                    Разрешено: 1,
                    КтоОбновил: await currentUserId()
                });
            }
            closeSectionModal();
            UI.setAlert('section-result', 'ok', 'Раздел интерфейса сохранён.');
            await loadSections();
            await loadAccess();
        } catch (err) {
            errorEl.textContent = err.message || 'Ошибка соединения.';
            errorEl.style.display = 'flex';
        } finally {
            UI.setBusy(btn, false);
        }
    }

    async function loadAccess() {
        var roleId = selectedRoleId();
        var body = document.getElementById('access-body');
        if (!roleId) {
            body.innerHTML = UI.stateBlock('info', 'Роль не выбрана', 'Выберите роль для настройки доступа.');
            return;
        }
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьДоступРазделовРоли', { Роль_ID: roleId, КтоЗапросил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var rows = normalizeRows(response.data);
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Раздел</th><th>Группа</th><th>Путь</th><th>Доступ</th></tr></thead><tbody>' +
                rows.map(function (row) {
                    var sectionId = pick(row, 'Раздел_ID') || '';
                    var allowed = Number(pick(row, 'Разрешено') || 0) === 1;
                    return '<tr>' +
                        '<td><strong>' + UI.esc(pick(row, 'Заголовок') || '—') + '</strong><div class="list-meta">' + UI.esc(pick(row, 'Код') || '') + '</div></td>' +
                        '<td>' + UI.esc(pick(row, 'Группа_Меню') || '—') + '</td>' +
                        '<td><code>' + UI.esc(pick(row, 'Путь') || '—') + '</code></td>' +
                        '<td><label class="switch-row"><input type="checkbox" class="section-access-toggle" data-section-id="' + UI.esc(sectionId) + '"' + (allowed ? ' checked' : '') + '><span>Разрешено</span></label></td>' +
                    '</tr>';
                }).join('') +
                '</tbody></table></div>';
        } catch (error) {
            body.innerHTML = UI.stateBlock('error', 'Доступ недоступен', error.message || 'Ошибка соединения.');
        }
    }

    async function saveAccess(input) {
        var roleId = parseInt(document.getElementById('role-select').value || '0', 10);
        var sectionId = parseInt(input.getAttribute('data-section-id') || '0', 10);
        if (!roleId || !sectionId) return;
        input.disabled = true;
        try {
            var response = await callAPI('СохранитьДоступРазделаРоли', {
                Роль_ID: roleId,
                Раздел_ID: sectionId,
                Разрешено: input.checked ? 1 : 0,
                КтоОбновил: await currentUserId()
            });
            UI.setAlert('access-result', response && response.success ? 'ok' : 'err', response && response.success ? 'Доступ обновлён.' : (response.message || 'Ошибка сохранения.'));
        } catch (error) {
            input.checked = !input.checked;
            UI.setAlert('access-result', 'err', error.message || 'Ошибка соединения.');
        } finally {
            input.disabled = false;
        }
    }

    document.getElementById('refresh-btn').addEventListener('click', function () {
        loadInfrastructure();
        loadOperations();
        loadSections();
        loadAccess();
    });
    document.getElementById('reload-access-btn').addEventListener('click', loadAccess);
    document.getElementById('reload-sections-btn').addEventListener('click', loadSections);
    document.getElementById('add-section-btn').addEventListener('click', function () {
        openSectionModal(null);
    });
    document.getElementById('section-modal-close').addEventListener('click', closeSectionModal);
    document.getElementById('section-modal-cancel').addEventListener('click', closeSectionModal);
    document.getElementById('section-modal-save').addEventListener('click', saveSection);
    document.getElementById('role-select').addEventListener('change', loadAccess);
    document.getElementById('ops-body').addEventListener('click', function (event) {
        var button = event.target.closest('.run-operation');
        if (button) runOperation(button);
    });
    document.getElementById('sections-body').addEventListener('click', function (event) {
        var button = event.target.closest('.edit-section');
        if (!button) return;
        var rowEl = event.target.closest('tr[data-section-row]');
        var id = rowEl ? parseInt(rowEl.getAttribute('data-section-row') || '0', 10) : 0;
        var row = sections.find(function(item) { return sectionId(item) === id; });
        if (row) openSectionModal(row);
    });
    document.getElementById('access-body').addEventListener('change', function (event) {
        if (event.target.classList.contains('section-access-toggle')) saveAccess(event.target);
    });

    loadInfrastructure();
    loadOperations();
    loadSections();
    loadRoles().catch(function (error) {
        document.getElementById('access-body').innerHTML = UI.stateBlock('error', 'Роли недоступны', error.message || 'Ошибка соединения.');
    });
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

