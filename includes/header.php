<?php
declare(strict_types=1);
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><?= htmlspecialchars($page_title ?? 'АИС') ?> — Система посещаемости</title>
    <link rel="stylesheet" href="/ais-system-ru/assets/css/style.css?v=20260602-ui-surgery-a11y">
    <script src="/ais-system-ru/assets/js/common.js"></script>
    <script src="/ais-system-ru/assets/js/dashboard-charts.js"></script>
    <script src="/ais-system-ru/assets/js/role-capabilities.js"></script>
    <script src="/ais-system-ru/assets/js/offline-queue.js"></script>
    <script src="/ais-system-ru/assets/vendor/qrcode.min.js"></script>
    <script src="/ais-system-ru/assets/vendor/html5-qrcode.min.js"></script>
    <script src="/ais-system-ru/assets/js/qr-scanner.js"></script>
</head>
<body>
<a class="skip-link" href="#main">Перейти к содержимому</a>

