<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Методист');
$page_title = 'Расписание';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Расписание занятий</div>
        <div class="page-sub" id="sched-sub">Загрузка...</div>
    </div>
</div>

<div class="alert alert-err" id="create-error" style="display:none"></div>
<div class="alert alert-ok" id="create-success" style="display:none"></div>

<div class="card" style="margin-bottom:16px">
    <div class="card-hdr"><span class="card-title">Добавить занятие в расписание</span></div>
    <div class="card-body">
        <div class="form-grid">
            <select class="form-ctrl" id="new-group"><option value="">Группа</option></select>
            <select class="form-ctrl" id="new-subject"><option value="">Дисциплина</option></select>
            <select class="form-ctrl" id="new-day">
                <option value="1">Понедельник</option>
                <option value="2">Вторник</option>
                <option value="3">Среда</option>
                <option value="4">Четверг</option>
                <option value="5">Пятница</option>
                <option value="6">Суббота</option>
                <option value="7">Воскресенье</option>
            </select>
            <input type="time" class="form-ctrl" id="new-start" value="09:00">
            <input type="time" class="form-ctrl" id="new-end" value="10:30">
            <select class="form-ctrl" id="new-lesson-type">
                <option value="Лекция">Лекция</option>
                <option value="Практика">Практика</option>
                <option value="Лабораторная">Лабораторная</option>
                <option value="Семинар">Семинар</option>
            </select>
            <select class="form-ctrl" id="new-week-type">
                <option value="Обе">Обе недели</option>
                <option value="Числитель">Числитель</option>
                <option value="Знаменатель">Знаменатель</option>
            </select>
            <select class="form-ctrl" id="new-building"><option value="">Корпус</option></select>
            <select class="form-ctrl" id="new-room"><option value="">Аудитория</option></select>
            <button class="btn btn-primary" id="create-btn">Добавить</button>
        </div>
    </div>
</div>

<div class="card" style="margin-bottom:16px">
    <div class="card-hdr">
        <span class="card-title">Изменить занятие с уведомлением</span>
        <span class="badge b-info">Backend уведомляет студентов</span>
    </div>
    <div class="card-body">
        <div class="form-grid">
            <input type="number" class="form-ctrl" id="edit-lesson-id" placeholder="ID занятия">
            <input type="date" class="form-ctrl" id="edit-date">
            <input type="time" class="form-ctrl" id="edit-start">
            <input type="time" class="form-ctrl" id="edit-end">
            <input type="text" class="form-ctrl" id="edit-room" placeholder="Аудитория">
            <select class="form-ctrl" id="edit-status">
                <option value="">Статус не менять</option>
                <option value="Запланировано">Запланировано</option>
                <option value="Проведено">Проведено</option>
                <option value="Отменено">Отменено</option>
                <option value="Перенесено">Перенесено</option>
            </select>
            <input type="text" class="form-ctrl" id="edit-note" placeholder="Примечание к статусу">
            <button class="btn btn-primary" id="update-lesson-btn">Обновить и уведомить</button>
            <button class="btn btn-outline" id="update-status-btn">Изменить статус</button>
        </div>
        <div class="alert alert-info mt-3">
            Выберите занятие в таблице ниже или введите ID вручную. При изменении даты, времени или аудитории студенты получат уведомление.
        </div>
    </div>
</div>

<div id="schedule-explorer"></div>

