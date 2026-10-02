/**
 * Общие функции для работы с API, токенами, сессиями и сетью
 * Используется во всех страницах системы
 */

// ------------------------------------------------------------------
// КЛЮЧИ ДЛЯ ХРАНЕНИЯ В localStorage
// ------------------------------------------------------------------
const STORAGE_KEYS = {
    SESSION_ID: 'ais_session_id',
    TOKEN: 'ais_token',
    USER_ROLE: 'ais_user_role',
    USER_NAME: 'ais_user_name'
};

// ------------------------------------------------------------------
// БАЗОВЫЙ URL API (можно переопределить при необходимости)
// ------------------------------------------------------------------
const API_URL = '/ais-system-ru/api.php';
const OFFLINE_HANDLER_URL = '/ais-system-ru/offline-handler.php';

// ------------------------------------------------------------------
// СОХРАНЕНИЕ ДАННЫХ СЕССИИ
// ------------------------------------------------------------------
function saveSessionData(sessionId, token, role = null, userName = null) {
    if (sessionId) localStorage.setItem(STORAGE_KEYS.SESSION_ID, sessionId);
    if (token) localStorage.setItem(STORAGE_KEYS.TOKEN, token);
    if (role) localStorage.setItem(STORAGE_KEYS.USER_ROLE, role);
    if (userName) localStorage.setItem(STORAGE_KEYS.USER_NAME, userName);
}

// ------------------------------------------------------------------
// ПОЛУЧЕНИЕ ДАННЫХ СЕССИИ
// ------------------------------------------------------------------
function getSessionId() {
    return localStorage.getItem(STORAGE_KEYS.SESSION_ID);
}

function getToken() {
    return localStorage.getItem(STORAGE_KEYS.TOKEN);
}

function getUserRole() {
    return localStorage.getItem(STORAGE_KEYS.USER_ROLE);
}

function getUserName() {
    return localStorage.getItem(STORAGE_KEYS.USER_NAME);
}

// ------------------------------------------------------------------
// ОЧИСТКА СЕССИИ (ВЫХОД)
// ------------------------------------------------------------------
function clearSessionData() {
    localStorage.removeItem(STORAGE_KEYS.SESSION_ID);
    localStorage.removeItem(STORAGE_KEYS.TOKEN);
    localStorage.removeItem(STORAGE_KEYS.USER_ROLE);
    localStorage.removeItem(STORAGE_KEYS.USER_NAME);
    localStorage.removeItem('ais_user_id');
    localStorage.removeItem('ais_student_id');
    localStorage.removeItem('ais_teacher_id');
    localStorage.removeItem('ais_group_id');
}

async function logout() {
    try {
        await fetch('/ais-system-ru/login/logout.php', {
            method: 'POST',
            headers: { 'Accept': 'application/json' },
            credentials: 'same-origin',
        });
    } catch (e) { /* нет сети — игнорируем */ }
    clearSessionData();
    window.location.href = '/ais-system-ru/login/index.php';
}

// ------------------------------------------------------------------
// ПРОВЕРКА СОСТОЯНИЯ СЕТИ (ONLINE/OFFLINE)
// ------------------------------------------------------------------
function isOnline() {
    return navigator.onLine;
}

function addNetworkListener(callback) {
    window.addEventListener('online', callback);
    window.addEventListener('offline', callback);
}

// ------------------------------------------------------------------
// ЕДИНАЯ СХЕМА OFFLINE-ЗАПРОСОВ
// ------------------------------------------------------------------
async function generateOfflineIdempotencyKey(clientId, action, payload, ts) {
    const s = `${clientId}|${action}|${JSON.stringify(payload)}|${ts}`;
    if (window.crypto && crypto.subtle) {
        const enc = new TextEncoder().encode(s);
        const hash = await crypto.subtle.digest('SHA-256', enc);
        return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2,'0')).join('');
    }

    let h = 0;
    for (let i = 0; i < s.length; i++) {
        h = ((h << 5) - h) + s.charCodeAt(i);
        h |= 0;
    }
    return 'h' + Math.abs(h).toString(16);
}

