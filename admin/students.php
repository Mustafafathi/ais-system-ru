<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Студенты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Студенты</div>
        <div class="page-sub">Создание, обновление и деактивация карточек студентов</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск по имени / группе..." style="width:240px">
        <select class="form-ctrl" id="group-filter" style="width:auto"><option value="">Все группы</option></select>
        <button class="btn btn-primary btn-sm" id="add-btn" type="button">Добавить студента</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка студентов...</div>
<div class="alert alert-err" id="error" style="display:none"></div>
<div class="alert alert-ok" id="success" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Студент</th>
                    <th>Группа</th>
                    <th>Логин</th>
                    <th>Email</th>
                    <th>Статус</th>
                    <th>Действия</th>
                </tr>
            </thead>
            <tbody id="students-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">S</div>
    <div class="empty-title">Студенты не найдены</div>
</div>

<div class="modal-overlay" id="student-modal" style="display:none">
    <div class="modal" style="max-width:760px">
        <div class="modal-hdr">
            <span class="modal-title" id="modal-title">Добавить студента</span>
            <button class="modal-close" id="modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="m-fio">ФИО</label>
                    <input class="form-ctrl" id="m-fio">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-group">Группа</label>
                    <select class="form-ctrl" id="m-group"></select>
                </div>
                <div class="form-group create-only">
                    <label class="form-label" for="m-login">Логин</label>
                    <input class="form-ctrl" id="m-login">
                </div>
                <div class="form-group create-only">
                    <label class="form-label" for="m-password">Пароль</label>
                    <input class="form-ctrl" id="m-password" type="password">
                </div>
                <div class="form-group create-only">
                    <label class="form-label" for="m-email">Email</label>
                    <input class="form-ctrl" id="m-email" type="email">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-admission">Дата поступления</label>
                    <input class="form-ctrl" id="m-admission" type="date">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-birth">Дата рождения</label>
                    <input class="form-ctrl" id="m-birth" type="date">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-gender">Пол</label>
                    <select class="form-ctrl" id="m-gender">
                        <option value="">Не указан</option>
                        <option value="Мужской">Мужской</option>
                        <option value="Женский">Женский</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-parent-phone">Телефон родителей</label>
                    <input class="form-ctrl" id="m-parent-phone">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="m-address">Адрес</label>
                <input class="form-ctrl" id="m-address">
            </div>
            <div class="form-group">
                <label class="form-label" for="m-note">Примечание</label>
                <textarea class="form-ctrl" id="m-note" rows="3"></textarea>
            </div>
            <div class="alert alert-err" id="modal-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="modal-cancel" type="button">Отмена</button>
            <button class="btn btn-primary" id="modal-save" type="button">Сохранить</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';
    var UI = window.AISRoleUI;
    function esc(s) { return UI.esc(s); }
    function pick(obj) { return UI.pick.apply(UI, arguments); }

    var allRows = [];
    var groups = [];
    var editingId = null;

    async function currentUserId() {
        var id = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        if (id) return id;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        id = parseInt(pick(row, 'Пользователь_ID') || '0', 10);
        if (id) localStorage.setItem('ais_user_id', String(id));
        return id;
    }

    function alertBox(id, text, ok) {
        var el = document.getElementById(id);
        el.className = 'alert ' + (ok ? 'alert-ok' : 'alert-err');
        el.textContent = text;
        el.style.display = 'flex';
        if (ok) setTimeout(function () { el.style.display = 'none'; }, 3200);
    }

    async function loadGroups() {
        var response = await callAPI('ПолучитьУчебныеГруппы', {});
        groups = response && response.success ? UI.rows(response.data) : [];
        var options = '<option value="">Выберите группу</option>' + groups.map(function (row) {
            return '<option value="' + esc(pick(row, 'Группа_ID') || '') + '">' + esc(pick(row, 'Название', 'Название_Группы') || '—') + '</option>';
        }).join('');
        document.getElementById('m-group').innerHTML = options;
        document.getElementById('group-filter').innerHTML = '<option value="">Все группы</option>' + options.replace('<option value="">Выберите группу</option>', '');
    }

    async function load() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('error').style.display = 'none';
        try {
            var response = await callAPI('ПоискСтудентов', { ТолькоАктивные: 0, РазмерСтраницы: 1000 });
            document.getElementById('loading').style.display = 'none';
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            allRows = UI.rows(response.data);
            applyFilters();
        } catch (error) {
            document.getElementById('loading').style.display = 'none';
            alertBox('error', error.message || 'Ошибка соединения.', false);
        }
    }

    function applyFilters() {
        var q = document.getElementById('search-input').value.toLowerCase();
        var groupId = document.getElementById('group-filter').value;
        render(allRows.filter(function (row) {
            var text = String((pick(row, 'ФИО') || '') + ' ' + (pick(row, 'Название_Группы') || '') + ' ' + (pick(row, 'Логин') || '')).toLowerCase();
            return text.indexOf(q) !== -1 && (!groupId || String(pick(row, 'Группа_ID')) === String(groupId));
        }));
    }

    function render(rows) {
        var wrap = document.getElementById('list-wrap');
        var empty = document.getElementById('empty');
        if (!rows.length) {
            wrap.style.display = 'none';
            empty.style.display = 'flex';
            return;
        }
        document.getElementById('students-tbody').innerHTML = rows.map(function (row, idx) {
            var sid = pick(row, 'Студент_ID') || '';
            var uid = pick(row, 'Пользователь_ID') || '';
            var fio = pick(row, 'ФИО') || '—';
            var active = Number(pick(row, 'Активен') || 0) === 1;
            var ini = fio.split(' ').map(function (part) { return part ? part[0].toUpperCase() : ''; }).join('').slice(0, 2);
            return '<tr>' +
                '<td>' + (idx + 1) + '</td>' +
                '<td><div class="flex gap-2 items-center"><div class="avatar">' + esc(ini) + '</div><strong>' + esc(fio) + '</strong></div></td>' +
                '<td><span class="tag">' + esc(pick(row, 'Название_Группы') || '—') + '</span></td>' +
                '<td><code>' + esc(pick(row, 'Логин') || '—') + '</code></td>' +
                '<td>' + esc(pick(row, 'Email') || '—') + '</td>' +
                '<td>' + UI.badge(active ? 'Активен' : 'Заблокирован') + '</td>' +
                '<td><div class="cap-actions"><button class="btn btn-ghost btn-sm" data-edit="' + esc(sid) + '">Изм.</button><button class="btn btn-ghost btn-sm text-danger" data-block="' + esc(uid) + '" data-active="' + (active ? '1' : '0') + '">' + (active ? 'Блок' : 'Разблок') + '</button><a class="btn btn-outline btn-sm" href="/ais-system-ru/admin/reports.php?student=' + esc(sid) + '">Отчёт</a></div></td>' +
            '</tr>';
        }).join('');
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    function openModal(row) {
        editingId = row ? pick(row, 'Студент_ID') : null;
        document.getElementById('modal-title').textContent = editingId ? 'Редактировать студента' : 'Добавить студента';
        document.querySelectorAll('.create-only').forEach(function (el) { el.style.display = editingId ? 'none' : ''; });
        document.getElementById('m-fio').value = row ? (pick(row, 'ФИО') || '') : '';
        document.getElementById('m-group').value = row ? (pick(row, 'Группа_ID') || '') : '';
        document.getElementById('m-login').value = '';
        document.getElementById('m-password').value = '';
        document.getElementById('m-email').value = row ? (pick(row, 'Email') || '') : '';
        document.getElementById('m-admission').value = row ? String(pick(row, 'Дата_Поступления') || '').slice(0, 10) : new Date().toISOString().slice(0, 10);
        document.getElementById('m-birth').value = row ? String(pick(row, 'Дата_Рождения') || '').slice(0, 10) : '';
        document.getElementById('m-gender').value = row ? (pick(row, 'Пол') || '') : '';
        document.getElementById('m-parent-phone').value = row ? (pick(row, 'Телефон_Родителей') || '') : '';
        document.getElementById('m-address').value = row ? (pick(row, 'Адрес') || '') : '';
        document.getElementById('m-note').value = row ? (pick(row, 'Примечание') || '') : '';
        document.getElementById('modal-error').style.display = 'none';
        document.getElementById('student-modal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('student-modal').style.display = 'none';
        editingId = null;
    }

    async function save() {
        var error = document.getElementById('modal-error');
        error.style.display = 'none';
        var fio = document.getElementById('m-fio').value.trim();
        var groupId = parseInt(document.getElementById('m-group').value || '0', 10);
        if (!fio || !groupId) { error.textContent = 'Укажите ФИО и группу.'; error.style.display = 'flex'; return; }

        var btn = document.getElementById('modal-save');
        UI.setBusy(btn, true, 'Сохранение...');
        try {
            var action;
            var params;
            if (editingId) {
                action = 'ОбновитьСтудента';
                params = {
                    Студент_ID: editingId,
                    ФИО: fio,
                    Группа_ID: groupId,
                    Дата_Рождения: document.getElementById('m-birth').value || null,
                    Пол: document.getElementById('m-gender').value || null,
                    Адрес: document.getElementById('m-address').value.trim() || null,
                    Телефон_Родителей: document.getElementById('m-parent-phone').value.trim() || null,
                    Примечание: document.getElementById('m-note').value.trim() || null,
                    КтоОбновил: await currentUserId()
                };
            } else {
                var login = document.getElementById('m-login').value.trim();
                var password = document.getElementById('m-password').value;
                if (!login || password.length < 6) { error.textContent = 'Укажите логин и пароль минимум 6 символов.'; error.style.display = 'flex'; return; }
                action = 'СоздатьСтудентаСУчетнойЗаписью';
                params = {
                    Логин: login,
                    Пароль: password,
                    Email: document.getElementById('m-email').value.trim() || null,
                    ФИО: fio,
                    Группа_ID: groupId,
                    Дата_Поступления: document.getElementById('m-admission').value || null,
                    Дата_Рождения: document.getElementById('m-birth').value || null,
                    Пол: document.getElementById('m-gender').value || null,
                    Адрес: document.getElementById('m-address').value.trim() || null,
                    Телефон_Родителей: document.getElementById('m-parent-phone').value.trim() || null,
                    Примечание: document.getElementById('m-note').value.trim() || null,
                    КтоСоздал: await currentUserId()
                };
            }
            var response = await callAPI(action, params);
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка сохранения');
            closeModal();
            alertBox('success', editingId ? 'Карточка студента обновлена.' : 'Студент создан.', true);
            await load();
        } catch (err) {
            error.textContent = err.message || 'Ошибка соединения.';
            error.style.display = 'flex';
        } finally {
            UI.setBusy(btn, false);
        }
    }

    async function toggleUser(uid, active) {
        if (!uid) return;
        var next = active ? 0 : 1;
        if (!window.confirm(next ? 'Разблокировать пользователя?' : 'Заблокировать пользователя?')) return;
        try {
            var response = await callAPI('ОбновитьПользователя', { Пользователь_ID: uid, Активен: next, КтоОбновил: await currentUserId() });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка изменения статуса');
            alertBox('success', next ? 'Пользователь разблокирован.' : 'Пользователь заблокирован.', true);
            load();
        } catch (error) {
            alertBox('error', error.message || 'Ошибка соединения.', false);
        }
    }

    document.getElementById('add-btn').addEventListener('click', function () { openModal(null); });
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('modal-cancel').addEventListener('click', closeModal);
    document.getElementById('modal-save').addEventListener('click', save);
    document.getElementById('search-input').addEventListener('input', applyFilters);
    document.getElementById('group-filter').addEventListener('change', applyFilters);
    document.getElementById('students-tbody').addEventListener('click', function (event) {
        var edit = event.target.closest('[data-edit]');
        var block = event.target.closest('[data-block]');
        if (edit) {
            var row = allRows.find(function (item) { return String(pick(item, 'Студент_ID')) === String(edit.getAttribute('data-edit')); });
            if (row) openModal(row);
        }
        if (block) toggleUser(block.getAttribute('data-block'), block.getAttribute('data-active') === '1');
    });

    loadGroups().then(load);
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

