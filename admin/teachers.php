<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Преподаватели';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Преподаватели</div>
        <div class="page-sub">Создание, редактирование и управление учетными записями преподавателей</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск по имени..." style="width:240px">
        <button class="btn btn-primary btn-sm" id="add-btn" type="button">Добавить преподавателя</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка преподавателей...</div>
<div class="alert alert-err" id="error" style="display:none"></div>
<div class="alert alert-ok" id="success" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Преподаватель</th>
                    <th>Кафедра</th>
                    <th>Должность</th>
                    <th>Email</th>
                    <th>Дисциплин</th>
                    <th>Статус</th>
                    <th>Действия</th>
                </tr>
            </thead>
            <tbody id="teachers-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">T</div>
    <div class="empty-title">Преподаватели не найдены</div>
</div>

<div class="modal-overlay" id="teacher-modal" style="display:none">
    <div class="modal" style="max-width:780px">
        <div class="modal-hdr">
            <span class="modal-title" id="modal-title">Добавить преподавателя</span>
            <button class="modal-close" id="modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="m-fio">ФИО</label>
                    <input class="form-ctrl" id="m-fio">
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
                    <label class="form-label" for="m-role">Роль</label>
                    <select class="form-ctrl" id="m-role"></select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-dept">Кафедра</label>
                    <input class="form-ctrl" id="m-dept">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-degree">Ученая степень</label>
                    <input class="form-ctrl" id="m-degree">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-position">Должность</label>
                    <input class="form-ctrl" id="m-position">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-work-phone">Рабочий телефон</label>
                    <input class="form-ctrl" id="m-work-phone">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-work-email">Рабочий email</label>
                    <input class="form-ctrl" id="m-work-email" type="email">
                </div>
                <div class="form-group create-only">
                    <label class="form-label" for="m-email">Email учетной записи</label>
                    <input class="form-ctrl" id="m-email" type="email">
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-hire-date">Дата найма</label>
                    <input class="form-ctrl" id="m-hire-date" type="date">
                </div>
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
    var roles = [];
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

    async function loadRoles() {
        var response = await callAPI('ПолучитьРоли', { ТолькоАктивные: 0 });
        roles = response && response.success ? UI.rows(response.data) : [];
        document.getElementById('m-role').innerHTML = roles.map(function (row) {
            var name = pick(row, 'Название') || '';
            var selected = name === 'Преподаватель' ? ' selected' : '';
            return '<option value="' + esc(pick(row, 'Роль_ID') || '') + '"' + selected + '>' + esc(name) + '</option>';
        }).join('');
    }

    async function load() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('error').style.display = 'none';
        try {
            var response = await callAPI('ПолучитьПреподавателей', { ТолькоАктивные: 0 });
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
        render(allRows.filter(function (row) {
            return String((pick(row, 'ФИО') || '') + ' ' + (pick(row, 'Кафедра') || '') + ' ' + (pick(row, 'Логин') || '')).toLowerCase().indexOf(q) !== -1;
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
        document.getElementById('teachers-tbody').innerHTML = rows.map(function (row, idx) {
            var tid = pick(row, 'Преподаватель_ID') || '';
            var uid = pick(row, 'Пользователь_ID') || '';
            var fio = pick(row, 'ФИО') || '—';
            var active = Number(pick(row, 'Активен') || 0) === 1;
            var ini = fio.split(' ').map(function (part) { return part ? part[0].toUpperCase() : ''; }).join('').slice(0, 2);
            return '<tr>' +
                '<td>' + (idx + 1) + '</td>' +
                '<td><div class="flex gap-2 items-center"><div class="avatar">' + esc(ini) + '</div><strong>' + esc(fio) + '</strong></div><div class="list-meta">' + esc(pick(row, 'Логин') || '') + '</div></td>' +
                '<td>' + esc(pick(row, 'Кафедра') || '—') + '</td>' +
                '<td>' + esc(pick(row, 'Должность') || '—') + '</td>' +
                '<td>' + esc(pick(row, 'Email_Рабочий', 'Email') || '—') + '</td>' +
                '<td><span class="tag">' + esc(pick(row, 'КоличествоДисциплин') || 0) + '</span></td>' +
                '<td>' + UI.badge(active ? 'Активен' : 'Заблокирован') + '</td>' +
                '<td><div class="cap-actions"><button class="btn btn-ghost btn-sm" data-edit="' + esc(tid) + '">Изм.</button><button class="btn btn-ghost btn-sm text-danger" data-block="' + esc(uid) + '" data-active="' + (active ? '1' : '0') + '">' + (active ? 'Блок' : 'Разблок') + '</button><a class="btn btn-outline btn-sm" href="/ais-system-ru/admin/reports.php?teacher=' + esc(tid) + '">Отчёт</a></div></td>' +
            '</tr>';
        }).join('');
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    function openModal(row) {
        editingId = row ? pick(row, 'Преподаватель_ID') : null;
        document.getElementById('modal-title').textContent = editingId ? 'Редактировать преподавателя' : 'Добавить преподавателя';
        document.querySelectorAll('.create-only').forEach(function (el) { el.style.display = editingId ? 'none' : ''; });
        document.getElementById('m-fio').value = row ? (pick(row, 'ФИО') || '') : '';
        document.getElementById('m-login').value = '';
        document.getElementById('m-password').value = '';
        document.getElementById('m-dept').value = row ? (pick(row, 'Кафедра') || '') : '';
        document.getElementById('m-degree').value = row ? (pick(row, 'Ученая_Степень') || '') : '';
        document.getElementById('m-position').value = row ? (pick(row, 'Должность') || '') : '';
        document.getElementById('m-work-phone').value = row ? (pick(row, 'Телефон_Рабочий') || '') : '';
        document.getElementById('m-work-email').value = row ? (pick(row, 'Email_Рабочий') || '') : '';
        document.getElementById('m-email').value = row ? (pick(row, 'Email') || '') : '';
        document.getElementById('m-hire-date').value = row ? String(pick(row, 'Дата_Найма') || '').slice(0, 10) : '';
        document.getElementById('m-note').value = row ? (pick(row, 'Примечание') || '') : '';
        document.getElementById('modal-error').style.display = 'none';
        document.getElementById('teacher-modal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('teacher-modal').style.display = 'none';
        editingId = null;
    }

    async function save() {
        var error = document.getElementById('modal-error');
        error.style.display = 'none';
        var fio = document.getElementById('m-fio').value.trim();
        if (!fio) { error.textContent = 'Введите ФИО.'; error.style.display = 'flex'; return; }
        var btn = document.getElementById('modal-save');
        UI.setBusy(btn, true, 'Сохранение...');
        try {
            var base = {
                ФИО: fio,
                Кафедра: document.getElementById('m-dept').value.trim() || null,
                Ученая_Степень: document.getElementById('m-degree').value.trim() || null,
                Должность: document.getElementById('m-position').value.trim() || null,
                Телефон_Рабочий: document.getElementById('m-work-phone').value.trim() || null,
                Email_Рабочий: document.getElementById('m-work-email').value.trim() || null,
                Дата_Найма: document.getElementById('m-hire-date').value || null,
                Примечание: document.getElementById('m-note').value.trim() || null
            };
            var action;
            var params;
            if (editingId) {
                action = 'ОбновитьПреподавателя';
                params = Object.assign(base, {
                    Преподаватель_ID: editingId,
                    Email: document.getElementById('m-work-email').value.trim() || null,
                    Телефон: document.getElementById('m-work-phone').value.trim() || null,
                    КтоОбновил: await currentUserId()
                });
            } else {
                var login = document.getElementById('m-login').value.trim();
                var password = document.getElementById('m-password').value;
                if (!login || password.length < 6) { error.textContent = 'Укажите логин и пароль минимум 6 символов.'; error.style.display = 'flex'; return; }
                action = 'СоздатьПреподавателяСУчетнойЗаписью';
                params = Object.assign(base, {
                    Логин: login,
                    Пароль: password,
                    Email: document.getElementById('m-email').value.trim() || null,
                    Телефон: document.getElementById('m-work-phone').value.trim() || null,
                    Роль_ID: parseInt(document.getElementById('m-role').value || '0', 10) || null,
                    КтоСоздал: await currentUserId()
                });
            }
            var response = await callAPI(action, params);
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка сохранения');
            closeModal();
            alertBox('success', editingId ? 'Преподаватель обновлен.' : 'Преподаватель создан.', true);
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
    document.getElementById('teachers-tbody').addEventListener('click', function (event) {
        var edit = event.target.closest('[data-edit]');
        var block = event.target.closest('[data-block]');
        if (edit) {
            var row = allRows.find(function (item) { return String(pick(item, 'Преподаватель_ID')) === String(edit.getAttribute('data-edit')); });
            if (row) openModal(row);
        }
        if (block) toggleUser(block.getAttribute('data-block'), block.getAttribute('data-active') === '1');
    });

    loadRoles();
    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

