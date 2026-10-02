<?php
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Очередь офлайн-запросов';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>
<div class="page-hdr">
  <div>
    <h1 class="page-title">Очередь офлайн-запросов</h1>
    <div class="page-sub">Просмотр и управление локально сохранёнными запросами</div>
  </div>
  <div class="page-actions">
    <button id="btn-refresh" class="btn btn-outline">Обновить</button>
    <button id="btn-flush" class="btn btn-primary">Отправить все</button>
  </div>
</div>

<div class="card">
  <div class="card-body">
    <div id="queue-msg"></div>
    <div class="tbl-wrap">
      <table id="queue-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Action</th>
            <th>Params</th>
            <th>Idempotency</th>
            <th>Schema</th>
            <th>Session</th>
            <th>Auth</th>
            <th>Timestamp</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>

<script src="/ais-system-ru/assets/js/offline-queue-manager.js"></script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