async function buildOfflineRequest(action, params = {}, useAuth = true, overrides = {}) {
    const timestamp = overrides.timestamp || new Date().toISOString();
    const sessionId = useAuth && typeof getSessionId === 'function' ? getSessionId() : null;
    const token = useAuth && typeof getToken === 'function' ? getToken() : null;
    const clientId = useAuth ? (sessionId || token || 'anon') : 'anon';
    const normalizedParams = (params && typeof params === 'object' && !Array.isArray(params)) ? params : {};

    const request = {
        id: overrides.id || (Date.now() + '_' + Math.random().toString(36).substr(2, 8)),
        schema_version: overrides.schema_version || 1,
        action: String(action || ''),
        params: normalizedParams,
        session_id: sessionId,
        token: token,
        timestamp: timestamp
    };

    request.idempotency_key = overrides.idempotency_key || await generateOfflineIdempotencyKey(clientId, request.action, normalizedParams, timestamp);
    return request;
}

window.AISOfflineRequest = {
    schemaVersion: 1,
    buildRequest: buildOfflineRequest,
    generateIdempotencyKey: generateOfflineIdempotencyKey
};

// ------------------------------------------------------------------
// ОСНОВНАЯ ФУНКЦИЯ ВЫЗОВА API
// ------------------------------------------------------------------
async function callAPI(action, params = {}, useAuth = true, options = {}) {
    const payload = { action, params };
    let authToken = null;
    
    if (useAuth) {
        const sessionId = getSessionId();
        const token = getToken();
        authToken = token;
        if (!sessionId || !token) {
            throw new Error('Нет активной сессии. Пожалуйста, войдите снова.');
        }
        payload.session_id = sessionId;
        payload.token = token;
    }
    
    const headers = {
        'Content-Type': 'application/json'
    };

    // Optional idempotency header
    if (options.idempotencyKey) {
        headers['Idempotency-Key'] = options.idempotencyKey;
    }

    // If we have a token, also set Authorization header (Bearer) to support servers that expect it
    if (authToken) {
        headers['Authorization'] = 'Bearer ' + authToken;
    }

    const requestOptions = {
        method: 'POST',
        headers,
        body: JSON.stringify(payload)
    };

    try {
        const response = await fetch(API_URL, requestOptions);
        const data = await response.json();

        // Обработка ошибок авторизации
        if (!data.success && (data.error_code === 401 || (data.message && (data.message.toLowerCase().includes('токен') || data.message.toLowerCase().includes('сесс'))))) {
            // Сессия недействительна — выходим
            clearSessionData();
            window.location.href = '/ais-system-ru/login/index.php?error=session_expired';
            throw new Error('Сессия истекла. Пожалуйста, войдите снова.');
        }

        return data;
    } catch (error) {
        console.error('Ошибка вызова API:', error);
        throw error;
    }
}

// ------------------------------------------------------------------
// ВЫЗОВ API С ПОДДЕРЖКОЙ ОФЛАЙН-РЕЖИМА
// ------------------------------------------------------------------
async function callAPIOfflineSupport(action, params = {}, useAuth = true) {
    // Если онлайн — вызываем напрямую, но с idempotency ключом
    if (isOnline()) {
        let idempotencyKey = null;
        try {
            const clientId = useAuth ? (getSessionId() || getToken() || 'anon') : 'anon';
            const ts = new Date().toISOString();
            if (window.AISOfflineRequest && typeof window.AISOfflineRequest.generateIdempotencyKey === 'function') {
                idempotencyKey = await window.AISOfflineRequest.generateIdempotencyKey(clientId, action, params, ts);
            } else {
                idempotencyKey = await generateOfflineIdempotencyKey(clientId, action, params, ts);
            }
        } catch (e) {
            idempotencyKey = 'k_' + Date.now() + '_' + Math.random().toString(36).substr(2,8);
        }

        return await callAPI(action, params, useAuth, { idempotencyKey });
    }

    // Если офлайн — используем OfflineQueue.enqueue (предпочтительно) или fallback
    try {
        if (typeof OfflineQueue !== 'undefined' && typeof OfflineQueue.enqueue === 'function') {
            const req = await OfflineQueue.enqueue(action, params, useAuth);
            return {
                success: false,
                offline: true,
                message: 'Нет подключения к сети. Запрос сохранён и будет отправлен автоматически при восстановлении связи.',
                queued_id: req.id,
                idempotency_key: req.idempotency_key
            };
        }
    } catch (e) {
        console.warn('Offline enqueue failed:', e);
    }

    // Fallback: old behavior using saveOfflineRequest
    const queuedRequest = await buildOfflineRequest(action, params, useAuth);
    await saveOfflineRequest(queuedRequest);

    // Возвращаем специальный объект, указывающий, что запрос сохранён
    return {
        success: false,
        offline: true,
        message: 'Нет подключения к сети. Запрос сохранён и будет отправлен автоматически при восстановлении связи.',
        queued_id: queuedRequest.id,
        idempotency_key: queuedRequest.idempotency_key
    };
}

