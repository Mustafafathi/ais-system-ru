USE [Улучшенная];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION dbo.AIS_HTML_ENCODE(@Value NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @Value IS NULL
        RETURN N'';

    DECLARE @Result NVARCHAR(MAX) = @Value;
    SET @Result = REPLACE(@Result, N'&', N'&amp;');
    SET @Result = REPLACE(@Result, N'<', N'&lt;');
    SET @Result = REPLACE(@Result, N'>', N'&gt;');
    SET @Result = REPLACE(@Result, N'"', N'&quot;');
    SET @Result = REPLACE(@Result, N'''', N'&#39;');
    RETURN @Result;
END;
GO

IF OBJECT_ID(N'dbo.Плановый_Отчет', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Плановый_Отчет (
        Плановый_Отчет_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Плановый_Отчет PRIMARY KEY,
        Код_Отчета NVARCHAR(80) NOT NULL,
        Название NVARCHAR(200) NOT NULL,
        Описание NVARCHAR(500) NULL,
        Процедура_Генерации SYSNAME NOT NULL,
        Код_Расписания NVARCHAR(80) NOT NULL,
        Стратегия_Получателей NVARCHAR(50) NOT NULL,
        Формат NVARCHAR(20) NOT NULL CONSTRAINT DF_Плановый_Отчет_Формат DEFAULT N'HTML',
        Активен BIT NOT NULL CONSTRAINT DF_Плановый_Отчет_Активен DEFAULT 1,
        ТолькоДляАдмина BIT NOT NULL CONSTRAINT DF_Плановый_Отчет_ТолькоДляАдмина DEFAULT 0,
        Период_По_Умолчанию NVARCHAR(30) NOT NULL,
        Хранить_Дней INT NOT NULL CONSTRAINT DF_Плановый_Отчет_Хранить DEFAULT 365,
        Agent_Job_Name SYSNAME NULL,
        Ожидаемое_Время TIME(0) NULL,
        Ожидаемый_День_Недели NVARCHAR(20) NULL,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Плановый_Отчет_Создан DEFAULT SYSUTCDATETIME(),
        Дата_Обновления DATETIME2(0) NULL,
        CONSTRAINT UQ_Плановый_Отчет_Код UNIQUE (Код_Отчета),
        CONSTRAINT CHK_Плановый_Отчет_Стратегия CHECK (Стратегия_Получателей IN (N'ADMINS', N'CURATORS_BY_GROUP', N'METHODISTS', N'EXPLICIT')),
        CONSTRAINT CHK_Плановый_Отчет_Формат CHECK (Формат IN (N'HTML'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Получатель_Планового_Отчета', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Получатель_Планового_Отчета (
        Получатель_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Получатель_Планового_Отчета PRIMARY KEY,
        Плановый_Отчет_ID INT NOT NULL,
        Пользователь_ID INT NULL,
        Роль_ID INT NULL,
        Группа_ID INT NULL,
        Куратор_ID INT NULL,
        Email NVARCHAR(200) NULL,
        Тип_Области NVARCHAR(50) NOT NULL CONSTRAINT DF_Получатель_Планового_Отчета_Область DEFAULT N'EXPLICIT',
        Активен BIT NOT NULL CONSTRAINT DF_Получатель_Планового_Отчета_Активен DEFAULT 1,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Получатель_Планового_Отчета_Создан DEFAULT SYSUTCDATETIME(),
        Кто_Создал INT NULL,
        CONSTRAINT FK_Получатель_Планового_Отчета_Отчет FOREIGN KEY (Плановый_Отчет_ID) REFERENCES dbo.Плановый_Отчет(Плановый_Отчет_ID),
        CONSTRAINT FK_Получатель_Планового_Отчета_Пользователь FOREIGN KEY (Пользователь_ID) REFERENCES dbo.Пользователь(Пользователь_ID),
        CONSTRAINT FK_Получатель_Планового_Отчета_Роль FOREIGN KEY (Роль_ID) REFERENCES dbo.Роль(Роль_ID),
        CONSTRAINT FK_Получатель_Планового_Отчета_Группа FOREIGN KEY (Группа_ID) REFERENCES dbo.Учебная_Группа(Группа_ID),
        CONSTRAINT FK_Получатель_Планового_Отчета_Куратор FOREIGN KEY (Куратор_ID) REFERENCES dbo.Преподаватель(Преподаватель_ID),
        CONSTRAINT CHK_Получатель_Планового_Отчета_Target CHECK (
            Пользователь_ID IS NOT NULL OR Роль_ID IS NOT NULL OR Группа_ID IS NOT NULL OR Куратор_ID IS NOT NULL OR Email IS NOT NULL
        )
    );
END;
GO

IF OBJECT_ID(N'dbo.Запуск_Планового_Отчета', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Запуск_Планового_Отчета (
        Запуск_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Запуск_Планового_Отчета PRIMARY KEY,
        Плановый_Отчет_ID INT NOT NULL,
        Код_Отчета NVARCHAR(80) NOT NULL,
        Период_С DATE NOT NULL,
        Период_По DATE NOT NULL,
        Источник_Запуска NVARCHAR(30) NOT NULL,
        SqlAgentJobName SYSNAME NULL,
        SqlAgentJobId UNIQUEIDENTIFIER NULL,
        Начало_Запуска DATETIME2(0) NOT NULL,
        Конец_Запуска DATETIME2(0) NULL,
        Статус NVARCHAR(30) NOT NULL,
        Количество_Строк INT NULL,
        Количество_Получателей INT NULL,
        Количество_Отправлено INT NULL,
        Количество_Ошибок INT NULL,
        Ошибка NVARCHAR(MAX) NULL,
        Идемпотентный_Ключ NVARCHAR(200) NOT NULL,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Запуск_Планового_Отчета_Создан DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Запуск_Планового_Отчета_Отчет FOREIGN KEY (Плановый_Отчет_ID) REFERENCES dbo.Плановый_Отчет(Плановый_Отчет_ID),
        CONSTRAINT CHK_Запуск_Планового_Отчета_Статус CHECK (Статус IN (N'Создан', N'Выполняется', N'Успешно', N'Частично', N'Ошибка', N'Пропущено', N'Дубликат'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Артефакт_Планового_Отчета', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Артефакт_Планового_Отчета (
        Артефакт_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Артефакт_Планового_Отчета PRIMARY KEY,
        Запуск_ID BIGINT NOT NULL,
        Тип_Содержимого NVARCHAR(50) NOT NULL,
        Заголовок NVARCHAR(300) NOT NULL,
        Тело_HTML NVARCHAR(MAX) NULL,
        Данные_JSON NVARCHAR(MAX) NULL,
        Путь_К_Файлу NVARCHAR(500) NULL,
        Хэш_Содержимого NVARCHAR(128) NULL,
        Истекает_После DATETIME2(0) NULL,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Артефакт_Планового_Отчета_Создан DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Артефакт_Планового_Отчета_Запуск FOREIGN KEY (Запуск_ID) REFERENCES dbo.Запуск_Планового_Отчета(Запуск_ID)
    );
END;
GO

IF OBJECT_ID(N'dbo.Доставка_Планового_Отчета', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Доставка_Планового_Отчета (
        Доставка_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Доставка_Планового_Отчета PRIMARY KEY,
        Запуск_ID BIGINT NOT NULL,
        Получатель_ID INT NULL,
        Пользователь_ID INT NULL,
        Email NVARCHAR(200) NOT NULL,
        Имя_Получателя NVARCHAR(200) NULL,
        Область NVARCHAR(100) NULL,
        MailItemId INT NULL,
        Статус NVARCHAR(30) NOT NULL,
        Ошибка NVARCHAR(MAX) NULL,
        Время_Постановки DATETIME2(0) NULL,
        Время_Отправки DATETIME2(0) NULL,
        Дата_Создания DATETIME2(0) NOT NULL CONSTRAINT DF_Доставка_Планового_Отчета_Создан DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Доставка_Планового_Отчета_Запуск FOREIGN KEY (Запуск_ID) REFERENCES dbo.Запуск_Планового_Отчета(Запуск_ID),
        CONSTRAINT FK_Доставка_Планового_Отчета_Получатель FOREIGN KEY (Получатель_ID) REFERENCES dbo.Получатель_Планового_Отчета(Получатель_ID),
        CONSTRAINT FK_Доставка_Планового_Отчета_Пользователь FOREIGN KEY (Пользователь_ID) REFERENCES dbo.Пользователь(Пользователь_ID),
        CONSTRAINT CHK_Доставка_Планового_Отчета_Статус CHECK (Статус IN (N'Ожидает', N'Отправлено', N'Ошибка', N'Пропущено'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Запуск_Планового_Отчета_Код_Период' AND object_id = OBJECT_ID(N'dbo.Запуск_Планового_Отчета'))
    CREATE INDEX IX_Запуск_Планового_Отчета_Код_Период ON dbo.Запуск_Планового_Отчета(Код_Отчета, Период_С, Период_По, Статус);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Запуск_Планового_Отчета_Ключ' AND object_id = OBJECT_ID(N'dbo.Запуск_Планового_Отчета'))
    CREATE INDEX IX_Запуск_Планового_Отчета_Ключ ON dbo.Запуск_Планового_Отчета(Идемпотентный_Ключ);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Доставка_Планового_Отчета_Запуск' AND object_id = OBJECT_ID(N'dbo.Доставка_Планового_Отчета'))
    CREATE INDEX IX_Доставка_Планового_Отчета_Запуск ON dbo.Доставка_Планового_Отчета(Запуск_ID, Статус);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Отчеты.DatabaseMailProfile')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Отчеты.DatabaseMailProfile', N'AIS Database Mail', N'Строка', N'Отчеты', N'Плановые', N'Профиль Database Mail для плановых отчетов', 1, 0, GETDATE(), NULL, GETDATE());
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Отчеты.Плановые.Включены')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Отчеты.Плановые.Включены', N'true', N'Булево', N'Отчеты', N'Плановые', N'Разрешить отправку плановых отчетов через Database Mail', 1, 0, GETDATE(), NULL, GETDATE());
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Отчеты.Плановые.ХранениеДней')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Отчеты.Плановые.ХранениеДней', N'365', N'Число', N'Отчеты', N'Плановые', N'Срок хранения артефактов плановых отчетов', 1, 0, GETDATE(), NULL, GETDATE());
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Отчеты.Плановые.ТестовыйПолучатель')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Отчеты.Плановые.ТестовыйПолучатель', NULL, N'Строка', N'Отчеты', N'Плановые', N'Email для тестовых запусков плановых отчетов', 1, 0, GETDATE(), NULL, GETDATE());
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Отчеты.Плановые.ЗапретДубликатов')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Отчеты.Плановые.ЗапретДубликатов', N'true', N'Булево', N'Отчеты', N'Плановые', N'Не отправлять повторно отчет за тот же период без явного разрешения', 1, 0, GETDATE(), NULL, GETDATE());
END;
GO

MERGE dbo.Плановый_Отчет AS target
USING (VALUES
    (N'DAILY_MAINTENANCE', N'Ежедневный отчет обслуживания', N'Состояние системы, целостность данных, резервные копии и последние ошибки', N'СформироватьОтчетОбслуживания', N'DAILY_0800', N'ADMINS', N'DAY', 365, N'AIS_Daily_Maintenance_Report', CONVERT(TIME(0), '08:00'), NULL),
    (N'WEEKLY_ATTENDANCE_ANALYTICS', N'Еженедельная аналитика посещаемости', N'Посещаемость по группам, студенты риска и ожидающие обоснования', N'СформироватьОтчетПосещаемостиСАналитикой', N'MONDAY_0900', N'CURATORS_BY_GROUP', N'PREVIOUS_7_DAYS', 365, N'AIS_Weekly_Attendance_Analytics', CONVERT(TIME(0), '09:00'), N'Понедельник'),
    (N'FRIDAY_USERS_GAPS', N'Отчет по пользователям и пропускам данных', N'Проблемы учетных записей, карт, расписания и незаполненных занятий', N'СформироватьОтчетПользователейИПропусков', N'FRIDAY_1800', N'METHODISTS', N'PREVIOUS_7_DAYS', 365, N'AIS_Friday_Users_Gaps_Report', CONVERT(TIME(0), '18:00'), N'Пятница')
) AS source (Код_Отчета, Название, Описание, Процедура_Генерации, Код_Расписания, Стратегия_Получателей, Период_По_Умолчанию, Хранить_Дней, Agent_Job_Name, Ожидаемое_Время, Ожидаемый_День_Недели)
ON target.Код_Отчета = source.Код_Отчета
WHEN MATCHED THEN
    UPDATE SET Название = source.Название,
               Описание = source.Описание,
               Процедура_Генерации = source.Процедура_Генерации,
               Код_Расписания = source.Код_Расписания,
               Стратегия_Получателей = source.Стратегия_Получателей,
               Период_По_Умолчанию = source.Период_По_Умолчанию,
               Хранить_Дней = source.Хранить_Дней,
               Agent_Job_Name = source.Agent_Job_Name,
               Ожидаемое_Время = source.Ожидаемое_Время,
               Ожидаемый_День_Недели = source.Ожидаемый_День_Недели,
               Дата_Обновления = SYSUTCDATETIME()
WHEN NOT MATCHED THEN
    INSERT (Код_Отчета, Название, Описание, Процедура_Генерации, Код_Расписания, Стратегия_Получателей, Период_По_Умолчанию, Хранить_Дней, Agent_Job_Name, Ожидаемое_Время, Ожидаемый_День_Недели)
    VALUES (source.Код_Отчета, source.Название, source.Описание, source.Процедура_Генерации, source.Код_Расписания, source.Стратегия_Получателей, source.Период_По_Умолчанию, source.Хранить_Дней, source.Agent_Job_Name, source.Ожидаемое_Время, source.Ожидаемый_День_Недели);
GO

CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетОбслуживания
    @Дата DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Дата = ISNULL(@Дата, CAST(GETDATE() AS DATE));

    DECLARE @Health TABLE (Компонент NVARCHAR(100), Статус NVARCHAR(50), Значение NVARCHAR(200), Приоритет INT);
    DECLARE @Integrity TABLE (Проверка NVARCHAR(200), Статус NVARCHAR(20), Сообщение NVARCHAR(MAX));

    DECLARE @ActiveUsers INT;
    SELECT @ActiveUsers = COUNT(*) FROM dbo.Пользователь WHERE Активен = 1;

    DECLARE @ActiveSessions INT;
    SELECT @ActiveSessions = COUNT(*)
    FROM dbo.Сессия_Пользователя
    WHERE Активна = 1 AND Время_Истечения > GETDATE();

    DECLARE @LessonsToday INT;
    SELECT @LessonsToday = COUNT(*)
    FROM dbo.Занятие
    WHERE Дата_Занятия = @Дата;

    DECLARE @CriticalErrors INT;
    SELECT @CriticalErrors = COUNT(*)
    FROM dbo.Ошибки_Системы
    WHERE Дата_Возникновения >= @Дата
      AND Дата_Возникновения < DATEADD(DAY, 1, @Дата)
      AND Уровень_Ошибки IN (N'Высокий', N'Критический');

    DECLARE @LastBackup DATETIME;
    SELECT @LastBackup = MAX(Дата_Завершения)
    FROM dbo.Резервные_Копии
    WHERE Статус IN (N'Успешно', N'Завершено');

    INSERT INTO @Health (Компонент, Статус, Значение, Приоритет)
    VALUES
        (N'База данных', N'Работает', N'Версия: ' + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 1),
        (N'Пользователи', CASE WHEN @ActiveUsers > 0 THEN N'Активны' ELSE N'Нет активных' END, N'Активных: ' + CAST(@ActiveUsers AS NVARCHAR(20)), 2),
        (N'Сессии', CASE WHEN @ActiveSessions > 0 THEN N'Активны' ELSE N'Нет активных' END, N'Активных сессий: ' + CAST(@ActiveSessions AS NVARCHAR(20)), 3),
        (N'Занятия сегодня', CASE WHEN @LessonsToday > 0 THEN N'Есть занятия' ELSE N'Нет занятий' END, N'Количество: ' + CAST(@LessonsToday AS NVARCHAR(20)), 4),
        (N'Критические ошибки', CASE WHEN @CriticalErrors = 0 THEN N'OK' ELSE N'Внимание' END, N'За день: ' + CAST(@CriticalErrors AS NVARCHAR(20)), 5),
        (N'Резервное копирование', CASE WHEN @LastBackup IS NULL THEN N'Нет данных' WHEN @LastBackup < DATEADD(DAY, -1, GETDATE()) THEN N'Требует внимания' ELSE N'OK' END, ISNULL(CONVERT(NVARCHAR(19), @LastBackup, 120), N'Нет успешных копий'), 6);

    DECLARE @StudentsWithoutUsers INT;
    SELECT @StudentsWithoutUsers = COUNT(*)
    FROM dbo.Студент s
    LEFT JOIN dbo.Пользователь u ON u.Пользователь_ID = s.Пользователь_ID
    WHERE u.Пользователь_ID IS NULL;

    DECLARE @UsersWithoutRole INT;
    SELECT @UsersWithoutRole = COUNT(*)
    FROM dbo.Пользователь u
    LEFT JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
    WHERE r.Роль_ID IS NULL;

    DECLARE @LessonsWithoutSchedule INT;
    SELECT @LessonsWithoutSchedule = COUNT(*)
    FROM dbo.Занятие z
    LEFT JOIN dbo.Расписание r ON r.Расписание_ID = z.Расписание_ID
    WHERE r.Расписание_ID IS NULL;

    DECLARE @AttendanceWithoutStudent INT;
    SELECT @AttendanceWithoutStudent = COUNT(*)
    FROM dbo.Посещаемость p
    LEFT JOIN dbo.Студент s ON s.Студент_ID = p.Студент_ID
    WHERE s.Студент_ID IS NULL;

    DECLARE @AttendanceWithoutLesson INT;
    SELECT @AttendanceWithoutLesson = COUNT(*)
    FROM dbo.Посещаемость p
    LEFT JOIN dbo.Занятие z ON z.Занятие_ID = p.Занятие_ID
    WHERE z.Занятие_ID IS NULL;

    INSERT INTO @Integrity (Проверка, Статус, Сообщение)
    VALUES
        (N'Студенты без пользователей', CASE WHEN @StudentsWithoutUsers = 0 THEN N'OK' ELSE N'Ошибка' END, N'Найдено: ' + CAST(@StudentsWithoutUsers AS NVARCHAR(20))),
        (N'Пользователи без роли', CASE WHEN @UsersWithoutRole = 0 THEN N'OK' ELSE N'Ошибка' END, N'Найдено: ' + CAST(@UsersWithoutRole AS NVARCHAR(20))),
        (N'Занятия без расписания', CASE WHEN @LessonsWithoutSchedule = 0 THEN N'OK' ELSE N'Ошибка' END, N'Найдено: ' + CAST(@LessonsWithoutSchedule AS NVARCHAR(20))),
        (N'Посещаемость без студентов', CASE WHEN @AttendanceWithoutStudent = 0 THEN N'OK' ELSE N'Ошибка' END, N'Найдено: ' + CAST(@AttendanceWithoutStudent AS NVARCHAR(20))),
        (N'Посещаемость без занятий', CASE WHEN @AttendanceWithoutLesson = 0 THEN N'OK' ELSE N'Ошибка' END, N'Найдено: ' + CAST(@AttendanceWithoutLesson AS NVARCHAR(20)));

    DECLARE @HealthRows NVARCHAR(MAX);
    SELECT @HealthRows = ISNULL((
        SELECT STRING_AGG(
            N'<tr><td>' + dbo.AIS_HTML_ENCODE(Компонент) + N'</td><td>' + dbo.AIS_HTML_ENCODE(Статус) + N'</td><td>' + dbo.AIS_HTML_ENCODE(Значение) + N'</td></tr>',
            N''
        )
        FROM @Health
    ), N'');

    DECLARE @IntegrityRows NVARCHAR(MAX);
    SELECT @IntegrityRows = ISNULL((
        SELECT STRING_AGG(
            N'<tr><td>' + dbo.AIS_HTML_ENCODE(Проверка) + N'</td><td>' + dbo.AIS_HTML_ENCODE(Статус) + N'</td><td>' + dbo.AIS_HTML_ENCODE(Сообщение) + N'</td></tr>',
            N''
        )
        FROM @Integrity
    ), N'');

    DECLARE @Title NVARCHAR(300) = N'AIS: ежедневный отчет обслуживания за ' + CONVERT(NVARCHAR(10), @Дата, 104);
    DECLARE @Body NVARCHAR(MAX) =
        N'<h2>' + dbo.AIS_HTML_ENCODE(@Title) + N'</h2>' +
        N'<p>Сформировано SQL Server Agent / Database Mail. Бизнес-логика и аудит выполняются в SQL Server.</p>' +
        N'<h3>Ключевые показатели</h3><table border="1" cellpadding="6" cellspacing="0">' +
        N'<tr><th>Показатель</th><th>Значение</th></tr>' +
        N'<tr><td>Критические ошибки за день</td><td>' + CAST(@CriticalErrors AS NVARCHAR(20)) + N'</td></tr>' +
        N'<tr><td>Последняя успешная резервная копия</td><td>' + dbo.AIS_HTML_ENCODE(ISNULL(CONVERT(NVARCHAR(19), @LastBackup, 120), N'Нет данных')) + N'</td></tr>' +
        N'</table><h3>Состояние системы</h3><table border="1" cellpadding="6" cellspacing="0"><tr><th>Компонент</th><th>Статус</th><th>Значение</th></tr>' +
        @HealthRows + N'</table><h3>Целостность данных</h3><table border="1" cellpadding="6" cellspacing="0"><tr><th>Проверка</th><th>Статус</th><th>Сообщение</th></tr>' +
        @IntegrityRows + N'</table>';

    SELECT
        N'DAILY_MAINTENANCE' AS Код_Отчета,
        @Title AS Заголовок,
        @Body AS Тело_HTML,
        (SELECT COUNT(*) FROM @Health) + (SELECT COUNT(*) FROM @Integrity) AS Количество_Строк;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетПосещаемостиСАналитикой
    @Дата_С DATE,
    @Дата_По DATE,
    @Куратор_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH GroupStats AS (
        SELECT
            g.Группа_ID,
            g.Название AS Группа,
            pr.ФИО AS Куратор,
            COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентов,
            COUNT(DISTINCT z.Занятие_ID) AS ВсегоЗанятий,
            SUM(CASE WHEN z.Занятие_ID IS NOT NULL THEN 1 ELSE 0 END) AS ОжидаемыхОтметок,
            SUM(CASE WHEN pos.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствий,
            SUM(CASE WHEN pos.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствий,
            SUM(CASE WHEN pos.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опозданий,
            SUM(CASE WHEN pos.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS Уважительных
        FROM dbo.Учебная_Группа g
        LEFT JOIN dbo.Преподаватель pr ON pr.Преподаватель_ID = g.Куратор_ID
        LEFT JOIN dbo.Студент s ON s.Группа_ID = g.Группа_ID
        LEFT JOIN dbo.Расписание r ON r.Группа_ID = g.Группа_ID
        LEFT JOIN dbo.Занятие z ON z.Расписание_ID = r.Расписание_ID
            AND z.Дата_Занятия BETWEEN @Дата_С AND @Дата_По
        LEFT JOIN dbo.Посещаемость pos ON pos.Занятие_ID = z.Занятие_ID
            AND pos.Студент_ID = s.Студент_ID
        WHERE (@Куратор_ID IS NULL OR g.Куратор_ID = @Куратор_ID)
          AND g.Статус = N'Активна'
        GROUP BY g.Группа_ID, g.Название, pr.ФИО
    ),
    RiskRows AS (
        SELECT
            Группа,
            Куратор,
            ВсегоСтудентов,
            ВсегоЗанятий,
            Присутствий,
            Отсутствий,
            Опозданий,
            Уважительных,
            CAST(Присутствий * 100.0 / NULLIF(ОжидаемыхОтметок, 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
        FROM GroupStats
    )
    SELECT *
    INTO #AttendanceReport
    FROM RiskRows;

    DECLARE @Rows NVARCHAR(MAX);
    SELECT @Rows = ISNULL((
        SELECT STRING_AGG(
            N'<tr><td>' + dbo.AIS_HTML_ENCODE(Группа) + N'</td><td>' +
            dbo.AIS_HTML_ENCODE(ISNULL(Куратор, N'Не назначен')) + N'</td><td>' +
            CAST(ВсегоСтудентов AS NVARCHAR(20)) + N'</td><td>' +
            CAST(ВсегоЗанятий AS NVARCHAR(20)) + N'</td><td>' +
            dbo.AIS_HTML_ENCODE(ISNULL(CAST(ПроцентПосещаемости AS NVARCHAR(20)), N'Нет данных')) + N'</td><td>' +
            CAST(ISNULL(Отсутствий, 0) AS NVARCHAR(20)) + N'</td></tr>',
            N''
        )
        FROM #AttendanceReport
    ), N'');

    DECLARE @PendingExcuses INT;
    SELECT @PendingExcuses = COUNT(*)
    FROM dbo.Обоснования_Отсутствия o
    JOIN dbo.Студент s ON s.Студент_ID = o.Студент_ID
    JOIN dbo.Учебная_Группа g ON g.Группа_ID = s.Группа_ID
    WHERE o.Дата_Подачи >= @Дата_С
      AND o.Дата_Подачи < DATEADD(DAY, 1, @Дата_По)
      AND o.Статус IN (N'На рассмотрении', N'Ожидает', N'Новое')
      AND (@Куратор_ID IS NULL OR g.Куратор_ID = @Куратор_ID);

    DECLARE @Title NVARCHAR(300) =
        N'AIS: аналитика посещаемости за ' + CONVERT(NVARCHAR(10), @Дата_С, 104) + N' - ' + CONVERT(NVARCHAR(10), @Дата_По, 104);

    DECLARE @Body NVARCHAR(MAX) =
        N'<h2>' + dbo.AIS_HTML_ENCODE(@Title) + N'</h2>' +
        N'<p>Отчет сформирован по данным посещаемости SQL Server. Для кураторов применена область назначенных групп.</p>' +
        N'<p>Ожидающих обоснований за период: <strong>' + CAST(@PendingExcuses AS NVARCHAR(20)) + N'</strong></p>' +
        N'<table border="1" cellpadding="6" cellspacing="0"><tr><th>Группа</th><th>Куратор</th><th>Студентов</th><th>Занятий</th><th>% посещаемости</th><th>Отсутствий</th></tr>' +
        CASE WHEN @Rows = N'' THEN N'<tr><td colspan="6">Нет данных за выбранный период</td></tr>' ELSE @Rows END +
        N'</table>';

    SELECT
        N'WEEKLY_ATTENDANCE_ANALYTICS' AS Код_Отчета,
        @Title AS Заголовок,
        @Body AS Тело_HTML,
        (SELECT COUNT(*) FROM #AttendanceReport) AS Количество_Строк;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетПользователейИПропусков
    @Дата_С DATE,
    @Дата_По DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentUsersWithoutProfile INT;
    SELECT @StudentUsersWithoutProfile = COUNT(*)
    FROM dbo.Пользователь u
    JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
    LEFT JOIN dbo.Студент s ON s.Пользователь_ID = u.Пользователь_ID
    WHERE u.Активен = 1 AND r.Название = N'Студент' AND s.Студент_ID IS NULL;

    DECLARE @TeacherUsersWithoutProfile INT;
    SELECT @TeacherUsersWithoutProfile = COUNT(*)
    FROM dbo.Пользователь u
    JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
    LEFT JOIN dbo.Преподаватель p ON p.Пользователь_ID = u.Пользователь_ID
    WHERE u.Активен = 1 AND r.Название IN (N'Преподаватель', N'Куратор') AND p.Преподаватель_ID IS NULL;

    DECLARE @StudentsWithoutCards INT;
    SELECT @StudentsWithoutCards = COUNT(*)
    FROM dbo.Студент s
    JOIN dbo.Пользователь u ON u.Пользователь_ID = s.Пользователь_ID
    WHERE u.Активен = 1
      AND NOT EXISTS (SELECT 1 FROM dbo.СКУД_Карта c WHERE c.Студент_ID = s.Студент_ID AND c.Статус IN (N'Активна', N'Активен'));

    DECLARE @ClassesWithoutAttendance INT;
    SELECT @ClassesWithoutAttendance = COUNT(*)
    FROM dbo.Занятие z
    WHERE z.Дата_Занятия BETWEEN @Дата_С AND @Дата_По
      AND z.Статус NOT IN (N'Отменено', N'Перенесено')
      AND NOT EXISTS (SELECT 1 FROM dbo.Посещаемость p WHERE p.Занятие_ID = z.Занятие_ID);

    DECLARE @SchedulesWithoutRoom INT;
    SELECT @SchedulesWithoutRoom = COUNT(*)
    FROM dbo.Расписание r
    JOIN dbo.Учебная_Группа g ON g.Группа_ID = r.Группа_ID
    WHERE g.Статус = N'Активна'
      AND r.Аудитория_ID IS NULL
      AND (r.Кабинет IS NULL OR LTRIM(RTRIM(r.Кабинет)) = N'');

    DECLARE @Title NVARCHAR(300) =
        N'AIS: пользователи и пропуски данных за ' + CONVERT(NVARCHAR(10), @Дата_С, 104) + N' - ' + CONVERT(NVARCHAR(10), @Дата_По, 104);

    DECLARE @Body NVARCHAR(MAX) =
        N'<h2>' + dbo.AIS_HTML_ENCODE(@Title) + N'</h2>' +
        N'<p>Отчет предназначен для методиста: учетные записи, карты СКУД, расписание и занятия без отметок.</p>' +
        N'<table border="1" cellpadding="6" cellspacing="0"><tr><th>Проверка</th><th>Количество</th><th>Действие</th></tr>' +
        N'<tr><td>Активные студенты без профиля</td><td>' + CAST(@StudentUsersWithoutProfile AS NVARCHAR(20)) + N'</td><td>Проверить связь пользователь-студент</td></tr>' +
        N'<tr><td>Преподаватели/кураторы без профиля</td><td>' + CAST(@TeacherUsersWithoutProfile AS NVARCHAR(20)) + N'</td><td>Проверить карточки преподавателей</td></tr>' +
        N'<tr><td>Активные студенты без активной карты СКУД</td><td>' + CAST(@StudentsWithoutCards AS NVARCHAR(20)) + N'</td><td>Сверить выдачу карт</td></tr>' +
        N'<tr><td>Занятия без отметок посещаемости</td><td>' + CAST(@ClassesWithoutAttendance AS NVARCHAR(20)) + N'</td><td>Проверить журнал посещаемости</td></tr>' +
        N'<tr><td>Расписание без аудитории/кабинета</td><td>' + CAST(@SchedulesWithoutRoom AS NVARCHAR(20)) + N'</td><td>Дополнить расписание</td></tr>' +
        N'</table>';

    SELECT
        N'FRIDAY_USERS_GAPS' AS Код_Отчета,
        @Title AS Заголовок,
        @Body AS Тело_HTML,
        @StudentUsersWithoutProfile + @TeacherUsersWithoutProfile + @StudentsWithoutCards + @ClassesWithoutAttendance + @SchedulesWithoutRoom AS Количество_Строк;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ВыполнитьПлановыйОтчет
    @Код_Отчета NVARCHAR(80),
    @Период_С DATE = NULL,
    @Период_По DATE = NULL,
    @Источник_Запуска NVARCHAR(30) = N'SQL_AGENT',
    @ТестовыйРежим BIT = 0,
    @РазрешитьПовтор BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    DECLARE
        @Отчет_ID INT,
        @Название NVARCHAR(200),
        @Процедура SYSNAME,
        @Стратегия NVARCHAR(50),
        @Период NVARCHAR(30),
        @Хранить INT,
        @JobName SYSNAME,
        @MailProfile NVARCHAR(256),
        @MailEnabled NVARCHAR(20),
        @TestEmail NVARCHAR(200),
        @Запуск_ID BIGINT,
        @Key NVARCHAR(200),
        @RecipientsCount INT = 0,
        @SentCount INT = 0,
        @ErrorCount INT = 0,
        @RowsTotal INT = 0;

    SELECT
        @Отчет_ID = Плановый_Отчет_ID,
        @Название = Название,
        @Процедура = Процедура_Генерации,
        @Стратегия = Стратегия_Получателей,
        @Период = Период_По_Умолчанию,
        @Хранить = Хранить_Дней,
        @JobName = Agent_Job_Name
    FROM dbo.Плановый_Отчет
    WHERE Код_Отчета = @Код_Отчета
      AND Активен = 1;

    IF @Отчет_ID IS NULL
        THROW 51000, N'Плановый отчет не найден или отключен.', 1;

    IF @Период_С IS NULL OR @Период_По IS NULL
    BEGIN
        DECLARE @Today DATE = CAST(GETDATE() AS DATE);
        IF @Период = N'DAY'
        BEGIN
            SET @Период_С = @Today;
            SET @Период_По = @Today;
        END
        ELSE
        BEGIN
            SET @Период_С = DATEADD(DAY, -7, @Today);
            SET @Период_По = DATEADD(DAY, -1, @Today);
        END
    END;

    SET @Key = @Код_Отчета + N'|' + CONVERT(NVARCHAR(10), @Период_С, 120) + N'|' + CONVERT(NVARCHAR(10), @Период_По, 120);

    -- Use an application lock to make the idempotency check+insert atomic when repeats are not allowed.
    DECLARE @appLockName NVARCHAR(400) = N'Запуск_Планового_Отчета|' + @Key;
    DECLARE @lockResult INT = 0;

    IF @РазрешитьПовтор = 0
    BEGIN
        -- Try to acquire an exclusive lock for the key (short timeout)
        EXEC @lockResult = sp_getapplock @Resource = @appLockName, @LockMode = 'Exclusive', @LockOwner = 'Session', @LockTimeout = 10000;
        IF @lockResult < 0
        BEGIN
            -- Could not acquire lock — be conservative and record as duplicate
            INSERT INTO dbo.Запуск_Планового_Отчета (
                Плановый_Отчет_ID, Код_Отчета, Период_С, Период_По, Источник_Запуска,
                SqlAgentJobName, Начало_Запуска, Конец_Запуска, Статус, Количество_Строк,
                Количество_Получателей, Количество_Отправлено, Количество_Ошибок, Ошибка, Идемпотентный_Ключ
            )
            VALUES (
                @Отчет_ID, @Код_Отчета, @Период_С, @Период_По, @Источник_Запуска,
                @JobName, SYSUTCDATETIME(), SYSUTCDATETIME(), N'Дубликат', 0,
                0, 0, 0, N'Повторная отправка за период заблокирована политикой идемпотентности (lock failed).', @Key
            );

            SELECT SCOPE_IDENTITY() AS Запуск_ID, @Код_Отчета AS Код_Отчета, N'Дубликат' AS Статус,
                   0 AS Количество_Получателей, 0 AS Количество_Отправлено, 0 AS Количество_Ошибок,
                   N'Отчет за этот период уже был отправлен или заблокирован.' AS Сообщение;
            RETURN;
        END

        -- Re-check under lock
        IF EXISTS (
            SELECT 1
            FROM dbo.Запуск_Планового_Отчета
            WHERE Идемпотентный_Ключ = @Key
              AND Статус IN (N'Успешно', N'Частично')
        )
        BEGIN
            INSERT INTO dbo.Запуск_Планового_Отчета (
                Плановый_Отчет_ID, Код_Отчета, Период_С, Период_По, Источник_Запуска,
                SqlAgentJobName, Начало_Запуска, Конец_Запуска, Статус, Количество_Строк,
                Количество_Получателей, Количество_Отправлено, Количество_Ошибок, Ошибка, Идемпотентный_Ключ
            )
            VALUES (
                @Отчет_ID, @Код_Отчета, @Период_С, @Период_По, @Источник_Запуска,
                @JobName, SYSUTCDATETIME(), SYSUTCDATETIME(), N'Дубликат', 0,
                0, 0, 0, N'Повторная отправка за период заблокирована политикой идемпотентности.', @Key
            );

            EXEC sp_releaseapplock @Resource = @appLockName, @LockOwner = 'Session';

            SELECT SCOPE_IDENTITY() AS Запуск_ID, @Код_Отчета AS Код_Отчета, N'Дубликат' AS Статус,
                   0 AS Количество_Получателей, 0 AS Количество_Отправлено, 0 AS Количество_Ошибок,
                   N'Отчет за этот период уже был отправлен.' AS Сообщение;
            RETURN;
        END
    END

    IF @РазрешитьПовтор = 1
        SET @Key = @Key + N'|RERUN|' + CONVERT(NVARCHAR(36), NEWID());

    INSERT INTO dbo.Запуск_Планового_Отчета (
        Плановый_Отчет_ID, Код_Отчета, Период_С, Период_По, Источник_Запуска,
        SqlAgentJobName, Начало_Запуска, Статус, Идемпотентный_Ключ
    )
    VALUES (@Отчет_ID, @Код_Отчета, @Период_С, @Период_По, @Источник_Запуска, @JobName, SYSUTCDATETIME(), N'Выполняется', @Key);

    SET @Запуск_ID = SCOPE_IDENTITY();

    -- Release the lock if we acquired it earlier
    IF @РазрешитьПовтор = 0 AND @lockResult >= 0
    BEGIN
        EXEC sp_releaseapplock @Resource = @appLockName, @LockOwner = 'Session';
    END

    DECLARE @Recipients TABLE (
        RowNo INT IDENTITY(1,1),
        Получатель_ID INT NULL,
        Пользователь_ID INT NULL,
        Куратор_ID INT NULL,
        Email NVARCHAR(200) NOT NULL,
        Имя_Получателя NVARCHAR(200) NULL,
        Область NVARCHAR(100) NULL
    );

    IF @Стратегия = N'ADMINS'
    BEGIN
        INSERT INTO @Recipients (Пользователь_ID, Email, Имя_Получателя, Область)
        SELECT u.Пользователь_ID, u.Email, COALESCE(p.ФИО, s.ФИО, u.Логин), r.Название
        FROM dbo.Пользователь u
        JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
        LEFT JOIN dbo.Преподаватель p ON p.Пользователь_ID = u.Пользователь_ID
        LEFT JOIN dbo.Студент s ON s.Пользователь_ID = u.Пользователь_ID
        WHERE u.Активен = 1
          AND r.Название IN (N'Admin', N'Директор')
          AND NULLIF(LTRIM(RTRIM(u.Email)), N'') IS NOT NULL;
    END
    ELSE IF @Стратегия = N'METHODISTS'
    BEGIN
        INSERT INTO @Recipients (Пользователь_ID, Email, Имя_Получателя, Область)
        SELECT u.Пользователь_ID, u.Email, COALESCE(p.ФИО, u.Логин), r.Название
        FROM dbo.Пользователь u
        JOIN dbo.Роль r ON r.Роль_ID = u.Роль_ID
        LEFT JOIN dbo.Преподаватель p ON p.Пользователь_ID = u.Пользователь_ID
        WHERE u.Активен = 1
          AND r.Название IN (N'Методист', N'Admin')
          AND NULLIF(LTRIM(RTRIM(u.Email)), N'') IS NOT NULL;
    END
    ELSE IF @Стратегия = N'CURATORS_BY_GROUP'
    BEGIN
        INSERT INTO @Recipients (Пользователь_ID, Куратор_ID, Email, Имя_Получателя, Область)
        SELECT DISTINCT u.Пользователь_ID, p.Преподаватель_ID,
               COALESCE(NULLIF(LTRIM(RTRIM(p.Email_Рабочий)), N''), u.Email),
               COALESCE(p.ФИО, u.Логин),
               N'Куратор'
        FROM dbo.Учебная_Группа g
        JOIN dbo.Преподаватель p ON p.Преподаватель_ID = g.Куратор_ID
        JOIN dbo.Пользователь u ON u.Пользователь_ID = p.Пользователь_ID
        WHERE u.Активен = 1
          AND g.Статус = N'Активна'
          AND NULLIF(LTRIM(RTRIM(COALESCE(p.Email_Рабочий, u.Email))), N'') IS NOT NULL;
    END
    ELSE IF @Стратегия = N'EXPLICIT'
    BEGIN
        INSERT INTO @Recipients (Получатель_ID, Пользователь_ID, Куратор_ID, Email, Имя_Получателя, Область)
        SELECT rec.Получатель_ID, rec.Пользователь_ID, rec.Куратор_ID,
               COALESCE(rec.Email, u.Email, p.Email_Рабочий),
               COALESCE(p.ФИО, s.ФИО, u.Логин, rec.Email),
               rec.Тип_Области
        FROM dbo.Получатель_Планового_Отчета rec
        LEFT JOIN dbo.Пользователь u ON u.Пользователь_ID = rec.Пользователь_ID
        LEFT JOIN dbo.Преподаватель p ON p.Преподаватель_ID = rec.Куратор_ID OR p.Пользователь_ID = u.Пользователь_ID
        LEFT JOIN dbo.Студент s ON s.Пользователь_ID = u.Пользователь_ID
        WHERE rec.Плановый_Отчет_ID = @Отчет_ID
          AND rec.Активен = 1
          AND NULLIF(LTRIM(RTRIM(COALESCE(rec.Email, u.Email, p.Email_Рабочий))), N'') IS NOT NULL;
    END;

    SELECT @MailProfile = NULLIF(LTRIM(RTRIM(Значение)), N'')
    FROM dbo.Настройки_Системы
    WHERE Ключ = N'Отчеты.DatabaseMailProfile';

    SELECT @MailEnabled = LOWER(ISNULL(Значение, N'true'))
    FROM dbo.Настройки_Системы
    WHERE Ключ = N'Отчеты.Плановые.Включены';

    SELECT @TestEmail = NULLIF(LTRIM(RTRIM(Значение)), N'')
    FROM dbo.Настройки_Системы
    WHERE Ключ = N'Отчеты.Плановые.ТестовыйПолучатель';

    IF @ТестовыйРежим = 1 AND @TestEmail IS NOT NULL
    BEGIN
        DELETE FROM @Recipients;
        INSERT INTO @Recipients (Email, Имя_Получателя, Область)
        VALUES (@TestEmail, N'Тестовый получатель', N'TEST');
    END;

    SELECT @RecipientsCount = COUNT(*) FROM @Recipients;

    IF @RecipientsCount = 0
    BEGIN
        UPDATE dbo.Запуск_Планового_Отчета
        SET Конец_Запуска = SYSUTCDATETIME(),
            Статус = N'Пропущено',
            Количество_Строк = 0,
            Количество_Получателей = 0,
            Количество_Отправлено = 0,
            Количество_Ошибок = 0,
            Ошибка = N'Нет активных получателей с email.'
        WHERE Запуск_ID = @Запуск_ID;

        SELECT @Запуск_ID AS Запуск_ID, @Код_Отчета AS Код_Отчета, N'Пропущено' AS Статус,
               0 AS Количество_Получателей, 0 AS Количество_Отправлено, 0 AS Количество_Ошибок,
               N'Нет активных получателей с email.' AS Сообщение;
        RETURN;
    END;

    DECLARE
        @RowNo INT = 1,
        @MaxRow INT,
        @Получатель_ID INT,
        @Пользователь_ID INT,
        @Куратор_ID INT,
        @Email NVARCHAR(200),
        @Имя NVARCHAR(200),
        @Область NVARCHAR(100),
        @Title NVARCHAR(300),
        @Body NVARCHAR(MAX),
        @Rows INT,
        @MailItemId INT,
        @DeliveryError NVARCHAR(MAX);

    SELECT @MaxRow = MAX(RowNo) FROM @Recipients;

    DECLARE @Generated TABLE (
        Код_Отчета NVARCHAR(80),
        Заголовок NVARCHAR(300),
        Тело_HTML NVARCHAR(MAX),
        Количество_Строк INT
    );

    WHILE @RowNo <= @MaxRow
    BEGIN
        SELECT
            @Получатель_ID = Получатель_ID,
            @Пользователь_ID = Пользователь_ID,
            @Куратор_ID = Куратор_ID,
            @Email = Email,
            @Имя = Имя_Получателя,
            @Область = Область
        FROM @Recipients
        WHERE RowNo = @RowNo;

        DELETE FROM @Generated;

        BEGIN TRY
            IF @Код_Отчета = N'DAILY_MAINTENANCE'
                INSERT INTO @Generated EXEC dbo.СформироватьОтчетОбслуживания @Дата = @Период_По;
            ELSE IF @Код_Отчета = N'WEEKLY_ATTENDANCE_ANALYTICS'
                INSERT INTO @Generated EXEC dbo.СформироватьОтчетПосещаемостиСАналитикой @Дата_С = @Период_С, @Дата_По = @Период_По, @Куратор_ID = @Куратор_ID;
            ELSE IF @Код_Отчета = N'FRIDAY_USERS_GAPS'
                INSERT INTO @Generated EXEC dbo.СформироватьОтчетПользователейИПропусков @Дата_С = @Период_С, @Дата_По = @Период_По;
            ELSE
                THROW 51001, N'Процедура генерации не входит в allowlist плановых отчетов.', 1;

            SELECT TOP 1 @Title = Заголовок, @Body = Тело_HTML, @Rows = Количество_Строк FROM @Generated;
            SET @RowsTotal = @RowsTotal + ISNULL(@Rows, 0);

            INSERT INTO dbo.Артефакт_Планового_Отчета (Запуск_ID, Тип_Содержимого, Заголовок, Тело_HTML, Хэш_Содержимого, Истекает_После)
            VALUES (@Запуск_ID, N'text/html', @Title, @Body, CONVERT(NVARCHAR(128), HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Body)), 2), DATEADD(DAY, ISNULL(@Хранить, 365), SYSUTCDATETIME()));

            IF @MailEnabled IN (N'false', N'0', N'нет')
            BEGIN
                INSERT INTO dbo.Доставка_Планового_Отчета (Запуск_ID, Получатель_ID, Пользователь_ID, Email, Имя_Получателя, Область, Статус, Ошибка, Время_Постановки)
                VALUES (@Запуск_ID, @Получатель_ID, @Пользователь_ID, @Email, @Имя, @Область, N'Пропущено', N'Отправка плановых отчетов отключена настройкой.', SYSUTCDATETIME());
            END
            ELSE
            BEGIN
                SET @MailItemId = NULL;
                EXEC msdb.dbo.sp_send_dbmail
                    @profile_name = @MailProfile,
                    @recipients = @Email,
                    @subject = @Title,
                    @body = @Body,
                    @body_format = 'HTML',
                    @mailitem_id = @MailItemId OUTPUT;

                -- Record as queued/placed with MailItemId; actual send time will be reconciled by a separate job
                INSERT INTO dbo.Доставка_Планового_Отчета (Запуск_ID, Получатель_ID, Пользователь_ID, Email, Имя_Получателя, Область, MailItemId, Статус, Время_Постановки)
                VALUES (@Запуск_ID, @Получатель_ID, @Пользователь_ID, @Email, @Имя, @Область, @MailItemId, N'Ожидает', SYSUTCDATETIME());

                SET @SentCount += 1;
            END;
        END TRY
        BEGIN CATCH
            SET @DeliveryError = ERROR_MESSAGE();
            SET @ErrorCount += 1;

            INSERT INTO dbo.Доставка_Планового_Отчета (Запуск_ID, Получатель_ID, Пользователь_ID, Email, Имя_Получателя, Область, Статус, Ошибка, Время_Постановки)
            VALUES (@Запуск_ID, @Получатель_ID, @Пользователь_ID, @Email, @Имя, @Область, N'Ошибка', @DeliveryError, SYSUTCDATETIME());
        END CATCH;

        SET @RowNo += 1;
    END;

    DECLARE @FinalStatus NVARCHAR(30) =
        CASE
            WHEN @ErrorCount = 0 AND @SentCount > 0 THEN N'Успешно'
            WHEN @SentCount > 0 AND @ErrorCount > 0 THEN N'Частично'
            WHEN @MailEnabled IN (N'false', N'0', N'нет') THEN N'Пропущено'
            ELSE N'Ошибка'
        END;

    UPDATE dbo.Запуск_Планового_Отчета
    SET Конец_Запуска = SYSUTCDATETIME(),
        Статус = @FinalStatus,
        Количество_Строк = @RowsTotal,
        Количество_Получателей = @RecipientsCount,
        Количество_Отправлено = @SentCount,
        Количество_Ошибок = @ErrorCount,
        Ошибка = CASE WHEN @ErrorCount > 0 THEN N'Есть ошибки доставки. Подробности в Доставка_Планового_Отчета.' ELSE NULL END
    WHERE Запуск_ID = @Запуск_ID;

    INSERT INTO dbo.Лог_Действий (Пользователь_ID, Уровень_Лога, Действие, Таблица, Запись_ID, Время_Действия, Параметры, Статус, Дата_Создания)
    VALUES (NULL, N'Информация', N'Выполнение планового отчета', N'Запуск_Планового_Отчета', CONVERT(INT, @Запуск_ID), GETDATE(),
            N'Код=' + @Код_Отчета + N', Период=' + CONVERT(NVARCHAR(10), @Период_С, 120) + N' - ' + CONVERT(NVARCHAR(10), @Период_По, 120),
            @FinalStatus, GETDATE());

    SELECT @Запуск_ID AS Запуск_ID, @Код_Отчета AS Код_Отчета, @FinalStatus AS Статус,
           @RecipientsCount AS Количество_Получателей, @SentCount AS Количество_Отправлено, @ErrorCount AS Количество_Ошибок,
           CASE WHEN @FinalStatus = N'Успешно' THEN N'Плановый отчет отправлен.' ELSE N'Плановый отчет завершен со статусом: ' + @FinalStatus END AS Сообщение;

    IF @Источник_Запуска = N'SQL_AGENT' AND @FinalStatus = N'Ошибка'
        THROW 51002, N'Плановый отчет завершился ошибкой. Смотрите Запуск_Планового_Отчета и Доставка_Планового_Отчета.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьПлановыеОтчеты
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.Плановый_Отчет_ID,
        r.Код_Отчета,
        r.Название,
        r.Описание,
        r.Стратегия_Получателей,
        r.Активен,
        r.Agent_Job_Name,
        r.Ожидаемое_Время,
        r.Ожидаемый_День_Недели,
        lastRun.Запуск_ID AS Последний_Запуск_ID,
        lastRun.Начало_Запуска AS Последний_Запуск,
        lastRun.Статус AS Последний_Статус,
        lastRun.Количество_Получателей,
        lastRun.Количество_Отправлено,
        lastRun.Количество_Ошибок,
        lastRun.Ошибка AS Последняя_Ошибка
    FROM dbo.Плановый_Отчет r
    OUTER APPLY (
        SELECT TOP 1 *
        FROM dbo.Запуск_Планового_Отчета run
        WHERE run.Плановый_Отчет_ID = r.Плановый_Отчет_ID
        ORDER BY run.Начало_Запуска DESC
    ) lastRun
    ORDER BY r.Плановый_Отчет_ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьЗапускиПлановыхОтчетов
    @Код_Отчета NVARCHAR(80) = NULL,
    @Статус NVARCHAR(30) = NULL,
    @Дата_С DATE = NULL,
    @Дата_По DATE = NULL,
    @Лимит INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    IF @Лимит IS NULL OR @Лимит < 1 SET @Лимит = 50;
    IF @Лимит > 500 SET @Лимит = 500;

    SELECT TOP (@Лимит)
        run.Запуск_ID,
        run.Код_Отчета,
        r.Название,
        run.Период_С,
        run.Период_По,
        run.Источник_Запуска,
        run.SqlAgentJobName,
        run.Начало_Запуска,
        run.Конец_Запуска,
        run.Статус,
        run.Количество_Строк,
        run.Количество_Получателей,
        run.Количество_Отправлено,
        run.Количество_Ошибок,
        run.Ошибка
    FROM dbo.Запуск_Планового_Отчета run
    JOIN dbo.Плановый_Отчет r ON r.Плановый_Отчет_ID = run.Плановый_Отчет_ID
    WHERE (@Код_Отчета IS NULL OR run.Код_Отчета = @Код_Отчета)
      AND (@Статус IS NULL OR run.Статус = @Статус)
      AND (@Дата_С IS NULL OR run.Период_С >= @Дата_С)
      AND (@Дата_По IS NULL OR run.Период_По <= @Дата_По)
    ORDER BY run.Начало_Запуска DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДоставкиПлановогоОтчета
    @Запуск_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Доставка_ID,
        d.Запуск_ID,
        d.Пользователь_ID,
        d.Email,
        d.Имя_Получателя,
        d.Область,
        d.MailItemId,
        d.Статус,
        d.Ошибка,
        d.Время_Постановки,
        d.Время_Отправки
    FROM dbo.Доставка_Планового_Отчета d
    WHERE d.Запуск_ID = @Запуск_ID
    ORDER BY d.Доставка_ID;
END;
GO

IF IS_SRVROLEMEMBER(N'sysadmin') = 1
BEGIN
    DECLARE @DbName SYSNAME = DB_NAME();

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'AIS_Daily_Maintenance_Report')
        EXEC msdb.dbo.sp_add_job @job_name = N'AIS_Daily_Maintenance_Report', @enabled = 1, @description = N'AIS daily maintenance report at 08:00';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobsteps js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id WHERE j.name = N'AIS_Daily_Maintenance_Report' AND js.step_name = N'Run report')
        EXEC msdb.dbo.sp_add_jobstep @job_name = N'AIS_Daily_Maintenance_Report', @step_name = N'Run report', @subsystem = N'TSQL', @database_name = @DbName, @command = N'EXEC dbo.ВыполнитьПлановыйОтчет @Код_Отчета = N''DAILY_MAINTENANCE'', @Источник_Запуска = N''SQL_AGENT'';';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'AIS_Daily_Maintenance_Report_0800')
        EXEC msdb.dbo.sp_add_schedule @schedule_name = N'AIS_Daily_Maintenance_Report_0800', @enabled = 1, @freq_type = 4, @freq_interval = 1, @active_start_time = 080000;

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id JOIN msdb.dbo.sysschedules s ON s.schedule_id = js.schedule_id WHERE j.name = N'AIS_Daily_Maintenance_Report' AND s.name = N'AIS_Daily_Maintenance_Report_0800')
        EXEC msdb.dbo.sp_attach_schedule @job_name = N'AIS_Daily_Maintenance_Report', @schedule_name = N'AIS_Daily_Maintenance_Report_0800';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobservers jsv JOIN msdb.dbo.sysjobs j ON j.job_id = jsv.job_id WHERE j.name = N'AIS_Daily_Maintenance_Report')
        EXEC msdb.dbo.sp_add_jobserver @job_name = N'AIS_Daily_Maintenance_Report';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'AIS_Weekly_Attendance_Analytics')
        EXEC msdb.dbo.sp_add_job @job_name = N'AIS_Weekly_Attendance_Analytics', @enabled = 1, @description = N'AIS weekly attendance analytics report on Monday at 09:00';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobsteps js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id WHERE j.name = N'AIS_Weekly_Attendance_Analytics' AND js.step_name = N'Run report')
        EXEC msdb.dbo.sp_add_jobstep @job_name = N'AIS_Weekly_Attendance_Analytics', @step_name = N'Run report', @subsystem = N'TSQL', @database_name = @DbName, @command = N'EXEC dbo.ВыполнитьПлановыйОтчет @Код_Отчета = N''WEEKLY_ATTENDANCE_ANALYTICS'', @Источник_Запуска = N''SQL_AGENT'';';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'AIS_Weekly_Attendance_Analytics_Mon0900')
        EXEC msdb.dbo.sp_add_schedule @schedule_name = N'AIS_Weekly_Attendance_Analytics_Mon0900', @enabled = 1, @freq_type = 8, @freq_interval = 2, @freq_recurrence_factor = 1, @active_start_time = 090000;

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id JOIN msdb.dbo.sysschedules s ON s.schedule_id = js.schedule_id WHERE j.name = N'AIS_Weekly_Attendance_Analytics' AND s.name = N'AIS_Weekly_Attendance_Analytics_Mon0900')
        EXEC msdb.dbo.sp_attach_schedule @job_name = N'AIS_Weekly_Attendance_Analytics', @schedule_name = N'AIS_Weekly_Attendance_Analytics_Mon0900';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobservers jsv JOIN msdb.dbo.sysjobs j ON j.job_id = jsv.job_id WHERE j.name = N'AIS_Weekly_Attendance_Analytics')
        EXEC msdb.dbo.sp_add_jobserver @job_name = N'AIS_Weekly_Attendance_Analytics';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'AIS_Friday_Users_Gaps_Report')
        EXEC msdb.dbo.sp_add_job @job_name = N'AIS_Friday_Users_Gaps_Report', @enabled = 1, @description = N'AIS users and missing classes report on Friday at 18:00';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobsteps js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id WHERE j.name = N'AIS_Friday_Users_Gaps_Report' AND js.step_name = N'Run report')
        EXEC msdb.dbo.sp_add_jobstep @job_name = N'AIS_Friday_Users_Gaps_Report', @step_name = N'Run report', @subsystem = N'TSQL', @database_name = @DbName, @command = N'EXEC dbo.ВыполнитьПлановыйОтчет @Код_Отчета = N''FRIDAY_USERS_GAPS'', @Источник_Запуска = N''SQL_AGENT'';';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'AIS_Friday_Users_Gaps_Report_Fri1800')
        EXEC msdb.dbo.sp_add_schedule @schedule_name = N'AIS_Friday_Users_Gaps_Report_Fri1800', @enabled = 1, @freq_type = 8, @freq_interval = 32, @freq_recurrence_factor = 1, @active_start_time = 180000;

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules js JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id JOIN msdb.dbo.sysschedules s ON s.schedule_id = js.schedule_id WHERE j.name = N'AIS_Friday_Users_Gaps_Report' AND s.name = N'AIS_Friday_Users_Gaps_Report_Fri1800')
        EXEC msdb.dbo.sp_attach_schedule @job_name = N'AIS_Friday_Users_Gaps_Report', @schedule_name = N'AIS_Friday_Users_Gaps_Report_Fri1800';

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobservers jsv JOIN msdb.dbo.sysjobs j ON j.job_id = jsv.job_id WHERE j.name = N'AIS_Friday_Users_Gaps_Report')
        EXEC msdb.dbo.sp_add_jobserver @job_name = N'AIS_Friday_Users_Gaps_Report';
END
ELSE
BEGIN
    PRINT N'SQL Server Agent job creation skipped: deployment login is not sysadmin. Tables and procedures were still created.';
END;
GO

