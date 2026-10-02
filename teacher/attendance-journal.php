<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'Журнал посещаемости';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Журнал посещаемости</div>
        <div class="page-sub" id="journal-sub">Выберите занятие для отметки</div>
    </div>
    <div class="page-actions">
        <select class="form-ctrl control-lg" id="session-select">
            <option value="">Загрузка занятий...</option>
        </select>
        <a href="/ais-system-ru/teacher/qr-generator.php" class="btn btn-outline btn-sm">Создать QR</a>
    </div>
</div>

<div class="alert alert-info" id="select-hint">Выберите занятие из списка выше для загрузки студентов.</div>
<div class="alert alert-info" id="loading" style="display:none">Загрузка студентов...</div>
<div class="alert alert-err" id="error" style="display:none"></div>
<div class="alert alert-ok" id="save-ok" style="display:none"></div>

<div id="journal-wrap" style="display:none">
    <div class="table-card">
        <div class="tbl-wrap">
            <table class="table-min">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Студент</th>
                        <th>Статус</th>
                        <th>Тип отметки</th>
                        <th>Примечание</th>
                        <th>Сохранение</th>
                    </tr>
                </thead>
                <tbody id="journal-tbody"></tbody>
            </table>
        </div>
    </div>

    <div class="attendance-footer">
        <div class="attendance-legend">
            <span class="att-status att-ok is-static" aria-hidden="true">P</span> Присутствовал
            <span class="att-status att-err is-static" aria-hidden="true">A</span> Отсутствовал
            <span class="att-status att-warn is-static" aria-hidden="true">L</span> Опоздал
            <span class="att-status att-info is-static" aria-hidden="true">R</span> Уваж. причина
            <span class="tag" id="queue-state">Очередь: 0</span>
        </div>
        <button class="btn btn-primary" id="save-btn">Сохранить изменения</button>
    </div>
</div>

<script src="/ais-system-ru/assets/js/attendance-journal.js"></script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

