<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Студент');
$page_title = 'Профиль';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div class="page-title">Профиль</div>
</div>

<div class="alert alert-ok"  id="save-success" style="display:none"></div>
<div class="alert alert-err" id="save-error"   style="display:none"></div>

<div class="grid-2" style="max-width:840px" id="profile-grid">
    <div class="card" id="info-card" style="display:none">
        <div class="card-hdr"><span class="card-title">Личные данные</span></div>
        <div class="card-body">
            <div style="display:flex;align-items:center;gap:16px;margin-bottom:20px">
                <div class="avatar avatar-lg" id="profile-avatar" style="width:64px;height:64px;font-size:22px"></div>
                <div>
                    <div class="font-bold" id="profile-name" style="font-size:16px"></div>
                    <div class="text-muted" id="profile-login-group"></div>
                    <span class="role-tag role-student" style="margin-top:4px;display:inline-block">Студент</span>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">ФИО</label>
                <input class="form-ctrl" id="field-fio" disabled>
            </div>
            <div class="form-group">
                <label class="form-label">Группа</label>
                <input class="form-ctrl" id="field-group" disabled>
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input class="form-ctrl" id="field-email" type="email" placeholder="email@example.com">
            </div>
            <div class="form-group">
                <label class="form-label">Телефон</label>
                <input class="form-ctrl" id="field-phone" type="tel" placeholder="+7 (000) 000-00-00">
            </div>
            <button class="btn btn-primary" id="save-btn">Сохранить изменения</button>
        </div>
    </div>

    <div class="card">
        <div class="card-hdr"><span class="card-title">Безопасность</span></div>
        <div class="card-body">
            <div class="form-group">
                <label class="form-label">Текущий пароль</label>
                <input type="password" class="form-ctrl" id="pw-current" placeholder="••••••••" autocomplete="current-password">
            </div>
            <div class="form-group">
                <label class="form-label">Новый пароль</label>
                <input type="password" class="form-ctrl" id="pw-new" placeholder="Минимум 6 символов" autocomplete="new-password">
            </div>
            <div class="form-group">
                <label class="form-label">Подтвердите пароль</label>
                <input type="password" class="form-ctrl" id="pw-confirm" placeholder="Повторите пароль" autocomplete="new-password">
            </div>
            <button class="btn btn-primary btn-block" id="pw-btn">Сменить пароль</button>
        </div>
    </div>
</div>

<div class="alert alert-info" id="loading" style="max-width:840px">Загрузка профиля...</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    function initials(name) {
        var parts = String(name||'').trim().split(/\s+/);
        var ini = '';
        parts.forEach(function(p){ if(p) ini += p[0].toUpperCase(); });
        return ini.slice(0,2) || '?';
    }

    function showMsg(type, msg) {
        document.getElementById('save-success').style.display = 'none';
        document.getElementById('save-error').style.display   = 'none';
        if (type === 'ok')  { document.getElementById('save-success').innerHTML = '✅ ' + msg; document.getElementById('save-success').style.display = 'flex'; }
        if (type === 'err') { document.getElementById('save-error').innerHTML   = '⚠️ ' + msg; document.getElementById('save-error').style.display   = 'flex'; }
        window.scrollTo(0,0);
    }

    async function loadProfile() {
        var userId = parseInt(localStorage.getItem('ais_user_id')||'0', 10);
        if (!userId) {
            var sess = await callAPI('ПроверитьСессию', {});
            if (sess && sess.success && sess.data && sess.data[0]) {
                userId = pick(sess.data[0], 'Пользователь_ID', 'user_id') || 0;
                if (userId) localStorage.setItem('ais_user_id', userId);
            }
        }

        var r = await callAPI('ПолучитьПользователяПоID', { Пользователь_ID: userId });

        document.getElementById('loading').style.display = 'none';
        document.getElementById('info-card').style.display = '';

        if (!r || !r.success || !r.data || !r.data[0]) return;
        var d = r.data[0];

        var fio   = pick(d,'ФИО','Имя') || '';
        var login = pick(d,'Логин','login') || '';
        var group = pick(d,'Группа','Название_Группы') || '';
        var email = pick(d,'Email','Почта') || '';
        var phone = pick(d,'Телефон','Мобильный') || '';

        document.getElementById('profile-avatar').textContent      = initials(fio);
        document.getElementById('profile-name').textContent        = fio;
        document.getElementById('profile-login-group').textContent = login + (group ? ' · ' + group : '');
        document.getElementById('field-fio').value                 = fio;
        document.getElementById('field-group').value               = group;
        document.getElementById('field-email').value               = email;
        document.getElementById('field-phone').value               = phone;
    }

    document.getElementById('save-btn').addEventListener('click', async function () {
        var btn = this;
        btn.disabled = true;
        var userId = parseInt(localStorage.getItem('ais_user_id')||'0', 10);
        // ОбновитьПользователя: Пользователь_ID, Email, Телефон, КтоОбновил
        var r = await callAPI('ОбновитьПользователя', {
            Пользователь_ID: userId,
            Email:           document.getElementById('field-email').value.trim(),
            Телефон:         document.getElementById('field-phone').value.trim() || null,
            КтоОбновил:      userId,
        }).catch(function(e){ return {success:false,message:e.message}; });
        btn.disabled = false;
        if (r && r.success) showMsg('ok', 'Данные сохранены.');
        else showMsg('err', r && r.message ? r.message : 'Ошибка сохранения.');
    });

    document.getElementById('pw-btn').addEventListener('click', async function () {
        var btn = this;
        var curr    = document.getElementById('pw-current').value;
        var newPw   = document.getElementById('pw-new').value;
        var confirm = document.getElementById('pw-confirm').value;
        if (!curr || !newPw) { showMsg('err', 'Введите текущий и новый пароль.'); return; }
        if (newPw.length < 6) { showMsg('err', 'Новый пароль должен содержать минимум 6 символов.'); return; }
        if (newPw !== confirm) { showMsg('err', 'Пароли не совпадают.'); return; }
        btn.disabled = true;
        var userId = parseInt(localStorage.getItem('ais_user_id')||'0', 10);
        // ОбновитьПарольПользователя: Пользователь_ID, НовыйПароль, КтоОбновил
        var r = await callAPI('ОбновитьПарольПользователя', {
            Пользователь_ID: userId,
            НовыйПароль:     newPw,
            КтоОбновил:      userId,
        }).catch(function(e){ return {success:false,message:e.message}; });
        btn.disabled = false;
        document.getElementById('pw-current').value = '';
        document.getElementById('pw-new').value     = '';
        document.getElementById('pw-confirm').value = '';
        if (r && r.success) showMsg('ok', 'Пароль успешно изменён.');
        else showMsg('err', r && r.message ? r.message : 'Ошибка смены пароля.');
    });

    loadProfile();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

