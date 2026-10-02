# Интеграции AIS V2

## 1. Общая модель интеграций

Все интеграции построены по тому же принципу, что и UI:

```text
External System
  -> PHP integration endpoint
    -> validation / normalization
      -> SQL Server stored procedure
        -> audit / business result
```

Интеграционный PHP-код не должен содержать бизнес-логики посещаемости. Он проверяет источник, нормализует payload и вызывает процедуру.

## 2. SKUD

### 2.1 Endpoint

```text
POST /ais-system-ru/integration/skud/event.php
```

Файлы:

- `integration/skud/event.php`
- `integration/skud/auth_ip_hmac.php`
- `integration/skud/mapping.php`
- `integration/common/integration_audit.php`
- `integration/common/procedure_gateway.php`

### 2.2 Формат входного события

Ожидаемые поля:

| Поле | Назначение |
| --- | --- |
| `device_id` | Идентификатор устройства SKUD. |
| `card_number` | Номер карты. |
| `event_type` | Тип события: entry/exit/denied и русские аналоги. |
| `direction` | Направление, если передаётся отдельно. |
| `timestamp` | Время события. |
| `temperature` | Опционально. |
| `photo_url` | Опционально. |
| `zone` или `access_zone` | Зона доступа. |
| `student_id` | Опционально, источник может передавать внешний id. |

### 2.3 Защитные заголовки

| Заголовок | Назначение |
| --- | --- |
| `X-SKUD-Signature` | HMAC SHA-256 подпись. |
| `X-SKUD-Timestamp` | Timestamp запроса. |
| `X-SKUD-Nonce` | Уникальный nonce против replay. |

Подпись:

```text
hash_hmac('sha256', timestamp + '.' + nonce + '.' + rawBody, AIS_SKUD_SECRET)
```

### 2.4 Процедура БД

`ПринятьСобытиеСКУД` принимает нормализованные параметры:

- `Устройство_ID`;
- `Номер_Карты`;
- `Тип_События`;
- `Направление`;
- `Время_События`;
- `Температура`;
- `Фото_URL`;
- `Данные_Датчиков`;
- `Зона_Доступа`.

Процедура должна:

1. зарегистрировать событие;
2. сопоставить карту со студентом;
3. найти релевантное активное занятие;
4. создать или обновить посещаемость;
5. записать аудит.

## 3. CSV / 1C

### 3.1 Назначение

Прямая интеграция с 1C не используется из-за ограничений безопасности. Обмен выполняется через CSV:

- импорт групп;
- импорт студентов;
- экспорт посещаемости.

### 3.2 API actions

| Action | Процедура | Назначение |
| --- | --- | --- |
| `ИмпортГруппИзCSV` | `ИмпортГруппИзCSV` | Импорт учебных групп. |
| `ИмпортСтудентовИзCSV` | `ИмпортСтудентовИзCSV` | Импорт студентов. |
| `ЭкспортПосещаемостиВCSV` | `ЭкспортПосещаемостиВCSV` | Экспорт посещаемости. |

### 3.3 Файлы

- `integration/csv/mapping.php` - связь action и процедуры;
- `integration/csv/normalizers.php` - нормализация CSV-содержимого;
- `api.php` - специальный маршрут для CSV import actions.

### 3.4 Контроль качества CSV

Требования:

- валидная кодировка UTF-8;
- согласованный разделитель;
- наличие обязательных колонок;
- проверка дублей;
- запись результата в `Журнал_Импорта_CSV`;
- понятные ошибки для оператора.

## 4. Offline replay

### 4.1 Компоненты

| Компонент | Назначение |
| --- | --- |
| `assets/js/common.js` | Создаёт offline-request, хранит IndexedDB/localStorage, flush queue. |
| `assets/js/offline-queue.js` | Упрощённый класс `OfflineQueue`. |
| `admin/offline-queue.php` | Административный просмотр очереди. |
| `offline-handler.php` | Серверный приём очереди и повторный вызов API. |
| `runtime/idempotency` | Кэш для защиты от повторного выполнения. |

### 4.2 Жизненный цикл

1. UI вызывает `callAPIOfflineSupport`.
2. Если сеть есть, запрос идёт в `api.php`.
3. Если сети нет, запрос сохраняется локально.
4. При online событии запускается `flushOfflineQueue`.
5. Запрос отправляется в `offline-handler.php`.
6. Сервер вызывает `api.php` с тем же action/params.
7. `Idempotency-Key` предотвращает дубль.

## 5. Health endpoint

Endpoint:

```text
GET /ais-system-ru/integration/system/health.php
Header: X-System-Secret: <AIS_HEALTH_SECRET>
```

Функция:

- проверка доступности БД;
- вызов `ПроверитьСостояниеСистемы`;
- возврат JSON для внутреннего мониторинга.

Endpoint защищён обязательным секретом. Если `AIS_HEALTH_SECRET` не задан, endpoint возвращает `503`.

## 6. Интеграционный аудит

Для интеграций необходимо фиксировать:

- endpoint;
- IP источника;
- метод;
- статус;
- задержку;
- результат;
- ошибку без раскрытия секретов;
- идентификаторы события, если применимо.

Запрещено логировать:

- `AIS_SKUD_SECRET`;
- raw HMAC secret;
- пароли;
- reset tokens;
- персональные данные сверх необходимого.


