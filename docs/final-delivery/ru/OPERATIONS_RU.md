# Эксплуатация и развёртывание AIS V2

## 1. Требования к среде

| Компонент | Требование |
| --- | --- |
| Web server | Apache/XAMPP. |
| PHP | PHP 8.2 с расширением `sqlsrv`. |
| DBMS | SQL Server 2022. |
| Порт БД | `15432` по локальной конфигурации. |
| База | `Улучшенная`. |
| ОС | Windows host или совместимая среда. |
| Дополнительно | SQL Server Agent и Database Mail, если включены плановые отчёты/почта. |

## 2. Рекомендуемое размещение

Содержимое `V2` рекомендуется разворачивать как активный web-root проекта:

```text
C:\xampp\htdocs\ais-system-ru
```

Причина: в клиентском коде используются абсолютные пути `/ais-system-ru/...`.

## 3. Переменные окружения

| Переменная | Обязательность | Описание |
| --- | --- | --- |
| `AIS_DB_PASSWORD` | Обязательно для production | Пароль SQL-пользователя. На локальном стенде может использоваться демонстрационный fallback из `config.php`. |
| `AIS_SKUD_SECRET` | Обязательно для SKUD | HMAC-секрет SKUD. |
| `AIS_HEALTH_SECRET` | Обязательно для health endpoint | Секрет внутреннего мониторинга. |
| `AIS_DB_HOST` | Опционально | По умолчанию `localhost`. |
| `AIS_DB_PORT` | Опционально | По умолчанию `15432`. |
| `AIS_DB_NAME` | Опционально | По умолчанию `Улучшенная`. |
| `AIS_DB_USER` | Опционально | По умолчанию `php_user`. |
| `AIS_SITE_URL` | Рекомендуется | Базовый URL. |
| `AIS_DEBUG` | Рекомендуется | В production `false`. |
| `AIS_INTEGRATION_ALLOWLIST` | Рекомендуется | IP-адреса, разрешённые для интеграций. |

## 4. Порядок развёртывания

1. Сделать резервную копию текущего каталога приложения.
2. Сделать резервную копию базы данных.
3. Подготовить переменные окружения.
4. Развернуть содержимое поставочного каталога приложения в web-root.
5. Проверить права записи на runtime-папки.
6. Применить SQL-скрипты в staging.
7. Применить SQL-скрипты в production.
8. Запустить Apache.
9. Проверить `login/index.php`.
10. Выполнить smoke-тесты API.
11. Проверить роли.
12. Проверить интеграции.

## 5. Порядок SQL-миграций

Рекомендуемый порядок:

1. `Database/Улучшенная.sql`
2. `Database/Дополнения.sql`
3. `Database/Integration SP.sql`
4. `Database/fix_trigger_notifications.sql`
5. `Database/admin_roles_permissions.sql`
6. `Database/password_reset_database_mail.sql`
7. `Database/schedule_overview_migration.sql`
8. `Database/scheduled_reports_agent.sql`
9. `Database/admin_control_plane.sql`
10. `Database/admin_group_report_fix.sql`

Перед каждым шагом:

- проверить backup;
- проверить idempotency скрипта;
- выполнить на staging;
- сохранить output;
- иметь rollback-план.

## 6. Права на файловую систему

Папки с записью:

- `runtime/sessions`;
- `runtime/idempotency`;
- `runtime/tmp`;
- `uploads`.

Остальные каталоги должны быть read-only для web-процесса, если это возможно.

## 7. Регламентные операции

| Операция | Частота | Инструмент |
| --- | --- | --- |
| Проверка доступности БД | ежедневно/мониторинг | `integration/system/health.php` |
| Проверка ошибок | ежедневно | `admin/logs.php`, `Ошибки_Системы` |
| Проверка аудита | регулярно | `Лог_Действий` |
| Очистка старых логов | по политике | `ОчиститьСтарыеЛоги` |
| Обслуживание индексов | по расписанию | `ОбслуживаниеИндексов` |
| Сбор статистики | по расписанию | `СобратьСтатистикуСистемы` |
| Backup БД | ежедневно или по политике | SQL Server backup + `СоздатьРезервнуюКопию` |
| Проверка SKUD | после изменений сети/секретов | signed webhook smoke |
| Проверка CSV | перед импортной кампанией | sample CSV |

## 8. Мониторинг

Контролировать:

- Apache service;
- PHP errors;
- SQL Server service;
- SQL Server Agent;
- Database Mail queue;
- свободное место на диске;
- размер журналов;
- рост `runtime/idempotency`;
- рост `uploads`;
- ошибки интеграции SKUD.

## 9. Резервное копирование

Минимальная политика:

- полный backup БД ежедневно;
- backup перед миграциями;
- проверка восстановления на тестовой среде;
- хранение backup вне web-root;
- запрет доступа к backup-файлам через HTTP.

## 10. Обработка инцидентов

### 10.1 Не открывается сайт

1. Проверить Apache.
2. Проверить путь deployment.
3. Проверить `.htaccess`.
4. Проверить PHP errors.
5. Проверить базовый URL `/ais-system-ru/`.

### 10.2 Ошибка подключения к БД

1. Проверить SQL Server service.
2. Проверить порт `15432`.
3. Проверить `AIS_DB_HOST`, `AIS_DB_PORT`, `AIS_DB_NAME`, `AIS_DB_USER`, `AIS_DB_PASSWORD`.
4. Проверить extension `sqlsrv`.
5. Проверить firewall.

### 10.3 Не работает SKUD

1. Проверить `AIS_SKUD_SECRET`.
2. Проверить `AIS_INTEGRATION_ALLOWLIST`.
3. Проверить HMAC headers.
4. Проверить timestamp/nonce.
5. Проверить процедуру `ПринятьСобытиеСКУД`.
6. Проверить audit log.

### 10.4 Не отправляется почта

1. Проверить Database Mail XPs.
2. Проверить профиль Database Mail.
3. Проверить SQL Server Agent, если это плановые отчёты.
4. Проверить очередь mail.
5. Проверить, что reset token не выводится наружу.

### 10.5 Не синхронизируется offline queue

1. Проверить сеть клиента.
2. Проверить IndexedDB/localStorage.
3. Проверить `offline-handler.php`.
4. Проверить session/token.
5. Проверить `runtime/idempotency`.
6. Проверить результат `api.php`.



