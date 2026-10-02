<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Справочники';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Справочники</div>
        <div class="page-sub">Факультеты, специальности, роли и права доступа</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-primary btn-sm" id="add-role-btn" type="button" style="display:none">Добавить роль</button>
        <button class="btn btn-outline btn-sm" id="refresh-btn" type="button">Обновить</button>
    </div>
</div>

<div class="tabs-row">
    <button class="btn btn-outline tab-btn active" data-tab="faculties" type="button">Факультеты</button>
    <button class="btn btn-outline tab-btn" data-tab="specialties" type="button">Специальности</button>
    <button class="btn btn-outline tab-btn" data-tab="roles" type="button">Роли и доступ</button>
</div>

<div class="alert alert-err" id="ref-error" style="display:none"></div>
<div class="alert alert-ok" id="ref-ok" style="display:none"></div>

<div class="card">
    <div class="card-body">
        <div id="ref-body"><div class="alert alert-info">Загрузка...</div></div>
    </div>
</div>

<div class="modal-overlay" id="role-modal" style="display:none">
    <div class="modal" style="max-width:560px">
        <div class="modal-hdr">
            <span class="modal-title" id="role-modal-title">Добавить роль</span>
            <button class="modal-close" id="role-modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label" for="role-name">Название роли</label>
                <input class="form-ctrl" id="role-name" placeholder="Например: Диспетчер">
            </div>
            <div class="form-group">
                <label class="form-label" for="role-description">Описание</label>
                <textarea class="form-ctrl" id="role-description" rows="3" placeholder="Назначение роли"></textarea>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="role-level">Уровень доступа</label>
                    <input class="form-ctrl" id="role-level" type="number" min="0" step="1" value="1">
                </div>
                <div class="form-group">
                    <label class="form-label" for="role-deletable">Удаляемая роль</label>
                    <select class="form-ctrl" id="role-deletable">
                        <option value="1">Да</option>
                        <option value="0">Нет</option>
                    </select>
                </div>
            </div>
            <div class="form-group" id="copy-permissions-wrap">
                <label class="form-label" for="copy-role">Скопировать права с роли</label>
                <select class="form-ctrl" id="copy-role">
                    <option value="">Не копировать</option>
                </select>
            </div>
            <div class="alert alert-err" id="role-modal-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="role-modal-cancel" type="button">Отмена</button>
            <button class="btn btn-primary" id="role-modal-save" type="button">Сохранить</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="perm-modal" style="display:none">
    <div class="modal" style="max-width:620px">
        <div class="modal-hdr">
            <span class="modal-title" id="perm-modal-title">Добавить право</span>
            <button class="modal-close" id="perm-modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="perm-object">Объект</label>
                    <input class="form-ctrl" id="perm-object" list="perm-object-list" placeholder="Пользователь">
                    <datalist id="perm-object-list"></datalist>
                </div>
                <div class="form-group">
                    <label class="form-label" for="perm-action">Действие</label>
                    <input class="form-ctrl" id="perm-action" list="perm-action-list" placeholder="Чтение">
                    <datalist id="perm-action-list"></datalist>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="perm-allowed">Разрешение</label>
                <select class="form-ctrl" id="perm-allowed">
                    <option value="1">Разрешено</option>
                    <option value="0">Запрещено</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label" for="perm-condition">Условие</label>
                <textarea class="form-ctrl" id="perm-condition" rows="2" placeholder="Например: ТолькоСвоиГруппы"></textarea>
            </div>
            <div class="form-group">
                <label class="form-label" for="perm-description">Описание</label>
                <textarea class="form-ctrl" id="perm-description" rows="3" placeholder="Что разрешает это право"></textarea>
            </div>
            <div class="alert alert-err" id="perm-modal-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="perm-modal-cancel" type="button">Отмена</button>
            <button class="btn btn-primary" id="perm-modal-save" type="button">Сохранить</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="ref-modal" style="display:none">
    <div class="modal" style="max-width:620px">
        <div class="modal-hdr">
            <span class="modal-title" id="ref-modal-title">Справочник</span>
            <button class="modal-close" id="ref-modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="ref-name">Название</label>
                    <input class="form-ctrl" id="ref-name">
                </div>
                <div class="form-group" id="ref-code-wrap">
                    <label class="form-label" for="ref-code">Код</label>
                    <input class="form-ctrl" id="ref-code">
                </div>
            </div>
            <div class="form-group" id="ref-faculty-wrap" style="display:none">
                <label class="form-label" for="ref-faculty">Факультет</label>
                <select class="form-ctrl" id="ref-faculty"></select>
            </div>
            <div class="form-group">
                <label class="form-label" for="ref-description">Описание</label>
                <textarea class="form-ctrl" id="ref-description" rows="3"></textarea>
            </div>
            <div class="alert alert-err" id="ref-modal-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="ref-modal-cancel" type="button">Отмена</button>
            <button class="btn btn-primary" id="ref-modal-save" type="button">Сохранить</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    var UI = window.AISRoleUI || {};
    var current = 'faculties';
    var allRoles = [];
    var permissions = [];
    var selectedRoleId = null;
    var editingRoleId = null;
    var editingPermissionRow = null;
    var referenceRows = [];
    var facultiesCache = [];
    var editingRefRow = null;

    var configs = {
        faculties: {
            action: 'ПолучитьФакультеты',
            title: 'Факультеты',
            singular: 'факультет',
            id: 'Факультет_ID',
            columns: ['Название','Описание','Дата_Создания'],
            createAction: 'СоздатьФакультет',
            updateAction: 'ОбновитьФакультет',
            deleteAction: 'УдалитьФакультет'
        },
        specialties: {
            action: 'ПолучитьСпециальности',
            title: 'Специальности',
            singular: 'специальность',
            id: 'Специальность_ID',
            columns: ['Название','Код','ФакультетНазвание','Описание'],
            createAction: 'СоздатьСпециальность',
            updateAction: 'ОбновитьСпециальность',
            deleteAction: 'УдалитьСпециальность',
            needsFaculty: true
        }
    };

    function esc(value) {
        if (UI.esc) return UI.esc(value);
        return String(value == null ? '' : value).replace(/[&<>"']/g, function(ch) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch];
        });
    }

    function pick(obj) {
        for (var i = 1; i < arguments.length; i++) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) return obj[arguments[i]];
        }
        return null;
    }

    function rows(data) {
        if (UI.rows) return UI.rows(data);
        if (Array.isArray(data) && Array.isArray(data[0])) return data.reduce(function(acc, set) { return acc.concat(set); }, []);
        return Array.isArray(data) ? data : [];
    }

    function currentUserId() {
        return parseInt(localStorage.getItem('ais_user_id') || '0', 10);
    }

    function setError(message) {
        var el = document.getElementById('ref-error');
        el.textContent = message || '';
        el.style.display = message ? 'flex' : 'none';
    }

    function setOk(message) {
        var el = document.getElementById('ref-ok');
        el.textContent = message || '';
        el.style.display = message ? 'flex' : 'none';
        if (message) setTimeout(function(){ el.style.display = 'none'; }, 3200);
    }

    function normalizeBool(value) {
        return value === true || value === 1 || value === '1' || String(value).toLowerCase() === 'true';
    }

    function roleId(row) {
        return parseInt(pick(row, 'Роль_ID', 'role_id') || '0', 10);
    }

    function selectedRole() {
        return allRoles.find(function(role) { return roleId(role) === selectedRoleId; }) || null;
    }

    function roleBadge(row) {
        var name = String(pick(row, 'Название') || '');
        if (name === 'Admin') return '<span class="badge b-err">Admin</span>';
        if (name === 'Методист') return '<span class="badge b-muted">Методист</span>';
        if (name === 'Преподаватель') return '<span class="badge b-ok">Преподаватель</span>';
        if (name === 'Студент') return '<span class="badge b-primary">Студент</span>';
        if (name === 'Куратор') return '<span class="badge b-warn">Куратор</span>';
        return '<span class="badge b-info">' + esc(name || 'Роль') + '</span>';
    }

    function cell(row, key) {
        var value = pick(row, key, key.replace(/_/g, ' '), key + 'Название');
        return esc(value === null || value === undefined || value === '' ? '-' : value);
    }

    async function loadReference() {
        var cfg = configs[current];
        var body = document.getElementById('ref-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        setError('');
        try {
            var result = await callAPI(cfg.action, {});
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка загрузки');
            referenceRows = rows(result.data);
            if (!referenceRows.length) {
                body.innerHTML = (UI.stateBlock ? UI.stateBlock('info', 'Нет данных', 'Справочник пуст или недоступен.') : '<div class="empty-state">Нет данных</div>');
                return;
            }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>#</th>' +
                cfg.columns.map(function(col) { return '<th>' + esc(col.replace(/_/g, ' ')) + '</th>'; }).join('') +
                '<th>Действия</th>' +
                '</tr></thead><tbody>' +
                referenceRows.map(function(row, index) {
                    var id = pick(row, cfg.id) || '';
                    return '<tr data-ref-id="' + esc(id) + '"><td>' + (index + 1) + '</td>' +
                        cfg.columns.map(function(col) { return '<td>' + cell(row, col) + '</td>'; }).join('') +
                        '<td><div class="flex gap-1">' +
                            '<button class="btn btn-ghost btn-sm" type="button" data-action="edit-ref">Изм.</button>' +
                            '<button class="btn btn-ghost btn-sm text-danger" type="button" data-action="delete-ref">Удалить</button>' +
                        '</div></td></tr>';
                }).join('') +
                '</tbody></table></div>';
        } catch (error) {
            body.innerHTML = (UI.stateBlock ? UI.stateBlock('error', cfg.title + ' недоступны', error.message || 'Ошибка соединения.') : '<div class="alert alert-err">Ошибка загрузки</div>');
        }
    }

    async function ensureFaculties() {
        if (facultiesCache.length) return facultiesCache;
        var result = await callAPI('ПолучитьФакультеты', {});
        if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка загрузки факультетов');
        facultiesCache = rows(result.data);
        return facultiesCache;
    }

    function refId(row) {
        var cfg = configs[current];
        return parseInt(pick(row, cfg.id) || '0', 10);
    }

    async function openReferenceModal(row) {
        var cfg = configs[current];
        editingRefRow = row || null;
        document.getElementById('ref-modal-title').textContent = (row ? 'Редактировать ' : 'Добавить ') + cfg.singular;
        document.getElementById('ref-name').value = row ? (pick(row, 'Название') || '') : '';
        document.getElementById('ref-code').value = row ? (pick(row, 'Код') || '') : '';
        document.getElementById('ref-description').value = row ? (pick(row, 'Описание') || '') : '';
        document.getElementById('ref-code-wrap').style.display = current === 'specialties' ? '' : 'none';
        document.getElementById('ref-faculty-wrap').style.display = cfg.needsFaculty ? '' : 'none';
        document.getElementById('ref-modal-error').style.display = 'none';

        if (cfg.needsFaculty) {
            try {
                var faculties = await ensureFaculties();
                var selected = row ? parseInt(pick(row, 'Факультет_ID') || '0', 10) : 0;
                document.getElementById('ref-faculty').innerHTML = '<option value="">Выберите факультет</option>' +
                    faculties.map(function(faculty) {
                        var id = parseInt(pick(faculty, 'Факультет_ID') || '0', 10);
                        return '<option value="' + id + '"' + (id === selected ? ' selected' : '') + '>' + esc(pick(faculty, 'Название') || '-') + '</option>';
                    }).join('');
            } catch (error) {
                document.getElementById('ref-faculty').innerHTML = '<option value="">Факультеты недоступны</option>';
            }
        }

        document.getElementById('ref-modal').style.display = 'flex';
    }

    function closeReferenceModal() {
        document.getElementById('ref-modal').style.display = 'none';
        editingRefRow = null;
    }

    function referenceParams(cfg, isUpdate) {
        var params = {
            Название: document.getElementById('ref-name').value.trim(),
            Описание: document.getElementById('ref-description').value.trim() || null
        };

        if (current === 'specialties') {
            params['Код'] = document.getElementById('ref-code').value.trim() || null;
            params['Факультет_ID'] = parseInt(document.getElementById('ref-faculty').value || '0', 10);
        }

        if (isUpdate && editingRefRow) {
            params[cfg.id] = refId(editingRefRow);
            params['КтоОбновил'] = currentUserId();
        } else {
            params['КтоСоздал'] = currentUserId();
        }

        return params;
    }

    async function saveReference() {
        var cfg = configs[current];
        var err = document.getElementById('ref-modal-error');
        var btn = document.getElementById('ref-modal-save');
        var isUpdate = !!editingRefRow;
        err.style.display = 'none';

        var params = referenceParams(cfg, isUpdate);
        if (!params['Название']) {
            err.textContent = 'Введите название.';
            err.style.display = 'flex';
            return;
        }
        if (cfg.needsFaculty && !params['Факультет_ID']) {
            err.textContent = 'Выберите факультет.';
            err.style.display = 'flex';
            return;
        }

        btn.disabled = true;
        btn.textContent = 'Сохранение...';
        try {
            var result = await callAPI(isUpdate ? cfg.updateAction : cfg.createAction, params);
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка сохранения');
            closeReferenceModal();
            setOk(isUpdate ? 'Запись обновлена.' : 'Запись создана.');
            facultiesCache = current === 'faculties' ? [] : facultiesCache;
            await loadReference();
        } catch (error) {
            err.textContent = error.message || 'Ошибка соединения.';
            err.style.display = 'flex';
        } finally {
            btn.disabled = false;
            btn.textContent = 'Сохранить';
        }
    }

    async function deleteReference(row, button) {
        var cfg = configs[current];
        if (!window.confirm('Удалить запись справочника? Если запись используется, база данных отклонит операцию.')) return;
        button.disabled = true;
        try {
            var params = {};
            params[cfg.id] = refId(row);
            params['КтоУдалил'] = currentUserId();
            var result = await callAPI(cfg.deleteAction, params);
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка удаления');
            setOk('Запись удалена.');
            facultiesCache = current === 'faculties' ? [] : facultiesCache;
            await loadReference();
        } catch (error) {
            setError(error.message || 'Ошибка соединения.');
        } finally {
            button.disabled = false;
        }
    }

    function onReferenceBodyClick(event) {
        if (current === 'roles') return;
        var button = event.target.closest('button[data-action]');
        if (!button) return;
        var rowEl = event.target.closest('tr[data-ref-id]');
        if (!rowEl) return;
        var id = parseInt(rowEl.getAttribute('data-ref-id') || '0', 10);
        var row = referenceRows.find(function(item) { return refId(item) === id; });
        if (!row) return;
        var action = button.getAttribute('data-action');
        if (action === 'edit-ref') openReferenceModal(row);
        if (action === 'delete-ref') deleteReference(row, button);
    }

    function renderRolesShell() {
        document.getElementById('ref-body').innerHTML =
            '<div class="roles-admin-grid">' +
                '<section class="roles-list-panel">' +
                    '<div class="roles-panel-hdr">' +
                        '<div><strong>Роли системы</strong><span>Создание, изменение и удаление разрешённых ролей</span></div>' +
                        '<span class="tag" id="roles-count">0</span>' +
                    '</div>' +
                    '<div class="roles-list" id="roles-list"></div>' +
                '</section>' +
                '<section class="permissions-panel">' +
                    '<div class="roles-panel-hdr">' +
                        '<div><strong id="perm-role-title">Права роли</strong><span id="perm-role-sub">Выберите роль</span></div>' +
                        '<button class="btn btn-primary btn-sm" id="add-perm-btn" type="button" disabled>Добавить право</button>' +
                    '</div>' +
                    '<div id="permissions-body"><div class="alert alert-info">Выберите роль для управления правами.</div></div>' +
                '</section>' +
            '</div>';

        document.getElementById('add-perm-btn').addEventListener('click', function() { openPermissionModal(null); });
        document.getElementById('roles-list').addEventListener('click', onRoleListClick);
        document.getElementById('permissions-body').addEventListener('click', onPermissionClick);
    }

    async function loadRoles() {
        renderRolesShell();
        setError('');
        try {
            var result = await callAPI('ПолучитьРоли', { ТолькоАктивные: 0 });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка загрузки ролей');
            allRoles = rows(result.data);
            if (!selectedRoleId && allRoles.length) selectedRoleId = roleId(allRoles[0]);
            if (selectedRoleId && !allRoles.some(function(row) { return roleId(row) === selectedRoleId; })) {
                selectedRoleId = allRoles.length ? roleId(allRoles[0]) : null;
            }
            renderRoleOptions();
            renderRoles();
            if (selectedRoleId) await loadPermissions(selectedRoleId);
        } catch (error) {
            document.getElementById('ref-body').innerHTML = UI.stateBlock ? UI.stateBlock('error', 'Роли недоступны', error.message || 'Ошибка соединения.') : '<div class="alert alert-err">Роли недоступны</div>';
        }
    }

    function renderRoleOptions() {
        var copySelect = document.getElementById('copy-role');
        if (!copySelect) return;
        copySelect.innerHTML = '<option value="">Не копировать</option>' + allRoles.map(function(role) {
            return '<option value="' + roleId(role) + '">' + esc(pick(role, 'Название') || '') + '</option>';
        }).join('');
    }

    function renderRoles() {
        var list = document.getElementById('roles-list');
        var count = document.getElementById('roles-count');
        if (!list) return;
        count.textContent = allRoles.length + ' ролей';

        if (!allRoles.length) {
            list.innerHTML = '<div class="empty-state">Роли не найдены</div>';
            return;
        }

        list.innerHTML = allRoles.map(function(role) {
            var id = roleId(role);
            var canDelete = normalizeBool(pick(role, 'Можно_Удалять'));
            var active = id === selectedRoleId ? ' active' : '';
            return '<article class="role-card' + active + '" data-role-id="' + id + '">' +
                '<div class="role-card-main">' +
                    '<div>' + roleBadge(role) + '</div>' +
                    '<strong>' + esc(pick(role, 'Название') || '-') + '</strong>' +
                    '<span>' + esc(pick(role, 'Описание') || 'Описание не задано') + '</span>' +
                    '<div class="setting-tags">' +
                        '<span class="tag">Уровень: ' + esc(pick(role, 'Уровень_Доступа') || '0') + '</span>' +
                        (canDelete ? '<span class="badge b-warn">Удаляемая</span>' : '<span class="badge b-muted">Системная</span>') +
                    '</div>' +
                '</div>' +
                '<div class="role-card-actions">' +
                    '<button class="btn btn-ghost btn-sm" type="button" data-action="select">Права</button>' +
                    '<button class="btn btn-ghost btn-sm" type="button" data-action="edit">Изм.</button>' +
                    '<button class="btn btn-ghost btn-sm text-danger" type="button" data-action="delete"' + (canDelete ? '' : ' disabled') + '>Удалить</button>' +
                '</div>' +
            '</article>';
        }).join('');
    }

    async function loadPermissions(roleIdValue) {
        selectedRoleId = parseInt(roleIdValue, 10);
        permissions = [];
        renderRoles();
        var role = selectedRole();
        var title = document.getElementById('perm-role-title');
        var sub = document.getElementById('perm-role-sub');
        var body = document.getElementById('permissions-body');
        var addBtn = document.getElementById('add-perm-btn');

        title.textContent = role ? 'Права: ' + (pick(role, 'Название') || '') : 'Права роли';
        sub.textContent = role ? 'Объекты и действия, которыми управляет эта роль' : 'Выберите роль';
        addBtn.disabled = !role;
        body.innerHTML = '<div class="alert alert-info">Загрузка прав...</div>';

        if (!role) return;

        try {
            var result = await callAPI('ПолучитьРазрешенияРоли', {
                Роль_ID: selectedRoleId,
                КтоЗапросил: currentUserId()
            });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка загрузки прав');
            permissions = rows(result.data);
            renderPermissions();
        } catch (error) {
            body.innerHTML = UI.stateBlock ? UI.stateBlock('error', 'Права недоступны', error.message || 'Ошибка соединения.') : '<div class="alert alert-err">Права недоступны</div>';
        }
    }

    function updatePermissionDatalists() {
        var objects = Array.from(new Set(permissions.map(function(row) { return String(pick(row, 'Объект') || ''); }).filter(Boolean))).sort();
        var actions = Array.from(new Set(permissions.map(function(row) { return String(pick(row, 'Действие') || ''); }).filter(Boolean))).sort();
        document.getElementById('perm-object-list').innerHTML = objects.map(function(value) { return '<option value="' + esc(value) + '">'; }).join('');
        document.getElementById('perm-action-list').innerHTML = actions.map(function(value) { return '<option value="' + esc(value) + '">'; }).join('');
    }

    function renderPermissions() {
        var body = document.getElementById('permissions-body');
        updatePermissionDatalists();
        if (!permissions.length) {
            body.innerHTML = '<div class="empty-state">Для роли пока не заданы права</div>';
            return;
        }

        body.innerHTML = '<div class="tbl-wrap"><table><thead><tr>' +
            '<th>Объект</th><th>Действие</th><th>Статус</th><th>Условие</th><th>Описание</th><th>Действия</th>' +
            '</tr></thead><tbody>' +
            permissions.map(function(row) {
                var id = parseInt(pick(row, 'Разрешение_ID') || '0', 10);
                var allowed = normalizeBool(pick(row, 'Разрешено'));
                return '<tr data-permission-id="' + id + '">' +
                    '<td><strong>' + esc(pick(row, 'Объект') || '-') + '</strong></td>' +
                    '<td>' + esc(pick(row, 'Действие') || '-') + '</td>' +
                    '<td>' + (allowed ? '<span class="badge b-ok">Разрешено</span>' : '<span class="badge b-err">Запрещено</span>') + '</td>' +
                    '<td>' + esc(pick(row, 'Условие') || '-') + '</td>' +
                    '<td>' + esc(pick(row, 'Описание') || '-') + '</td>' +
                    '<td><div class="flex gap-1">' +
                        '<button class="btn btn-ghost btn-sm" type="button" data-action="toggle">' + (allowed ? 'Запретить' : 'Разрешить') + '</button>' +
                        '<button class="btn btn-ghost btn-sm" type="button" data-action="edit">Изм.</button>' +
                        '<button class="btn btn-ghost btn-sm text-danger" type="button" data-action="delete">Удалить</button>' +
                    '</div></td>' +
                '</tr>';
            }).join('') +
            '</tbody></table></div>';
    }

    function onRoleListClick(event) {
        var button = event.target.closest('button[data-action]');
        var card = event.target.closest('.role-card');
        if (!card) return;
        var id = parseInt(card.getAttribute('data-role-id') || '0', 10);
        if (!button) {
            loadPermissions(id);
            return;
        }
        var action = button.getAttribute('data-action');
        if (action === 'select') loadPermissions(id);
        if (action === 'edit') openRoleModal(id);
        if (action === 'delete') deleteRole(id, button);
    }

    function onPermissionClick(event) {
        var button = event.target.closest('button[data-action]');
        if (!button) return;
        var rowEl = event.target.closest('tr[data-permission-id]');
        if (!rowEl) return;
        var id = parseInt(rowEl.getAttribute('data-permission-id') || '0', 10);
        var row = permissions.find(function(item) { return parseInt(pick(item, 'Разрешение_ID') || '0', 10) === id; });
        if (!row) return;
        var action = button.getAttribute('data-action');
        if (action === 'edit') openPermissionModal(row);
        if (action === 'toggle') togglePermission(row, button);
        if (action === 'delete') deletePermission(row, button);
    }

    function openRoleModal(id) {
        editingRoleId = id || null;
        var role = editingRoleId ? allRoles.find(function(item) { return roleId(item) === editingRoleId; }) : null;
        document.getElementById('role-modal-title').textContent = editingRoleId ? 'Редактировать роль' : 'Добавить роль';
        document.getElementById('role-name').value = role ? (pick(role, 'Название') || '') : '';
        document.getElementById('role-description').value = role ? (pick(role, 'Описание') || '') : '';
        document.getElementById('role-level').value = role ? (pick(role, 'Уровень_Доступа') || 1) : 1;
        document.getElementById('role-deletable').value = role && normalizeBool(pick(role, 'Можно_Удалять')) ? '1' : (role ? '0' : '1');
        document.getElementById('copy-permissions-wrap').style.display = editingRoleId ? 'none' : '';
        document.getElementById('copy-role').value = '';
        document.getElementById('role-modal-error').style.display = 'none';
        document.getElementById('role-modal').style.display = 'flex';
    }

    function closeRoleModal() {
        document.getElementById('role-modal').style.display = 'none';
        editingRoleId = null;
    }

    async function saveRole() {
        var err = document.getElementById('role-modal-error');
        var btn = document.getElementById('role-modal-save');
        err.style.display = 'none';

        var name = document.getElementById('role-name').value.trim();
        var description = document.getElementById('role-description').value.trim();
        var level = parseInt(document.getElementById('role-level').value || '1', 10);
        var deletable = parseInt(document.getElementById('role-deletable').value || '0', 10);
        var copyRole = parseInt(document.getElementById('copy-role').value || '0', 10);

        if (!name) {
            err.textContent = 'Введите название роли.';
            err.style.display = 'flex';
            return;
        }

        btn.disabled = true;
        btn.textContent = 'Сохранение...';
        try {
            var params = {
                Название: name,
                Описание: description || null,
                Уровень_Доступа: isNaN(level) ? 1 : level,
                Можно_Удалять: deletable
            };
            var action;
            if (editingRoleId) {
                action = 'ОбновитьРоль';
                params['Роль_ID'] = editingRoleId;
                params['КтоОбновил'] = currentUserId();
            } else {
                action = 'СоздатьРоль';
                params['КтоСоздал'] = currentUserId();
                if (copyRole > 0) params['КопироватьПраваСРоли_ID'] = copyRole;
            }

            var result = await callAPI(action, params);
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка сохранения роли');
            closeRoleModal();
            setOk(editingRoleId ? 'Роль обновлена.' : 'Роль создана.');
            selectedRoleId = editingRoleId || selectedRoleId;
            await loadRoles();
        } catch (error) {
            err.textContent = error.message || 'Ошибка соединения.';
            err.style.display = 'flex';
        } finally {
            btn.disabled = false;
            btn.textContent = 'Сохранить';
        }
    }

    async function deleteRole(id, button) {
        if (!window.confirm('Удалить роль? Действие невозможно, если к роли привязаны пользователи.')) return;
        button.disabled = true;
        try {
            var result = await callAPI('УдалитьРоль', { Роль_ID: id, КтоУдалил: currentUserId() });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка удаления роли');
            if (selectedRoleId === id) selectedRoleId = null;
            setOk('Роль удалена.');
            await loadRoles();
        } catch (error) {
            setError(error.message || 'Ошибка соединения.');
        } finally {
            button.disabled = false;
        }
    }

    function openPermissionModal(row) {
        editingPermissionRow = row || null;
        document.getElementById('perm-modal-title').textContent = row ? 'Редактировать право' : 'Добавить право';
        document.getElementById('perm-object').value = row ? (pick(row, 'Объект') || '') : '';
        document.getElementById('perm-action').value = row ? (pick(row, 'Действие') || '') : '';
        document.getElementById('perm-allowed').value = row && !normalizeBool(pick(row, 'Разрешено')) ? '0' : '1';
        document.getElementById('perm-condition').value = row ? (pick(row, 'Условие') || '') : '';
        document.getElementById('perm-description').value = row ? (pick(row, 'Описание') || '') : '';
        document.getElementById('perm-modal-error').style.display = 'none';
        document.getElementById('perm-modal').style.display = 'flex';
    }

    function closePermissionModal() {
        document.getElementById('perm-modal').style.display = 'none';
        editingPermissionRow = null;
    }

    async function savePermission() {
        var err = document.getElementById('perm-modal-error');
        var btn = document.getElementById('perm-modal-save');
        err.style.display = 'none';

        var objectName = document.getElementById('perm-object').value.trim();
        var actionName = document.getElementById('perm-action').value.trim();
        var allowed = parseInt(document.getElementById('perm-allowed').value || '1', 10);
        var condition = document.getElementById('perm-condition').value.trim();
        var description = document.getElementById('perm-description').value.trim();

        if (!selectedRoleId) {
            err.textContent = 'Выберите роль.';
            err.style.display = 'flex';
            return;
        }
        if (!objectName || !actionName) {
            err.textContent = 'Введите объект и действие.';
            err.style.display = 'flex';
            return;
        }

        btn.disabled = true;
        btn.textContent = 'Сохранение...';
        try {
            var result = await callAPI('СохранитьРазрешениеРоли', {
                Роль_ID: selectedRoleId,
                Объект: objectName,
                Действие: actionName,
                Разрешено: allowed,
                Условие: condition || null,
                Описание: description || null,
                КтоОбновил: currentUserId()
            });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка сохранения права');
            closePermissionModal();
            setOk('Право сохранено.');
            await loadPermissions(selectedRoleId);
        } catch (error) {
            err.textContent = error.message || 'Ошибка соединения.';
            err.style.display = 'flex';
        } finally {
            btn.disabled = false;
            btn.textContent = 'Сохранить';
        }
    }

    async function togglePermission(row, button) {
        button.disabled = true;
        try {
            var result = await callAPI('СохранитьРазрешениеРоли', {
                Роль_ID: selectedRoleId,
                Объект: pick(row, 'Объект'),
                Действие: pick(row, 'Действие'),
                Разрешено: normalizeBool(pick(row, 'Разрешено')) ? 0 : 1,
                Условие: pick(row, 'Условие') || null,
                Описание: pick(row, 'Описание') || null,
                КтоОбновил: currentUserId()
            });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка изменения права');
            await loadPermissions(selectedRoleId);
        } catch (error) {
            setError(error.message || 'Ошибка соединения.');
        } finally {
            button.disabled = false;
        }
    }

    async function deletePermission(row, button) {
        if (!window.confirm('Удалить право роли?')) return;
        button.disabled = true;
        try {
            var result = await callAPI('УдалитьРазрешениеРоли', {
                Разрешение_ID: pick(row, 'Разрешение_ID'),
                КтоУдалил: currentUserId()
            });
            if (!result || !result.success) throw new Error(result && result.message ? result.message : 'Ошибка удаления права');
            setOk('Право удалено.');
            await loadPermissions(selectedRoleId);
        } catch (error) {
            setError(error.message || 'Ошибка соединения.');
        } finally {
            button.disabled = false;
        }
    }

    async function load() {
        var addBtn = document.getElementById('add-role-btn');
        addBtn.style.display = '';
        addBtn.textContent = current === 'roles' ? 'Добавить роль' : (current === 'faculties' ? 'Добавить факультет' : 'Добавить специальность');
        setError('');
        setOk('');
        if (current === 'roles') {
            await loadRoles();
        } else {
            await loadReference();
        }
    }

    document.querySelectorAll('.tab-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.tab-btn').forEach(function(item) { item.classList.remove('active'); });
            btn.classList.add('active');
            current = btn.dataset.tab;
            load();
        });
    });

    document.getElementById('refresh-btn').addEventListener('click', load);
    document.getElementById('add-role-btn').addEventListener('click', function() {
        if (current === 'roles') {
            openRoleModal(null);
            return;
        }
        openReferenceModal(null);
    });
    document.getElementById('ref-body').addEventListener('click', onReferenceBodyClick);
    document.getElementById('ref-modal-close').addEventListener('click', closeReferenceModal);
    document.getElementById('ref-modal-cancel').addEventListener('click', closeReferenceModal);
    document.getElementById('ref-modal-save').addEventListener('click', saveReference);
    document.getElementById('role-modal-close').addEventListener('click', closeRoleModal);
    document.getElementById('role-modal-cancel').addEventListener('click', closeRoleModal);
    document.getElementById('role-modal-save').addEventListener('click', saveRole);
    document.getElementById('perm-modal-close').addEventListener('click', closePermissionModal);
    document.getElementById('perm-modal-cancel').addEventListener('click', closePermissionModal);
    document.getElementById('perm-modal-save').addEventListener('click', savePermission);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

