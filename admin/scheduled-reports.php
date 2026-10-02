<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Плановые отчёты';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Плановые отчёты</div>
        <div class="page-sub">SQL Server Agent, Database Mail и история доставок</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-outline btn-sm" id="refresh-btn">Обновить</button>
    </div>
</div>

<div class="alert alert-info">
    Запуск и отправка выполняются в SQL Server. Эта страница показывает расписание, последние запуски и доставку без выполнения произвольного SQL.
</div>

<div class="cap-grid">
    <section class="cap-card">
        <div class="cap-card-hdr">
            <span class="cap-card-title">Расписание отчётов</span>
            <span id="reports-badge" class="badge b-muted">—</span>
        </div>
        <div class="cap-card-body" id="reports-body">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </section>

    <section class="cap-card">
        <div class="cap-card-hdr">
            <span class="cap-card-title">Последние запуски</span>
            <span id="runs-badge" class="badge b-muted">—</span>
        </div>
        <div class="cap-card-body">
            <div class="page-actions mb-3">
                <select class="form-ctrl control-auto" id="status-filter">
                    <option value="">Все статусы</option>
                    <option value="Успешно">Успешно</option>
                    <option value="Частично">Частично</option>
                    <option value="Ошибка">Ошибка</option>
                    <option value="Пропущено">Пропущено</option>
                    <option value="Дубликат">Дубликат</option>
                </select>
                <button class="btn btn-outline btn-sm" id="runs-load-btn">Показать</button>
            </div>
            <div id="runs-body">
                <div class="alert alert-info">Загрузка...</div>
            </div>
        </div>
    </section>

    <section class="cap-card">
        <div class="cap-card-hdr">
            <span class="cap-card-title">Доставки выбранного запуска</span>
            <span id="delivery-badge" class="badge b-muted">—</span>
        </div>
        <div class="cap-card-body" id="delivery-body">
            <div class="cap-state cap-state-info">
                <strong>Запуск не выбран</strong>
                <span>Выберите строку в таблице запусков, чтобы увидеть получателей и результат Database Mail.</span>
            </div>
        </div>
    </section>
</div>

