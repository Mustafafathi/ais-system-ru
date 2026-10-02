(function () {
    'use strict';

    function esc(value) {
        return String(value || '').replace(/[&<>"']/g, function (c) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
        });
    }

    function pick(obj) {
        for (var i = 1; i < arguments.length; i++) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) {
                return obj[arguments[i]];
            }
        }
        return null;
    }

    function mondayOf(date) {
        var d = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        var day = d.getDay();
        var diff = d.getDate() - day + (day === 0 ? -6 : 1);
        d.setDate(diff);
        d.setHours(0, 0, 0, 0);
        return d;
    }

    function isoLocal(date) {
        var y = date.getFullYear();
        var m = String(date.getMonth() + 1).padStart(2, '0');
        var d = String(date.getDate()).padStart(2, '0');
        return y + '-' + m + '-' + d;
    }

    function fmtDate(date) {
        return date.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' });
    }

    function academicWeekNumber(date) {
        var year = date.getMonth() >= 8 ? date.getFullYear() : date.getFullYear() - 1;
        var start = new Date(year, 8, 1);
        var startMonday = mondayOf(start);
        return Math.floor((mondayOf(date) - startMonday) / (7 * 24 * 60 * 60 * 1000)) + 1;
    }

    function weekTypeFor(date) {
        return academicWeekNumber(date) % 2 === 1 ? 'Числитель' : 'Знаменатель';
    }

    function weekBadge(type) {
        var cls = type === 'Числитель' ? 'b-primary' : (type === 'Знаменатель' ? 'b-warn' : 'b-muted');
        return '<span class="badge ' + cls + '">' + esc(type || 'Обе') + '</span>';
    }

    function lessonStatus(status) {
        var s = String(status || '').toLowerCase();
        if (s.includes('провед')) return '<span class="badge b-ok">Проведено</span>';
        if (s.includes('отмен')) return '<span class="badge b-err">Отменено</span>';
        if (s.includes('перенес')) return '<span class="badge b-warn">Перенесено</span>';
        if (s.includes('измен')) return '<span class="badge b-info">Изменено</span>';
        if (s.includes('уведом')) return '<span class="badge b-info">Уведомлено</span>';
        if (s.includes('заплан')) return '<span class="badge b-muted">Запланировано</span>';
        return status ? '<span class="badge b-muted">' + esc(status) + '</span>' : '';
    }

    function setOptions(select, rows, valueKey, labelKey, placeholder) {
        if (!select) return;
        var current = select.value;
        select.innerHTML = '<option value="">' + esc(placeholder || 'Все') + '</option>';
        rows.forEach(function (row) {
            var value = pick(row, valueKey, 'id');
            var label = pick(row, labelKey, 'Название', 'ФИО', 'Номер');
            if (value === null || value === '' || !label) return;
            var opt = document.createElement('option');
            opt.value = String(value);
            opt.textContent = String(label);
            select.appendChild(opt);
        });
        if (current) select.value = current;
    }

    function ensureOption(select, value, label) {
        if (!select || !value) return;
        if (!Array.prototype.some.call(select.options, function (opt) { return opt.value === String(value); })) {
            var opt = document.createElement('option');
            opt.value = String(value);
            opt.textContent = label || String(value);
            select.appendChild(opt);
        }
        select.value = String(value);
    }

    function debounce(fn, wait) {
        var timer = null;
        return function () {
            var args = arguments;
            clearTimeout(timer);
            timer = setTimeout(function () { fn.apply(null, args); }, wait);
        };
    }

    function Explorer(config) {
        this.config = config || {};
        this.root = document.getElementById(this.config.rootId);
        this.sub = this.config.subId ? document.getElementById(this.config.subId) : null;
        this.scope = this.config.scope || 'all';
        this.weekOffset = 0;
        this.page = 1;
        this.pageSize = this.config.pageSize || 200;
        this.initialGroup = this.config.initialGroup || new URLSearchParams(window.location.search).get('group') || '';
        this.context = {};
        this.controls = {};
    }

    Explorer.prototype.renderShell = function () {
        this.root.innerHTML =
            '<div class="schedule-panel">' +
                '<div class="schedule-nav">' +
                    '<div class="schedule-range">' +
                        '<strong id="' + this.config.rootId + '-range">Неделя</strong>' +
                        '<span id="' + this.config.rootId + '-week" class="schedule-week-pill"></span>' +
                    '</div>' +
                    '<div class="schedule-nav-actions">' +
                        '<button class="btn btn-outline btn-sm" data-act="prev">Пред.</button>' +
                        '<button class="btn btn-outline btn-sm" data-act="today">Сегодня</button>' +
                        '<button class="btn btn-outline btn-sm" data-act="next">След.</button>' +
                    '</div>' +
                '</div>' +
                '<div class="schedule-filters">' +
                    '<input class="form-ctrl" data-filter="search" placeholder="Поиск: дисциплина, корпус, аудитория, преподаватель">' +
                    '<select class="form-ctrl" data-filter="group"><option value="">Все группы</option></select>' +
                    '<select class="form-ctrl" data-filter="teacher"><option value="">Все преподаватели</option></select>' +
                    '<select class="form-ctrl" data-filter="building"><option value="">Все корпуса</option></select>' +
                    '<select class="form-ctrl" data-filter="room"><option value="">Все аудитории</option></select>' +
                    '<select class="form-ctrl" data-filter="week">' +
                        '<option value="">Тип недели: текущий</option>' +
                        '<option value="Обе">Обе</option>' +
                        '<option value="Числитель">Числитель</option>' +
                        '<option value="Знаменатель">Знаменатель</option>' +
                    '</select>' +
                    '<select class="form-ctrl" data-filter="lesson">' +
                        '<option value="">Все типы занятий</option>' +
                        '<option value="Лекция">Лекция</option>' +
                        '<option value="Практика">Практика</option>' +
                        '<option value="Лабораторная">Лабораторная</option>' +
                        '<option value="Семинар">Семинар</option>' +
                    '</select>' +
                    '<select class="form-ctrl" data-filter="day">' +
                        '<option value="">Все дни</option>' +
                        '<option value="1">Понедельник</option>' +
                        '<option value="2">Вторник</option>' +
                        '<option value="3">Среда</option>' +
                        '<option value="4">Четверг</option>' +
                        '<option value="5">Пятница</option>' +
                        '<option value="6">Суббота</option>' +
                        '<option value="7">Воскресенье</option>' +
                    '</select>' +
                '</div>' +
            '</div>' +
            '<div class="alert alert-info" data-state="loading">Загрузка расписания...</div>' +
            '<div class="alert alert-err" data-state="error" style="display:none"></div>' +
            '<div class="card table-card" data-state="table" style="display:none">' +
                '<div class="tbl-wrap">' +
                    '<table class="table-wide schedule-table">' +
                        '<thead><tr>' +
                            '<th>Дата</th><th>Время</th><th>Неделя</th><th>Дисциплина</th><th>Группа</th>' +
                            '<th>Преподаватель</th><th>Корпус</th><th>Аудитория</th><th>Тип</th><th>Статус</th><th></th>' +
                        '</tr></thead>' +
                        '<tbody data-schedule-body></tbody>' +
                    '</table>' +
                '</div>' +
                '<div class="schedule-pager">' +
                    '<button class="btn btn-outline btn-sm" data-act="page-prev">Пред. страница</button>' +
                    '<span data-page-info>Страница 1</span>' +
                    '<button class="btn btn-outline btn-sm" data-act="page-next">След. страница</button>' +
                '</div>' +
            '</div>';

        this.controls = {
            range: document.getElementById(this.config.rootId + '-range'),
            week: document.getElementById(this.config.rootId + '-week'),
            loading: this.root.querySelector('[data-state="loading"]'),
            error: this.root.querySelector('[data-state="error"]'),
            table: this.root.querySelector('[data-state="table"]'),
            tbody: this.root.querySelector('[data-schedule-body]'),
            pageInfo: this.root.querySelector('[data-page-info]'),
            search: this.root.querySelector('[data-filter="search"]'),
            group: this.root.querySelector('[data-filter="group"]'),
            teacher: this.root.querySelector('[data-filter="teacher"]'),
            building: this.root.querySelector('[data-filter="building"]'),
            room: this.root.querySelector('[data-filter="room"]'),
            weekFilter: this.root.querySelector('[data-filter="week"]'),
            lesson: this.root.querySelector('[data-filter="lesson"]'),
            day: this.root.querySelector('[data-filter="day"]')
        };
    };

    Explorer.prototype.resolveContext = async function () {
        // Offline-aware resolution: prefer live session when online, otherwise fall back to localStorage
        if (typeof navigator !== 'undefined' && navigator.onLine === false) {
            this.context = {
                userId: localStorage.getItem('ais_user_id') || null,
                groupId: localStorage.getItem('ais_group_id') || null,
                teacherId: localStorage.getItem('ais_teacher_id') || null
            };
            return;
        }

        try {
            var sess = await callAPI('ПроверитьСессию', {});
            var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
            this.context = {
                userId: pick(row, 'Пользователь_ID', 'user_id') || localStorage.getItem('ais_user_id'),
                groupId: pick(row, 'Группа_ID', 'group_id') || localStorage.getItem('ais_group_id'),
                teacherId: pick(row, 'Преподаватель_ID', 'teacher_id') || localStorage.getItem('ais_teacher_id')
            };
            if (this.context.userId) localStorage.setItem('ais_user_id', this.context.userId);
            if (this.context.groupId) localStorage.setItem('ais_group_id', this.context.groupId);
            if (this.context.teacherId) localStorage.setItem('ais_teacher_id', this.context.teacherId);
        } catch (err) {
            // If network is offline, fall back to local storage; otherwise surface the error
            if (typeof navigator !== 'undefined' && navigator.onLine === false) {
                this.context = {
                    userId: localStorage.getItem('ais_user_id') || null,
                    groupId: localStorage.getItem('ais_group_id') || null,
                    teacherId: localStorage.getItem('ais_teacher_id') || null
                };
                return;
            }
            throw err;
        }
    };

    Explorer.prototype.loadLookups = async function () {
        var groupPromise = callAPI('ПолучитьУчебныеГруппы', {}).catch(function () { return null; });
        var teacherPromise = callAPI('ПолучитьПреподавателей', {}).catch(function () { return null; });
        var buildingPromise = callAPI('ПолучитьКорпуса', {}).catch(function () { return null; });
        var roomPromise = callAPI('ПолучитьАудитории', {}).catch(function () { return null; });
        var results = await Promise.all([groupPromise, teacherPromise, buildingPromise, roomPromise]);

        if (results[0] && results[0].success) {
            setOptions(this.controls.group, Array.isArray(results[0].data) ? results[0].data : [], 'Группа_ID', 'Название', 'Все группы');
        }
        if (results[1] && results[1].success) {
            setOptions(this.controls.teacher, Array.isArray(results[1].data) ? results[1].data : [], 'Преподаватель_ID', 'ФИО', 'Все преподаватели');
        }
        if (results[2] && results[2].success) {
            setOptions(this.controls.building, Array.isArray(results[2].data) ? results[2].data : [], 'Корпус_ID', 'Название', 'Все корпуса');
        }
        if (results[3] && results[3].success) {
            setOptions(this.controls.room, Array.isArray(results[3].data) ? results[3].data : [], 'Аудитория_ID', 'Номер', 'Все аудитории');
        }

        if (this.scope === 'student' && this.context.groupId) {
            ensureOption(this.controls.group, this.context.groupId, 'Моя группа');
            this.controls.group.disabled = true;
        }
        if (this.scope === 'teacher' && this.context.teacherId) {
            ensureOption(this.controls.teacher, this.context.teacherId, 'Моё расписание');
            this.controls.teacher.disabled = true;
        }
        if (this.initialGroup) {
            ensureOption(this.controls.group, this.initialGroup, 'Выбранная группа');
        }
    };

    Explorer.prototype.bind = function () {
        var self = this;
        this.root.addEventListener('click', function (event) {
            var btn = event.target.closest('[data-act]');
            if (!btn) return;
            var act = btn.getAttribute('data-act');
            if (act === 'prev') { self.weekOffset--; self.page = 1; self.load(); }
            if (act === 'today') { self.weekOffset = 0; self.page = 1; self.load(); }
            if (act === 'next') { self.weekOffset++; self.page = 1; self.load(); }
            if (act === 'page-prev' && self.page > 1) { self.page--; self.load(); }
            if (act === 'page-next') { self.page++; self.load(); }
        });
        this.root.addEventListener('click', function (event) {
            var edit = event.target.closest('[data-schedule-edit]');
            if (!edit) return;
            self.root.dispatchEvent(new CustomEvent('ais:schedule-edit', {
                bubbles: true,
                detail: { lessonId: edit.getAttribute('data-schedule-edit') }
            }));
        });

        var onFilter = function () { self.page = 1; self.load(); };
        var debounced = debounce(onFilter, 300);
        // Do not attach generic onFilter to building — we need to reload rooms first and then apply filters
        ['group', 'teacher', 'room', 'weekFilter', 'lesson', 'day'].forEach(function (key) {
            if (self.controls[key]) self.controls[key].addEventListener('change', onFilter);
        });
        this.controls.search.addEventListener('input', debounced);
        if (this.controls.building) {
            this.controls.building.addEventListener('change', async function () {
                self.page = 1;
                try {
                    await self.loadRoomsForBuilding();
                } catch (e) { /* ignore */ }
                onFilter();
            });
        }
    };

    Explorer.prototype.loadRoomsForBuilding = async function () {
        var params = {};
        var buildingId = parseInt(this.controls.building.value || '0', 10);
        if (buildingId) params['Корпус_ID'] = buildingId;
        var r = await callAPI('ПолучитьАудитории', params).catch(function () { return null; });
        if (r && r.success) {
            setOptions(this.controls.room, Array.isArray(r.data) ? r.data : [], 'Аудитория_ID', 'Номер', 'Все аудитории');
        }
    };

    Explorer.prototype.params = function (mon, sun) {
        var params = {
            Дата_Начала: isoLocal(mon),
            Дата_Конца: isoLocal(sun),
            Страница: this.page,
            Размер_Страницы: this.pageSize
        };
        var groupId = parseInt(this.controls.group.value || '0', 10);
        var teacherId = parseInt(this.controls.teacher.value || '0', 10);
        var buildingId = parseInt(this.controls.building.value || '0', 10);
        var roomId = parseInt(this.controls.room.value || '0', 10);
        var day = parseInt(this.controls.day.value || '0', 10);

        if (this.scope === 'student' && this.context.groupId) groupId = parseInt(this.context.groupId, 10);
        if (this.scope === 'teacher' && this.context.teacherId) teacherId = parseInt(this.context.teacherId, 10);
        if (this.scope === 'curator' && this.context.teacherId) params['Куратор_ID'] = parseInt(this.context.teacherId, 10);

        if (groupId) params['Группа_ID'] = groupId;
        if (teacherId) params['Преподаватель_ID'] = teacherId;
        if (buildingId) params['Корпус_ID'] = buildingId;
        if (roomId) params['Аудитория_ID'] = roomId;
        if (day) params['День_Недели'] = day;
        if (this.controls.weekFilter.value) params['Тип_Недели'] = this.controls.weekFilter.value;
        if (this.controls.lesson.value) params['Тип_Занятия'] = this.controls.lesson.value;
        if (this.controls.search.value.trim()) params['Поиск'] = this.controls.search.value.trim();

        return params;
    };

    Explorer.prototype.updateRange = function (mon, sun) {
        var type = weekTypeFor(mon);
        var weekNum = academicWeekNumber(mon);
        var text = 'Неделя: ' + fmtDate(mon) + ' - ' + fmtDate(sun) + ' | учебная неделя ' + weekNum;
        this.controls.range.textContent = text;
        this.controls.week.innerHTML = weekBadge(type);
        if (this.sub) {
            this.sub.textContent = text + ' | ' + type;
        }
    };

    Explorer.prototype.renderRows = function (rows) {
        var self = this;
        if (!rows.length) {
            this.controls.tbody.innerHTML = '<tr><td colspan="11" class="table-empty">Нет занятий по выбранным фильтрам</td></tr>';
            return;
        }

        this.controls.tbody.innerHTML = rows.map(function (row) {
            var date = pick(row, 'Дата', 'Дата_Занятия') || '';
            var day = pick(row, 'День_Недели_Название') || '';
            var time = pick(row, 'Время') || ((pick(row, 'Время_Начала') || '') + ' - ' + (pick(row, 'Время_Окончания') || ''));
            var week = pick(row, 'Тип_Недели') || 'Обе';
            var subj = pick(row, 'Дисциплина', 'Название_Дисциплины') || '';
            var code = pick(row, 'Код_Дисциплины', 'краткое наименование') || '';
            var group = pick(row, 'Группа', 'Название_Группы') || '';
            var teacher = pick(row, 'Преподаватель', 'ФИО_Преподавателя') || '';
            var building = pick(row, 'Корпус') || '';
            var room = pick(row, 'Аудитория', 'Кабинет') || '';
            var type = pick(row, 'Тип_Занятия', 'Тип') || '';
            var status = pick(row, 'Статус') || '';
            var zid = pick(row, 'Занятие_ID') || '';
            var action = '';

            if (zid && self.config.action === 'student') {
                action = '<a class="btn btn-ghost btn-sm" href="/ais-system-ru/student/attendance.php?z=' + esc(zid) + '">Посещаемость</a>';
            } else if (zid && self.config.action === 'teacher') {
                action = '<a class="btn btn-ghost btn-sm" href="/ais-system-ru/teacher/attendance-journal.php?z=' + esc(zid) + '">Журнал</a>';
            } else if (zid && self.config.action === 'methodist') {
                action = '<button type="button" class="btn btn-ghost btn-sm" data-schedule-edit="' + esc(zid) + '">Изменить</button>';
            }

            return '<tr>' +
                '<td><strong>' + esc(date) + '</strong><div class="text-muted">' + esc(day) + '</div></td>' +
                '<td><strong>' + esc(time) + '</strong></td>' +
                '<td>' + weekBadge(week) + '</td>' +
                '<td><strong>' + esc(subj) + '</strong><div class="text-muted">' + esc(code) + '</div></td>' +
                '<td>' + esc(group) + '</td>' +
                '<td>' + esc(teacher) + '</td>' +
                '<td>' + esc(building) + '</td>' +
                '<td>' + esc(room) + '</td>' +
                '<td><span class="tag">' + esc(type) + '</span></td>' +
                '<td>' + lessonStatus(status) + '</td>' +
                '<td>' + action + '</td>' +
            '</tr>';
        }).join('');
    };

    Explorer.prototype.load = async function () {
        var mon = mondayOf(new Date());
        mon.setDate(mon.getDate() + this.weekOffset * 7);
        var sun = new Date(mon.getFullYear(), mon.getMonth(), mon.getDate() + 6);
        this.updateRange(mon, sun);

        this.controls.loading.style.display = 'flex';
        this.controls.error.style.display = 'none';
        this.controls.table.style.display = 'none';

        try {
            // Offline: try to render cached data if available
            if (typeof navigator !== 'undefined' && navigator.onLine === false) {
                var cacheKey = 'ais_schedule_cache_' + (this.config.rootId || 'default');
                var cached = localStorage.getItem(cacheKey);
                this.controls.loading.style.display = 'none';
                if (cached) {
                    var crow = JSON.parse(cached) || [];
                    var rows = Array.isArray(crow) ? crow : [];
                    var total = rows.length ? parseInt(pick(rows[0], 'Всего_Строк') || rows.length, 10) : 0;
                    var maxPage = Math.max(1, Math.ceil(total / this.pageSize));
                    this.page = Math.min(this.page, maxPage);
                    this.renderRows(rows);
                    this.controls.pageInfo.textContent = 'Страница ' + this.page + ' из ' + maxPage + ' | записей: ' + total;
                    this.root.querySelector('[data-act="page-prev"]').disabled = this.page <= 1;
                    this.root.querySelector('[data-act="page-next"]').disabled = this.page >= maxPage;
                    this.controls.table.style.display = '';
                    return;
                } else {
                    this.controls.error.textContent = 'Оффлайн: кэш не доступен.';
                    this.controls.error.style.display = 'flex';
                    return;
                }
            }

            var r = await callAPI('ПолучитьРасписаниеОбзор', this.params(mon, sun));
            this.controls.loading.style.display = 'none';
            if (!r || !r.success) {
                this.controls.error.textContent = r && r.message ? r.message : 'Ошибка загрузки расписания';
                this.controls.error.style.display = 'flex';
                return;
            }
            var rows = Array.isArray(r.data) ? r.data : [];
            // Cache the latest successful set for offline use
            try { localStorage.setItem('ais_schedule_cache_' + (this.config.rootId || 'default'), JSON.stringify(rows)); } catch (ignore) {}

            var total = rows.length ? parseInt(pick(rows[0], 'Всего_Строк') || rows.length, 10) : 0;
            var maxPage = Math.max(1, Math.ceil(total / this.pageSize));
            if (this.page > maxPage) {
                // Clamp page to max but do not re-invoke load() to avoid a second fetch
                this.page = maxPage;
            }
            this.renderRows(rows);
            this.controls.pageInfo.textContent = 'Страница ' + this.page + ' из ' + maxPage + ' | записей: ' + total;
            this.root.querySelector('[data-act="page-prev"]').disabled = this.page <= 1;
            this.root.querySelector('[data-act="page-next"]').disabled = this.page >= maxPage;
            this.controls.table.style.display = '';
        } catch (e) {
            console.error(e);
            // If we lost connectivity during the request try cached data
            if (typeof navigator !== 'undefined' && navigator.onLine === false) {
                var cacheKey = 'ais_schedule_cache_' + (this.config.rootId || 'default');
                var cached = localStorage.getItem(cacheKey);
                this.controls.loading.style.display = 'none';
                if (cached) {
                    var crow = JSON.parse(cached) || [];
                    var rows = Array.isArray(crow) ? crow : [];
                    var total = rows.length ? parseInt(pick(rows[0], 'Всего_Строк') || rows.length, 10) : 0;
                    var maxPage = Math.max(1, Math.ceil(total / this.pageSize));
                    this.page = Math.min(this.page, maxPage);
                    this.renderRows(rows);
                    this.controls.pageInfo.textContent = 'Страница ' + this.page + ' из ' + maxPage + ' | записей: ' + total;
                    this.root.querySelector('[data-act="page-prev"]').disabled = this.page <= 1;
                    this.root.querySelector('[data-act="page-next"]').disabled = this.page >= maxPage;
                    this.controls.table.style.display = '';
                    return;
                }
            }
            this.controls.loading.style.display = 'none';
            this.controls.error.textContent = e && e.message ? e.message : 'Ошибка соединения.';
            this.controls.error.style.display = 'flex';
        }
    };

    Explorer.prototype.init = async function () {
        if (!this.root) return;
        this.renderShell();
        this.bind();
        await this.resolveContext();
        await this.loadLookups();
        await this.load();
        return this;
    };

    window.AISScheduleExplorer = {
        init: function (config) {
            var explorer = new Explorer(config);
            return explorer.init();
        },
        weekTypeFor: weekTypeFor,
        academicWeekNumber: academicWeekNumber,
        isoLocal: isoLocal
    };
}());

