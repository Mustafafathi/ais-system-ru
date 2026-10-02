<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
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
window.AISScheduleExplorer.init({
    rootId: 'schedule-explorer',
    subId: 'sched-sub',
    scope: 'student',
    action: 'student'
});
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

