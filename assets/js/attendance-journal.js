(function () {
    'use strict';

    const STATUSES = [
        { value: 'Присутствовал', icon: 'P', cls: 'ok' },
        { value: 'Отсутствовал', icon: 'A', cls: 'err' },
        { value: 'Опоздал', icon: 'L', cls: 'warn' },
        { value: 'Уважительная причина', icon: 'R', cls: 'info' }
    ];

    const state = {
        selectedSessionId: null,
        teacherId: 0,
        userId: parseInt(localStorage.getItem('ais_user_id') || '0', 10) || 0,
        preselectedLessonId: new URLSearchParams(window.location.search).get('z') || '',
        lastRows: []
    };

    function el(id) {
        return document.getElementById(id);
    }

    function esc(value) {
        return String(value || '').replace(/[&<>"']/g, function (char) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char];
        });
    }

    function pick(obj) {
        for (let i = 1; i < arguments.length; i += 1) {
            const key = arguments[i];
            if (obj && obj[key] !== undefined && obj[key] !== null) {
                return obj[key];
            }
        }
        return null;
    }

    function show(node, display) {
        if (node) node.style.display = display === undefined ? 'flex' : display;
    }

    function hide(node) {
        if (node) node.style.display = 'none';
    }

    function setAlert(target, text) {
        if (!target) return;
        target.textContent = text || '';
        show(target);
    }

    function initials(fullName) {
        const parts = String(fullName || '').trim().split(/\s+/);
        return parts.map(function (part) { return part ? part[0].toUpperCase() : ''; }).join('').slice(0, 2) || 'С';
    }

    function getStatusMeta(status) {
        return STATUSES.find(function (item) { return item.value === status; }) || STATUSES[0];
    }

    function sourceBadge(source) {
        if (window.AISRoleUI && typeof window.AISRoleUI.sourceBadge === 'function') {
            return window.AISRoleUI.sourceBadge(source);
        }
        return '<span class="tag">' + esc(source || '—') + '</span>';
    }

    async function getTeacherId() {
        const cached = parseInt(localStorage.getItem('ais_teacher_id') || '0', 10);
        if (cached && state.userId) return cached;

        const session = await callAPI('ПроверитьСессию', {});
        const row = session && session.success && Array.isArray(session.data) ? session.data[0] : null;
        const teacherId = parseInt(pick(row, 'Преподаватель_ID', 'teacher_id') || '0', 10);
        const userId = parseInt(pick(row, 'Пользователь_ID', 'user_id') || '0', 10);
        if (teacherId) localStorage.setItem('ais_teacher_id', String(teacherId));
        if (userId) {
            state.userId = userId;
            localStorage.setItem('ais_user_id', String(userId));
        }
        return teacherId || cached;
    }

    async function getQueuedAttendanceMap(sessionId) {
        const map = {};
        if (!window.OfflineQueue || typeof OfflineQueue.getAll !== 'function') return map;

        const queued = await OfflineQueue.getAll();
        queued.forEach(function (request) {
            if (!request || request.action !== 'ОтметитьПосещаемость') return;
            const params = request.params || {};
            const queuedLesson = String(pick(params, 'Занятие_ID', 'ЗанятиеId') || '');
            const studentId = String(pick(params, 'Студент_ID', 'СтудентId') || '');
            if (!studentId || queuedLesson !== String(sessionId)) return;

            const previous = map[studentId];
            const previousTs = previous ? String(previous.timestamp || '') : '';
            const currentTs = String(request.timestamp || '');
            if (!previous || currentTs >= previousTs) {
                map[studentId] = request;
            }
        });

        return map;
    }

    async function removeQueuedAttendanceForStudent(sessionId, studentId) {
        if (!window.OfflineQueue || typeof OfflineQueue.getAll !== 'function' || typeof OfflineQueue.remove !== 'function') return 0;

        const queued = await OfflineQueue.getAll();
        let removed = 0;
        for (const request of queued) {
            if (!request || request.action !== 'ОтметитьПосещаемость') continue;
            const params = request.params || {};
            const queuedLesson = String(pick(params, 'Занятие_ID', 'ЗанятиеId') || '');
            const queuedStudent = String(pick(params, 'Студент_ID', 'СтудентId') || '');
            if (queuedLesson === String(sessionId) && queuedStudent === String(studentId)) {
                await OfflineQueue.remove(request.id);
                removed += 1;
            }
        }
        return removed;
    }

    function markRowDirty(row) {
        if (!row) return;
        row.dataset.dirty = '1';
        const stateCell = row.querySelector('.save-state');
        if (stateCell) stateCell.innerHTML = '<span class="badge b-warn">Изменено</span>';
    }

    function markRowSaved(row, label, badgeClass) {
        if (!row) return;
        row.dataset.dirty = '0';
        row.dataset.queued = badgeClass === 'b-warn' ? '1' : '0';
        const status = row.querySelector('.att-val');
        const note = row.querySelector('.note-input');
        if (status) row.dataset.originalStatus = status.value;
        if (note) row.dataset.originalNote = note.value.trim();
        const stateCell = row.querySelector('.save-state');
        if (stateCell) stateCell.innerHTML = '<span class="badge ' + badgeClass + '">' + esc(label) + '</span>';
    }

    function buildRowHtml(row, index, queuedRequest) {
        const sid = String(pick(row, 'Студент_ID') || '');
        const fio = pick(row, 'ФИО_Студента', 'ФИО', 'Имя_Студента') || 'Студент ' + (index + 1);
        const queuedParams = queuedRequest ? queuedRequest.params || {} : {};
        const dbStatus = pick(row, 'Статус', 'Статус_Посещаемости') || 'Присутствовал';
        const dbNote = pick(row, 'ПримечаниеПосещаемости', 'Примечание') || '';
        const status = pick(queuedParams, 'Статус') || dbStatus;
        const note = pick(queuedParams, 'Примечание') || dbNote;
        const markType = queuedRequest
            ? ('Офлайн: ' + (pick(queuedParams, 'Тип_Отметки') || 'Ручная'))
            : (pick(row, 'Тип_Отметки', 'Источник', 'Способ') || '—');
        const markedBy = pick(row, 'ФИО_Отметившего', 'Логин_Отметившего') || '';
        const queuedBadge = queuedRequest ? '<span class="badge b-warn">В очереди</span>' : '';

        let buttons = '';
        STATUSES.forEach(function (item) {
            const active = status === item.value ? ' active-status' : '';
            buttons += '<button type="button" class="att-status att-' + item.cls + active + '" data-status="' + esc(item.value) + '" title="' + esc(item.value) + '">' + item.icon + '</button>';
        });

        return '<tr data-sid="' + esc(sid) + '" data-dirty="0" data-queued="' + (queuedRequest ? '1' : '0') + '" data-original-status="' + esc(status) + '" data-original-note="' + esc(note) + '">' +
            '<td>' + (index + 1) + '</td>' +
            '<td><div class="flex gap-2 items-center"><div class="avatar">' + esc(initials(fio)) + '</div><div>' + esc(fio) + '<div class="text-muted">' + queuedBadge + '</div></div></div></td>' +
            '<td><div class="att-toggle-group">' + buttons + '</div><input type="hidden" class="att-val" value="' + esc(status) + '"></td>' +
            '<td>' + sourceBadge(markType) + (markedBy ? '<div class="text-muted">' + esc(markedBy) + '</div>' : '') + '</td>' +
            '<td><input class="form-ctrl note-input" maxlength="300" placeholder="Примечание..." value="' + esc(note) + '"></td>' +
            '<td class="save-state">' + (queuedRequest ? '<span class="badge b-warn">В очереди</span>' : '<span class="badge b-muted">Без изменений</span>') + '</td>' +
        '</tr>';
    }

    async function updateQueueState() {
        const queueState = el('queue-state');
        if (!queueState) return;

        try {
            const count = window.OfflineQueue && typeof OfflineQueue.count === 'function' ? await OfflineQueue.count() : 0;
            const online = typeof isOnline === 'function' ? isOnline() : navigator.onLine;
            queueState.textContent = (online ? 'Онлайн' : 'Офлайн') + ' · Очередь: ' + count;
            queueState.className = online ? 'tag' : 'badge b-warn';
        } catch (error) {
            queueState.textContent = 'Очередь: недоступна';
            queueState.className = 'badge b-err';
        }
    }

    async function loadSessions() {
        const select = el('session-select');
        const error = el('error');
        hide(error);

        try {
            state.teacherId = await getTeacherId();
            const today = new Date().toISOString().slice(0, 10);
            const result = await callAPI('ПолучитьЗанятияПоДате', {
                Преподаватель_ID: state.teacherId,
                Дата_Занятия: today
            });

            select.innerHTML = '<option value="">— Выберите занятие —</option>';
            const rows = result && result.success && Array.isArray(result.data) ? result.data : [];

            if (!result || !result.success) {
                setAlert(error, ((result && result.message) || 'Не удалось загрузить занятия.'));
                return;
            }

            rows.forEach(function (row) {
                const lessonId = pick(row, 'Занятие_ID') || '';
                if (!lessonId) return;
                const time = pick(row, 'Время_Начала_Факт', 'Время_Начала_План', 'Время_Начала', 'Время') || '';
                const subject = pick(row, 'Дисциплина', 'Название_Дисциплины') || '';
                const group = pick(row, 'Группа', 'Название_Группы') || '';
                const option = document.createElement('option');
                option.value = lessonId;
                option.textContent = [time, subject, group].filter(Boolean).join(' — ') || ('Занятие #' + lessonId);
                if (state.preselectedLessonId && String(lessonId) === String(state.preselectedLessonId)) option.selected = true;
                select.appendChild(option);
            });

            if (select.value) await loadStudents(parseInt(select.value, 10));
            else if (state.preselectedLessonId) {
                setAlert(error, 'Выбранное занятие недоступно в сегодняшнем списке. Возможно, оно завершено, отменено или не принадлежит текущему преподавателю.');
            } else if (rows.length === 0) {
                show(el('select-hint'));
                el('select-hint').textContent = 'Сегодня нет занятий для загрузки журнала.';
            }
        } catch (errorObject) {
            console.error(errorObject);
            setAlert(error, errorObject && errorObject.message && errorObject.message.indexOf('сесс') !== -1 ? 'Сессия недоступна. Войдите заново.' : 'Ошибка загрузки занятий.');
        } finally {
            await updateQueueState();
        }
    }

    async function loadStudents(sessionId) {
        state.selectedSessionId = sessionId;
        const hint = el('select-hint');
        const loading = el('loading');
        const error = el('error');
        const wrap = el('journal-wrap');
        const ok = el('save-ok');
        const tbody = el('journal-tbody');

        hide(hint);
        hide(error);
        hide(ok);
        hide(wrap);
        show(loading);

        try {
            const result = await callAPI('ПолучитьПосещаемостьПоЗанятию', { Занятие_ID: sessionId });
            hide(loading);

            if (!result || !result.success) {
                setAlert(error, ((result && result.message) || 'Ошибка загрузки журнала.'));
                return;
            }

            const rows = Array.isArray(result.data) ? result.data : [];
            state.lastRows = rows;

            if (rows.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-muted">Нет записей посещаемости для выбранного занятия.</td></tr>';
                el('journal-sub').textContent = 'Нет записей для выбранного занятия';
                show(wrap, '');
                return;
            }

            const queuedMap = await getQueuedAttendanceMap(sessionId);
            const info = rows[0] || {};
            const subject = pick(info, 'Дисциплина', 'Название_Дисциплины') || '';
            const group = pick(info, 'Группа', 'Название_Группы') || '';
            if (subject || group) el('journal-sub').textContent = [subject, group].filter(Boolean).join(' · ');

            tbody.innerHTML = rows.map(function (row, index) {
                const studentId = String(pick(row, 'Студент_ID') || '');
                return buildRowHtml(row, index, queuedMap[studentId]);
            }).join('');

            show(wrap, '');
        } catch (errorObject) {
            console.error(errorObject);
            hide(loading);
            setAlert(error, 'Ошибка соединения.');
        } finally {
            await updateQueueState();
        }
    }

    function collectDirtyRows() {
        return Array.from(document.querySelectorAll('#journal-tbody tr')).filter(function (row) {
            return row.dataset.sid && row.dataset.dirty === '1';
        });
    }

    async function saveJournal() {
        const saveOk = el('save-ok');
        const error = el('error');
        const button = el('save-btn');
        hide(saveOk);
        hide(error);

        if (!state.selectedSessionId) {
            setAlert(error, 'Сначала выберите занятие.');
            return;
        }

        const rows = collectDirtyRows();
        if (rows.length === 0) {
            setAlert(saveOk, 'Нет несохранённых изменений.');
            return;
        }

        const whoMarked = state.userId || parseInt(localStorage.getItem('ais_user_id') || '0', 10) || 0;
        let saved = 0;
        let queued = 0;
        let failed = 0;

        button.disabled = true;
        button.textContent = 'Сохранение...';

        for (const row of rows) {
            const studentId = parseInt(row.dataset.sid || '0', 10);
            const statusInput = row.querySelector('.att-val');
            const noteInput = row.querySelector('.note-input');
            const status = statusInput ? statusInput.value : 'Присутствовал';
            const note = noteInput ? noteInput.value.trim() : '';
            const stateCell = row.querySelector('.save-state');
            if (stateCell) stateCell.innerHTML = '<span class="badge b-muted">Сохранение...</span>';

            try {
                if (typeof isOnline === 'function' && !isOnline()) {
                    await removeQueuedAttendanceForStudent(state.selectedSessionId, studentId);
                }

                const response = await callAPIOfflineSupport('ОтметитьПосещаемость', {
                    Занятие_ID: state.selectedSessionId,
                    Студент_ID: studentId,
                    Статус: status,
                    Тип_Отметки: 'Ручная',
                    Примечание: note || null,
                    КтоОтметил: whoMarked
                });

                if (response && response.offline) {
                    queued += 1;
                    markRowSaved(row, 'В очереди', 'b-warn');
                } else if (response && response.success) {
                    saved += 1;
                    const messageRow = Array.isArray(response.data) ? response.data[0] : null;
                    const message = pick(messageRow, 'Сообщение') || 'Сохранено';
                    markRowSaved(row, message, 'b-ok');
                } else {
                    failed += 1;
                    if (stateCell) stateCell.innerHTML = '<span class="badge b-err">Ошибка</span>';
                }
            } catch (errorObject) {
                console.warn('attendance save failed', errorObject);
                failed += 1;
                if (stateCell) stateCell.innerHTML = '<span class="badge b-err">Ошибка</span>';
            }
        }

        if (failed > 0) {
            setAlert(error, 'Не сохранено: ' + failed + ' из ' + rows.length + '. Успешно: ' + saved + ', в очереди: ' + queued + '.');
        } else if (queued > 0) {
            setAlert(saveOk, 'Изменения поставлены в офлайн-очередь: ' + queued + '. При восстановлении связи они отправятся один раз.');
        } else {
            setAlert(saveOk, 'Журнал сохранён. Обновлено записей: ' + saved + '.');
        }

        button.disabled = false;
        button.textContent = 'Сохранить изменения';
        await updateQueueState();
    }

    function bindEvents() {
        const select = el('session-select');
        if (select) {
            select.addEventListener('change', function () {
                const lessonId = parseInt(select.value || '0', 10);
                if (lessonId) loadStudents(lessonId);
            });
        }

        const tbody = el('journal-tbody');
        if (tbody) {
            tbody.addEventListener('click', function (event) {
                const button = event.target.closest('.att-status');
                if (!button || !button.dataset.status) return;
                const row = button.closest('tr');
                const hidden = row.querySelector('.att-val');
                if (hidden) hidden.value = button.dataset.status;
                row.querySelectorAll('.att-status').forEach(function (item) {
                    item.classList.remove('active-status');
                });
                button.classList.add('active-status');
                markRowDirty(row);
            });

            tbody.addEventListener('input', function (event) {
                if (!event.target.classList.contains('note-input')) return;
                const row = event.target.closest('tr');
                const current = event.target.value.trim();
                const original = row.dataset.originalNote || '';
                const status = row.querySelector('.att-val');
                const originalStatus = row.dataset.originalStatus || '';
                if (current !== original || (status && status.value !== originalStatus)) {
                    markRowDirty(row);
                }
            });
        }

        const saveButton = el('save-btn');
        if (saveButton) saveButton.addEventListener('click', saveJournal);
        window.addEventListener('online', updateQueueState);
        window.addEventListener('offline', updateQueueState);
    }

    document.addEventListener('DOMContentLoaded', function () {
        bindEvents();
        loadSessions();
    });
}());

