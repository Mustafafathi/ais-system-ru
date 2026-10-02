(function () {
    'use strict';

    function esc(value) {
        if (window.AIS && typeof window.AIS.esc === 'function') return window.AIS.esc(value);
        return String(value || '').replace(/[&<>"']/g, function (char) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char];
        });
    }

    function pick(obj) {
        for (var i = 1; i < arguments.length; i += 1) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) return obj[arguments[i]];
        }
        return null;
    }

    function rows(data) {
        if (!data) return [];
        if (Array.isArray(data) && Array.isArray(data[0])) return data.reduce(function (acc, set) { return acc.concat(set); }, []);
        return Array.isArray(data) ? data : [];
    }

    function setVisible(target, visible, display) {
        var el = typeof target === 'string' ? document.getElementById(target) : target;
        if (!el) return;
        el.style.display = visible ? (display || 'flex') : 'none';
    }

    function setAlert(target, type, message) {
        var el = typeof target === 'string' ? document.getElementById(target) : target;
        if (!el) return;
        el.className = 'alert alert-' + (type || 'info');
        el.innerHTML = esc(message || '');
        setVisible(el, true);
    }

    function stateBlock(type, title, text) {
        var cls = type === 'error' ? 'cap-state cap-state-error'
            : type === 'warning' ? 'cap-state cap-state-warning'
            : type === 'success' ? 'cap-state cap-state-success'
            : 'cap-state';
        return '<div class="' + cls + '"><strong>' + esc(title || 'Состояние') + '</strong>' +
            (text ? '<span>' + esc(text) + '</span>' : '') + '</div>';
    }

    function badge(status) {
        var s = String(status || '').toLowerCase();
        if (s.indexOf('ok') !== -1 || s.indexOf('норма') !== -1 || s.indexOf('усп') !== -1 || s.indexOf('работ') !== -1) return '<span class="badge b-ok">' + esc(status) + '</span>';
        if (s.indexOf('ошиб') !== -1 || s.indexOf('крит') !== -1 || s.indexOf('fail') !== -1 || s.indexOf('трев') !== -1) return '<span class="badge b-err">' + esc(status) + '</span>';
        if (s.indexOf('вним') !== -1 || s.indexOf('ожид') !== -1 || s.indexOf('warn') !== -1 || s.indexOf('риск') !== -1) return '<span class="badge b-warn">' + esc(status) + '</span>';
        if (s.indexOf('инф') !== -1 || s.indexOf('актив') !== -1) return '<span class="badge b-info">' + esc(status) + '</span>';
        return '<span class="badge b-muted">' + esc(status || '—') + '</span>';
    }

    function sourceBadge(source) {
        var s = String(source || '').toLowerCase();
        if (!s) return '<span class="tag">—</span>';
        if (s.indexOf('qr') !== -1 || s.indexOf('qrcode') !== -1) return '<span class="tag">QR</span>';
        if (s.indexOf('скуд') !== -1) return '<span class="tag">СКУД</span>';
        if (s.indexOf('офлайн') !== -1 || s.indexOf('offline') !== -1) return '<span class="badge b-warn">Офлайн</span>';
        if (s.indexOf('руч') !== -1) return '<span class="tag">Ручная</span>';
        return '<span class="tag">' + esc(source) + '</span>';
    }

    function setBusy(button, busy, label) {
        if (!button) return;
        if (busy) {
            button.dataset.originalText = button.textContent;
            button.disabled = true;
            button.textContent = label || 'Выполняется...';
        } else {
            button.disabled = false;
            button.textContent = button.dataset.originalText || label || button.textContent;
        }
    }

    async function runGuarded(button, options) {
        options = options || {};
        if (options.confirmText && !window.confirm(options.confirmText)) return null;
        setBusy(button, true, options.busyText);
        try {
            var result = await callAPI(options.action, options.params || {});
            if (options.resultEl) {
                setAlert(options.resultEl, result && result.success ? 'ok' : 'err', result && result.message ? result.message : (result && result.success ? 'Операция выполнена.' : 'Операция не выполнена.'));
            }
            return result;
        } catch (error) {
            if (options.resultEl) setAlert(options.resultEl, 'err', error && error.message ? error.message : 'Ошибка соединения.');
            return { success: false, message: error && error.message ? error.message : 'Ошибка соединения.' };
        } finally {
            setBusy(button, false);
        }
    }

    function renderKeyValueList(items) {
        if (!items || !items.length) return stateBlock('info', 'Нет данных', 'Backend не вернул строки для отображения.');
        return '<div class="cap-list">' + items.map(function (item) {
            var title = pick(item, 'Компонент', 'Проверка', 'Показатель', 'Название', 'Тип_Статистики') || 'Показатель';
            var status = pick(item, 'Статус', 'Результат') || '';
            var value = pick(item, 'Значение', 'Сообщение', 'Значение_1', 'Описание') || '';
            return '<div class="cap-list-row"><div class="cap-list-main"><strong>' + esc(title) + '</strong>' +
                (value ? '<div class="list-meta">' + esc(value) + '</div>' : '') + '</div><div>' + badge(status || 'OK') + '</div></div>';
        }).join('') + '</div>';
    }

    window.AISRoleUI = {
        esc: esc,
        pick: pick,
        rows: rows,
        setVisible: setVisible,
        setAlert: setAlert,
        stateBlock: stateBlock,
        badge: badge,
        sourceBadge: sourceBadge,
        setBusy: setBusy,
        runGuarded: runGuarded,
        renderKeyValueList: renderKeyValueList
    };
}());