// ------------------------------------------------------------------
// РАБОТА С ОЧЕРЕДЬЮ ОФЛАЙН-ЗАПРОСОВ (IndexedDB)
// ------------------------------------------------------------------
let db = null;
const DB_NAME = 'AIS_OfflineQueue';
const DB_VERSION = 2;
const STORE_NAME = 'requests';

function openOfflineDB() {
    return new Promise((resolve, reject) => {
        if (db && db.name === DB_NAME) {
            resolve(db);
            return;
        }
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        request.onerror = () => reject(request.error);
        request.onsuccess = () => {
            db = request.result;
            resolve(db);
        };
        request.onupgradeneeded = (event) => {
            const dbUpgrade = event.target.result;
            if (!dbUpgrade.objectStoreNames.contains(STORE_NAME)) {
                const store = dbUpgrade.createObjectStore(STORE_NAME, { keyPath: 'id' });
                store.createIndex('timestamp', 'timestamp', { unique: false });
                store.createIndex('idempotency_key', 'idempotency_key', { unique: false });
            } else {
                const transaction = event.target.transaction;
                const store = transaction.objectStore(STORE_NAME);
                if (!store.indexNames.contains('idempotency_key')) {
                    store.createIndex('idempotency_key', 'idempotency_key', { unique: false });
                }
            }
        };
    });
}

async function saveOfflineRequest(request) {
    try {
        const existingRequests = await getAllOfflineRequests();
        if (request.idempotency_key && existingRequests.some(req => req && req.idempotency_key === request.idempotency_key)) {
            return true;
        }

        const database = await openOfflineDB();
        const transaction = database.transaction([STORE_NAME], 'readwrite');
        const store = transaction.objectStore(STORE_NAME);
        store.put(request);
        return new Promise((resolve, reject) => {
            transaction.oncomplete = () => resolve(true);
            transaction.onerror = () => reject(transaction.error);
        });
    } catch (e) {
        console.warn('IndexedDB недоступна, сохраняем в localStorage');
        // fallback на localStorage
        let fallbackQueue = JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
        if (request.idempotency_key && fallbackQueue.some(req => req && req.idempotency_key === request.idempotency_key)) {
            return true;
        }
        fallbackQueue.push(request);
        localStorage.setItem('ais_offline_queue', JSON.stringify(fallbackQueue));
        return true;
    }
}

async function getAllOfflineRequests() {
    try {
        const database = await openOfflineDB();
        const transaction = database.transaction([STORE_NAME], 'readonly');
        const store = transaction.objectStore(STORE_NAME);
        const requests = await new Promise((resolve, reject) => {
            const result = [];
            const cursor = store.openCursor();
            cursor.onsuccess = (event) => {
                const cur = event.target.result;
                if (cur) {
                    result.push(cur.value);
                    cur.continue();
                } else {
                    resolve(result);
                }
            };
            cursor.onerror = () => reject(cursor.error);
        });
        return requests;
    } catch (e) {
        // fallback localStorage
        return JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
    }
}

