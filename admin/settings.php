<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Настройки';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Настройки системы</div>
        <div class="page-sub">Полное управление параметрами АИС</div>
    </div>
    <button class="btn btn-outline" id="reload-btn" type="button">Обновить</button>
</div>

<div class="alert alert-info" id="loading">Загрузка настроек...</div>
<div class="alert alert-err" id="load-err" style="display:none"></div>

<div id="settings-wrap" class="settings-layout settings-layout-wide" style="display:none">
    <div class="settings-toolbar">
        <div class="form-group">
            <label class="form-label" for="settings-search">Поиск</label>
            <input class="form-ctrl" id="settings-search" type="search" placeholder="Ключ, описание или значение">
        </div>
        <div class="form-group">
            <label class="form-label" for="category-filter">Категория</label>
            <select class="form-ctrl" id="category-filter">
                <option value="">Все категории</option>
            </select>
        </div>
        <div class="settings-counter" id="settings-counter">0 параметров</div>
    </div>

    <div class="settings-summary" id="settings-summary"></div>

    <div class="settings-main settings-main-wide" id="settings-categories"></div>

    <div class="settings-actions">
        <div class="alert alert-ok" id="save-ok" style="display:none"></div>
        <div class="alert alert-err" id="save-err" style="display:none"></div>
        <button class="btn btn-primary control-save" id="save-btn" type="button" disabled>Сохранить изменения</button>
    </div>
</div>

