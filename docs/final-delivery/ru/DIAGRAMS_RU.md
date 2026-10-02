# Диаграммы AIS V2

## D01. Контекст системы

```mermaid
flowchart LR
    Student["Студент"] --> Browser["Браузер AIS"]
    Teacher["Преподаватель"] --> Browser
    Curator["Куратор"] --> Browser
    Methodist["Методист"] --> Browser
    Admin["Администратор"] --> Browser

    Browser --> Apache["Apache / XAMPP"]
    Apache --> PHP["PHP 8.2 thin layer"]
    PHP --> SQL["SQL Server 2022 / Улучшенная"]

    SKUD["СКУД / турникеты"] --> SkudEndpoint["integration/skud/event.php"]
    SkudEndpoint --> SQL

    OneC["1C / ERP"] <--> CSV["CSV-файлы"]
    CSV <--> PHP

    SQLAgent["SQL Server Agent"] --> SQL
    DBMail["Database Mail"] --> SQL
```

## D02. Архитектура по слоям

```mermaid
flowchart TB
    subgraph UI["Клиентский слой"]
        Pages["PHP-страницы ролей"]
        JS["common.js / offline queue / QR / schedule"]
        CSS["style.css"]
    end

    subgraph APP["PHP thin backend"]
        API["api.php"]
        Auth["includes/auth_check.php"]
        Offline["offline-handler.php"]
        Integration["integration/*"]
    end

    subgraph DB["SQL Server thick database"]
        SP["Хранимые процедуры"]
        TRG["Триггеры"]
        Tables["Таблицы"]
        Audit["Лог_Действий / Ошибки_Системы"]
    end

    Pages --> JS
    JS --> API
    Pages --> Auth
    Offline --> API
    Integration --> SP
    API --> SP
    SP --> Tables
    TRG --> Tables
    SP --> Audit
```

## D03. Общий поток API

```mermaid
sequenceDiagram
    participant UI as Браузер
    participant API as api.php
    participant DB as SQL Server

    UI->>API: POST action + params + token
    API->>API: readRequestPayload()
    API->>API: validateActionName()
    API->>DB: ПроверитьСессию для защищённых actions
    DB-->>API: session status
    API->>DB: INFORMATION_SCHEMA.ROUTINES
    API->>DB: INFORMATION_SCHEMA.PARAMETERS
    API->>DB: EXEC dbo.<action> @params
    DB-->>API: result sets / output params
    API-->>UI: JSON success/data/message
```

## D04. Авторизация и доступ к странице

```mermaid
sequenceDiagram
    participant User as Пользователь
    participant Login as login/index.php
    participant API as api.php
    participant DB as SQL Server
    participant Page as Защищённая страница

    User->>Login: ввод логина и пароля
    Login->>API: Авторизация
    API->>DB: dbo.Авторизация
    DB-->>API: session_id, token, role
    API-->>Login: JSON success
    Login->>Page: переход по роли
    Page->>API: ПроверитьСессию
    API->>DB: dbo.ПроверитьСессию
    DB-->>API: пользователь действителен
    Page->>API: ПолучитьНавигациюПользователя
    Page->>API: ПроверитьДоступКСтранице
```

## D05. Роли и навигация

```mermaid
flowchart LR
    User["Пользователь"] --> Role["Роль"]
    Role --> Permissions["Разрешения_Ролей"]
    Role --> SectionAccess["Доступ_Разделов_Ролей"]
    SectionAccess --> Sections["Разделы_Интерфейса"]
    Sections --> Nav["Навигация интерфейса"]
    Permissions --> APIAccess["Проверка операций"]
```

## D06. Ручная посещаемость

```mermaid
sequenceDiagram
    participant T as Преподаватель
    participant Journal as attendance-journal.js
    participant API as api.php
    participant DB as SQL Server

    T->>Journal: выбирает дату и занятие
    Journal->>API: ПолучитьЗанятияПоДате
    API->>DB: dbo.ПолучитьЗанятияПоДате
    DB-->>Journal: список занятий
    Journal->>API: ПолучитьПосещаемостьПоЗанятию
    DB-->>Journal: список студентов
    T->>Journal: меняет статус
    Journal->>API: ОтметитьПосещаемость
    API->>DB: dbo.ОтметитьПосещаемость
    DB-->>API: результат и аудит
    API-->>Journal: JSON
```

## D07. QR-посещаемость

```mermaid
sequenceDiagram
    participant Teacher as Преподаватель
    participant QRGen as teacher/qr-generator.php
    participant API as api.php
    participant DB as SQL Server
    participant Student as Студент
    participant Scanner as student/qr-scanner.php

    Teacher->>QRGen: выбирает занятие
    QRGen->>API: СгенерироватьQRДляЗанятия
    API->>DB: dbo.СгенерироватьQRДляЗанятия
    DB-->>API: QR_Код, QR_Сессия_ID, срок действия
    API-->>QRGen: JSON
    QRGen-->>Teacher: показывает QR

    Student->>Scanner: сканирует QR
    Scanner->>API: ПроверитьQRИОтметить
    API->>DB: dbo.ПроверитьQRИОтметить
    DB-->>API: посещаемость создана или отказ
    API-->>Scanner: результат
```