async function removeOfflineRequest(id) {
    try {
        const database = await openOfflineDB();
        const transaction = database.transaction([STORE_NAME], 'readwrite');
        const store = transaction.objectStore(STORE_NAME);
        store.delete(id);
        return new Promise((resolve, reject) => {
            transaction.oncomplete = () => resolve(true);
            transaction.onerror = () => reject(transaction.error);
        });
    } catch (e) {
        // fallback localStorage
        let queue = JSON.parse(localStorage.getItem('ais_offline_queue') || '[]');
        queue = queue.filter(req => req.id !== id);
        localStorage.setItem('ais_offline_queue', JSON.stringify(queue));
        return true;
    }
}

// ------------------------------------------------------------------
// ОТПРАВКА ВСЕХ СОХРАНЁННЫХ ОФЛАЙН-ЗАПРОСОВ
// ------------------------------------------------------------------
async function flushOfflineQueue() {
    if (!isOnline()) return { success: false, message: 'Нет подключения к сети' };
    
    let requests = await getAllOfflineRequests();
    if (requests.length === 0) return { success: true, message: 'Очередь пуста' };

    // Dedupe by idempotency_key on client side to reduce duplicate sends
    const unique = [];
    const seenKeys = new Set();
    for (const r of requests) {
        if (!r) continue;
        const key = r.idempotency_key || null;
        if (key) {
            if (seenKeys.has(key)) continue;
            seenKeys.add(key);
        }
        unique.push(r);
    }

    const results = [];
    for (const req of unique) {
        try {
            const response = await fetch(OFFLINE_HANDLER_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ requests: [req] })
            });
            const result = await response.json();
            if (result.success && result.results && result.results[0] && result.results[0].success) {
                // Успешно отправлено — удаляем из очереди
                await removeOfflineRequest(req.id);
                results.push({ id: req.id, success: true });
            } else {
                results.push({ id: req.id, success: false, error: result.message });
            }
        } catch (e) {
            results.push({ id: req.id, success: false, error: e.message });
        }
    }
    return { success: true, results };
}

// ------------------------------------------------------------------
// АВТОМАТИЧЕСКАЯ ОТПРАВКА ПРИ ВОССТАНОВЛЕНИИ СЕТИ
// ------------------------------------------------------------------
let flushScheduled = false;
function scheduleFlush() {
    if (flushScheduled) return;
    flushScheduled = true;
    setTimeout(async () => {
        if (isOnline()) {
            await flushOfflineQueue();
        }
        flushScheduled = false;
    }, 2000);
}

addNetworkListener(() => {
    if (isOnline()) {
        scheduleFlush();
    }
});

