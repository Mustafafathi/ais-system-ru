<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Профиль';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Мой профиль</div>
        <div class="page-sub">Личные данные и настройки аккаунта</div>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка профиля...</div>
<div class="alert alert-err"  id="load-error" style="display:none"></div>

<div id="profile-wrap" style="display:none;max-width:780px">
    <div class="grid-2" style="align-items:start">

        <div class="card">
            <div class="card-hdr"><span class="card-title">Личные данные</span></div>
            <div class="card-body">
                <div style="display:flex;align-items:center;gap:16px;margin-bottom:20px">
                    <div class="avatar avatar-lg" id="prof-avatar" style="width:64px;height:64px;font-size:24px;border-radius:50%;background:var(--c-admin,#dc2626)"></div>
                    <div>
                        <div style="font-weight:700;font-size:18px" id="prof-name"></div>
                        <div style="color:var(--c-muted);font-size:13px">Администратор</div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Логин</label>
                    <div id="prof-login" class="form-static">—</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input class="form-ctrl" id="prof-email" type="email" placeholder="email@example.com">
                </div>
                <div class="form-group">
                    <label class="form-label">Телефон</label>
                    <input class="form-ctrl" id="prof-phone" type="tel" placeholder="+7 (___) ___-__-__">
                </div>
                <div class="alert alert-ok"  id="save-ok"  style="display:none"></div>
                <div class="alert alert-err" id="save-err" style="display:none"></div>
                <button class="btn btn-primary btn-block" id="save-btn">Сохранить изменения</button>
            </div>
        </div>

        <div class="card">
            <div class="card-hdr"><span class="card-title">Смена пароля</span></div>
            <div class="card-body">
                <div class="form-group">
                    <label class="form-label">Текущий пароль</label>
                    <input class="form-ctrl" id="pw-current" type="password" placeholder="Введите текущий пароль">
                </div>
                <div class="form-group">
                    <label class="form-label">Новый пароль</label>
                    <input class="form-ctrl" id="pw-new" type="password" placeholder="Минимум 6 символов">
                </div>
                <div class="form-group">
                    <label class="form-label">Подтверждение</label>
                    <input class="form-ctrl" id="pw-confirm" type="password" placeholder="Повторите новый пароль">
                </div>
                <div class="alert alert-ok"  id="pw-ok"  style="display:none"></div>
                <div class="alert alert-err" id="pw-err" style="display:none"></div>
                <button class="btn btn-outline btn-block" id="pw-btn">Изменить пароль</button>
            </div>
        </div>

    </div>
</div>

<script>
(function () {
    'use strict';
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var userId = 0;

    async function loadProfile() {
        try {
            var sess = await callAPI('ПроверитьСессию', {});
            if (!sess || !sess.success || !sess.data || !sess.data[0]) return;
            userId = pick(sess.data[0],'Пользователь_ID','user_id') || 0;

            var r = await callAPI('ПолучитьПользователяПоID', { Пользователь_ID: userId });
            document.getElementById('loading').style.display = 'none';

            if (!r || !r.success || !r.data || !r.data[0]) {
                document.getElementById('load-error').textContent = '⚠️ Не удалось загрузить профиль.';
                document.getElementById('load-error').style.display = 'flex'; return;
            }

            var d = r.data[0];
            var fio   = pick(d,'ФИО','Имя','Полное_Имя') || '';
            var login = pick(d,'Логин','login') || '';
            var email = pick(d,'Email','email') || '';
            var phone = pick(d,'Телефон','phone') || '';

            var ini = fio.split(' ').map(function(p){return p?p[0].toUpperCase():''}).join('').slice(0,2) || 'A';
            document.getElementById('prof-avatar').textContent = ini;
            document.getElementById('prof-name').textContent   = fio;
            document.getElementById('prof-login').textContent  = login;
            document.getElementById('prof-email').value = email;
            document.getElementById('prof-phone').value = phone;

            document.getElementById('profile-wrap').style.display = '';
        } catch(e) {
            console.error(e);
            document.getElementById('loading').style.display = 'none';
            document.getElementById('load-error').textContent = '⚠️ Ошибка соединения.';
            document.getElementById('load-error').style.display = 'flex';
        }
    }

    document.getElementById('save-btn').addEventListener('click', async function() {
        var btn = this;
        var okEl  = document.getElementById('save-ok');
        var errEl = document.getElementById('save-err');
        okEl.style.display = 'none'; errEl.style.display = 'none';
        btn.disabled = true; btn.textContent = 'Сохранение...';
        try {
            // ОбновитьПользователя: Пользователь_ID, Email, Телефон, КтоОбновил
            var r = await callAPI('ОбновитьПользователя', {
                Пользователь_ID: userId,
                Email:           document.getElementById('prof-email').value.trim(),
                Телефон:         document.getElementById('prof-phone').value.trim() || null,
                КтоОбновил:      userId,
            });
            if (r && r.success) { okEl.textContent = '✅ Данные сохранены.'; okEl.style.display = 'flex'; }
            else { errEl.textContent = '⚠️ ' + (r && r.message ? r.message : 'Ошибка.'); errEl.style.display = 'flex'; }
        } catch(e) { errEl.textContent = '⚠️ Ошибка соединения.'; errEl.style.display = 'flex'; }
        finally { btn.disabled = false; btn.textContent = 'Сохранить изменения'; }
    });

    document.getElementById('pw-btn').addEventListener('click', async function() {
        var btn = this;
        var okEl  = document.getElementById('pw-ok');
        var errEl = document.getElementById('pw-err');
        okEl.style.display = 'none'; errEl.style.display = 'none';
        var current = document.getElementById('pw-current').value;
        var newPw   = document.getElementById('pw-new').value;
        var confirm = document.getElementById('pw-confirm').value;
        if (!current) { errEl.textContent = '⚠️ Введите текущий пароль.'; errEl.style.display = 'flex'; return; }
        if (newPw.length < 6) { errEl.textContent = '⚠️ Минимум 6 символов.'; errEl.style.display = 'flex'; return; }
        if (newPw !== confirm) { errEl.textContent = '⚠️ Пароли не совпадают.'; errEl.style.display = 'flex'; return; }
        btn.disabled = true; btn.textContent = 'Изменение...';
        try {
            // ОбновитьПарольПользователя: Пользователь_ID, НовыйПароль, КтоОбновил
            var r = await callAPI('ОбновитьПарольПользователя', { Пользователь_ID: userId, НовыйПароль: newPw, КтоОбновил: userId });
            if (r && r.success) {
                okEl.textContent = '✅ Пароль изменён.'; okEl.style.display = 'flex';
                document.getElementById('pw-current').value = '';
                document.getElementById('pw-new').value = '';
                document.getElementById('pw-confirm').value = '';
            } else { errEl.textContent = '⚠️ ' + (r && r.message ? r.message : 'Ошибка.'); errEl.style.display = 'flex'; }
        } catch(e) { errEl.textContent = '⚠️ Ошибка соединения.'; errEl.style.display = 'flex'; }
        finally { btn.disabled = false; btn.textContent = 'Изменить пароль'; }
    });

    loadProfile();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

