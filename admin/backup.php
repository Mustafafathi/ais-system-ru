<?php
declare(strict_types=1);
require_once __DIR__ . '/../includes/auth_check.php';
requireRole('Admin');
$page_title = 'Резервные копии';
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/nav.php';
?>

<div class="page-hdr">
    <div>
        <div class="page-title">Резервные копии</div>
        <div class="page-sub">Управление резервным копированием базы данных</div>
    </div>
</div>

<div class="grid-2 backup-layout">

    <!-- Create backup -->
    <div class="card">
        <div class="card-hdr"><span class="card-title">Создать резервную копию</span></div>
        <div class="card-body">
            <p class="backup-help">
                Создаёт полную резервную копию базы данных «Улучшенная» на сервере SQL Server.
            </p>
            <div class="form-group">
                <label class="form-label">Описание (необязательно)</label>
                <input class="form-ctrl" id="backup-desc" placeholder="Плановое резервирование...">
            </div>
            <div class="alert alert-ok"  id="create-ok"  style="display:none"></div>
            <div class="alert alert-err" id="create-err" style="display:none"></div>
            <button class="btn btn-primary btn-block" id="create-btn">Создать копию</button>
        </div>
    </div>

    <!-- Backup list -->
    <div class="card">
        <div class="card-hdr">
            <span class="card-title">История копий</span>
            <button class="btn btn-ghost btn-sm" id="refresh-btn">Обновить</button>
        </div>
        <div class="card-body" id="backup-list">
            <div class="alert alert-info">Загрузка...</div>
        </div>
    </div>

</div>

<script>
(function () {
    'use strict';
    function esc(s) { return String(s||'').replace(/[&<>"']/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];}); }
    function pick(obj) { for(var i=1;i<arguments.length;i++){if(obj&&obj[arguments[i]]!==undefined&&obj[arguments[i]]!==null)return obj[arguments[i]];} return null; }

    async function currentUserId() {
        var id = parseInt(localStorage.getItem('ais_user_id') || '0', 10);
        if (id) return id;
        var sess = await callAPI('ПроверитьСессию', {});
        var row = sess && sess.success && sess.data && sess.data[0] ? sess.data[0] : {};
        id = pick(row, 'Пользователь_ID', 'user_id') || 0;
        if (id) localStorage.setItem('ais_user_id', id);
        return id;
    }

    async function loadList() {
        var body = document.getElementById('backup-list');
        body.innerHTML = '<div class="alert alert-info">Загрузка...</div>';

        try {
            var r = await callAPI('ПолучитьСписокБэкапов', {});

            if (!r || !r.success) {
                body.innerHTML = '<div class="alert alert-err">Ошибка загрузки.</div>'; return;
            }

            var rows = Array.isArray(r.data) ? r.data : [];
            if (rows.length === 0) {
                body.innerHTML = '<div class="empty-state"><div class="empty-icon">BK</div><div class="empty-title">Копий пока нет</div></div>';
                return;
            }

            var html = '<div class="cap-list backup-history-list">';
            rows.forEach(function(row) {
                var name = pick(row,'Имя','Файл','name','Название_Файла') || '—';
                var date = pick(row,'Дата','created_at','Дата_Создания') || '';
                var size = pick(row,'Размер','size','Размер_МБ','Размер_Файла_MB') || '';
                var status = pick(row,'Статус') || 'OK';
                var d = date ? new Date(date) : null;
                var ageDays = d && !Number.isNaN(d.getTime()) ? Math.floor((Date.now() - d.getTime()) / 86400000) : null;
                var ageLabel = ageDays === null ? '' : (' · возраст: ' + ageDays + ' дн.');
                var severity = status;
                if (ageDays !== null && ageDays > 7) severity = 'Внимание';

                html += '<div class="cap-list-row backup-history-row">';
                html += '<div class="cap-list-main backup-history-main">';
                html += '<strong>' + esc(name) + '</strong>';
                html += '<div class="list-meta">' + esc(date) + (size ? ' · ' + esc(String(size)) : '') + esc(ageLabel) + '</div>';
                html += '</div>';
                html += (window.AISRoleUI ? window.AISRoleUI.badge(severity) : '<span class="badge b-muted">' + esc(status) + '</span>');
                html += '</div>';
            });
            html += '</div>';
            body.innerHTML = html;

        } catch(e) {
            body.innerHTML = '<div class="alert alert-err">Ошибка соединения.</div>';
        }
    }

    document.getElementById('create-btn').addEventListener('click', async function() {
        var btn   = this;
        var desc  = document.getElementById('backup-desc').value.trim();
        var okEl  = document.getElementById('create-ok');
        var errEl = document.getElementById('create-err');
        okEl.style.display = 'none'; errEl.style.display = 'none';
        btn.disabled = true; btn.textContent = 'Создание копии...';

        try {
            // СоздатьРезервнуюКопию: Тип_Копии, Название_Файла, Путь_Хранения, КтоСоздал
            var userId   = await currentUserId();
            var ts       = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
            var fileName = 'backup_' + ts + '.bak';
            var r = await callAPI('СоздатьРезервнуюКопию', {
                Тип_Копии:     'Полная',
                Название_Файла: fileName,
                Путь_Хранения: 'C:\\Backups\\AIS\\' + fileName,
                КтоСоздал:     userId
            });
            if (r && r.success) {
                var bname = r.data && r.data[0] ? (pick(r.data[0],'Имя','Файл','name','Название_Файла') || '') : '';
                okEl.textContent = 'Резервная копия создана.' + (bname ? ' Файл: ' + bname : '');
                okEl.style.display = 'flex';
                document.getElementById('backup-desc').value = '';
                loadList();
            } else {
                errEl.textContent = r && r.message ? r.message : 'Ошибка создания.';
                errEl.style.display = 'flex';
            }
        } catch(e) {
            errEl.textContent = 'Ошибка соединения.'; errEl.style.display = 'flex';
        } finally {
            btn.disabled = false; btn.textContent = 'Создать копию';
        }
    });

    document.getElementById('refresh-btn').addEventListener('click', loadList);
    loadList();
}());
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>