## D08. Offline queue

```mermaid
flowchart TB
    Action["Действие пользователя"] --> Online{"navigator.onLine?"}
    Online -- Да --> API["callAPI -> api.php"]
    Online -- Нет --> Build["buildOfflineRequest + idempotency_key"]
    Build --> IndexedDB["IndexedDB AIS_OfflineQueue"]
    IndexedDB --> LocalStorage["fallback localStorage"]
    Restore["Сеть восстановлена"] --> Flush["flushOfflineQueue"]
    Flush --> OfflineHandler["offline-handler.php"]
    OfflineHandler --> API
    API --> Idempotency["runtime/idempotency"]
    API --> DB["SQL Server"]
```

## D09. Обоснование отсутствия

```mermaid
stateDiagram-v2
    [*] --> Submitted: студент создаёт
    Submitted --> UnderReview: отображается куратору/преподавателю
    UnderReview --> Approved: принято
    UnderReview --> Rejected: отклонено
    Approved --> AttendanceUpdated: статус посещаемости обновлён
    Rejected --> NotificationSent: студент уведомлён
    AttendanceUpdated --> NotificationSent
    NotificationSent --> [*]
```

## D10. SKUD webhook

```mermaid
sequenceDiagram
    participant SKUD as СКУД
    participant Endpoint as integration/skud/event.php
    participant Auth as auth_ip_hmac.php
    participant DB as SQL Server

    SKUD->>Endpoint: POST event + HMAC headers
    Endpoint->>Auth: IP allowlist + timestamp + nonce + signature
    Auth-->>Endpoint: ok / duplicate / reject
    Endpoint->>DB: dbo.ПринятьСобытиеСКУД
    DB-->>Endpoint: принято / привязано / ошибка
    Endpoint->>DB: integration audit
    Endpoint-->>SKUD: JSON result
```

## D11. CSV / 1C exchange

```mermaid
flowchart LR
    OneC["1C"] --> CSVIn["CSV импорт"]
    CSVIn --> API["api.php"]
    API --> Map["integration/csv/mapping.php"]
    Map --> Normalizers["normalizers.php"]
    Normalizers --> SPImport["ИмпортГруппИзCSV / ИмпортСтудентовИзCSV"]
    SPImport --> DB["SQL Server"]

    DB --> SPExport["ЭкспортПосещаемостиВCSV"]
    SPExport --> API
    API --> CSVOut["CSV экспорт"]
    CSVOut --> OneC
```

## D12. Защита SKUD-запроса

```mermaid
flowchart TB
    Request["Входящий запрос"] --> IP{"IP в allowlist?"}
    IP -- Нет --> Reject403["403"]
    IP -- Да --> Headers{"Есть signature/timestamp/nonce?"}
    Headers -- Нет --> Reject401["401"]
    Headers -- Да --> Timestamp{"timestamp свежий?"}
    Timestamp -- Нет --> Reject401B["401 stale"]
    Timestamp -- Да --> HMAC{"HMAC корректен?"}
    HMAC -- Нет --> Reject401C["401 invalid signature"]
    HMAC -- Да --> Nonce{"nonce новый?"}
    Nonce -- Нет --> Duplicate["duplicate ignored"]
    Nonce -- Да --> Accept["ПринятьСобытиеСКУД"]
```

## D13. Администрирование

```mermaid
flowchart TB
    Admin["Администратор"] --> Users["Пользователи"]
    Admin --> Roles["Роли и разрешения"]
    Admin --> Reference["Справочники"]
    Admin --> Reports["Отчёты"]
    Admin --> Monitor["Мониторинг"]
    Admin --> Maintenance["Регламентные операции"]
    Admin --> Backup["Резервные копии"]
    Admin --> ControlPlane["Конструктор интерфейсов ролей"]

    Users --> SP["Хранимые процедуры"]
    Roles --> SP
    Reference --> SP
    Reports --> SP
    Monitor --> SP
    Maintenance --> SP
    Backup --> SP
    ControlPlane --> SP
```

## D14. Плановые отчёты

```mermaid
flowchart LR
    Admin["Администратор"] --> Plan["Плановый_Отчет"]
    Plan --> Recipients["Получатель_Планового_Отчета"]
    SQLAgent["SQL Server Agent"] --> Run["ВыполнитьПлановыйОтчет"]
    Run --> Artifact["Артефакт_Планового_Отчета"]
    Run --> Delivery["Доставка_Планового_Отчета"]
    Delivery --> DBMail["Database Mail"]
```

## D15. Расписание

```mermaid
flowchart TB
    Methodist["Методист"] --> SchedulePage["methodist/schedule.php"]
    Teacher["Преподаватель"] --> TeacherSchedule["teacher/schedule.php"]
    Student["Студент"] --> StudentSchedule["student/schedule.php"]
    Curator["Куратор"] --> CuratorSchedule["curator/schedule.php"]

    SchedulePage --> Overview["ПолучитьРасписаниеОбзор"]
    TeacherSchedule --> Overview
    StudentSchedule --> Overview
    CuratorSchedule --> Overview

    Overview --> Tables["Расписание / Занятие / Аудитория / Корпус / Дисциплина"]
```