// ------------------------------------------------------------------
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ UI
// ------------------------------------------------------------------
function showToast(message, type = 'info') {
    // Простая реализация toast (можно заменить на красивую библиотеку)
    const toast = document.createElement('div');
    toast.className = `alert alert-${type}`;
    toast.style.position = 'fixed';
    toast.style.bottom = '20px';
    toast.style.right = '20px';
    toast.style.zIndex = '9999';
    toast.style.maxWidth = '300px';
    toast.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
    toast.innerText = message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

function showLoading(selector = '.app-main') {
    const container = document.querySelector(selector);
    if (!container) return;
    const loader = document.createElement('div');
    loader.className = 'loading-overlay';
    loader.innerHTML = '<div class="spinner"></div><div>Загрузка...</div>';
    loader.style.position = 'relative';
    loader.style.padding = '40px';
    loader.style.textAlign = 'center';
    // Если нужно затемнение — добавим стили
    container.style.opacity = '0.6';
    container.style.pointerEvents = 'none';
    const loaderElem = container.appendChild(loader);
    return () => {
        container.style.opacity = '';
        container.style.pointerEvents = '';
        if (loaderElem && loaderElem.parentNode) loaderElem.remove();
    };
}

// ------------------------------------------------------------------
// ГЛОБАЛЬНЫЕ НАСТРОЙКИ СИСТЕМЫ (AIS namespace)
// Значения берутся из localStorage (кэш) или используются defaults.
// loadAISSettings() обновляет их с сервера при каждом запуске.
// ------------------------------------------------------------------
window.AIS = {
    riskThresh: parseFloat(localStorage.getItem('ais_risk_thresh') || '70'),  // attendance.risk_threshold
    critThresh: parseFloat(localStorage.getItem('ais_crit_thresh') || '50'),  // attendance.crit_threshold

    esc: function(s) {
        return String(s || '').replace(/[&<>"']/g, function(c) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
        });
    },

    pick: function(obj) {
        for (var i = 1; i < arguments.length; i++) {
            if (obj && obj[arguments[i]] !== undefined && obj[arguments[i]] !== null) return obj[arguments[i]];
        }
        return null;
    },

    statusBadge: function(status) {
        var s = String(status || '').toLowerCase();
        var esc = window.AIS.esc;
        if (s.includes('присутств') || s.includes('present'))   return '<span class="badge b-ok">Присутствовал</span>';
        if (s.includes('отсутств') || s.includes('absent'))     return '<span class="badge b-err">Отсутствовал</span>';
        if (s.includes('опозда') || s.includes('late'))         return '<span class="badge b-warn">Опоздал</span>';
        if (s.includes('уважит') || s.includes('excuse'))       return '<span class="badge b-info">Уважительная</span>';
        if (s.includes('идёт') || s.includes('active'))         return '<span class="badge b-warn">Идёт сейчас</span>';
        if (s.includes('предст') || s.includes('upcoming'))     return '<span class="badge b-muted">Предстоит</span>';
        if (s.includes('завер') || s.includes('done'))          return '<span class="badge b-ok">Завершено</span>';
        if (s.includes('ожидает') || s.includes('pending'))     return '<span class="badge b-warn">Ожидает</span>';
        if (s.includes('одобрен') || s.includes('approved'))    return '<span class="badge b-ok">Одобрено</span>';
        if (s.includes('отклон') || s.includes('rejected'))     return '<span class="badge b-err">Отклонено</span>';
        return '<span class="badge b-muted">' + esc(status) + '</span>';
    },
};

async function loadAISSettings() {
    try {
        var r = await callAPI('ПолучитьНастройки', {});
        if (r && r.success && Array.isArray(r.data)) {
            r.data.forEach(function(row) {
                var k = row['Ключ'] || row['Key'] || '';
                var v = parseFloat(row['Значение'] || row['Value'] || 0);
                if (k === 'attendance.risk_threshold' && !isNaN(v) && v > 0) {
                    window.AIS.riskThresh = v;
                    localStorage.setItem('ais_risk_thresh', v);
                }
                if (k === 'attendance.crit_threshold' && !isNaN(v) && v > 0) {
                    window.AIS.critThresh = v;
                    localStorage.setItem('ais_crit_thresh', v);
                }
            });
        }
    } catch(e) { /* используем значения по умолчанию */ }
}

// Вспомогательная функция для цвета прогресс-бара посещаемости
function attendanceColor(pct) {
    return pct >= window.AIS.riskThresh ? 'prog-green'
         : pct >= window.AIS.critThresh ? 'prog-yellow'
         : 'prog-red';
}

function attendanceTextColor(pct) {
    return pct < window.AIS.critThresh ? 'color:var(--c-err)'
         : pct < window.AIS.riskThresh ? 'color:var(--c-warn)'
         : '';
}

function attendanceTextClass(pct) {
    return pct < window.AIS.critThresh ? 'metric-bad'
         : pct < window.AIS.riskThresh ? 'metric-warn'
         : 'metric-good';
}

// Доступ через AIS namespace
window.AIS.attendanceColor = attendanceColor;
window.AIS.attendanceTextColor = attendanceTextColor;
window.AIS.attendanceTextClass = attendanceTextClass;

// ------------------------------------------------------------------
// ИНИЦИАЛИЗАЦИЯ ПРИ ЗАГРУЗКЕ СТРАНИЦЫ
// ------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
    // При загрузке страницы, если есть сеть — пробуем отправить накопившиеся офлайн-запросы
    if (isOnline()) {
        flushOfflineQueue().catch(console.warn);
        // Обновляем настройки системы в фоне (не блокируем страницу)
        loadAISSettings().catch(console.warn);
    }
});

