<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Пользователи';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Пользователи системы</div>
        <div class="page-sub">Управление учётными записями</div>
    </div>
    <div class="page-actions">
        <input type="text" class="form-ctrl" id="search-input" placeholder="Поиск по логину / имени..." style="width:240px">
        <select class="form-ctrl" id="role-filter" style="width:auto">
            <option value="">Все роли</option>
        </select>
        <button class="btn btn-primary btn-sm" id="add-btn">Добавить</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка пользователей...</div>
<div class="alert alert-err"  id="error" style="display:none"></div>
<div class="alert alert-ok"  id="action-ok" style="display:none"></div>

<div id="list-wrap" style="display:none">
    <div class="tbl-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Пользователь</th>
                    <th>Логин</th>
                    <th>Роль</th>
                    <th>Email</th>
                    <th>Статус</th>
                    <th>Сессии</th>
                    <th>Действия</th>
                </tr>
            </thead>
            <tbody id="users-tbody"></tbody>
        </table>
    </div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">U</div>
    <div class="empty-title">Пользователи не найдены</div>
</div>

<!-- Modal: добавить / редактировать -->
<div class="modal-overlay" id="user-modal" style="display:none">
    <div class="modal" style="max-width:500px">
        <div class="modal-hdr">
            <span class="modal-title" id="modal-title">Добавить пользователя</span>
            <button class="modal-close" id="modal-close">✕</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label">ФИО <span style="color:var(--c-err)">*</span></label>
                <input class="form-ctrl" id="m-fio" placeholder="Фамилия Имя Отчество">
            </div>
            <div class="form-group">
                <label class="form-label">Логин <span style="color:var(--c-err)">*</span></label>
                <input class="form-ctrl" id="m-login" placeholder="username">
            </div>
            <div class="form-group" id="m-pw-wrap">
                <label class="form-label">Пароль <span style="color:var(--c-err)">*</span></label>
                <input class="form-ctrl" id="m-password" type="password" placeholder="Минимум 6 символов">
            </div>
            <div class="form-group">
                <label class="form-label">Роль <span style="color:var(--c-err)">*</span></label>
                <select class="form-ctrl" id="m-role">
                    <option value="" selected disabled>Выберите роль</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input class="form-ctrl" id="m-email" type="email" placeholder="email@example.com">
            </div>
            <div class="alert alert-err" id="m-error" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" id="modal-cancel">Отмена</button>
            <button class="btn btn-primary" id="modal-save">Сохранить</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var allRows = [];
    var allRoles = [];
    var editingId = null;

    function roleBadge(r) {
        var map = {'Студент':'b-primary','Преподаватель':'b-ok','Куратор':'b-warn','Методист':'b-muted','Admin':'b-err','Администратор':'b-err'};
        return '<span class="badge ' + (map[r]||'b-muted') + '">' + esc(r) + '</span>';
    }

    function roleRows(data) {
        if (Array.isArray(data) && Array.isArray(data[0])) return data.reduce(function(acc, set) { return acc.concat(set); }, []);
        return Array.isArray(data) ? data : [];
    }

    function roleId(role) {
        if (role === null || role === undefined || role === '') return null;

        var id = parseInt(role, 10);
        if (allRoles.some(function(row) { return parseInt(pick(row, 'Роль_ID') || '0', 10) === id; })) {
            return id;
        }

        var match = allRoles.find(function(row) { return String(pick(row, 'Название') || '') === String(role); });
        if (match) return parseInt(pick(match, 'Роль_ID') || '0', 10);

        return null;
    }

    function roleLabel(roleIdValue) {
        var id = parseInt(roleIdValue, 10);
        var match = allRoles.find(function(row) { return parseInt(pick(row, 'Роль_ID') || '0', 10) === id; });
        return match ? String(pick(match, 'Название') || '') : '';
    }

    function renderRoleControls() {
        var filter = document.getElementById('role-filter');
        var modalRole = document.getElementById('m-role');
        var currentFilter = filter.value;
        var currentModal = modalRole.value;

        filter.innerHTML = '<option value="">Все роли</option>' + allRoles.map(function(row) {
            var name = String(pick(row, 'Название') || '');
            return '<option value="' + esc(name) + '">' + esc(name) + '</option>';
        }).join('');
        filter.value = Array.prototype.some.call(filter.options, function(opt) { return opt.value === currentFilter; }) ? currentFilter : '';

        modalRole.innerHTML = '<option value="" selected disabled>Выберите роль</option>' + allRoles.map(function(row) {
            var id = parseInt(pick(row, 'Роль_ID') || '0', 10);
            var name = String(pick(row, 'Название') || '');
            return '<option value="' + id + '">' + esc(name) + '</option>';
        }).join('');
        if (currentModal && Array.prototype.some.call(modalRole.options, function(opt) { return opt.value === currentModal; })) {
            modalRole.value = currentModal;
        }
    }

    async function loadRoles() {
        var r = await callAPI('ПолучитьРоли', { ТолькоАктивные: 0 });
        if (!r || !r.success) {
            throw new Error(r && r.message ? r.message : 'Ошибка загрузки ролей');
        }
        allRoles = roleRows(r.data);
        renderRoleControls();
    }

    async function load() {
        var loading = document.getElementById('loading');
        var error   = document.getElementById('error');
        loading.style.display = 'flex'; error.style.display = 'none';
        document.getElementById('list-wrap').style.display = 'none';
        document.getElementById('empty').style.display = 'none';

        try {
            if (!allRoles.length) {
                await loadRoles();
            }
            var r = await callAPI('ПолучитьСписокПользователей', {});
            loading.style.display = 'none';

            if (!r || !r.success) {
                error.textContent = r && r.message ? r.message : 'Ошибка загрузки';
                error.style.display = 'flex'; return;
            }

            allRows = Array.isArray(r.data) ? r.data : [];
            applyFilters();

        } catch(e) {
            console.error(e);
            loading.style.display = 'none';
            error.textContent = 'Ошибка соединения.'; error.style.display = 'flex';
        }
    }

    function applyFilters() {
        var q    = document.getElementById('search-input').value.toLowerCase();
        var role = document.getElementById('role-filter').value;
        var filtered = allRows.filter(function(row) {
            var fio   = String(pick(row,'ФИО','Имя','ФИО_Студента','ФИО_Преподавателя','Логин') || '').toLowerCase();
            var login = String(pick(row,'Логин','login') || '').toLowerCase();
            var r     = String(pick(row,'Роль','role') || '');
            return (fio.includes(q) || login.includes(q)) && (!role || r === role);
        });
        render(filtered);
    }

    function render(rows) {
        var wrap  = document.getElementById('list-wrap');
        var empty = document.getElementById('empty');

        if (!rows || rows.length === 0) { empty.style.display = 'flex'; return; }

        var html = '';
        rows.forEach(function(row, idx) {
            var uid    = pick(row,'Пользователь_ID','id') || '';
            var fio    = pick(row,'ФИО','Имя','ФИО_Студента','ФИО_Преподавателя','Логин') || '—';
            var login  = pick(row,'Логин','login') || '—';
            var role   = pick(row,'Роль','role') || '—';
            var email  = pick(row,'Email','email') || '—';
            var active = pick(row,'Активен','is_active','active');
            var sessions = pick(row,'Активных_Сессий','АктивныеСессии','Сессии_Активные','sessions_active');
            var ini    = fio.split(' ').map(function(p){return p?p[0].toUpperCase():''}).join('').slice(0,2);

            html += '<tr>';
            html += '<td>' + (idx+1) + '</td>';
            html += '<td><div class="flex gap-2 items-center"><div class="avatar">' + esc(ini) + '</div><strong>' + esc(fio) + '</strong></div></td>';
            html += '<td><code style="font-size:13px">' + esc(login) + '</code></td>';
            html += '<td>' + roleBadge(role) + '</td>';
            html += '<td><span style="font-size:13px">' + esc(email) + '</span></td>';
            html += '<td>' + (active !== 0 && active !== false && active !== '0' ? '<span class="badge b-ok">Активен</span>' : '<span class="badge b-err">Заблокирован</span>') + '</td>';
            html += '<td>' + (sessions !== null ? '<span class="tag">' + esc(String(sessions)) + '</span>' : '<span class="badge b-muted">Нет данных</span>') + '</td>';
            html += '<td><div class="flex gap-1">';
            html += '<button class="btn btn-ghost btn-sm" onclick="openEdit(\'' + esc(String(uid)) + '\')">Изм.</button>';
            html += '<button class="btn btn-ghost btn-sm text-danger" onclick="toggleBlock(\'' + esc(String(uid)) + '\', ' + (active !== 0 && active !== false && active !== '0' ? 'true' : 'false') + ')">Блок</button>';
            html += '</div></td>';
            html += '</tr>';
        });

        document.getElementById('users-tbody').innerHTML = html;
        wrap.style.display = '';
        empty.style.display = 'none';
    }

    function openModal(isEdit) {
        editingId = isEdit || null;
        document.getElementById('modal-title').textContent = isEdit ? 'Редактировать пользователя' : 'Добавить пользователя';
        document.getElementById('m-pw-wrap').style.display = isEdit ? 'none' : '';
        document.getElementById('m-fio').value = '';
        document.getElementById('m-login').value = '';
        document.getElementById('m-password').value = '';
        document.getElementById('m-email').value = '';
        document.getElementById('m-role').value = '';
        document.getElementById('m-error').style.display = 'none';
        document.getElementById('user-modal').style.display = 'flex';
    }

    window.openEdit = function(uid) {
        var row = allRows.find(function(r){ return String(pick(r,'Пользователь_ID','id')) === String(uid); });
        if (!row) return;
        openModal(uid);
        document.getElementById('m-fio').value   = pick(row,'ФИО','Имя','ФИО_Студента','ФИО_Преподавателя') || '';
        document.getElementById('m-login').value  = pick(row,'Логин','login') || '';
        document.getElementById('m-email').value  = pick(row,'Email','email') || '';
        var currentRoleId = roleId(pick(row,'Роль_ID','role_id')) || roleId(pick(row,'Роль','role'));
        document.getElementById('m-role').value   = currentRoleId ? String(currentRoleId) : '';
        if (!currentRoleId) {
            var errEl = document.getElementById('m-error');
            errEl.textContent = 'Текущая роль пользователя отсутствует в справочнике ролей.';
            errEl.style.display = 'flex';
        }
    };

    window.toggleBlock = async function(uid, isActive) {
        var userId = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        var r = await callAPI('ОбновитьПользователя', { Пользователь_ID: uid, Активен: isActive ? 0 : 1, КтоОбновил: userId });
        if (r && r.success) {
            document.getElementById('action-ok').textContent = isActive ? 'Пользователь заблокирован.' : 'Пользователь разблокирован.';
            document.getElementById('action-ok').style.display = 'flex';
            setTimeout(function(){ document.getElementById('action-ok').style.display = 'none'; }, 3000);
            load();
        }
    };

    function closeModal() { document.getElementById('user-modal').style.display = 'none'; editingId = null; }
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('modal-cancel').addEventListener('click', closeModal);

    document.getElementById('modal-save').addEventListener('click', async function() {
        var btn   = this;
        var errEl = document.getElementById('m-error');
        errEl.style.display = 'none';

        var fio   = document.getElementById('m-fio').value.trim();
        var login = document.getElementById('m-login').value.trim();
        var pw    = document.getElementById('m-password').value;
        var role  = document.getElementById('m-role').value;
        var email = document.getElementById('m-email').value.trim();

        if (!fio)   { errEl.textContent = 'Введите ФИО.';   errEl.style.display = 'flex'; return; }
        if (!login) { errEl.textContent = 'Введите логин.'; errEl.style.display = 'flex'; return; }
        if (!editingId && pw.length < 6) { errEl.textContent = 'Пароль минимум 6 символов.'; errEl.style.display = 'flex'; return; }

        var roleIdValue = roleId(role);
        if (!roleIdValue) {
            errEl.textContent = 'Выберите роль из справочника.';
            errEl.style.display = 'flex';
            return;
        }

        btn.disabled = true; btn.textContent = 'Сохранение...';

        try {
            var currentUserId = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
            var params = { Логин: login, Роль_ID: roleIdValue, Email: email || null };
            if (!editingId) params['Пароль'] = pw;
            if (!editingId) params['КтоСоздал'] = currentUserId;
            else {
                params['Пользователь_ID'] = editingId;
                params['КтоОбновил'] = currentUserId;
            }

            var action = editingId ? 'ОбновитьПользователя' : 'СоздатьПользователя';
            var r = await callAPI(action, params);

            if (r && r.success) {
                closeModal();
                document.getElementById('action-ok').textContent = editingId ? 'Пользователь обновлён.' : 'Пользователь создан.';
                document.getElementById('action-ok').style.display = 'flex';
                setTimeout(function(){ document.getElementById('action-ok').style.display = 'none'; }, 3000);
                load();
            } else {
                errEl.textContent = r && r.message ? r.message : 'Ошибка.';
                errEl.style.display = 'flex';
            }
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.'; errEl.style.display = 'flex';
        } finally {
            btn.disabled = false; btn.textContent = 'Сохранить';
        }
    });

    document.getElementById('add-btn').addEventListener('click', function() { openModal(null); });
    document.getElementById('search-input').addEventListener('input', applyFilters);
    document.getElementById('role-filter').addEventListener('change', applyFilters);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

