/* OfflineQueue wrapper — uses existing common.js IndexedDB helpers
   Provides a small class API for pages to enqueue and flush requests.
*/
(function(window){
  class OfflineQueue {
    static async enqueue(action, params = {}, useAuth = true) {
      const builder = window.AISOfflineRequest && typeof window.AISOfflineRequest.buildRequest === 'function'
        ? window.AISOfflineRequest.buildRequest
        : null;
      const request = builder
        ? await builder(action, params, useAuth)
        : {
            id: Date.now() + '_' + Math.random().toString(36).substr(2,8),
            schema_version: 1,
            action,
            params,
            session_id: useAuth && typeof getSessionId === 'function' ? getSessionId() : null,
            token: useAuth && typeof getToken === 'function' ? getToken() : null,
            timestamp: new Date().toISOString(),
            idempotency_key: 'k_' + Date.now() + '_' + Math.random().toString(36).substr(2,8)
          };

      if (typeof saveOfflineRequest === 'function') {
        await saveOfflineRequest(request);
        return request;
      }

      // fallback localStorage
      let q = JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
      q.push(request);
      localStorage.setItem('ais_offline_queue', JSON.stringify(q));
      return request;
    }

    static async getAll() {
      if (typeof getAllOfflineRequests === 'function') return await getAllOfflineRequests();
      return JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
    }

    static async count() {
      const arr = await OfflineQueue.getAll();
      return arr.length;
    }

    static async flush() {
      if (typeof flushOfflineQueue === 'function') return await flushOfflineQueue();
      // fallback: try to POST to offline handler
      if (!navigator.onLine) throw new Error('Нет подключения');
      const queue = JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
      if (queue.length === 0) return { success: true, results: [] };
      const resp = await fetch('/ais-system-ru/offline-handler.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requests: queue })
      });
      const data = await resp.json();
      if (data.success && Array.isArray(data.results)) {
        const succeeded = new Set(data.results.filter(r => r && r.success).map(r => r.original_index));
        const remaining = queue.filter((_, idx) => !succeeded.has(idx));
        localStorage.setItem('ais_offline_queue', JSON.stringify(remaining));
      } else if (data.success) {
        localStorage.removeItem('ais_offline_queue');
      }
      return data;
    }

    static async remove(id) {
      if (typeof removeOfflineRequest === 'function') return await removeOfflineRequest(id);
      let q = JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
      q = q.filter(r => r.id !== id);
      localStorage.setItem('ais_offline_queue', JSON.stringify(q));
      return true;
    }

    static async generateIdempotencyKey(clientId, action, payload, ts) {
      if (window.AISOfflineRequest && typeof window.AISOfflineRequest.generateIdempotencyKey === 'function') {
        return await window.AISOfflineRequest.generateIdempotencyKey(clientId, action, payload, ts);
      }
      const s = `${clientId}|${action}|${JSON.stringify(payload)}|${ts}`;
      if (window.crypto && crypto.subtle) {
        const enc = new TextEncoder().encode(s);
        const hash = await crypto.subtle.digest('SHA-256', enc);
        return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2,'0')).join('');
      }
      let h = 0;
      for (let i=0;i<s.length;i++) { h = ((h<<5)-h) + s.charCodeAt(i); h |= 0; }
      return 'h' + Math.abs(h).toString(16);
    }
  }

  window.OfflineQueue = OfflineQueue;
})(window);

