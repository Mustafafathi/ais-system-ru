<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Преподаватель');
$page_title = 'Моё расписание';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Моё расписание</div>
        <div class="page-sub" id="sched-sub">Загрузка...</div>
    </div>
</div>

<div id="schedule-explorer"></div>

<script src="/ais-system-ru/assets/js/schedule-explorer.js?v=20260526"></script>
<script>
if (window.AISScheduleExplorer && typeof window.AISScheduleExplorer.init === 'function') {
    try {
        var _initRes = window.AISScheduleExplorer.init({
            rootId: 'schedule-explorer',
            subId: 'sched-sub',
            scope: 'teacher',
            action: 'teacher'
        });
        if (_initRes && typeof _initRes.then === 'function') {
            _initRes.catch(function(err){
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
    console.error('AISScheduleExplorer is not available');
    var root = document.getElementById('schedule-explorer');
    if (root) root.innerHTML = '<div class="alert alert-err">Модуль расписания недоступен.</div>';
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

