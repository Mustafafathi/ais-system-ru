<?php
declare(strict_types=1);
require_once __DIR__ . '/includes/auth_check.php';
$page_title = 'Уведомления';
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Уведомления</div>
        <div class="page-sub" id="notif-sub">Загрузка...</div>
    </div>
    <div class="page-actions">
        <button class="btn btn-ghost btn-sm" id="read-all-btn">Прочитать все</button>
    </div>
</div>

<div class="alert alert-info" id="loading">Загрузка уведомлений...</div>
<div class="alert alert-err" id="error" style="display:none"></div>
<div class="alert alert-ok" id="result" style="display:none"></div>

<div class="card" id="notif-card" style="display:none">
    <div class="card-body" style="padding:0 20px" id="notif-list"></div>
</div>

<div class="empty-state" id="empty" style="display:none">
    <div class="empty-icon">N</div>
    <div class="empty-title">Нет уведомлений</div>
    <div class="empty-sub">Все уведомления прочитаны</div>
</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    var userId = parseInt(localStorage.getItem('ais_user_id')||'0', 10);

    function dotColor(type) {
        if (!type) return 'var(--c-muted)';
        type = type.toLowerCase();
        if (type.includes('порог') || type.includes('warn')) return 'var(--c-warn)';
        if (type.includes('одобр') || type.includes('ok')) return 'var(--c-ok)';
        if (type.includes('откло') || type.includes('err')) return 'var(--c-err)';
        return 'var(--c-info)';
    }

    async function resolveUserId() {
        if (userId) return userId;
        var sess = await callAPI('ПроверитьСессию', {});
        if (sess && sess.success && sess.data && sess.data[0]) {
            userId = pick(sess.data[0], 'Пользователь_ID', 'user_id') || 0;
            if (userId) localStorage.setItem('ais_user_id', userId);
        }
        return userId;
    }

    async function load() {
        document.getElementById('loading').style.display = 'flex';
        document.getElementById('error').style.display = 'none';
        document.getElementById('result').style.display = 'none';
        document.getElementById('empty').style.display = 'none';
        document.getElementById('notif-card').style.display = 'none';

        try {
            await resolveUserId();
            if (!userId) {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('error').textContent = 'Пользователь не определён. Войдите в систему заново.';
                document.getElementById('error').style.display = 'flex';
                return;
            }

            var r = await callAPI('ПолучитьУведомленияПользователя', {
                Пользователь_ID: userId,
                Лимит: 50
            });

            document.getElementById('loading').style.display = 'none';

            if (!r || !r.success) {
                document.getElementById('error').textContent = r && r.message ? r.message : 'Ошибка загрузки';
                document.getElementById('error').style.display = 'flex';
                return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];
            var unread = rows.filter(function(row){ return !pick(row,'Прочитано','Прочитано_Флаг'); }).length;
            document.getElementById('notif-sub').textContent = rows.length + ' уведомлений' + (unread > 0 ? ' · ' + unread + ' непрочитанных' : '');

            if (rows.length === 0) {
                document.getElementById('empty').style.display = 'block';
                return;
            }

            var html = '';
            rows.forEach(function(row) {
                var title = pick(row,'Заголовок','Название','title') || 'Уведомление';
                var msg = pick(row,'Сообщение','Текст','message') || '';
                var time = pick(row,'Дата_Создания','Время','created_at') || '';
                var read = pick(row,'Прочитано','read_flag');
                var type = pick(row,'Тип','type') || '';
                var isUnread = !read || parseInt(read,10) === 0;

                html += '<div class="notif-item' + (isUnread ? ' unread' : '') + '">';
                html += '<div class="notif-dot-big" style="background:' + dotColor(type) + ';flex-shrink:0"></div>';
                html += '<div class="notif-body">';
                html += '<div class="notif-title">' + esc(title) + '</div>';
                html += '<div class="notif-msg">' + esc(msg) + '</div>';
                html += '<div class="notif-time">' + esc(time) + '</div>';
                html += '</div></div>';
            });

            document.getElementById('notif-list').innerHTML = html;
            document.getElementById('notif-card').style.display = '';
        } catch(err) {
            console.error(err);
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').textContent = 'Ошибка соединения.';
            document.getElementById('error').style.display = 'flex';
        }
    }

    document.getElementById('read-all-btn').addEventListener('click', async function () {
        var btn = this;
        btn.disabled = true;
        document.getElementById('error').style.display = 'none';
        document.getElementById('result').style.display = 'none';
        try {
            await resolveUserId();
            if (!userId) return;
            var r = await callAPI('ПометитьУведомленияПрочитанными', { Пользователь_ID: userId });
            if (!r || !r.success) {
                document.getElementById('error').textContent = r && r.message ? r.message : 'Не удалось отметить уведомления.';
                document.getElementById('error').style.display = 'flex';
                return;
            }
            document.querySelectorAll('.notif-item.unread').forEach(function(el){ el.classList.remove('unread'); });
            document.getElementById('notif-sub').textContent = document.querySelectorAll('.notif-item').length + ' уведомлений';
            document.getElementById('result').textContent = 'Уведомления отмечены как прочитанные.';
            document.getElementById('result').style.display = 'flex';
            var dot = document.getElementById('notif-dot');
            if (dot) dot.style.display = 'none';
        } catch (err) {
            document.getElementById('error').textContent = 'Ошибка соединения.';
            document.getElementById('error').style.display = 'flex';
        } finally {
            btn.disabled = false;
        }
    });

    load();
}());
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>

