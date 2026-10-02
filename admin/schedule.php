<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
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

<div id="schedule-explorer"></div>

<script src="/ais-system-ru/assets/js/schedule-explorer.js?v=20260526"></script>
<script>
if (window.AISScheduleExplorer && typeof window.AISScheduleExplorer.init === 'function') {
    try {
        var __init = window.AISScheduleExplorer.init({
            rootId: 'schedule-explorer',
            subId: 'sched-sub',
            scope: 'all'
        });
        if (__init && typeof __init.then === 'function') {
            __init.catch(function(err){
                console.error('AISScheduleExplorer.init failed:', err);
                var root = document.getElementById('schedule-explorer');
                if (root) root.innerHTML = '<div class="alert alert-err">Ошибка инициализации модуля расписания.</div>';
            });
        }
    } catch (err) {
        console.error('AISScheduleExplorer.init threw:', err);
        var root = document.getElementById('schedule-explorer');
        if (root) root.innerHTML = '<div class="alert alert-err">Ошибка инициализации модуля расписания.</div>';
    }
} else {
    console.error('AISScheduleExplorer not available');
    var root = document.getElementById('schedule-explorer');
    if (root) root.innerHTML = '<div class="alert alert-err">Модуль расписания недоступен.</div>';
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

