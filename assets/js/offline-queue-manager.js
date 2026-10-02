document.addEventListener('DOMContentLoaded', () => {
  const tableBody = document.querySelector('#queue-table tbody');
  const btnFlush = document.getElementById('btn-flush');
  const btnRefresh = document.getElementById('btn-refresh');
  const msg = document.getElementById('queue-msg');

  async function loadQueue() {
    tableBody.innerHTML = '';
    msg.innerHTML = '';
    try {
      const list = await OfflineQueue.getAll();
      if (!list || list.length === 0) {
        msg.innerHTML = '<div class="alert alert-info">Очередь пуста</div>';
        return;
      }
        list.forEach((r, idx) => {
        const tr = document.createElement('tr');
        const paramsStr = typeof r.params === 'object' ? JSON.stringify(r.params, null, 0) : String(r.params || '');
        tr.innerHTML = `
          <td>${idx+1}</td>
          <td>${escapeHtml(r.action)}</td>
          <td><pre style="white-space:pre-wrap; max-width:400px">${escapeHtml(paramsStr)}</pre></td>
          <td>${escapeHtml(r.idempotency_key || '')}</td>
          <td>${escapeHtml(String(r.schema_version || 1))}</td>
          <td><code style="font-size:12px">${escapeHtml(r.session_id || '—')}</code></td>
          <td>${r.token ? '<span class="badge b-ok">Да</span>' : '<span class="badge b-muted">Нет</span>'}</td>
          <td>${escapeHtml(r.timestamp || '')}</td>
          <td>
            <button class="btn btn-sm btn-outline btn-retry">Отправить</button>
            <button class="btn btn-sm btn-danger btn-remove">Удалить</button>
          </td>
        `;
        tableBody.appendChild(tr);

        tr.querySelector('.btn-remove').addEventListener('click', async () => {
          const ok = confirm('Удалить запрос из очереди?');
          if (!ok) return;
          await OfflineQueue.remove(r.id);
          await loadQueue();
          showToast('Запрос удалён', 'info');
        });

        tr.querySelector('.btn-retry').addEventListener('click', async () => {
          try {
            showToast('Отправка...', 'info');
            const resp = await fetch('/ais-system-ru/offline-handler.php', {
              method: 'POST',
              headers: {'Content-Type':'application/json'},
              body: JSON.stringify({ requests: [r] })
            });
            const j = await resp.json();
            if (j.success && j.results && j.results[0] && j.results[0].success) {
              await OfflineQueue.remove(r.id);
              await loadQueue();
              showToast('Успешно отправлено', 'ok');
            } else {
              showToast('Не удалось отправить: ' + (j.results && j.results[0] && j.results[0].message ? j.results[0].message : j.message || 'ошибка'), 'err');
            }
          } catch (e) {
            showToast('Ошибка: ' + e.message, 'err');
          }
        });
      });
    } catch (e) {
      msg.innerHTML = `<div class="alert alert-err">Ошибка загрузки: ${escapeHtml(e.message)}</div>`;
    }
  }

  btnFlush.addEventListener('click', async () => {
    if (!confirm('Отправить все запросы из очереди сейчас?')) return;
    try {
      showToast('Отправка очереди...', 'info');
      const result = await OfflineQueue.flush();
      if (result && result.success) {
        await loadQueue();
        showToast('Очередь обработана', 'ok');
      } else {
        showToast('Ошибка при отправке очереди', 'err');
      }
    } catch (e) {
      showToast('Ошибка: ' + e.message, 'err');
    }
  });

  btnRefresh.addEventListener('click', async () => loadQueue());

  function escapeHtml(text) { if (!text) return ''; return String(text).replace(/[&<>"]+/g, function(m){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]; }); }

  loadQueue();
});

