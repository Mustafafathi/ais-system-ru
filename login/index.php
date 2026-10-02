<?php
declare(strict_types=1);
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../includes/role_helpers.php';
startSessionIfNeeded();

// Already logged in?
if (isset($_SESSION['session_id'], $_SESSION['token'])) {
    header('Location: /ais-system-ru/');
    exit;
}

$error = '';
if (isset($_GET['error'])) {
    $error = match($_GET['error']) {
        'session_expired' => 'Сессия истекла. Пожалуйста, войдите снова.',
        'unknown_role'    => 'Неизвестная роль пользователя.',
        'no_navigation'   => 'Для вашей роли не назначены разделы интерфейса. Обратитесь к администратору.',
        default           => 'Произошла ошибка при входе.',
    };
}
?>
<?php
$roleDashboardMap = [];
foreach (aisRoleRoutes() as $roleName => $meta) {
    $roleDashboardMap[$roleName] = $meta['path'];
}
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Вход — АИС Посещаемость</title>
    <link rel="stylesheet" href="/ais-system-ru/assets/css/style.css?v=20260530-enterprise-polish">
</head>
<body>

<div class="login-bg">
    <nav class="login-nav">
        <div class="login-brand-mark">
            <img src="/ais-system-ru/assets/images/misis-logo.png" alt="МИСИС">
        </div>
        <div class="login-brand-copy">
            <span class="login-brand-title">Система учёта посещаемости</span>
            <span class="login-brand-sub">СТИ НИТУ «МИСИС»</span>
        </div>
    </nav>

    <div class="login-body">
        <div class="login-wrap">

            <!-- Hero section -->
            <div class="login-hero">
                <h1>Система<br>учёта <span>посещаемости</span><br>студентов</h1>
                <p>Автоматизированная информационная система для отслеживания посещаемости в реальном времени с поддержкой QR-кодов и СКУД.</p>
                <div class="feature-list">
                    <div class="feature-item">Отметка через QR-код и СКУД</div>
                    <div class="feature-item">Автоматические уведомления о пропусках</div>
                    <div class="feature-item">Отчёты и статистика в реальном времени</div>
                    <div class="feature-item">Интеграция с 1С и СКУД-системой</div>
                    <div class="feature-item">Работа в режиме офлайн</div>
                </div>
            </div>

            <!-- Login card -->
            <div class="login-card">
                <h2>Добро пожаловать</h2>
                <p class="subtitle">Войдите в свою учётную запись</p>

                <?php if ($error): ?>
                <div class="alert alert-err"><?= htmlspecialchars($error) ?></div>
                <?php endif; ?>

                <div class="alert alert-err" id="login-error" style="display:none"></div>
                <div class="alert alert-ok" id="login-success" style="display:none"></div>

                <div class="auth-panel" id="login-panel">
                    <div class="form-group">
                        <label class="form-label" for="login-input">Имя пользователя</label>
                        <input type="text" id="login-input" class="form-ctrl" placeholder="Введите логин" autocomplete="username">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="pw-input">Пароль</label>
                        <div class="pw-container input-wrap">
                            <input type="password" id="pw-input" class="form-ctrl" placeholder="••••••••" autocomplete="current-password">
                            <button type="button" class="input-end" id="pw-toggle" title="Показать пароль">Показать</button>
                        </div>
                    </div>

                    <div class="form-row-inline auth-row">
                        <div class="form-check">
                            <input type="checkbox" id="remember-me" checked>
                            <label for="remember-me">Запомнить меня</label>
                        </div>
                        <button type="button" class="auth-link" id="forgot-link">Забыли пароль?</button>
                    </div>

                    <button class="btn btn-primary btn-block btn-lg" id="login-btn">Войти в систему</button>
                </div>

                <div class="auth-panel" id="reset-request-panel" hidden>
                    <div class="form-group">
                        <label class="form-label" for="reset-email-input">Email</label>
                        <input type="email" id="reset-email-input" class="form-ctrl" placeholder="Введите email учетной записи" autocomplete="email">
                    </div>
                    <p class="form-hint">Если учетная запись существует и к ней привязан email, система отправит ссылку для восстановления пароля.</p>
                    <button class="btn btn-primary btn-block btn-lg" id="reset-request-btn">Отправить ссылку</button>
                    <button type="button" class="auth-link auth-link-block" id="back-to-login-from-request">Вернуться ко входу</button>
                </div>

                <div class="auth-panel" id="reset-confirm-panel" hidden>
                    <p class="form-hint">Установите новый пароль для учетной записи.</p>
                    <div class="form-group">
                        <label class="form-label" for="new-password-input">Новый пароль</label>
                        <input type="password" id="new-password-input" class="form-ctrl" placeholder="Введите новый пароль" autocomplete="new-password">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="confirm-password-input">Повторите пароль</label>
                        <input type="password" id="confirm-password-input" class="form-ctrl" placeholder="Повторите новый пароль" autocomplete="new-password">
                    </div>
                    <button class="btn btn-primary btn-block btn-lg" id="reset-confirm-btn">Сохранить новый пароль</button>
                    <button type="button" class="auth-link auth-link-block" id="back-to-login-from-confirm">Вернуться ко входу</button>
                </div>

                <p class="tiny-muted">
                    СТИ НИТУ «МИСИС» · Старый Оскол · 2026
                </p>
            </div>

        </div>
    </div>
