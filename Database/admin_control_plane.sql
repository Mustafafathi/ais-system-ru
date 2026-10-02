/*
    AIS Admin Control Plane
    Safe, DB-owned contracts for dynamic navigation, UI permissions, controlled
    administrator operations, infrastructure status, and missing admin CRUD flows.
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'dbo.Разделы_Интерфейса', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Разделы_Интерфейса (
        Раздел_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Разделы_Интерфейса PRIMARY KEY,
        Код NVARCHAR(120) NOT NULL CONSTRAINT UQ_Разделы_Интерфейса_Код UNIQUE,
        Область NVARCHAR(40) NOT NULL,
        Группа_Меню NVARCHAR(100) NOT NULL,
        Группа_Сортировка INT NOT NULL CONSTRAINT DF_Разделы_Интерфейса_Группа_Сортировка DEFAULT (100),
        Заголовок NVARCHAR(120) NOT NULL,
        Путь NVARCHAR(300) NOT NULL,
        Иконка NVARCHAR(40) NOT NULL CONSTRAINT DF_Разделы_Интерфейса_Иконка DEFAULT (N'settings'),
        Сортировка INT NOT NULL CONSTRAINT DF_Разделы_Интерфейса_Сортировка DEFAULT (100),
        По_Умолчанию BIT NOT NULL CONSTRAINT DF_Разделы_Интерфейса_ПоУмолчанию DEFAULT (0),
        Активен BIT NOT NULL CONSTRAINT DF_Разделы_Интерфейса_Активен DEFAULT (1),
        Описание NVARCHAR(500) NULL,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Разделы_Интерфейса_ДатаСоздания DEFAULT (SYSDATETIME()),
        Дата_Обновления DATETIME2(0) NULL,
        Кто_Обновил INT NULL
    );

    CREATE INDEX IX_Разделы_Интерфейса_Путь ON dbo.Разделы_Интерфейса(Путь) INCLUDE (Активен);
    CREATE INDEX IX_Разделы_Интерфейса_Сортировка ON dbo.Разделы_Интерфейса(Группа_Сортировка, Сортировка);
END
GO

IF OBJECT_ID(N'dbo.Доступ_Разделов_Ролей', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Доступ_Разделов_Ролей (
        Доступ_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Доступ_Разделов_Ролей PRIMARY KEY,
        Роль_ID INT NOT NULL,
        Раздел_ID INT NOT NULL,
        Разрешено BIT NOT NULL CONSTRAINT DF_Доступ_Разделов_Ролей_Разрешено DEFAULT (1),
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Доступ_Разделов_Ролей_ДатаСоздания DEFAULT (SYSDATETIME()),
        Дата_Обновления DATETIME2(0) NULL,
        Кто_Обновил INT NULL,
        CONSTRAINT UQ_Доступ_Разделов_Ролей UNIQUE (Роль_ID, Раздел_ID),
        CONSTRAINT FK_Доступ_Разделов_Ролей_Роль FOREIGN KEY (Роль_ID) REFERENCES dbo.Роль(Роль_ID),
        CONSTRAINT FK_Доступ_Разделов_Ролей_Раздел FOREIGN KEY (Раздел_ID) REFERENCES dbo.Разделы_Интерфейса(Раздел_ID)
    );

    CREATE INDEX IX_Доступ_Разделов_Ролей_Роль ON dbo.Доступ_Разделов_Ролей(Роль_ID, Разрешено);
END
GO

IF OBJECT_ID(N'dbo.Админ_Операции', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Админ_Операции (
        Операция_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Админ_Операции PRIMARY KEY,
        Код NVARCHAR(100) NOT NULL CONSTRAINT UQ_Админ_Операции_Код UNIQUE,
        Категория NVARCHAR(80) NOT NULL,
        Название NVARCHAR(160) NOT NULL,
        Описание NVARCHAR(700) NULL,
        Процедура NVARCHAR(128) NULL,
        Риск NVARCHAR(30) NOT NULL CONSTRAINT DF_Админ_Операции_Риск DEFAULT (N'Средний'),
        Требует_Причину BIT NOT NULL CONSTRAINT DF_Админ_Операции_ТребуетПричину DEFAULT (1),
        Требует_Параметры BIT NOT NULL CONSTRAINT DF_Админ_Операции_ТребуетПараметры DEFAULT (0),
        Активна BIT NOT NULL CONSTRAINT DF_Админ_Операции_Активна DEFAULT (1),
        Сортировка INT NOT NULL CONSTRAINT DF_Админ_Операции_Сортировка DEFAULT (100),
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Админ_Операции_ДатаСоздания DEFAULT (SYSDATETIME()),
        Дата_Обновления DATETIME2(0) NULL
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.ПроверитьАдминистратора
    @Пользователь_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Пользователь u
        INNER JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
        WHERE u.Пользователь_ID = @Пользователь_ID
          AND u.Активен = 1
          AND r.Название = N'Admin'
    )
    BEGIN
        RAISERROR(N'Недостаточно прав: требуется роль Admin', 16, 1);
        RETURN;
    END
END;
GO

DECLARE @Sections TABLE (
    Код NVARCHAR(120) NOT NULL,
    Область NVARCHAR(40) NOT NULL,
    Группа_Меню NVARCHAR(100) NOT NULL,
    Группа_Сортировка INT NOT NULL,
    Заголовок NVARCHAR(120) NOT NULL,
    Путь NVARCHAR(300) NOT NULL,
    Иконка NVARCHAR(40) NOT NULL,
    Сортировка INT NOT NULL,
    По_Умолчанию BIT NOT NULL,
    Описание NVARCHAR(500) NULL
);

INSERT INTO @Sections (Код, Область, Группа_Меню, Группа_Сортировка, Заголовок, Путь, Иконка, Сортировка, По_Умолчанию, Описание)
VALUES
    (N'common.notifications', N'common', N'Аккаунт', 900, N'Уведомления', N'/ais-system-ru/notifications.php', N'bell', 10, 0, N'Личные уведомления пользователя'),

    (N'student.dashboard', N'student', N'Главное', 100, N'Главная', N'/ais-system-ru/student/dashboard.php', N'home', 10, 1, N'Личный дашборд студента'),
    (N'student.schedule', N'student', N'Главное', 100, N'Расписание', N'/ais-system-ru/student/schedule.php', N'calendar', 20, 0, N'Расписание студента'),
    (N'student.attendance', N'student', N'Главное', 100, N'Посещаемость', N'/ais-system-ru/student/attendance.php', N'attendance', 30, 0, N'История посещаемости'),
    (N'student.qr', N'student', N'Главное', 100, N'QR-сканер', N'/ais-system-ru/student/qr-scanner.php', N'qr', 40, 0, N'Отметка посещаемости по QR'),
    (N'student.excuses', N'student', N'Заявки', 200, N'Мои обоснования', N'/ais-system-ru/student/excuses.php', N'note', 10, 0, N'Список обоснований студента'),
    (N'student.profile', N'student', N'Аккаунт', 900, N'Профиль', N'/ais-system-ru/student/profile.php', N'user', 20, 0, N'Профиль студента'),

    (N'teacher.dashboard', N'teacher', N'Главное', 100, N'Главная', N'/ais-system-ru/teacher/dashboard.php', N'home', 10, 1, N'Дашборд преподавателя'),
    (N'teacher.schedule', N'teacher', N'Главное', 100, N'Моё расписание', N'/ais-system-ru/teacher/schedule.php', N'calendar', 20, 0, N'Расписание преподавателя'),
    (N'teacher.journal', N'teacher', N'Главное', 100, N'Отметить посещаемость', N'/ais-system-ru/teacher/attendance-journal.php', N'attendance', 30, 0, N'Журнал посещаемости'),
    (N'teacher.qr', N'teacher', N'Главное', 100, N'QR-генератор', N'/ais-system-ru/teacher/qr-generator.php', N'qr', 40, 0, N'Генерация QR-сессии'),
    (N'teacher.reports', N'teacher', N'Отчёты', 200, N'Отчёты по группам', N'/ais-system-ru/teacher/reports.php', N'report', 10, 0, N'Отчеты преподавателя'),
    (N'teacher.profile', N'teacher', N'Аккаунт', 900, N'Профиль', N'/ais-system-ru/teacher/profile.php', N'user', 20, 0, N'Профиль преподавателя'),

    (N'curator.dashboard', N'curator', N'Мониторинг', 100, N'Главная', N'/ais-system-ru/curator/dashboard.php', N'home', 10, 1, N'Дашборд куратора'),
    (N'curator.students', N'curator', N'Мониторинг', 100, N'Студенты группы', N'/ais-system-ru/curator/students.php', N'group', 20, 0, N'Список студентов куратора'),
    (N'curator.schedule', N'curator', N'Мониторинг', 100, N'Расписание', N'/ais-system-ru/curator/schedule.php', N'calendar', 30, 0, N'Расписание групп куратора'),
    (N'curator.excuses', N'curator', N'Мониторинг', 100, N'Обоснования', N'/ais-system-ru/curator/excuses.php', N'note', 40, 0, N'Рассмотрение обоснований'),
    (N'curator.reports', N'curator', N'Мониторинг', 100, N'Отчёты', N'/ais-system-ru/curator/reports.php', N'report', 50, 0, N'Отчеты куратора'),
    (N'curator.profile', N'curator', N'Аккаунт', 900, N'Профиль', N'/ais-system-ru/curator/profile.php', N'user', 20, 0, N'Профиль куратора'),

    (N'methodist.dashboard', N'methodist', N'Управление', 100, N'Главная', N'/ais-system-ru/methodist/dashboard.php', N'home', 10, 1, N'Дашборд методиста'),
    (N'methodist.groups', N'methodist', N'Управление', 100, N'Группы', N'/ais-system-ru/methodist/groups.php', N'group', 20, 0, N'Учебные группы'),
    (N'methodist.subjects', N'methodist', N'Управление', 100, N'Дисциплины', N'/ais-system-ru/methodist/subjects.php', N'book', 30, 0, N'Дисциплины'),
    (N'methodist.schedule', N'methodist', N'Управление', 100, N'Расписание', N'/ais-system-ru/methodist/schedule.php', N'calendar', 40, 0, N'Управление расписанием'),
    (N'methodist.teachers', N'methodist', N'Управление', 100, N'Преподаватели', N'/ais-system-ru/methodist/teachers.php', N'user', 50, 0, N'Справочник преподавателей'),
    (N'methodist.profile', N'methodist', N'Аккаунт', 900, N'Профиль', N'/ais-system-ru/methodist/profile.php', N'user', 20, 0, N'Профиль методиста'),

    (N'admin.dashboard', N'admin', N'Дашборд', 100, N'Главная', N'/ais-system-ru/admin/dashboard.php', N'home', 10, 1, N'Дашборд администратора'),
    (N'admin.control', N'admin', N'Дашборд', 100, N'Центр управления', N'/ais-system-ru/admin/control-plane.php', N'monitoring', 20, 0, N'Единая панель управления системой'),
    (N'admin.users', N'admin', N'Пользователи', 200, N'Пользователи', N'/ais-system-ru/admin/users.php', N'user', 10, 0, N'Учетные записи'),
    (N'admin.students', N'admin', N'Пользователи', 200, N'Студенты', N'/ais-system-ru/admin/students.php', N'group', 20, 0, N'Карточки студентов'),
    (N'admin.teachers', N'admin', N'Пользователи', 200, N'Преподаватели', N'/ais-system-ru/admin/teachers.php', N'user', 30, 0, N'Карточки преподавателей'),
    (N'admin.groups', N'admin', N'Пользователи', 200, N'Группы', N'/ais-system-ru/admin/groups.php', N'group', 40, 0, N'Учебные группы'),
    (N'admin.schedule', N'admin', N'Отчёты и данные', 300, N'Расписание', N'/ais-system-ru/admin/schedule.php', N'calendar', 10, 0, N'Расписание'),
    (N'admin.reports', N'admin', N'Отчёты и данные', 300, N'Отчёты', N'/ais-system-ru/admin/reports.php', N'report', 20, 0, N'Отчеты'),
    (N'admin.scheduled-reports', N'admin', N'Отчёты и данные', 300, N'Плановые отчёты', N'/ais-system-ru/admin/scheduled-reports.php', N'report', 30, 0, N'Плановые отчеты'),
    (N'admin.import-export', N'admin', N'Отчёты и данные', 300, N'Импорт / Экспорт', N'/ais-system-ru/admin/import-export.php', N'import', 40, 0, N'Интеграция CSV с 1С'),
    (N'admin.monitoring', N'admin', N'Система', 400, N'Мониторинг', N'/ais-system-ru/admin/monitoring.php', N'monitoring', 10, 0, N'Состояние системы'),
    (N'admin.maintenance', N'admin', N'Система', 400, N'Обслуживание', N'/ais-system-ru/admin/maintenance.php', N'settings', 20, 0, N'Операции обслуживания'),
    (N'admin.reference', N'admin', N'Система', 400, N'Справочники', N'/ais-system-ru/admin/reference-data.php', N'book', 30, 0, N'Справочники и роли'),
    (N'admin.settings', N'admin', N'Система', 400, N'Настройки', N'/ais-system-ru/admin/settings.php', N'settings', 40, 0, N'Настройки системы'),
    (N'admin.logs', N'admin', N'Система', 400, N'Журнал действий', N'/ais-system-ru/admin/logs.php', N'log', 50, 0, N'Аудит действий'),
    (N'admin.backup', N'admin', N'Система', 400, N'Резервные копии', N'/ais-system-ru/admin/backup.php', N'backup', 60, 0, N'Резервные копии'),
    (N'admin.profile', N'admin', N'Система', 400, N'Профиль', N'/ais-system-ru/admin/profile.php', N'user', 70, 0, N'Профиль администратора');

MERGE dbo.Разделы_Интерфейса AS target
USING @Sections AS source
ON target.Код = source.Код
WHEN MATCHED THEN
    UPDATE SET
        Область = source.Область,
        Группа_Меню = source.Группа_Меню,
        Группа_Сортировка = source.Группа_Сортировка,
        Заголовок = source.Заголовок,
        Путь = source.Путь,
        Иконка = source.Иконка,
        Сортировка = source.Сортировка,
        По_Умолчанию = source.По_Умолчанию,
        Активен = 1,
        Описание = source.Описание,
        Дата_Обновления = SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT (Код, Область, Группа_Меню, Группа_Сортировка, Заголовок, Путь, Иконка, Сортировка, По_Умолчанию, Активен, Описание)
    VALUES (source.Код, source.Область, source.Группа_Меню, source.Группа_Сортировка, source.Заголовок, source.Путь, source.Иконка, source.Сортировка, source.По_Умолчанию, 1, source.Описание);
GO

;WITH Grants AS (
    SELECT r.Роль_ID, s.Раздел_ID
    FROM dbo.Роль r
    CROSS JOIN dbo.Разделы_Интерфейса s
    WHERE r.Название = N'Admin'
      AND s.Область IN (N'admin', N'common')
       OR (r.Название = N'Студент' AND s.Область IN (N'student', N'common'))
       OR (r.Название = N'Преподаватель' AND s.Область IN (N'teacher', N'common'))
       OR (r.Название = N'Куратор' AND s.Область IN (N'curator', N'common'))
       OR (r.Название = N'Методист' AND s.Область IN (N'methodist', N'common'))
       OR (r.Название = N'Директор' AND s.Код IN (
            N'common.notifications',
            N'admin.dashboard',
            N'admin.control',
            N'admin.reports',
            N'admin.scheduled-reports',
            N'admin.monitoring',
            N'admin.logs'
       ))
)
MERGE dbo.Доступ_Разделов_Ролей AS target
USING Grants AS source
ON target.Роль_ID = source.Роль_ID AND target.Раздел_ID = source.Раздел_ID
WHEN MATCHED THEN
    UPDATE SET Разрешено = 1, Дата_Обновления = SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT (Роль_ID, Раздел_ID, Разрешено)
    VALUES (source.Роль_ID, source.Раздел_ID, 1);

UPDATE a
SET Разрешено = 0,
    Дата_Обновления = SYSDATETIME()
FROM dbo.Доступ_Разделов_Ролей a
INNER JOIN dbo.Роль r ON r.Роль_ID = a.Роль_ID
INNER JOIN dbo.Разделы_Интерфейса s ON s.Раздел_ID = a.Раздел_ID
WHERE r.Название = N'Admin'
  AND s.Область NOT IN (N'admin', N'common');
GO

DECLARE @Operations TABLE (
    Код NVARCHAR(100) NOT NULL,
    Категория NVARCHAR(80) NOT NULL,
    Название NVARCHAR(160) NOT NULL,
    Описание NVARCHAR(700) NULL,
    Процедура NVARCHAR(128) NULL,
    Риск NVARCHAR(30) NOT NULL,
    Требует_Причину BIT NOT NULL,
    Требует_Параметры BIT NOT NULL,
    Сортировка INT NOT NULL
);

INSERT INTO @Operations (Код, Категория, Название, Описание, Процедура, Риск, Требует_Причину, Требует_Параметры, Сортировка)
VALUES
    (N'CHECK_INTEGRITY', N'Целостность', N'Проверить целостность данных', N'Проверяет связи студентов, пользователей, занятий, QR и СКУД.', N'ПроверитьЦелостностьДанных', N'Средний', 1, 0, 10),
    (N'COLLECT_STATS_TODAY', N'Статистика', N'Собрать статистику за сегодня', N'Пересобирает агрегированную статистику системы за текущую дату.', N'СобратьСтатистикуСистемы', N'Средний', 1, 0, 20),
    (N'CLEAN_DUP_SESSIONS', N'Сессии', N'Очистить дубли сессий', N'Закрывает или удаляет дублирующиеся пользовательские сессии по правилам базы.', N'ОчиститьДублирующиесяСессии', N'Высокий', 1, 0, 30),
    (N'FIX_ATTENDANCE_STATUSES', N'Посещаемость', N'Исправить некорректные статусы', N'Корректирует некорректные статусы посещаемости по backend-правилам.', N'ИсправитьНекорректныеСтатусы', N'Высокий', 1, 0, 40),
    (N'DAILY_MAINTENANCE', N'Обслуживание', N'Ежедневное обслуживание', N'Запускает комплексную плановую операцию обслуживания.', N'ЕжедневноеОбслуживаниеСистемы', N'Высокий', 1, 0, 50),
    (N'INDEX_MAINTENANCE', N'Обслуживание', N'Обслуживание индексов', N'Обслуживает индексы SQL Server с безопасным порогом фрагментации.', N'ОбслуживаниеИндексов', N'Высокий', 1, 1, 60),
    (N'CLEAN_OLD_LOGS', N'Журнал', N'Очистить старые логи', N'Удаляет старые записи журнала старше заданного числа дней.', N'ОчиститьСтарыеЛоги', N'Высокий', 1, 1, 70),
    (N'END_USER_SESSIONS', N'Сессии', N'Завершить все сессии пользователя', N'Завершает активные сессии выбранного пользователя.', N'ЗавершитьВсеСессииПользователя', N'Высокий', 1, 1, 80);

MERGE dbo.Админ_Операции AS target
USING @Operations AS source
ON target.Код = source.Код
WHEN MATCHED THEN
    UPDATE SET
        Категория = source.Категория,
        Название = source.Название,
        Описание = source.Описание,
        Процедура = source.Процедура,
        Риск = source.Риск,
        Требует_Причину = source.Требует_Причину,
        Требует_Параметры = source.Требует_Параметры,
        Активна = 1,
        Сортировка = source.Сортировка,
        Дата_Обновления = SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT (Код, Категория, Название, Описание, Процедура, Риск, Требует_Причину, Требует_Параметры, Активна, Сортировка)
    VALUES (source.Код, source.Категория, source.Название, source.Описание, source.Процедура, source.Риск, source.Требует_Причину, source.Требует_Параметры, 1, source.Сортировка);
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьНавигациюПользователя
    @Пользователь_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Раздел_ID,
        s.Код,
        s.Область,
        s.Группа_Меню AS [Группа],
        s.Группа_Сортировка,
        s.Заголовок,
        s.Путь,
        s.Иконка,
        s.Сортировка,
        s.По_Умолчанию,
        s.Описание,
        r.Роль_ID,
        r.Название AS Роль
    FROM dbo.Пользователь u
    INNER JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
    INNER JOIN dbo.Доступ_Разделов_Ролей a ON a.Роль_ID = r.Роль_ID AND a.Разрешено = 1
    INNER JOIN dbo.Разделы_Интерфейса s ON s.Раздел_ID = a.Раздел_ID AND s.Активен = 1
    WHERE u.Пользователь_ID = @Пользователь_ID
      AND u.Активен = 1
    ORDER BY s.Группа_Сортировка, s.Сортировка, s.Заголовок;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПроверитьДоступКСтранице
    @Пользователь_ID INT,
    @Путь NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @НормПуть NVARCHAR(300) = LOWER(LTRIM(RTRIM(ISNULL(@Путь, N''))));
    IF CHARINDEX(N'?', @НормПуть) > 0
        SET @НормПуть = LEFT(@НормПуть, CHARINDEX(N'?', @НормПуть) - 1);
    IF @НормПуть <> N'' AND LEFT(@НормПуть, 1) <> N'/'
        SET @НормПуть = N'/ais-system-ru/' + @НормПуть;

    DECLARE @Allowed BIT = 0;
    DECLARE @Reason NVARCHAR(200) = N'Раздел не назначен роли пользователя';

    IF EXISTS (
        SELECT 1
        FROM dbo.Пользователь u
        INNER JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
        INNER JOIN dbo.Доступ_Разделов_Ролей a ON a.Роль_ID = r.Роль_ID AND a.Разрешено = 1
        INNER JOIN dbo.Разделы_Интерфейса s ON s.Раздел_ID = a.Раздел_ID AND s.Активен = 1
        WHERE u.Пользователь_ID = @Пользователь_ID
          AND u.Активен = 1
          AND LOWER(s.Путь) = @НормПуть
    )
    BEGIN
        SET @Allowed = 1;
        SET @Reason = N'Доступ разрешен ролью';
    END

    SELECT
        @Allowed AS ДоступРазрешен,
        @Reason AS Причина,
        @НормПуть AS Путь,
        r.Название AS Роль
    FROM dbo.Пользователь u
    INNER JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
    WHERE u.Пользователь_ID = @Пользователь_ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьРазделыИнтерфейса
    @КтоЗапросил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоЗапросил;

    SELECT
        s.Раздел_ID,
        s.Код,
        s.Область,
        s.Группа_Меню,
        s.Группа_Сортировка,
        s.Заголовок,
        s.Путь,
        s.Иконка,
        s.Сортировка,
        s.По_Умолчанию,
        s.Активен,
        s.Описание,
        COUNT(CASE WHEN a.Разрешено = 1 THEN 1 END) AS Разрешено_Ролей
    FROM dbo.Разделы_Интерфейса s
    LEFT JOIN dbo.Доступ_Разделов_Ролей a ON a.Раздел_ID = s.Раздел_ID
    GROUP BY s.Раздел_ID, s.Код, s.Область, s.Группа_Меню, s.Группа_Сортировка,
             s.Заголовок, s.Путь, s.Иконка, s.Сортировка, s.По_Умолчанию, s.Активен, s.Описание
    ORDER BY s.Группа_Сортировка, s.Сортировка, s.Заголовок;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДоступРазделовРоли
    @Роль_ID INT,
    @КтоЗапросил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоЗапросил;

    SELECT
        s.Раздел_ID,
        s.Код,
        s.Область,
        s.Группа_Меню,
        s.Заголовок,
        s.Путь,
        s.Иконка,
        s.Активен,
        CAST(ISNULL(a.Разрешено, 0) AS BIT) AS Разрешено,
        a.Дата_Обновления,
        a.Кто_Обновил
    FROM dbo.Разделы_Интерфейса s
    LEFT JOIN dbo.Доступ_Разделов_Ролей a ON a.Раздел_ID = s.Раздел_ID AND a.Роль_ID = @Роль_ID
    ORDER BY s.Группа_Сортировка, s.Сортировка, s.Заголовок;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СохранитьРазделИнтерфейса
    @Раздел_ID INT = NULL,
    @Код NVARCHAR(120),
    @Область NVARCHAR(40),
    @Группа_Меню NVARCHAR(100),
    @Группа_Сортировка INT = 100,
    @Заголовок NVARCHAR(120),
    @Путь NVARCHAR(300),
    @Иконка NVARCHAR(40) = N'settings',
    @Сортировка INT = 100,
    @По_Умолчанию BIT = 0,
    @Активен BIT = 1,
    @Описание NVARCHAR(500) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоОбновил;

    IF @Путь NOT LIKE N'/ais-system-ru/%.php'
       OR @Путь LIKE N'%..%'
       OR @Путь LIKE N'%://%'
       OR @Путь LIKE N'%?%'
       OR @Путь LIKE N'%#%'
    BEGIN
        RAISERROR(N'Путь раздела должен быть локальной PHP-страницей AIS без внешних ссылок и параметров', 16, 1);
        RETURN;
    END

    IF @Код LIKE N'%[^A-Za-z0-9_.-]%'
    BEGIN
        RAISERROR(N'Код раздела содержит недопустимые символы', 16, 1);
        RETURN;
    END

    IF @Раздел_ID IS NULL OR @Раздел_ID = 0
    BEGIN
        INSERT INTO dbo.Разделы_Интерфейса (
            Код, Область, Группа_Меню, Группа_Сортировка, Заголовок, Путь,
            Иконка, Сортировка, По_Умолчанию, Активен, Описание, Кто_Обновил
        )
        VALUES (
            @Код, @Область, @Группа_Меню, @Группа_Сортировка, @Заголовок, @Путь,
            @Иконка, @Сортировка, @По_Умолчанию, @Активен, @Описание, @КтоОбновил
        );

        SET @Раздел_ID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.Разделы_Интерфейса
        SET Код = @Код,
            Область = @Область,
            Группа_Меню = @Группа_Меню,
            Группа_Сортировка = @Группа_Сортировка,
            Заголовок = @Заголовок,
            Путь = @Путь,
            Иконка = @Иконка,
            Сортировка = @Сортировка,
            По_Умолчанию = @По_Умолчанию,
            Активен = @Активен,
            Описание = @Описание,
            Кто_Обновил = @КтоОбновил,
            Дата_Обновления = SYSDATETIME()
        WHERE Раздел_ID = @Раздел_ID;
    END

    INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
    VALUES (@КтоОбновил, N'Сохранение раздела интерфейса', N'Разделы_Интерфейса', @Раздел_ID, N'Успешно');

    SELECT @Раздел_ID AS Раздел_ID, N'Раздел интерфейса сохранен' AS Сообщение;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СохранитьДоступРазделаРоли
    @Роль_ID INT,
    @Раздел_ID INT,
    @Разрешено BIT,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоОбновил;

    MERGE dbo.Доступ_Разделов_Ролей AS target
    USING (SELECT @Роль_ID AS Роль_ID, @Раздел_ID AS Раздел_ID) AS source
    ON target.Роль_ID = source.Роль_ID AND target.Раздел_ID = source.Раздел_ID
    WHEN MATCHED THEN
        UPDATE SET Разрешено = @Разрешено, Кто_Обновил = @КтоОбновил, Дата_Обновления = SYSDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (Роль_ID, Раздел_ID, Разрешено, Кто_Обновил)
        VALUES (@Роль_ID, @Раздел_ID, @Разрешено, @КтоОбновил);

    INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
    VALUES (@КтоОбновил, N'Изменение доступа раздела роли', N'Доступ_Разделов_Ролей', @Раздел_ID, N'Успешно');

    SELECT 1 AS Обновлено, N'Доступ раздела обновлен' AS Сообщение;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьАдминОперации
    @КтоЗапросил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоЗапросил;

    SELECT
        Код,
        Категория,
        Название,
        Описание,
        Процедура,
        Риск,
        Требует_Причину,
        Требует_Параметры,
        Активна,
        Сортировка
    FROM dbo.Админ_Операции
    ORDER BY Категория, Сортировка, Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ВыполнитьАдминОперацию
    @Код NVARCHAR(100),
    @КтоЗапустил INT,
    @Подтверждение NVARCHAR(100),
    @Причина NVARCHAR(700) = NULL,
    @ПараметрыJSON NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоЗапустил;

    DECLARE @Risk NVARCHAR(30), @NeedsReason BIT, @NeedsParams BIT, @Name NVARCHAR(160);
    SELECT @Risk = Риск, @NeedsReason = Требует_Причину, @NeedsParams = Требует_Параметры, @Name = Название
    FROM dbo.Админ_Операции
    WHERE Код = @Код AND Активна = 1;

    IF @Name IS NULL
    BEGIN
        RAISERROR(N'Административная операция не найдена или отключена', 16, 1);
        RETURN;
    END

    IF @Подтверждение <> N'ВЫПОЛНИТЬ'
    BEGIN
        RAISERROR(N'Операция требует подтверждение ВЫПОЛНИТЬ', 16, 1);
        RETURN;
    END

    IF @NeedsReason = 1 AND NULLIF(LTRIM(RTRIM(ISNULL(@Причина, N''))), N'') IS NULL
    BEGIN
        RAISERROR(N'Укажите причину выполнения операции', 16, 1);
        RETURN;
    END

    DECLARE @Start DATETIME2(3) = SYSDATETIME();

    BEGIN TRY
        IF @Код = N'CHECK_INTEGRITY'
            EXEC dbo.ПроверитьЦелостностьДанных;
        ELSE IF @Код = N'COLLECT_STATS_TODAY'
        BEGIN
            DECLARE @Today DATE = CONVERT(date, GETDATE());
            EXEC dbo.СобратьСтатистикуСистемы @Дата = @Today;
        END
        ELSE IF @Код = N'CLEAN_DUP_SESSIONS'
            EXEC dbo.ОчиститьДублирующиесяСессии;
        ELSE IF @Код = N'FIX_ATTENDANCE_STATUSES'
            EXEC dbo.ИсправитьНекорректныеСтатусы;
        ELSE IF @Код = N'DAILY_MAINTENANCE'
            EXEC dbo.ЕжедневноеОбслуживаниеСистемы;
        ELSE IF @Код = N'INDEX_MAINTENANCE'
        BEGIN
            DECLARE @Frag INT = COALESCE(TRY_CONVERT(INT, JSON_VALUE(@ПараметрыJSON, N'$.ПерестроитьПриФрагментации')), 30);
            EXEC dbo.ОбслуживаниеИндексов @ПерестроитьПриФрагментации = @Frag;
        END
        ELSE IF @Код = N'CLEAN_OLD_LOGS'
        BEGIN
            DECLARE @Days INT = COALESCE(TRY_CONVERT(INT, JSON_VALUE(@ПараметрыJSON, N'$.СтаршеДней')), 365);
            EXEC dbo.ОчиститьСтарыеЛоги @СтаршеДней = @Days, @КтоОчистил = @КтоЗапустил;
        END
        ELSE IF @Код = N'END_USER_SESSIONS'
        BEGIN
            DECLARE @TargetUser INT = TRY_CONVERT(INT, JSON_VALUE(@ПараметрыJSON, N'$.Пользователь_ID'));
            IF @TargetUser IS NULL OR @TargetUser <= 0
            BEGIN
                RAISERROR(N'Укажите Пользователь_ID для завершения сессий', 16, 1);
                RETURN;
            END
            EXEC dbo.ЗавершитьВсеСессииПользователя @Пользователь_ID = @TargetUser, @Причина = @Причина;
        END
        ELSE
        BEGIN
            RAISERROR(N'Операция не имеет безопасного маршрута выполнения', 16, 1);
            RETURN;
        END

        INSERT INTO dbo.Лог_Действий (
            Пользователь_ID, Действие, Таблица, Статус, Параметры, Результат, Время_Выполнения_Мс
        )
        VALUES (
            @КтоЗапустил,
            N'Выполнение административной операции: ' + @Код,
            N'Админ_Операции',
            N'Успешно',
            @ПараметрыJSON,
            @Причина,
            DATEDIFF(MILLISECOND, @Start, SYSDATETIME())
        );

        SELECT 1 AS Выполнено, @Код AS Код, @Name AS Операция, N'Операция выполнена' AS Сообщение;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.Лог_Действий (
            Пользователь_ID, Действие, Таблица, Статус, Параметры, Результат, Время_Выполнения_Мс
        )
        VALUES (
            @КтоЗапустил,
            N'Ошибка административной операции: ' + ISNULL(@Код, N''),
            N'Админ_Операции',
            N'Ошибка',
            @ПараметрыJSON,
            ERROR_MESSAGE(),
            DATEDIFF(MILLISECOND, @Start, SYSDATETIME())
        );
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьИнфраструктурныйСтатус
    @КтоЗапросил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоЗапросил;

    SELECT
        N'SQL Server' AS Компонент,
        CONVERT(NVARCHAR(200), SERVERPROPERTY(N'Edition')) AS Значение,
        CONVERT(NVARCHAR(200), SERVERPROPERTY(N'ProductVersion')) AS Версия,
        N'Информация' AS Статус,
        N'Экземпляр базы данных AIS' AS Описание;

    BEGIN TRY
        SELECT
            N'Конфигурация сервера' AS Компонент,
            name AS Ключ,
            CONVERT(NVARCHAR(100), value_in_use) AS Значение,
            CASE WHEN value_in_use = 1 THEN N'Активно' ELSE N'Отключено' END AS Статус,
            description AS Описание
        FROM sys.configurations
        WHERE name IN (N'Database Mail XPs', N'Agent XPs');
    END TRY
    BEGIN CATCH
        SELECT
            N'Конфигурация сервера' AS Компонент,
            N'Database Mail XPs / Agent XPs' AS Ключ,
            NULL AS Значение,
            N'Недоступно' AS Статус,
            ERROR_MESSAGE() AS Описание;
    END CATCH;

    BEGIN TRY
        SELECT
            N'Database Mail' AS Компонент,
            name AS Ключ,
            CONVERT(NVARCHAR(100), profile_id) AS Значение,
            N'Профиль найден' AS Статус,
            N'msdb.dbo.sysmail_profile' AS Описание
        FROM msdb.dbo.sysmail_profile
        ORDER BY name;
    END TRY
    BEGIN CATCH
        SELECT
            N'Database Mail' AS Компонент,
            N'Профили' AS Ключ,
            NULL AS Значение,
            N'Недоступно' AS Статус,
            ERROR_MESSAGE() AS Описание;
    END CATCH;

    SELECT
        N'Настройки AIS' AS Компонент,
        Ключ,
        Значение,
        CASE WHEN ТолькоДляЧтения = 1 THEN N'Только чтение' ELSE N'Управляется' END AS Статус,
        Описание
    FROM dbo.Настройки_Системы
    WHERE Ключ IN (
        N'Безопасность.ВосстановлениеПароля.DatabaseMailProfile',
        N'Безопасность.ВосстановлениеПароля.PublicBaseUrl',
        N'PublicBaseUrl',
        N'SKUD.SharedSecret',
        N'1C.ExportPath'
    )
    ORDER BY Ключ;

    IF OBJECT_ID(N'dbo.Плановый_Отчет', N'U') IS NOT NULL
    BEGIN
        SELECT
            N'Плановые отчеты' AS Компонент,
            Код_Отчета AS Ключ,
            ISNULL(Agent_Job_Name, N'') AS Значение,
            CASE WHEN Активен = 1 THEN N'Активен' ELSE N'Отключен' END AS Статус,
            Название AS Описание
        FROM dbo.Плановый_Отчет
        ORDER BY Код_Отчета;
    END

    IF OBJECT_ID(N'dbo.СКУД_Событие', N'U') IS NOT NULL
    BEGIN
        SELECT
            N'СКУД' AS Компонент,
            N'События за 24 часа' AS Ключ,
            CONVERT(NVARCHAR(100), COUNT_BIG(*)) AS Значение,
            N'Мониторинг' AS Статус,
            N'Последнее событие: ' + ISNULL(CONVERT(NVARCHAR(30), MAX(Время_События), 120), N'нет') AS Описание
        FROM dbo.СКУД_Событие
        WHERE Время_События >= DATEADD(DAY, -1, GETDATE());
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПоискСтудентов
    @ПоисковыйЗапрос NVARCHAR(200) = NULL,
    @Группа_ID INT = NULL,
    @ТолькоАктивные BIT = 1,
    @Страница INT = 1,
    @РазмерСтраницы INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Начало INT = (@Страница - 1) * @РазмерСтраницы;

    WITH Результаты AS (
        SELECT
            s.Студент_ID,
            s.Пользователь_ID,
            s.ФИО,
            s.Группа_ID,
            g.Название AS Название_Группы,
            g.Год_Поступления,
            g.Специальность_ID,
            sp.Название AS Специальность,
            u.Логин,
            u.Email,
            u.Телефон,
            u.Активен,
            s.Дата_Поступления,
            s.Дата_Рождения,
            s.Пол,
            s.Адрес,
            s.Телефон_Родителей,
            s.Примечание,
            ROW_NUMBER() OVER (ORDER BY s.ФИО) AS Номер
        FROM dbo.Студент s
        INNER JOIN dbo.Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
        INNER JOIN dbo.Учебная_Группа g ON s.Группа_ID = g.Группа_ID
        LEFT JOIN dbo.Специальность sp ON sp.Специальность_ID = g.Специальность_ID
        WHERE (@ТолькоАктивные = 0 OR u.Активен = 1)
          AND (@Группа_ID IS NULL OR s.Группа_ID = @Группа_ID)
          AND (
            @ПоисковыйЗапрос IS NULL
            OR s.ФИО LIKE N'%' + @ПоисковыйЗапрос + N'%'
            OR u.Логин LIKE N'%' + @ПоисковыйЗапрос + N'%'
            OR u.Email LIKE N'%' + @ПоисковыйЗапрос + N'%'
            OR g.Название LIKE N'%' + @ПоисковыйЗапрос + N'%'
          )
    )
    SELECT
        *,
        (SELECT COUNT(*) FROM Результаты) AS ВсегоЗаписей,
        @Страница AS ТекущаяСтраница,
        @РазмерСтраницы AS РазмерСтраницы
    FROM Результаты
    WHERE Номер BETWEEN @Начало + 1 AND @Начало + @РазмерСтраницы
    ORDER BY Номер;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьПреподавателей
    @Кафедра NVARCHAR(100) = NULL,
    @ТолькоАктивные BIT = 1,
    @Сортировка NVARCHAR(50) = N'ФИО'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Преподаватель_ID,
        p.Пользователь_ID,
        p.ФИО,
        p.Кафедра,
        p.Ученая_Степень,
        p.Должность,
        p.Телефон_Рабочий,
        p.Email_Рабочий,
        p.Дата_Найма,
        u.Логин,
        u.Email,
        u.Телефон,
        u.Активен,
        COUNT(DISTINCT d.Дисциплина_ID) AS КоличествоДисциплин,
        COUNT(DISTINCT g.Группа_ID) AS КоличествоГруппКуратор
    FROM dbo.Преподаватель p
    INNER JOIN dbo.Пользователь u ON p.Пользователь_ID = u.Пользователь_ID
    LEFT JOIN dbo.Дисциплина d ON p.Преподаватель_ID = d.Преподаватель_ID
    LEFT JOIN dbo.Учебная_Группа g ON p.Преподаватель_ID = g.Куратор_ID
    WHERE (@Кафедра IS NULL OR p.Кафедра = @Кафедра)
      AND (@ТолькоАктивные = 0 OR u.Активен = 1)
    GROUP BY
        p.Преподаватель_ID, p.Пользователь_ID, p.ФИО, p.Кафедра, p.Ученая_Степень, p.Должность,
        p.Телефон_Рабочий, p.Email_Рабочий, p.Дата_Найма,
        u.Логин, u.Email, u.Телефон, u.Активен
    ORDER BY
        CASE WHEN @Сортировка = N'ФИО' THEN p.ФИО END,
        CASE WHEN @Сортировка = N'Кафедра' THEN p.Кафедра END,
        CASE WHEN @Сортировка = N'ДатаНайма' THEN p.Дата_Найма END DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьУчебныеГруппы
    @Год_Поступления INT = NULL,
    @Статус NVARCHAR(20) = NULL,
    @Сортировка NVARCHAR(50) = N'Название'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        g.Группа_ID,
        g.Название,
        g.Год_Поступления,
        g.Статус,
        g.Куратор_ID,
        p.ФИО AS ФИО_Куратора,
        g.Специальность_ID,
        sp.Название AS Специальность,
        sp.Код AS Код_Специальности,
        g.Примечание,
        g.Дата_Создания,
        COUNT(s.Студент_ID) AS КоличествоСтудентов
    FROM dbo.Учебная_Группа g
    LEFT JOIN dbo.Преподаватель p ON g.Куратор_ID = p.Преподаватель_ID
    LEFT JOIN dbo.Специальность sp ON sp.Специальность_ID = g.Специальность_ID
    LEFT JOIN dbo.Студент s ON g.Группа_ID = s.Группа_ID
    WHERE (@Год_Поступления IS NULL OR g.Год_Поступления = @Год_Поступления)
      AND (@Статус IS NULL OR g.Статус = @Статус)
    GROUP BY
        g.Группа_ID, g.Название, g.Год_Поступления, g.Статус,
        g.Куратор_ID, p.ФИО, g.Специальность_ID, sp.Название, sp.Код, g.Примечание, g.Дата_Создания
    ORDER BY
        CASE WHEN @Сортировка = N'Название' THEN g.Название END,
        CASE WHEN @Сортировка = N'ГодПоступления' THEN g.Год_Поступления END DESC,
        CASE WHEN @Сортировка = N'Статус' THEN g.Статус END;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьСтудентаСУчетнойЗаписью
    @Логин NVARCHAR(50),
    @Пароль NVARCHAR(255),
    @Email NVARCHAR(100) = NULL,
    @Телефон NVARCHAR(20) = NULL,
    @ФИО NVARCHAR(300),
    @Группа_ID INT,
    @Дата_Поступления DATE = NULL,
    @Дата_Рождения DATE = NULL,
    @Пол NVARCHAR(20) = NULL,
    @Адрес NVARCHAR(600) = NULL,
    @Телефон_Родителей NVARCHAR(40) = NULL,
    @Примечание NVARCHAR(1000) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоСоздал;

    DECLARE @RoleId INT = (SELECT Роль_ID FROM dbo.Роль WHERE Название = N'Студент');
    IF @RoleId IS NULL
    BEGIN
        RAISERROR(N'Роль Студент не найдена', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Учебная_Группа WHERE Группа_ID = @Группа_ID)
    BEGIN
        RAISERROR(N'Учебная группа не найдена', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM dbo.Пользователь WHERE Логин = @Логин)
    BEGIN
        RAISERROR(N'Логин уже существует', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Salt NVARCHAR(32) = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
        DECLARE @Hash NVARCHAR(64) = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Пароль + @Salt), 2);

        INSERT INTO dbo.Пользователь (Логин, Хэш_Пароля, Соль, Email, Роль_ID, Телефон, Активен, Примечание)
        VALUES (@Логин, @Hash, @Salt, @Email, @RoleId, @Телефон, 1, @Примечание);

        DECLARE @UserId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Студент (
            Пользователь_ID, ФИО, Группа_ID, Дата_Поступления, Дата_Рождения,
            Пол, Адрес, Телефон_Родителей, Примечание
        )
        VALUES (
            @UserId, @ФИО, @Группа_ID, ISNULL(@Дата_Поступления, CONVERT(date, GETDATE())),
            @Дата_Рождения, @Пол, @Адрес, @Телефон_Родителей, @Примечание
        );

        DECLARE @StudentId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание студента с учетной записью', N'Студент', @StudentId, N'Успешно');

        COMMIT TRANSACTION;

        SELECT @UserId AS Пользователь_ID, @StudentId AS Студент_ID, N'Студент и учетная запись созданы' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьПреподавателяСУчетнойЗаписью
    @Логин NVARCHAR(50),
    @Пароль NVARCHAR(255),
    @Email NVARCHAR(100) = NULL,
    @Телефон NVARCHAR(20) = NULL,
    @ФИО NVARCHAR(300),
    @Кафедра NVARCHAR(200) = NULL,
    @Ученая_Степень NVARCHAR(200) = NULL,
    @Должность NVARCHAR(200) = NULL,
    @Телефон_Рабочий NVARCHAR(40) = NULL,
    @Email_Рабочий NVARCHAR(200) = NULL,
    @Дата_Найма DATE = NULL,
    @Примечание NVARCHAR(1000) = NULL,
    @Роль_ID INT = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоСоздал;

    IF @Роль_ID IS NULL
        SELECT @Роль_ID = Роль_ID FROM dbo.Роль WHERE Название = N'Преподаватель';

    IF @Роль_ID IS NULL
    BEGIN
        RAISERROR(N'Роль преподавателя не найдена', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM dbo.Пользователь WHERE Логин = @Логин)
    BEGIN
        RAISERROR(N'Логин уже существует', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Salt NVARCHAR(32) = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
        DECLARE @Hash NVARCHAR(64) = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Пароль + @Salt), 2);

        INSERT INTO dbo.Пользователь (Логин, Хэш_Пароля, Соль, Email, Роль_ID, Телефон, Активен, Примечание)
        VALUES (@Логин, @Hash, @Salt, @Email, @Роль_ID, @Телефон, 1, @Примечание);

        DECLARE @UserId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Преподаватель (
            Пользователь_ID, ФИО, Кафедра, Ученая_Степень, Должность,
            Телефон_Рабочий, Email_Рабочий, Дата_Найма, Примечание
        )
        VALUES (
            @UserId, @ФИО, @Кафедра, @Ученая_Степень, @Должность,
            @Телефон_Рабочий, @Email_Рабочий, @Дата_Найма, @Примечание
        );

        DECLARE @TeacherId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание преподавателя с учетной записью', N'Преподаватель', @TeacherId, N'Успешно');

        COMMIT TRANSACTION;

        SELECT @UserId AS Пользователь_ID, @TeacherId AS Преподаватель_ID, N'Преподаватель и учетная запись созданы' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ОбновитьПреподавателя
    @Преподаватель_ID INT,
    @ФИО NVARCHAR(300),
    @Кафедра NVARCHAR(200) = NULL,
    @Ученая_Степень NVARCHAR(200) = NULL,
    @Должность NVARCHAR(200) = NULL,
    @Телефон_Рабочий NVARCHAR(40) = NULL,
    @Email_Рабочий NVARCHAR(200) = NULL,
    @Дата_Найма DATE = NULL,
    @Примечание NVARCHAR(1000) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Телефон NVARCHAR(20) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоОбновил;

    IF NOT EXISTS (SELECT 1 FROM dbo.Преподаватель WHERE Преподаватель_ID = @Преподаватель_ID)
    BEGIN
        RAISERROR(N'Преподаватель не найден', 16, 1);
        RETURN;
    END

    UPDATE p
    SET ФИО = @ФИО,
        Кафедра = @Кафедра,
        Ученая_Степень = @Ученая_Степень,
        Должность = @Должность,
        Телефон_Рабочий = @Телефон_Рабочий,
        Email_Рабочий = @Email_Рабочий,
        Дата_Найма = @Дата_Найма,
        Примечание = @Примечание
    FROM dbo.Преподаватель p
    WHERE p.Преподаватель_ID = @Преподаватель_ID;

    UPDATE u
    SET Email = ISNULL(@Email, u.Email),
        Телефон = ISNULL(@Телефон, u.Телефон)
    FROM dbo.Пользователь u
    INNER JOIN dbo.Преподаватель p ON p.Пользователь_ID = u.Пользователь_ID
    WHERE p.Преподаватель_ID = @Преподаватель_ID;

    INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
    VALUES (@КтоОбновил, N'Обновление преподавателя', N'Преподаватель', @Преподаватель_ID, N'Успешно');

    SELECT 1 AS Обновлено, N'Преподаватель обновлен' AS Сообщение;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ОбновитьСпециальность
    @Специальность_ID INT,
    @Название NVARCHAR(150),
    @Код NVARCHAR(20) = NULL,
    @Факультет_ID INT,
    @Описание NVARCHAR(500) = NULL,
    @КтоОбновил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.ПроверитьАдминистратора @КтоОбновил;

    IF NOT EXISTS (SELECT 1 FROM dbo.Специальность WHERE Специальность_ID = @Специальность_ID)
    BEGIN
        RAISERROR(N'Специальность не найдена', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Факультет WHERE Факультет_ID = @Факультет_ID)
    BEGIN
        RAISERROR(N'Факультет не найден', 16, 1);
        RETURN;
    END

    UPDATE dbo.Специальность
    SET Название = @Название,
        Код = @Код,
        Факультет_ID = @Факультет_ID,
        Описание = @Описание
    WHERE Специальность_ID = @Специальность_ID;

    INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
    VALUES (@КтоОбновил, N'Обновление специальности', N'Специальность', @Специальность_ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);

    SELECT 1 AS Обновлено, N'Специальность обновлена' AS Сообщение;
END;
GO

