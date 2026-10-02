<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Группы';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Учебные группы</div>
        <div class="page-sub">Создание, редактирование и управление статусом групп</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск группы..." style="width:220px">
        <button class="btn btn-primary btn-sm" id="add-btn" type="button">Создать группу</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка групп...</div>
<div class="alert alert-err" id="error" style="display:none"></div>
<div class="alert alert-ok" id="success" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Группа</th>
                    <th>Специальность</th>
                    <th>Год</th>
                    <th>Студентов</th>
                    <th>Куратор</th>
                    <th>Статус</th>
                    <th>Действия</th>
                </tr>
            </thead>
            <tbody id="groups-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">G</div>
    <div class="empty-title">Группы не найдены</div>
</div>

<div class="modal-overlay" id="group-modal" style="display:none">
    <div class="modal" style="max-width:620px">
        <div class="modal-hdr">
            <span class="modal-title" id="modal-title">Создать группу</span>
            <button class="modal-close" id="modal-close" type="button">x</button>
        </div>
        <div class="modal-body">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="m-name">Название</label>
                    <input class="form-ctrl" id="m-name">
                </div>
                <div class="form-group" id="m-year-wrap">
                    <label class="form-label" for="m-year">Год поступления</label>
                    <input class="form-ctrl" id="m-year" type="number" min="2000" max="2100">
                </div>
                <div class="form-group" id="m-spec-wrap">
                    <label class="form-label" for="m-specialty">Специальность</label>
                    <select class="form-ctrl" id="m-specialty"></select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-curator">Куратор</label>
                    <select class="form-ctrl" id="m-curator"></select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="m-status">Статус</label>
                    <select class="form-ctrl" id="m-status">
                        <option value="Активна">Активна</option>
                        <option value="Неактивна">Неактивна</option>
                        <option value="Архивная">Архивная</option>
                    </select>
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
    var teachers = [];
    var specialties = [];
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

    function showAlert(id, text, ok) {
        var el = document.getElementById(id);
        el.className = 'alert ' + (ok ? 'alert-ok' : 'alert-err');
        el.textContent = text;
        el.style.display = 'flex';
        if (ok) setTimeout(function () { el.style.display = 'none'; }, 3200);
    }

    async function loadRefs() {
        var teacherResponse = await callAPI('ПолучитьПреподавателей', { ТолькоАктивные: 0 }).catch(function(){ return null; });
        teachers = teacherResponse && teacherResponse.success ? UI.rows(teacherResponse.data) : [];
        var specResponse = await callAPI('ПолучитьСпециальности', {}).catch(function(){ return null; });
        specialties = specResponse && specResponse.success ? UI.rows(specResponse.data) : [];

        document.getElementById('m-curator').innerHTML = '<option value="">Без куратора</option>' + teachers.map(function (row) {
            return '<option value="' + esc(pick(row, 'Преподаватель_ID') || '') + '">' + esc(pick(row, 'ФИО', 'Преподаватель') || '—') + '</option>';
        }).join('');
        document.getElementById('m-specialty').innerHTML = '<option value="">Выберите специальность</option>' + specialties.map(function (row) {
            return '<option value="' + esc(pick(row, 'Специальность_ID') || '') + '">' + esc(pick(row, 'Название') || '—') + '</option>';
        }).join('');
    }

    async function load() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('error').style.display = 'none';
        try {
            var response = await callAPI('ПолучитьУчебныеГруппы', {});
            document.getElementById('loading').style.display = 'none';
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            allRows = UI.rows(response.data);
            applyFilters();
        } catch (error) {
            document.getElementById('loading').style.display = 'none';
            showAlert('error', error.message || 'Ошибка соединения.', false);
        }
    }

    function applyFilters() {
        var q = document.getElementById('search-input').value.toLowerCase();
        render(allRows.filter(function (row) {
            return String(pick(row, 'Название', 'Группа', 'Название_Группы') || '').toLowerCase().indexOf(q) !== -1;
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

        document.getElementById('groups-tbody').innerHTML = rows.map(function (row, idx) {
            var gid = pick(row, 'Группа_ID') || '';
            var name = pick(row, 'Название', 'Группа', 'Название_Группы') || '—';
            var specialty = pick(row, 'Специальность', 'Направление') || '—';
            var year = pick(row, 'Год_Поступления') || '—';
            var students = pick(row, 'КоличествоСтудентов', 'Студентов', 'Кол_Студентов') || 0;
            var curator = pick(row, 'ФИО_Куратора', 'Куратор') || '—';
            var status = pick(row, 'Статус') || 'Активна';
            return '<tr>' +
                '<td>' + (idx + 1) + '</td>' +
                '<td><strong>' + esc(name) + '</strong><div class="list-meta">ID ' + esc(gid) + '</div></td>' +
                '<td>' + esc(specialty) + '</td>' +
                '<td><span class="tag">' + esc(year) + '</span></td>' +
                '<td>' + esc(students) + '</td>' +
                '<td>' + esc(curator) + '</td>' +
                '<td>' + UI.badge(status) + '</td>' +
                '<td><div class="cap-actions"><button class="btn btn-ghost btn-sm" data-edit="' + esc(gid) + '">Изм.</button><button class="btn btn-ghost btn-sm text-danger" data-archive="' + esc(gid) + '">Архив</button></div></td>' +
            '</tr>';
        }).join('');
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    function openModal(row) {
        editingId = row ? pick(row, 'Группа_ID') : null;
        document.getElementById('modal-title').textContent = editingId ? 'Редактировать группу' : 'Создать группу';
        document.getElementById('m-name').value = row ? (pick(row, 'Название', 'Группа', 'Название_Группы') || '') : '';
        document.getElementById('m-year').value = row ? (pick(row, 'Год_Поступления') || '') : new Date().getFullYear();
        document.getElementById('m-specialty').value = row ? (pick(row, 'Специальность_ID') || '') : '';
        document.getElementById('m-curator').value = row ? (pick(row, 'Куратор_ID') || '') : '';
        document.getElementById('m-status').value = row ? (pick(row, 'Статус') || 'Активна') : 'Активна';
        document.getElementById('m-note').value = row ? (pick(row, 'Примечание') || '') : '';
        document.getElementById('m-year-wrap').style.display = editingId ? 'none' : '';
        document.getElementById('m-spec-wrap').style.display = editingId ? 'none' : '';
        document.getElementById('modal-error').style.display = 'none';
        document.getElementById('group-modal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('group-modal').style.display = 'none';
        editingId = null;
    }

    async function save() {
        var error = document.getElementById('modal-error');
        error.style.display = 'none';
        var name = document.getElementById('m-name').value.trim();
        var year = parseInt(document.getElementById('m-year').value || '0', 10);
        var specialty = parseInt(document.getElementById('m-specialty').value || '0', 10);
        var curator = parseInt(document.getElementById('m-curator').value || '0', 10);
        var status = document.getElementById('m-status').value;
        var note = document.getElementById('m-note').value.trim();

        if (!name) { error.textContent = 'Введите название группы.'; error.style.display = 'flex'; return; }
        if (!editingId && (!year || !specialty)) { error.textContent = 'Укажите год поступления и специальность.'; error.style.display = 'flex'; return; }

        var btn = document.getElementById('modal-save');
        UI.setBusy(btn, true, 'Сохранение...');
        try {
            var params;
            var action;
            if (editingId) {
                action = 'ОбновитьУчебнуюГруппу';
                params = {
                    Группа_ID: editingId,
                    Название: name,
                    Статус: status,
                    Куратор_ID: curator || null,
                    Примечание: note || null,
                    КтоОбновил: await currentUserId()
                };
            } else {
                action = 'СоздатьУчебнуюГруппу';
                params = {
                    Название: name,
                    Год_Поступления: year,
                    Куратор_ID: curator || null,
                    Специальность_ID: specialty,
                    Примечание: note || null,
                    КтоСоздал: await currentUserId()
                };
            }
            var response = await callAPI(action, params);
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка сохранения');
            closeModal();
            showAlert('success', editingId ? 'Группа обновлена.' : 'Группа создана.', true);
            await load();
        } catch (err) {
            error.textContent = err.message || 'Ошибка соединения.';
            error.style.display = 'flex';
        } finally {
            UI.setBusy(btn, false);
        }
    }

    async function archiveGroup(id) {
        var row = allRows.find(function (item) { return String(pick(item, 'Группа_ID')) === String(id); });
        if (!row || !window.confirm('Перевести группу в архив?')) return;
        try {
            var response = await callAPI('ОбновитьУчебнуюГруппу', {
                Группа_ID: id,
                Название: pick(row, 'Название', 'Группа', 'Название_Группы') || '',
                Статус: 'Архивная',
                Куратор_ID: pick(row, 'Куратор_ID') || null,
                Примечание: pick(row, 'Примечание') || null,
                КтоОбновил: await currentUserId()
            });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка архивации');
            showAlert('success', 'Группа переведена в архив.', true);
            load();
        } catch (error) {
            showAlert('error', error.message || 'Ошибка соединения.', false);
        }
    }

    document.getElementById('add-btn').addEventListener('click', function () { openModal(null); });
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('modal-cancel').addEventListener('click', closeModal);
    document.getElementById('modal-save').addEventListener('click', save);
    document.getElementById('search-input').addEventListener('input', applyFilters);
    document.getElementById('groups-tbody').addEventListener('click', function (event) {
        var edit = event.target.closest('[data-edit]');
        var archive = event.target.closest('[data-archive]');
        if (edit) {
            var row = allRows.find(function (item) { return String(pick(item, 'Группа_ID')) === String(edit.getAttribute('data-edit')); });
            if (row) openModal(row);
        }
        if (archive) archiveGroup(archive.getAttribute('data-archive'));
    });

    loadRefs();
    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