</div>

<script src="/ais-system-ru/assets/js/common.js"></script>
<script>
(function () {
    'use strict';

    var loginInput = document.getElementById('login-input');
    var pwInput    = document.getElementById('pw-input');
    var pwToggle   = document.getElementById('pw-toggle');
    var loginBtn   = document.getElementById('login-btn');
    var errorBox   = document.getElementById('login-error');
    var successBox = document.getElementById('login-success');
    var loginPanel = document.getElementById('login-panel');
    var resetRequestPanel = document.getElementById('reset-request-panel');
    var resetConfirmPanel = document.getElementById('reset-confirm-panel');
    var forgotLink = document.getElementById('forgot-link');
    var resetEmailInput = document.getElementById('reset-email-input');
    var resetRequestBtn = document.getElementById('reset-request-btn');
    var resetConfirmBtn = document.getElementById('reset-confirm-btn');
    var newPasswordInput = document.getElementById('new-password-input');
    var confirmPasswordInput = document.getElementById('confirm-password-input');
    var backToLoginFromRequest = document.getElementById('back-to-login-from-request');
    var backToLoginFromConfirm = document.getElementById('back-to-login-from-confirm');
    var resetToken = new URLSearchParams(window.location.search).get('reset_token') || '';

    pwToggle.addEventListener('click', function () {
        pwInput.type = (pwInput.type === 'password') ? 'text' : 'password';
        pwToggle.textContent = (pwInput.type === 'password') ? 'Показать' : 'Скрыть';
    });

    function showError(msg) {
        errorBox.textContent = msg;
        errorBox.style.display = 'flex';
        successBox.style.display = 'none';
    }

    function showSuccess(msg) {
        successBox.textContent = msg;
        successBox.style.display = 'flex';
        errorBox.style.display = 'none';
    }

    function hideMessages() {
        errorBox.style.display = 'none';
        successBox.style.display = 'none';
    }

    function showPanel(panelName) {
        hideMessages();
        loginPanel.hidden = panelName !== 'login';
        resetRequestPanel.hidden = panelName !== 'request';
        resetConfirmPanel.hidden = panelName !== 'confirm';

        if (panelName === 'login') {
            loginInput.focus();
        } else if (panelName === 'request') {
            resetEmailInput.focus();
        } else if (panelName === 'confirm') {
            newPasswordInput.focus();
        }
    }

    async function doLogin() {
        hideMessages();
        var login    = loginInput.value.trim();
        var password = pwInput.value;

        if (!login || !password) { showError('Введите логин и пароль.'); return; }

        loginBtn.disabled    = true;
        loginBtn.textContent = 'Входим...';

        try {
            var res = await callAPI('Авторизация', {
                Логин: login,
                Пароль: password,
                Устройство: navigator.platform || 'Browser',
                Браузер: navigator.userAgent || 'Unknown'
            }, false);

            if (!res || !res.success) {
                showError(res && res.message ? res.message : 'Неверный логин или пароль.');
                return;
            }

            var row = (Array.isArray(res.data) && res.data[0]) ? res.data[0] : {};

            // SP "Авторизация" возвращает поля:
            //   ID_Сессии, Токен_Сессии, Роль, Пользователь_ID,
            //   ФИО_Студента, ФИО_Преподавателя, Группа_ID, Студент_ID, Преподаватель_ID
            var sessionId = row['ID_Сессии']    || '';
            var token     = row['Токен_Сессии'] || '';
            var role      = row['Роль']         || '';
            var fio       = row['ФИО_Студента'] || row['ФИО_Преподавателя'] || row['Логин'] || login;

            if (!sessionId || !token) {
                showError('Сервер не вернул токен сессии.');
                return;
            }

            clearSessionData();

            // Сигнатура saveSessionData: (sessionId, token, role, userName)
            saveSessionData(sessionId, token, role, fio);

            // Дополнительные данные пользователя
            if (row['Пользователь_ID'])  localStorage.setItem('ais_user_id',     String(row['Пользователь_ID']));
            if (row['Студент_ID'])       localStorage.setItem('ais_student_id',  String(row['Студент_ID']));
            if (row['Преподаватель_ID']) localStorage.setItem('ais_teacher_id',  String(row['Преподаватель_ID']));
            if (row['Группа_ID'])        localStorage.setItem('ais_group_id',    String(row['Группа_ID']));

            // Синхронизируем PHP-сессию
            await fetch('/ais-system-ru/login/session_set.php', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json' },
                body:    JSON.stringify({
                    session_id: sessionId,
                    token: token,
                    role: role,
                    user_id: row['Пользователь_ID'] || null,
                    student_id: row['Студент_ID'] || null,
                    teacher_id: row['Преподаватель_ID'] || null,
                    group_id: row['Группа_ID'] || null
                })
            }).catch(function(){});
            window.location.href = '/ais-system-ru/';

        } catch (err) {
            showError('Ошибка соединения. Проверьте подключение к сети.');
            console.error(err);
        } finally {
            loginBtn.disabled    = false;
            loginBtn.textContent = 'Войти в систему';
        }
    }

    async function requestPasswordReset() {
        hideMessages();
        var email = resetEmailInput.value.trim();

        if (!email) { showError('Введите email учетной записи.'); return; }

        resetRequestBtn.disabled = true;
        resetRequestBtn.textContent = 'Отправляем...';

        try {
            var res = await callAPI('ВосстановитьПароль', {
                Email: email,
                Устройство: navigator.platform || 'Browser',
                Браузер: navigator.userAgent || 'Unknown'
            }, false);

            if (!res || !res.success) {
                showError(res && res.message ? res.message : 'Не удалось отправить запрос восстановления.');
                return;
            }

            var row = (Array.isArray(res.data) && res.data[0]) ? res.data[0] : {};
            if (row['Успешно'] !== undefined && Number(row['Успешно']) !== 1) {
                showError(row['Сообщение'] || res.message || 'Не удалось отправить запрос восстановления.');
                return;
            }

            showSuccess(row['Сообщение'] || res.message || 'Если учетная запись существует, ссылка отправлена на email.');
        } catch (err) {
            showError('Ошибка соединения. Проверьте подключение к сети.');
            console.error(err);
        } finally {
            resetRequestBtn.disabled = false;
            resetRequestBtn.textContent = 'Отправить ссылку';
        }
    }

    async function confirmPasswordReset() {
        hideMessages();
        var newPassword = newPasswordInput.value;
        var confirmPassword = confirmPasswordInput.value;

        if (!resetToken) { showError('Ссылка восстановления недействительна. Запросите новую ссылку.'); return; }
        if (!newPassword || !confirmPassword) { showError('Введите и повторите новый пароль.'); return; }
        if (newPassword !== confirmPassword) { showError('Пароли не совпадают.'); return; }

        resetConfirmBtn.disabled = true;
        resetConfirmBtn.textContent = 'Сохраняем...';

        try {
            var res = await callAPI('ПодтвердитьВосстановлениеПароля', {
                Токен: resetToken,
                НовыйПароль: newPassword
            }, false);

            var row = (Array.isArray(res.data) && res.data[0]) ? res.data[0] : {};
            if (!res || !res.success || (row['Успешно'] !== undefined && Number(row['Успешно']) !== 1)) {
                showError(row['Сообщение'] || res.message || 'Не удалось изменить пароль.');
                return;
            }

            resetToken = '';
            newPasswordInput.value = '';
            confirmPasswordInput.value = '';
            if (window.history && window.history.replaceState) {
                window.history.replaceState({}, document.title, '/ais-system-ru/login/index.php');
            }
            showPanel('login');
            showSuccess(row['Сообщение'] || 'Пароль успешно изменён. Войдите с новым паролем.');
        } catch (err) {
            showError('Ошибка соединения. Проверьте подключение к сети.');
            console.error(err);
        } finally {
            resetConfirmBtn.disabled = false;
            resetConfirmBtn.textContent = 'Сохранить новый пароль';
        }
    }

    loginBtn.addEventListener('click', doLogin);
    forgotLink.addEventListener('click', function(){ showPanel('request'); });
    resetRequestBtn.addEventListener('click', requestPasswordReset);
    resetConfirmBtn.addEventListener('click', confirmPasswordReset);
    backToLoginFromRequest.addEventListener('click', function(){ showPanel('login'); });
    backToLoginFromConfirm.addEventListener('click', function(){
        resetToken = '';
        if (window.history && window.history.replaceState) {
            window.history.replaceState({}, document.title, '/ais-system-ru/login/index.php');
        }
        showPanel('login');
    });
    pwInput.addEventListener('keydown',    function(e){ if(e.key==='Enter') doLogin(); });
    loginInput.addEventListener('keydown', function(e){ if(e.key==='Enter') pwInput.focus(); });
    resetEmailInput.addEventListener('keydown', function(e){ if(e.key==='Enter') requestPasswordReset(); });
    confirmPasswordInput.addEventListener('keydown', function(e){ if(e.key==='Enter') confirmPasswordReset(); });
    newPasswordInput.addEventListener('keydown', function(e){ if(e.key==='Enter') confirmPasswordInput.focus(); });

    if (resetToken) {
        showPanel('confirm');
    }
}());
</script>
</body>
</html>