<script>
(function () {
    'use strict';

    var allSettings = [];
    var changed = {};
    var loading = document.getElementById('loading');
    var loadErr = document.getElementById('load-err');
    var wrap = document.getElementById('settings-wrap');
    var categoriesEl = document.getElementById('settings-categories');
    var summaryEl = document.getElementById('settings-summary');
    var counterEl = document.getElementById('settings-counter');
    var searchInput = document.getElementById('settings-search');
    var categoryFilter = document.getElementById('category-filter');
    var saveBtn = document.getElementById('save-btn');
    var reloadBtn = document.getElementById('reload-btn');
    var saveOk = document.getElementById('save-ok');
    var saveErr = document.getElementById('save-err');

    function esc(value) {
        return String(value == null ? '' : value).replace(/[&<>"']/g, function(ch) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch];
        });
    }

    function normalizeRows(data) {
        return Array.isArray(data) && Array.isArray(data[0]) ? data[0] : (Array.isArray(data) ? data : []);
    }

    function rowKey(row) {
        return String(row && row['Ключ'] ? row['Ключ'] : '');
    }

    function isReadOnly(row) {
        return Number(row['ТолькоДляЧтения'] || 0) === 1;
    }

    function isAdminOnly(row) {
        return Number(row['ТолькоДляАдмина'] || 0) === 1;
    }

    function categoryName(row) {
        return String(row['Категория'] || 'Без категории');
    }

    function subcategoryName(row) {
        return String(row['Подкатегория'] || '');
    }

    function typeName(row) {
        return String(row['Тип'] || 'Строка');
    }

    function currentValue(row) {
        var key = rowKey(row);
        return Object.prototype.hasOwnProperty.call(changed, key) ? changed[key] : String(row['Значение'] == null ? '' : row['Значение']);
    }

    function markDirty(row, value) {
        var key = rowKey(row);
        var original = String(row['Значение'] == null ? '' : row['Значение']);
        if (String(value) === original) {
            delete changed[key];
        } else {
            changed[key] = String(value);
        }
        updateSaveState();
    }

    function updateSaveState() {
        var count = Object.keys(changed).length;
        saveBtn.disabled = count === 0;
        saveBtn.textContent = count === 0 ? 'Сохранить изменения' : 'Сохранить изменения (' + count + ')';
    }

    function makeControl(row) {
        var key = rowKey(row);
        var type = typeName(row).toLowerCase();
        var value = currentValue(row);
        var disabled = isReadOnly(row) ? ' disabled' : '';
        var id = 'setting-' + key.replace(/[^A-Za-z0-9_-]/g, '-');

        if (type.indexOf('бул') !== -1 || value === 'true' || value === 'false') {
            var trueSelected = value === 'true' || value === '1' ? ' selected' : '';
            var falseSelected = trueSelected ? '' : ' selected';
            return '<select class="form-ctrl setting-input" id="' + esc(id) + '" data-key="' + esc(key) + '"' + disabled + '>' +
                '<option value="true"' + trueSelected + '>Включено</option>' +
                '<option value="false"' + falseSelected + '>Отключено</option>' +
                '</select>';
        }

        if (type.indexOf('чис') !== -1) {
            return '<input class="form-ctrl setting-input control-number" id="' + esc(id) + '" data-key="' + esc(key) + '" type="number" value="' + esc(value) + '"' + disabled + '>';
        }

        if (value.length > 90 || type.indexOf('json') !== -1 || type.indexOf('текст') !== -1) {
            return '<textarea class="form-ctrl setting-input settings-textarea" id="' + esc(id) + '" data-key="' + esc(key) + '"' + disabled + '>' + esc(value) + '</textarea>';
        }

        return '<input class="form-ctrl setting-input" id="' + esc(id) + '" data-key="' + esc(key) + '" type="text" value="' + esc(value) + '"' + disabled + '>';
    }

    function settingMatches(row, query, category) {
        if (category && categoryName(row) !== category) return false;
        if (!query) return true;

        var haystack = [
            row['Ключ'],
            row['Значение'],
            row['Тип'],
            row['Категория'],
            row['Подкатегория'],
            row['Описание']
        ].join(' ').toLowerCase();

        return haystack.indexOf(query.toLowerCase()) !== -1;
    }

    function renderSummary(rows) {
        var total = rows.length;
        var editable = rows.filter(function(row) { return !isReadOnly(row); }).length;
        var readOnly = total - editable;
        var adminOnly = rows.filter(isAdminOnly).length;
        var dirty = Object.keys(changed).length;

        summaryEl.innerHTML =
            '<div class="stat-card settings-stat"><span>Всего параметров</span><strong>' + total + '</strong></div>' +
            '<div class="stat-card settings-stat"><span>Доступно к изменению</span><strong>' + editable + '</strong></div>' +
            '<div class="stat-card settings-stat"><span>Только чтение</span><strong>' + readOnly + '</strong></div>' +
            '<div class="stat-card settings-stat"><span>Изменено сейчас</span><strong>' + dirty + '</strong></div>' +
            '<div class="stat-card settings-stat"><span>Только админ</span><strong>' + adminOnly + '</strong></div>';
    }

    function renderCategoryOptions(rows) {
        var previous = categoryFilter.value;
        var categories = Array.from(new Set(rows.map(categoryName))).sort();
        categoryFilter.innerHTML = '<option value="">Все категории</option>' + categories.map(function(cat) {
            return '<option value="' + esc(cat) + '">' + esc(cat) + '</option>';
        }).join('');
        categoryFilter.value = categories.indexOf(previous) >= 0 ? previous : '';
    }

    function renderSettings() {
        var query = searchInput.value.trim();
        var category = categoryFilter.value;
        var rows = allSettings.filter(function(row) { return settingMatches(row, query, category); });
        var grouped = {};

        rows.forEach(function(row) {
            var cat = categoryName(row);
            if (!grouped[cat]) grouped[cat] = [];
            grouped[cat].push(row);
        });

        counterEl.textContent = rows.length + ' из ' + allSettings.length + ' параметров';
        renderSummary(allSettings);

        if (rows.length === 0) {
            categoriesEl.innerHTML = '<div class="empty-state">Параметры не найдены</div>';
            return;
        }

        categoriesEl.innerHTML = Object.keys(grouped).sort().map(function(cat) {
            var items = grouped[cat].map(function(row) {
                var key = rowKey(row);
                var readOnlyBadge = isReadOnly(row) ? '<span class="badge b-muted">Только чтение</span>' : '<span class="badge b-ok">Можно изменить</span>';
                var adminBadge = isAdminOnly(row) ? '<span class="badge b-warn">Админ</span>' : '';
                var sub = subcategoryName(row);
                var changedBadge = Object.prototype.hasOwnProperty.call(changed, key) ? '<span class="badge b-info">Изменено</span>' : '';

                return '<div class="setting-row" data-key="' + esc(key) + '">' +
                    '<div class="setting-meta">' +
                        '<div class="setting-key">' + esc(key) + '</div>' +
                        '<div class="setting-desc">' + esc(row['Описание'] || 'Описание не задано') + '</div>' +
                        '<div class="setting-tags">' +
                            '<span class="badge b-muted">' + esc(typeName(row)) + '</span>' +
                            (sub ? '<span class="badge b-muted">' + esc(sub) + '</span>' : '') +
                            readOnlyBadge + adminBadge + changedBadge +
                        '</div>' +
                    '</div>' +
                    '<div class="setting-control">' + makeControl(row) + '</div>' +
                '</div>';
            }).join('');

            return '<section class="card settings-card settings-card-full settings-category">' +
                '<div class="card-hdr"><span class="card-title">' + esc(cat) + '</span><span class="card-meta">' + grouped[cat].length + '</span></div>' +
                '<div class="card-body settings-list">' + items + '</div>' +
            '</section>';
        }).join('');

        categoriesEl.querySelectorAll('.setting-input').forEach(function(control) {
            control.addEventListener('input', function() {
                var key = this.getAttribute('data-key');
                var row = allSettings.find(function(item) { return rowKey(item) === key; });
                if (row) markDirty(row, this.value);
                var settingRow = this.closest('.setting-row');
                if (settingRow) settingRow.classList.toggle('is-dirty', Object.prototype.hasOwnProperty.call(changed, key));
                renderSummary(allSettings);
            });
        });
    }

    async function load() {
        loading.style.display = 'flex';
        loadErr.style.display = 'none';
        wrap.style.display = 'none';
        saveOk.style.display = 'none';
        saveErr.style.display = 'none';

        try {
            var userId = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
            var r = await callAPI('ПолучитьНастройки', { Пользователь_ID: userId });

            if (!r || !r.success) {
                loadErr.textContent = r && r.message ? r.message : 'Ошибка загрузки настроек.';
                loadErr.style.display = 'flex';
                return;
            }

            allSettings = normalizeRows(r.data);
            changed = {};
            renderCategoryOptions(allSettings);
            renderSettings();
            updateSaveState();
            wrap.style.display = '';
        } catch (e) {
            console.error(e);
            loadErr.textContent = 'Ошибка соединения.';
            loadErr.style.display = 'flex';
        } finally {
            loading.style.display = 'none';
        }
    }

    async function save() {
        var keys = Object.keys(changed);
        if (keys.length === 0) return;

        saveOk.style.display = 'none';
        saveErr.style.display = 'none';
        saveBtn.disabled = true;
        saveBtn.textContent = 'Сохранение...';

        try {
            var userId = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
            var errors = [];

            for (var i = 0; i < keys.length; i++) {
                var key = keys[i];
                var r = await callAPI('ОбновитьНастройку', {
                    Ключ: key,
                    Значение: changed[key],
                    Пользователь_ID: userId
                });
                if (!r || !r.success) {
                    errors.push(key);
                }
            }

            if (errors.length > 0) {
                saveErr.textContent = 'Не сохранены параметры: ' + errors.join(', ');
                saveErr.style.display = 'flex';
                updateSaveState();
                return;
            }

            saveOk.textContent = 'Настройки сохранены.';
            saveOk.style.display = 'flex';
            await load();
        } catch (e) {
            console.error(e);
            saveErr.textContent = 'Ошибка соединения.';
            saveErr.style.display = 'flex';
            updateSaveState();
        }
    }

    searchInput.addEventListener('input', renderSettings);
    categoryFilter.addEventListener('change', renderSettings);
    saveBtn.addEventListener('click', save);
    reloadBtn.addEventListener('click', load);

    load();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