<script>
(function () {
    'use strict';

    var UI = window.AISRoleUI;

    function pick(obj) {
        return UI.pick.apply(UI, arguments);
    }

    function pluralizeRussian(count, forms) {
        count = Math.abs(Number(count) || 0);
        var mod100 = count % 100;
        var mod10 = count % 10;
        if (count === 0) return forms[2];
        if (mod100 >= 11 && mod100 <= 14) return forms[2];
        if (mod10 === 1) return forms[0];
        if (mod10 >= 2 && mod10 <= 4) return forms[1];
        return forms[2];
    }

    function setBadge(id, label) {
        var el = document.getElementById(id);
        if (!el) return;
        var wrap = document.createElement('div');
        wrap.innerHTML = UI.badge(label || '—');
        var badge = wrap.firstChild;
        el.className = badge.className;
        el.textContent = badge.textContent;
    }

    function rows(data) {
        return UI.rows(data);
    }

    function scheduleLabel(row) {
        var day = pick(row, 'Ожидаемый_День_Недели') || 'Каждый день';
        var time = pick(row, 'Ожидаемое_Время') || '—';
        return day + ', ' + time;
    }

    async function loadReports() {
        var body = document.getElementById('reports-body');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьПлановыеОтчеты', {});
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var data = rows(response.data);
            setBadge('reports-badge', data.length ? data.length + ' ' + pluralizeRussian(data.length, ['отчёт','отчёта','отчётов']) : 'Нет данных');
            if (!data.length) {
                body.innerHTML = UI.stateBlock('warning', 'Нет настроенных отчётов', 'Примените Database/scheduled_reports_agent.sql.');
                return;
            }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Отчёт</th><th>Расписание</th><th>Получатели</th><th>Agent job</th><th>Последний статус</th></tr></thead><tbody>' +
                data.map(function (row) {
                    return '<tr>' +
                        '<td><strong>' + UI.esc(pick(row, 'Название') || pick(row, 'Код_Отчета') || '—') + '</strong><div class="list-meta">' + UI.esc(pick(row, 'Описание') || '') + '</div></td>' +
                        '<td>' + UI.esc(scheduleLabel(row)) + '</td>' +
                        '<td>' + UI.esc(pick(row, 'Стратегия_Получателей') || '—') + '</td>' +
                        '<td>' + UI.esc(pick(row, 'Agent_Job_Name') || '—') + '</td>' +
                        '<td>' + UI.badge(pick(row, 'Последний_Статус') || 'Нет запусков') + '</td>' +
                    '</tr>';
                }).join('') +
                '</tbody></table></div>';
        } catch (error) {
            setBadge('reports-badge', 'Ошибка');
            body.innerHTML = UI.stateBlock('error', 'Плановые отчёты недоступны', error.message || 'Ошибка соединения.');
        }
    }

    async function loadRuns() {
        var body = document.getElementById('runs-body');
        var status = document.getElementById('status-filter').value;
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var params = { Лимит: 50 };
            if (status) params.Статус = status;
            var response = await callAPI('ПолучитьЗапускиПлановыхОтчетов', params);
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var data = rows(response.data);
            setBadge('runs-badge', data.length ? data.length + ' ' + pluralizeRussian(data.length, ['запись','записи','записей']) : 'Нет запусков');
            if (!data.length) {
                body.innerHTML = UI.stateBlock('info', 'Запусков нет', 'История появится после выполнения SQL Server Agent job или тестового запуска процедуры.');
                return;
            }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Запуск</th><th>Отчёт</th><th>Период</th><th>Статус</th><th>Доставка</th><th></th></tr></thead><tbody>' +
                data.map(function (row) {
                    var runId = pick(row, 'Запуск_ID');
                    return '<tr>' +
                        '<td>' + UI.esc(pick(row, 'Начало_Запуска') || '—') + '</td>' +
                        '<td><strong>' + UI.esc(pick(row, 'Название') || pick(row, 'Код_Отчета') || '—') + '</strong><div class="list-meta">' + UI.esc(pick(row, 'SqlAgentJobName') || pick(row, 'Источник_Запуска') || '') + '</div></td>' +
                        '<td>' + UI.esc((pick(row, 'Период_С') || '—') + ' — ' + (pick(row, 'Период_По') || '—')) + '</td>' +
                        '<td>' + UI.badge(pick(row, 'Статус') || '—') + '</td>' +
                        '<td>' + UI.esc((pick(row, 'Количество_Отправлено') || 0) + '/' + (pick(row, 'Количество_Получателей') || 0)) + '</td>' +
                        '<td><button class="btn btn-outline btn-sm delivery-btn" data-run-id="' + UI.esc(runId || '') + '">Доставки</button></td>' +
                    '</tr>';
                }).join('') +
                '</tbody></table></div>';
            Array.prototype.forEach.call(document.querySelectorAll('.delivery-btn'), function (btn) {
                btn.addEventListener('click', function () {
                    loadDeliveries(btn.getAttribute('data-run-id'));
                });
            });
        } catch (error) {
            setBadge('runs-badge', 'Ошибка');
            body.innerHTML = UI.stateBlock('error', 'История запусков недоступна', error.message || 'Ошибка соединения.');
        }
    }

    async function loadDeliveries(runId) {
        var body = document.getElementById('delivery-body');
        if (!runId) return;
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';
        try {
            var response = await callAPI('ПолучитьДоставкиПлановогоОтчета', { Запуск_ID: runId });
            if (!response || !response.success) throw new Error(response && response.message ? response.message : 'Ошибка загрузки');
            var data = rows(response.data);
            setBadge('delivery-badge', data.length ? data.length + ' ' + pluralizeRussian(data.length, ['получатель','получателя','получателей']) : 'Нет доставок');
            if (!data.length) {
                body.innerHTML = UI.stateBlock('info', 'Доставок нет', 'Для выбранного запуска записи Database Mail не найдены.');
                return;
            }
            body.innerHTML = '<div class="tbl-wrap"><table><thead><tr><th>Получатель</th><th>Email</th><th>Статус</th><th>Mail item</th><th>Ошибка</th></tr></thead><tbody>' +
                data.map(function (row) {
                    return '<tr>' +
                        '<td>' + UI.esc(pick(row, 'Имя_Получателя') || pick(row, 'Область') || '—') + '</td>' +
                        '<td>' + UI.esc(pick(row, 'Email') || '—') + '</td>' +
                        '<td>' + UI.badge(pick(row, 'Статус') || '—') + '</td>' +
                        '<td>' + UI.esc(pick(row, 'MailItemId') || '—') + '</td>' +
                        '<td>' + UI.esc(pick(row, 'Ошибка') || '') + '</td>' +
                    '</tr>';
                }).join('') +
                '</tbody></table></div>';
        } catch (error) {
            setBadge('delivery-badge', 'Ошибка');
            body.innerHTML = UI.stateBlock('error', 'Доставки недоступны', error.message || 'Ошибка соединения.');
        }
    }

    function loadAll() {
        loadReports();
        loadRuns();
    }

    document.getElementById('refresh-btn').addEventListener('click', loadAll);
    document.getElementById('runs-load-btn').addEventListener('click', loadRuns);
    loadAll();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

