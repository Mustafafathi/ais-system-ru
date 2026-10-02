<?php declare(strict_types=1); ?>
</main><!-- /.app-main -->
</div><!-- /.app-body -->

<script>
(function () {
    'use strict';
    // Update navbar user info from localStorage (fast path, no extra API call)
    const name   = (typeof getUserName   === 'function') ? getUserName()   : null;
    const avatar = document.getElementById('nav-avatar');
    const uname  = document.getElementById('nav-username');
    if (name && avatar) {
        const parts = name.trim().split(/\s+/);
        let ini = '';
        parts.forEach(function(p){ if(p) ini += p[0].toUpperCase(); });
        avatar.textContent = ini.slice(0, 2) || name[0].toUpperCase();
    }
    if (name && uname) uname.textContent = name;

    // Check for unread notifications for the current user.
    const dot = document.getElementById('notif-dot');
    if (dot && typeof callAPI === 'function') {
        const uid = localStorage.getItem('ais_user_id');
        if (uid) {
            callAPI('ПолучитьУведомленияПользователя', {
                Пользователь_ID: parseInt(uid, 10),
                Только_Непрочитанные: 1,
                Лимит: 1
            }).then(function(r) {
                if (r && r.success && r.data && r.data.length > 0) {
                    dot.style.display = 'block';
                }
            }).catch(function(){});
        }
    }

    // Additive accessibility metadata only: no route, API, event-flow, or business changes.
    function textOf(node) {
        return node ? String(node.textContent || '').replace(/\s+/g, ' ').trim() : '';
    }

    function labelFromId(id) {
        var map = {
            'date-from': 'Дата начала',
            'date-to': 'Дата окончания',
            'qr-from': 'Дата начала QR',
            'qr-to': 'Дата окончания QR',
            'group-select': 'Группа',
            'group-filter': 'Фильтр группы',
            'student-select': 'Студент',
            'status-filter': 'Фильтр статуса',
            'role-filter': 'Фильтр роли',
            'report-type': 'Тип отчёта',
            'report-kind': 'Вид отчёта',
            'entity-id': 'ID записи',
            'session-select': 'Занятие',
            'session-date': 'Дата занятия',
            'session-name': 'Название сессии',
            'session-ttl': 'Срок действия QR',
            'new-group': 'Новая группа',
            'new-subject': 'Дисциплина',
            'new-day': 'День недели',
            'new-start': 'Время начала',
            'new-end': 'Время окончания',
            'new-lesson-type': 'Тип занятия',
            'new-week-type': 'Тип недели',
            'new-building': 'Корпус',
            'new-room': 'Аудитория',
            'new-name': 'Название',
            'new-year': 'Год поступления',
            'new-curator': 'Куратор',
            'edit-lesson-id': 'ID занятия',
            'edit-date': 'Дата занятия',
            'edit-start': 'Время начала',
            'edit-end': 'Время окончания',
            'edit-room': 'Аудитория',
            'edit-status': 'Статус занятия',
            'edit-note': 'Примечание',
            's-risk': 'Порог уведомления о пропусках',
            's-crit': 'Время опоздания',
            's-qr-ttl': 'Срок действия QR по умолчанию',
            's-max-attempts': 'Попыток до блокировки',
            's-lock-time': 'Длительность блокировки',
            'm-fio': 'ФИО',
            'm-login': 'Логин',
            'm-password': 'Пароль',
            'm-role': 'Роль',
            'm-email': 'Email',
            'm-comment': 'Комментарий'
        };
        return map[id] || '';
    }

    function ensureControlName(control) {
        if (!control || control.type === 'hidden') return;
        if (control.getAttribute('aria-label') || control.getAttribute('aria-labelledby') || control.getAttribute('title')) return;
        if (control.id && document.querySelector('label[for="' + CSS.escape(control.id) + '"]')) return;
        var nearbyLabel = control.closest('.form-group') ? control.closest('.form-group').querySelector('.form-label') : null;
        if (nearbyLabel && control.id && !nearbyLabel.getAttribute('for')) {
            nearbyLabel.setAttribute('for', control.id);
            return;
        }
        var label = labelFromId(control.id) || control.getAttribute('placeholder') || '';
        if (!label && control.tagName === 'SELECT' && control.options && control.options.length) {
            label = textOf(control.options[0]);
        }
        if (!label) {
            label = String(control.id || control.name || control.tagName).replace(/[-_]+/g, ' ');
        }
        control.setAttribute('aria-label', label);
    }

    function ensureScrollRegion(node) {
        if (!node || node.hasAttribute('data-a11y-scroll-ready')) return;
        node.setAttribute('data-a11y-scroll-ready', '1');
        if (!node.hasAttribute('tabindex')) node.setAttribute('tabindex', '0');
        if (!node.getAttribute('aria-label')) {
            node.setAttribute('aria-label', node.classList.contains('panel-flush') ? 'Прокручиваемая область данных' : 'Прокручиваемая таблица данных');
        }
    }

    function ensureDialogMetadata(modal) {
        if (!modal || modal.hasAttribute('data-a11y-dialog-ready')) return;
        modal.setAttribute('data-a11y-dialog-ready', '1');
        if (!modal.getAttribute('role')) modal.setAttribute('role', 'dialog');
        if (!modal.getAttribute('aria-modal')) modal.setAttribute('aria-modal', 'true');
        var title = modal.querySelector('.modal-title');
        if (title) {
            if (!title.id) title.id = 'modal-title-' + Math.random().toString(36).slice(2);
            if (!modal.getAttribute('aria-labelledby')) modal.setAttribute('aria-labelledby', title.id);
        }
        modal.querySelectorAll('.modal-close').forEach(function (button) {
            if (!button.getAttribute('aria-label')) button.setAttribute('aria-label', 'Закрыть');
        });
    }

    function annotateAccessibility(root) {
        var scope = root || document;
        if (scope.matches && scope.matches('input, select, textarea')) ensureControlName(scope);
        if (scope.matches && scope.matches('.tbl-wrap, .panel-flush')) ensureScrollRegion(scope);
        if (scope.matches && scope.matches('.modal')) ensureDialogMetadata(scope);
        scope.querySelectorAll('input, select, textarea').forEach(ensureControlName);
        scope.querySelectorAll('.tbl-wrap, .panel-flush').forEach(ensureScrollRegion);
        scope.querySelectorAll('.modal').forEach(ensureDialogMetadata);
    }

    annotateAccessibility(document);
    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            mutation.addedNodes.forEach(function (node) {
                if (node && node.nodeType === 1) annotateAccessibility(node);
            });
        });
    });
    observer.observe(document.body, { childList: true, subtree: true });
}());
</script>
</body>
</html>

