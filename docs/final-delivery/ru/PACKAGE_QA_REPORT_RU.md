# AIS V2 RU - отчёт комплексной проверки пакета

Дата проверки: 2026-06-16  
Приложение: `C:\xampp\htdocs\ais-system-ru`  
Документация: `C:\xampp\htdocs\ais-system-ru-docs`  
URL: `http://localhost/ais-system-ru/`

## Итоговое заключение

Статус пакета: **PASS для поставки приложения и документации; runtime-ограничение по SQL Server Agent зафиксировано отдельно**.

В ходе проверки найдены и исправлены две ошибки обработки API:

1. Некорректный `uniqueidentifier` в параметрах процедуры приводил к HTTP 500.
2. Ошибка авторизации из SQL Server возвращалась как HTTP 500 вместо контролируемого HTTP 401.

После исправлений повторные smoke-тесты API прошли корректно.

## Исправленные замечания Code Review

### CR-001 [P1] Некорректный UUID в API вызывал 500

- Область: `api.php`
- Симптом: `ПроверитьСессию` с `session_id = "x"` возвращал `500 Internal Server Error` из-за SQL conversion error.
- Исправление: добавлена предварительная проверка параметров SQL-типа `uniqueidentifier` до вызова процедуры.
- Текущий результат: HTTP `400 Bad Request` с понятным JSON-сообщением.

Контрольный результат:

```text
HTTP/1.1 400 Bad Request
{"success":false,"message":"Некорректный формат uniqueidentifier для параметра @Сессия_ID.","error_code":400}
```

### CR-002 [P1] Бизнес-ошибки авторизации возвращались как 500

- Область: `api.php`
- Симптом: неверный логин/пароль возвращал `500 Internal Server Error`.
- Причина: SQL Server RAISERROR с кодом 50000 оборачивался как техническое исключение.
- Исправление: добавлен mapper бизнес-ошибок SQL Server в HTTP-коды.
- Текущий результат: HTTP `401 Unauthorized`.

Контрольный результат:

```text
HTTP/1.1 401 Unauthorized
{"success":false,"message":"Неверный логин или пароль","error_code":401}
```

## Выполненные проверки

| Проверка | Статус | Результат |
| --- | --- | --- |
| Структура приложения | PASS | Каталог приложения существует, документация вынесена отдельно. |
| Разделение документации | PASS | В приложении нет `.md` файлов; документация находится в отдельном каталоге. |
| Отсутствие старых путей | PASS | Не найдены ссылки на предыдущие URL и рабочие каталоги исходной сборки. |
| Отсутствие служебных маркеров | PASS | Не найдены внутренние маркеры инструментов, внешние tool labels и нерелевантные служебные подписи. |
| PHP syntax | PASS | `php -l` пройден для 69 PHP-файлов. |
| JavaScript syntax | PASS | `node --check` пройден для 10 JS-файлов. |
| Локальные ссылки | PASS | Ссылки на `/ais-system-ru/...` указывают на существующие файлы или runtime endpoints. |
| Обязательные файлы | PASS | `api.php`, `config.php`, `index.php`, login, assets, vendor, SQL, runtime, uploads присутствуют. |
| Apache smoke | PASS | `/`, login, CSS, JS, PNG, QR vendor assets отвечают корректно. |
| Защита внутренних каталогов | PASS | `includes`, `Database`, `runtime`, `integration/common` возвращают `403`. |
| DB connection | PASS | PHP успешно подключается к SQL Server через `config.php`. |
| API invalid UUID | PASS after fix | Возвращает `400`, не `500`. |
| API invalid login | PASS after fix | Возвращает `401`, не `500`. |
| API missing procedure | PASS | Возвращает `404`. |
| Health endpoint without secret | PASS | Возвращает `503`, не раскрывает данные. |
| SKUD without secret | PASS | Возвращает `503`, не принимает событие. |
| Offline handler invalid payload | PASS | Возвращает `400`. |

## HTTP smoke results

| URL | Ожидаемо | Фактически |
| --- | --- | --- |
| `/ais-system-ru/` | redirect to login/session flow | `302` |
| `/ais-system-ru/login/index.php` | login page | `200` |
| `/ais-system-ru/admin/dashboard.php` без сессии | redirect | `302` |
| `/ais-system-ru/student/dashboard.php` без сессии | redirect | `302` |
| `/ais-system-ru/includes/auth_check.php` | forbidden | `403` |
| `/ais-system-ru/Database/Улучшенная.sql` | forbidden | `403` |
| `/ais-system-ru/runtime/sessions/.gitkeep` | forbidden | `403` |
| `/ais-system-ru/integration/common/error_response.php` | forbidden | `403` |
| `/ais-system-ru/assets/vendor/qrcode.min.js` | asset | `200` |
| `/ais-system-ru/assets/vendor/html5-qrcode.min.js` | asset | `200` |

## Runtime-состояние окружения

| Компонент | Статус | Комментарий |
| --- | --- | --- |
| Apache | PASS | Отвечает через `http://localhost/ais-system-ru/`. |
| SQL Server `MSSQLSERVER` | PASS | Служба запущена, подключение из PHP успешно. |
| SQL Server Agent | ENV BLOCKER | Служба остановлена; запуск из текущей сессии Windows запрещён правами. |
| SQL Browser | Not required for current local port | Остановлен; при явном `localhost,15432` не является блокером. |
| SKUD secret | Not configured | Endpoint корректно возвращает `503`. Требуется `AIS_SKUD_SECRET` для интеграционного теста. |
| Health secret | Not configured | Endpoint корректно возвращает `503`. Требуется `AIS_HEALTH_SECRET` для мониторинга. |

## Ограничения проверки

Полные E2E-сценарии входа по ролям не были выполнены, потому что в поставке не указаны действующие пароли тестовых пользователей. Были проверены:

- наличие активных пользователей в БД;
- корректная реакция API на неверный логин/пароль;
- защита страниц без сессии;
- корректная работа DB connection.

Для полного E2E нужны рабочие учётные данные для ролей:

- Admin;
- Студент;
- Преподаватель;
- Куратор;
- Методист.

## Оставшиеся действия для production-приёмки

| ID | Приоритет | Действие | Причина |
| --- | --- | --- | --- |
| QA-ENV-001 | Medium | Запустить `SQLSERVERAGENT` от имени администратора Windows, если плановые отчёты входят в scope. | Сейчас служба остановлена и не может быть запущена текущей сессией. |
| QA-ENV-002 | Medium | Настроить `AIS_SKUD_SECRET` и выполнить signed SKUD webhook test. | Без секрета endpoint защищённо отказывает. |
| QA-ENV-003 | Medium | Настроить `AIS_HEALTH_SECRET` и выполнить health check. | Без секрета endpoint защищённо отказывает. |
| QA-ENV-004 | Medium | Предоставить тестовые credentials для пяти ролей и выполнить E2E. | Нужны валидные пароли, не извлекаемые из hash. |
| QA-SEC-001 | Medium | Перед production перенести DB password из локального fallback в `AIS_DB_PASSWORD`. | В локальном стенде fallback оставлен для запуска на XAMPP. |

## Финальная оценка

Кодовая часть пакета после исправлений проходит статические, HTTP-smoke и API-smoke проверки. Найденные дефекты API исправлены и повторно проверены. Оставшиеся пункты относятся к настройке окружения и production-hardening, а не к отсутствующим файлам пакета.