<script src="/ais-system-ru/assets/js/schedule-explorer.js?v=20260526"></script>
<script>
(function () {
    'use strict';
    var scheduleExplorer = null;

    function pick(obj) {
        for (var i = 1; i < arguments.length; i++) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) return obj[arguments[i]];
        }
        return null;
    }

    function setSelectOptions(select, rows, valueKey, labelKey, placeholder) {
        select.innerHTML = '<option value="">' + placeholder + '</option>';
        rows.forEach(function(row) {
            var value = pick(row, valueKey, 'id');
            var label = pick(row, labelKey, 'Название', 'ФИО', 'Номер');
            if (!value || !label) return;
            var opt = document.createElement('option');
            opt.value = value;
            opt.textContent = label;
            select.appendChild(opt);
        });
    }

    async function currentUserId() {
        var id = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        if (id) return id;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        id = pick(row, 'Пользователь_ID', 'user_id') || 0;
        if (id) localStorage.setItem('ais_user_id', id);
        return id;
    }

    async function loadCreateLookups() {
        var groups = await callAPI('ПолучитьУчебныеГруппы', {}).catch(function(){ return null; });
        if (groups && groups.success) setSelectOptions(document.getElementById('new-group'), groups.data || [], 'Группа_ID', 'Название', 'Группа');

        var subjects = await callAPI('ПолучитьДисциплиныПреподавателя', {}).catch(function(){ return null; });
        if (subjects && subjects.success) setSelectOptions(document.getElementById('new-subject'), subjects.data || [], 'Дисциплина_ID', 'Название', 'Дисциплина');

        var buildings = await callAPI('ПолучитьКорпуса', {}).catch(function(){ return null; });
        if (buildings && buildings.success) setSelectOptions(document.getElementById('new-building'), buildings.data || [], 'Корпус_ID', 'Название', 'Корпус');

        await loadRooms();
    }

    async function loadRooms() {
        var buildingId = parseInt(document.getElementById('new-building').value || '0', 10);
        var params = {};
        if (buildingId) params['Корпус_ID'] = buildingId;
        var rooms = await callAPI('ПолучитьАудитории', params).catch(function(){ return null; });
        if (rooms && rooms.success) setSelectOptions(document.getElementById('new-room'), rooms.data || [], 'Аудитория_ID', 'Номер', 'Аудитория');
    }

    async function createSchedule() {
        var error = document.getElementById('create-error');
        var success = document.getElementById('create-success');
        error.style.display = 'none';
        success.style.display = 'none';

        var groupId = parseInt(document.getElementById('new-group').value || '0', 10);
        var subjectId = parseInt(document.getElementById('new-subject').value || '0', 10);
        var day = parseInt(document.getElementById('new-day').value || '0', 10);
        var start = document.getElementById('new-start').value;
        var end = document.getElementById('new-end').value;
        var lessonType = document.getElementById('new-lesson-type').value;
        var weekType = document.getElementById('new-week-type').value;
        var roomSelect = document.getElementById('new-room');
        var roomId = parseInt(roomSelect.value || '0', 10);
        var roomText = roomId ? roomSelect.options[roomSelect.selectedIndex].textContent : '';

        if (!groupId || !subjectId || !day || !start || !end) {
            error.textContent = 'Заполните группу, дисциплину, день и время.';
            error.style.display = 'flex';
            return;
        }

        var params = {
            Группа_ID: groupId,
            Дисциплина_ID: subjectId,
            День_Недели: day,
            Время_Начала: start,
            Время_Окончания: end,
            Тип_Занятия: lessonType,
            Тип_Недели: weekType,
            Кабинет: roomText || null,
            КтоСоздал: await currentUserId()
        };
        if (roomId) params['Аудитория_ID'] = roomId;

        var r = await callAPI('СоздатьРасписание', params).catch(function(e){ return {success:false, message:e.message}; });
        if (!r || !r.success) {
            error.textContent = r && r.message ? r.message : 'Ошибка создания расписания.';
            error.style.display = 'flex';
            return;
        }

        success.textContent = 'Расписание обновлено.';
        success.style.display = 'flex';
        localStorage.setItem('ais_schedule_changed_at', String(Date.now()));
        if (scheduleExplorer && typeof scheduleExplorer.load === 'function') {
            scheduleExplorer.load();
        }
    }

    async function updateLessonWithNotification() {
        var error = document.getElementById('create-error');
        var success = document.getElementById('create-success');
        error.style.display = 'none';
        success.style.display = 'none';

        var lessonId = parseInt(document.getElementById('edit-lesson-id').value || '0', 10);
        if (!lessonId) {
            error.textContent = 'Укажите ID занятия для изменения.';
            error.style.display = 'flex';
            return;
        }
        if (!window.confirm('Обновить занятие и отправить уведомление студентам группы?')) return;

        var params = {
            Занятие_ID: lessonId,
            КтоОбновил: await currentUserId()
        };
        var date = document.getElementById('edit-date').value;
        var start = document.getElementById('edit-start').value;
        var end = document.getElementById('edit-end').value;
        var room = document.getElementById('edit-room').value.trim();
        if (date) params['НоваяДата'] = date;
        if (start) params['НовоеВремяНачала'] = start;
        if (end) params['НовоеВремяОкончания'] = end;
        if (room) params['НовыйКабинет'] = room;

        var r = await callAPI('ОбновитьЗанятиеСУведомлением', params).catch(function(e){ return {success:false, message:e.message}; });
        if (!r || !r.success) {
            error.textContent = r && r.message ? r.message : 'Ошибка обновления занятия.';
            error.style.display = 'flex';
            return;
        }

        var row = Array.isArray(r.data) ? r.data[0] : null;
        success.textContent = row && row.Сообщение ? row.Сообщение : 'Занятие обновлено, уведомления обработаны backend.';
        success.style.display = 'flex';
        localStorage.setItem('ais_schedule_changed_at', String(Date.now()));
        if (scheduleExplorer && typeof scheduleExplorer.load === 'function') scheduleExplorer.load();
    }

    async function updateLessonStatus() {
        var error = document.getElementById('create-error');
        var success = document.getElementById('create-success');
        error.style.display = 'none';
        success.style.display = 'none';

        var lessonId = parseInt(document.getElementById('edit-lesson-id').value || '0', 10);
        var status = document.getElementById('edit-status').value;
        if (!lessonId || !status) {
            error.textContent = 'Укажите ID занятия и новый статус.';
            error.style.display = 'flex';
            return;
        }
        if (!window.confirm('Изменить статус выбранного занятия?')) return;

        var params = {
            Занятие_ID: lessonId,
            Статус: status,
            Примечание: document.getElementById('edit-note').value.trim() || null,
            КтоОбновил: await currentUserId()
        };
        var r = await callAPI('ОбновитьСтатусЗанятия', params).catch(function(e){ return {success:false, message:e.message}; });
        if (!r || !r.success) {
            error.textContent = r && r.message ? r.message : 'Ошибка изменения статуса.';
            error.style.display = 'flex';
            return;
        }
        success.textContent = 'Статус занятия обновлён.';
        success.style.display = 'flex';
        localStorage.setItem('ais_schedule_changed_at', String(Date.now()));
        if (scheduleExplorer && typeof scheduleExplorer.load === 'function') scheduleExplorer.load();
    }

    document.getElementById('new-building').addEventListener('change', loadRooms);
    document.getElementById('create-btn').addEventListener('click', createSchedule);
    document.getElementById('update-lesson-btn').addEventListener('click', updateLessonWithNotification);
    document.getElementById('update-status-btn').addEventListener('click', updateLessonStatus);
    document.getElementById('schedule-explorer').addEventListener('ais:schedule-edit', function(event) {
        document.getElementById('edit-lesson-id').value = event.detail && event.detail.lessonId ? event.detail.lessonId : '';
        document.getElementById('create-success').textContent = 'Занятие выбрано для изменения.';
        document.getElementById('create-success').style.display = 'flex';
    });
    loadCreateLookups();

    window.AISScheduleExplorer.init({
        rootId: 'schedule-explorer',
        subId: 'sched-sub',
        scope: 'all',
        action: 'methodist'
    }).then(function(instance) {
        scheduleExplorer = instance;
    });
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

