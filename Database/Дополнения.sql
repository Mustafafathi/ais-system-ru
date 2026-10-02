USE [Улучшенная];
GO

IF COL_LENGTH(N'dbo.Расписание', N'числ/знамен') IS NULL
BEGIN
    ALTER TABLE dbo.Расписание
    ADD [числ/знамен] NVARCHAR(20) NULL;
END;
GO

IF COL_LENGTH(N'dbo.Расписание', N'числ/знамен') IS NOT NULL
   AND NOT EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = N'CHK_Расписание_ЧислЗнамен'
          AND parent_object_id = OBJECT_ID(N'dbo.Расписание')
   )
BEGIN
    EXEC sys.sp_executesql N'
        ALTER TABLE dbo.Расписание WITH CHECK
        ADD CONSTRAINT CHK_Расписание_ЧислЗнамен
        CHECK (
            [числ/знамен] IS NULL
            OR [числ/знамен] IN (N''числитель'', N''знаменатель'', N''каждая'')
        );
    ';
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДашбордСтудента
    @Студент_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ДатаНачала DATE = DATEADD(MONTH, -6, GETDATE());
    DECLARE @Сегодня DATE = CAST(GETDATE() AS DATE);

    SELECT
        g.Название AS Группа,
        COUNT(DISTINCT п.Занятие_ID) AS Всего_Занятий,
        SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN п.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Пропустил,
        SUM(CASE WHEN п.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) * 2 AS Пропущено_Часов,
        CASE WHEN COUNT(DISTINCT п.Занятие_ID) = 0 THEN 0 ELSE
            CAST(SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0
            / COUNT(DISTINCT п.Занятие_ID) AS DECIMAL(5,2))
        END AS Процент_Посещаемости,
        (SELECT COUNT(*) FROM dbo.Обоснования_Отсутствия
         WHERE Студент_ID = @Студент_ID AND Статус = N'Ожидает') AS Обоснований_Ожидает
    FROM dbo.Студент s
    LEFT JOIN dbo.Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    LEFT JOIN dbo.Посещаемость п ON s.Студент_ID = п.Студент_ID
    LEFT JOIN dbo.Занятие з ON п.Занятие_ID = з.Занятие_ID AND з.Дата_Занятия >= @ДатаНачала
    WHERE s.Студент_ID = @Студент_ID
    GROUP BY g.Название;

    SELECT
        з.Занятие_ID,
        р.Время_Начала,
        р.Время_Окончания,
        д.Название AS Дисциплина,
        р.Кабинет AS Аудитория,
        ISNULL(п.Статус, N'Предстоит') AS Статус
    FROM dbo.Студент s
    INNER JOIN dbo.Занятие з ON 1 = 1
    INNER JOIN dbo.Расписание р ON з.Расписание_ID = р.Расписание_ID AND р.Группа_ID = s.Группа_ID
    INNER JOIN dbo.Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    LEFT JOIN dbo.Посещаемость п ON з.Занятие_ID = п.Занятие_ID AND п.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID = @Студент_ID AND з.Дата_Занятия = @Сегодня
    ORDER BY р.Время_Начала;

    SELECT
        д.Название AS Дисциплина,
        COUNT(DISTINCT п.Занятие_ID) AS Всего_Занятий,
        SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        CASE WHEN COUNT(DISTINCT п.Занятие_ID) = 0 THEN 0 ELSE
            CAST(SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0
            / COUNT(DISTINCT п.Занятие_ID) AS DECIMAL(5,2))
        END AS Процент
    FROM dbo.Посещаемость п
    INNER JOIN dbo.Занятие з ON п.Занятие_ID = з.Занятие_ID
    INNER JOIN dbo.Расписание р ON з.Расписание_ID = р.Расписание_ID
    INNER JOIN dbo.Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    WHERE п.Студент_ID = @Студент_ID AND з.Дата_Занятия >= @ДатаНачала
    GROUP BY д.Дисциплина_ID, д.Название
    ORDER BY д.Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДашбордКуратора
    @Куратор_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM dbo.Учебная_Группа WHERE Куратор_ID = @Куратор_ID AND Статус = N'Активна') AS Количество_Групп,
        (SELECT COUNT(*) FROM dbo.Студент с INNER JOIN dbo.Учебная_Группа г ON с.Группа_ID = г.Группа_ID WHERE г.Куратор_ID = @Куратор_ID) AS Количество_Студентов,
        (SELECT COUNT(*) FROM dbo.Обоснования_Отсутствия о INNER JOIN dbo.Студент с ON о.Студент_ID = с.Студент_ID INNER JOIN dbo.Учебная_Группа г ON с.Группа_ID = г.Группа_ID WHERE г.Куратор_ID = @Куратор_ID AND о.Статус = N'Ожидает') AS Обоснований_Ожидает;

    SELECT
        г.Группа_ID,
        г.Название AS Группа,
        COUNT(DISTINCT с.Студент_ID) AS Студентов,
        ISNULL(CAST(SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(п.Посещаемость_ID), 0) AS DECIMAL(5,2)), 0) AS Процент
    FROM dbo.Учебная_Группа г
    LEFT JOIN dbo.Студент с ON г.Группа_ID = с.Группа_ID
    LEFT JOIN dbo.Посещаемость п ON с.Студент_ID = п.Студент_ID
    WHERE г.Куратор_ID = @Куратор_ID
    GROUP BY г.Группа_ID, г.Название
    ORDER BY г.Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДашбордМетодиста
    @Пользователь_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Сегодня DATE = CAST(GETDATE() AS DATE);

    SELECT
        (SELECT COUNT(*) FROM dbo.Учебная_Группа WHERE Статус = N'Активна') AS Групп,
        (SELECT COUNT(*) FROM dbo.Дисциплина) AS Дисциплин,
        (SELECT COUNT(*) FROM dbo.Преподаватель) AS Преподавателей,
        (SELECT COUNT(*) FROM dbo.Занятие WHERE Дата_Занятия = @Сегодня) AS Занятий_Сегодня,
        (SELECT COUNT(*) FROM dbo.Студент с INNER JOIN dbo.Пользователь у ON с.Пользователь_ID = у.Пользователь_ID WHERE у.Активен = 1) AS Студентов_Активных;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДашбордАдмина
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Сегодня DATE = CAST(GETDATE() AS DATE);

    SELECT
        (SELECT COUNT(*) FROM dbo.Пользователь WHERE Активен = 1) AS Пользователей_Активных,
        (SELECT COUNT(*) FROM dbo.Студент) AS Студентов,
        (SELECT COUNT(*) FROM dbo.Преподаватель) AS Преподавателей,
        (SELECT COUNT(*) FROM dbo.Учебная_Группа WHERE Статус = N'Активна') AS Групп_Активных,
        (SELECT COUNT(*) FROM dbo.Занятие WHERE Дата_Занятия = @Сегодня) AS Занятий_Сегодня,
        (SELECT COUNT(*) FROM dbo.Сессия_Пользователя WHERE Активна = 1) AS Активных_Сессий;

    SELECT
        COUNT(п.Посещаемость_ID) AS Отметок_Всего,
        SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало,
        SUM(CASE WHEN п.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовало,
        CASE WHEN COUNT(п.Посещаемость_ID) = 0 THEN 0 ELSE
            CAST(SUM(CASE WHEN п.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / COUNT(п.Посещаемость_ID) AS DECIMAL(5,2))
        END AS Процент
    FROM dbo.Посещаемость п
    INNER JOIN dbo.Занятие з ON п.Занятие_ID = з.Занятие_ID
    WHERE з.Дата_Занятия = @Сегодня;

    SELECT TOP 15
        л.Лог_ID,
        у.Логин AS Пользователь,
        л.Действие,
        л.Таблица,
        л.Статус,
        л.Время_Действия AS Время
    FROM dbo.Лог_Действий л
    LEFT JOIN dbo.Пользователь у ON л.Пользователь_ID = у.Пользователь_ID
    ORDER BY л.Время_Действия DESC;

    SELECT TOP 5
        Копия_ID,
        Название_Файла,
        Тип_Копии,
        Статус,
        Дата_Начала AS Дата,
        Размер_Файла_MB AS Размер_МБ
    FROM dbo.Резервные_Копии
    ORDER BY Дата_Начала DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьСписокОбоснований
    @Студент_ID INT = NULL,
    @Куратор_ID INT = NULL,
    @Преподаватель_ID INT = NULL,
    @Статус NVARCHAR(50) = NULL,
    @Лимит INT = 100
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Лимит)
        о.Обоснование_ID,
        с.Студент_ID,
        с.ФИО,
        г.Название AS Группа,
        д.Название AS Дисциплина,
        з.Дата_Занятия,
        р.Время_Начала,
        о.Причина,
        о.Статус,
        о.Дата_Подачи,
        о.Комментарий_Модератора AS Комментарий,
        CASE WHEN о.Файл IS NOT NULL AND о.Файл <> N'' THEN 1 ELSE 0 END AS Документ,
        мод.Логин AS Кто_Рассмотрел,
        о.Дата_Рассмотрения
    FROM dbo.Обоснования_Отсутствия о
    INNER JOIN dbo.Студент с ON о.Студент_ID = с.Студент_ID
    INNER JOIN dbo.Учебная_Группа г ON с.Группа_ID = г.Группа_ID
    LEFT JOIN dbo.Занятие з ON о.Занятие_ID = з.Занятие_ID
    LEFT JOIN dbo.Расписание р ON з.Расписание_ID = р.Расписание_ID
    LEFT JOIN dbo.Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    LEFT JOIN dbo.Пользователь мод ON о.Кто_Рассмотрел = мод.Пользователь_ID
    WHERE (@Студент_ID IS NULL OR о.Студент_ID = @Студент_ID)
      AND (@Статус IS NULL OR о.Статус = @Статус)
      AND (@Куратор_ID IS NULL OR г.Куратор_ID = @Куратор_ID)
      AND (@Преподаватель_ID IS NULL OR д.Преподаватель_ID = @Преподаватель_ID)
    ORDER BY о.Дата_Подачи DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДетальныйОтчетПоСтуденту
    @Студент_ID INT,
    @ДатаНачала DATE = NULL,
    @ДатаКонца DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ДатаНачала IS NULL SET @ДатаНачала = DATEADD(MONTH, -3, GETDATE());
    IF @ДатаКонца IS NULL SET @ДатаКонца = GETDATE();

    SELECT
        з.Занятие_ID,
        з.Дата_Занятия,
        DATENAME(WEEKDAY, з.Дата_Занятия) AS ДеньНедели,
        р.Время_Начала,
        р.Время_Окончания,
        д.Название AS Дисциплина,
        преп.ФИО AS Преподаватель,
        р.Кабинет,
        ISNULL(п.Статус, N'Не отмечено') AS СтатусПосещения,
        п.Тип_Отметки,
        п.Дата_Отметки,
        о.Обоснование_ID,
        о.Статус AS СтатусОбоснования
    FROM dbo.Занятие з
    INNER JOIN dbo.Расписание р ON з.Расписание_ID = р.Расписание_ID
    INNER JOIN dbo.Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    INNER JOIN dbo.Преподаватель преп ON д.Преподаватель_ID = преп.Преподаватель_ID
    INNER JOIN dbo.Студент с ON р.Группа_ID = с.Группа_ID
    LEFT JOIN dbo.Посещаемость п ON з.Занятие_ID = п.Занятие_ID AND п.Студент_ID = с.Студент_ID
    LEFT JOIN dbo.Обоснования_Отсутствия о ON з.Занятие_ID = о.Занятие_ID AND о.Студент_ID = с.Студент_ID
    WHERE с.Студент_ID = @Студент_ID
      AND з.Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца
    ORDER BY з.Дата_Занятия DESC, р.Время_Начала;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьОбоснование
    @Студент_ID INT,
    @Занятие_ID INT,
    @Причина NVARCHAR(MAX),
    @Файл NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Студент WHERE Студент_ID = @Студент_ID)
        BEGIN
            RAISERROR(N'Студент не найден', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Занятие WHERE Занятие_ID = @Занятие_ID)
        BEGIN
            RAISERROR(N'Занятие не найдено', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Посещаемость
            WHERE Студент_ID = @Студент_ID
              AND Занятие_ID = @Занятие_ID
              AND Статус IN (N'Отсутствовал', N'Опоздал')
        )
        BEGIN
            RAISERROR(N'Для выбранного занятия нельзя подать обоснование', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM dbo.Обоснования_Отсутствия
            WHERE Студент_ID = @Студент_ID
              AND Занятие_ID = @Занятие_ID
              AND Статус IN (N'На рассмотрении', N'Одобрено')
        )
        BEGIN
            RAISERROR(N'Обоснование по этому занятию уже подано', 16, 1);
            RETURN;
        END

        INSERT INTO dbo.Обоснования_Отсутствия
            (Студент_ID, Занятие_ID, Дата_Подачи, Причина, Файл, Статус)
        VALUES
            (@Студент_ID, @Занятие_ID, GETDATE(), @Причина, @Файл, N'На рассмотрении');

        DECLARE @Обоснование_ID INT = SCOPE_IDENTITY();
        DECLARE @КураторПользователь_ID INT;

        SELECT @КураторПользователь_ID = куратор.Пользователь_ID
        FROM dbo.Студент с
        INNER JOIN dbo.Учебная_Группа г ON с.Группа_ID = г.Группа_ID
        INNER JOIN dbo.Преподаватель куратор ON г.Куратор_ID = куратор.Преподаватель_ID
        WHERE с.Студент_ID = @Студент_ID;

        IF @КураторПользователь_ID IS NOT NULL
        BEGIN
            INSERT INTO dbo.Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
            VALUES (
                @КураторПользователь_ID,
                N'Важное',
                N'Новое обоснование отсутствия',
                N'Студент подал новое обоснование отсутствия. Требуется рассмотрение.',
                CONCAT('/curator/excuses.php?id=', @Обоснование_ID)
            );
        END

        COMMIT TRANSACTION;

        SELECT @Обоснование_ID AS Обоснование_ID, N'Обоснование отправлено на рассмотрение' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьСписокБэкапов
    @Лимит INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Лимит)
        Копия_ID,
        Название_Файла AS Имя,
        Тип_Копии,
        Статус,
        Дата_Начала AS Дата,
        Дата_Завершения,
        Время_Выполнения_Сек,
        Размер_Файла_MB AS Размер,
        Путь_Хранения
    FROM dbo.Резервные_Копии
    ORDER BY Дата_Начала DESC;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.СКУД_Событие')
      AND name = N'Карта_ID'
      AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.СКУД_Событие ALTER COLUMN Карта_ID INT NULL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПринятьСобытиеСКУД
    @Устройство_ID INT,
    @Номер_Карты NVARCHAR(50),
    @Тип_События NVARCHAR(30),
    @Направление NVARCHAR(20) = NULL,
    @Время_События DATETIME = NULL,
    @Температура DECIMAL(4,1) = NULL,
    @Фото_URL NVARCHAR(500) = NULL,
    @Данные_Датчиков NVARCHAR(MAX) = NULL,
    @Зона_Доступа NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.СКУД_Устройство WHERE Устройство_ID = @Устройство_ID)
        BEGIN
            RAISERROR(N'Устройство СКУД не найдено', 16, 1);
            RETURN;
        END;

        IF @Тип_События NOT IN (
            N'Вход_разрешен', N'Вход_запрещен', N'Выход_разрешен', N'Выход_запрещен',
            N'Неизвестная_карта', N'Ошибка_чтения', N'Нарушение_доступа', N'Тест_устройства'
        )
        BEGIN
            RAISERROR(N'Неверный тип события СКУД', 16, 1);
            RETURN;
        END;

        IF @Направление IS NOT NULL AND @Направление NOT IN (N'Вход', N'Выход', N'Неизвестно')
        BEGIN
            RAISERROR(N'Неверное направление события СКУД', 16, 1);
            RETURN;
        END;

        DECLARE @Карта_ID INT = NULL;
        DECLARE @Студент_ID INT = NULL;
        DECLARE @Результат NVARCHAR(50) = N'Обработано';
        DECLARE @ПричинаЗапрета NVARCHAR(200) = NULL;
        DECLARE @Занятие_ID INT = NULL;
        DECLARE @СобытиеВремя DATETIME = ISNULL(@Время_События, GETDATE());

        SELECT
            @Карта_ID = Карта_ID,
            @Студент_ID = Студент_ID
        FROM dbo.СКУД_Карта
        WHERE Номер_Карты = @Номер_Карты
          AND Статус = N'Активна'
          AND Дата_Истечения > @СобытиеВремя;

        IF @Карта_ID IS NULL
        BEGIN
            SET @Результат = N'Карта не найдена или неактивна';
            SET @ПричинаЗапрета = N'Недействительная карта';
            SET @Тип_События = N'Неизвестная_карта';
            SET @Направление = ISNULL(@Направление, N'Неизвестно');
        END;

        INSERT INTO dbo.СКУД_Событие (
            Устройство_ID, Карта_ID, Время_События, Тип_События, Направление,
            Зона_Доступа, Результат, Причина_Запрета, Температура, Фото_URL,
            Данные_Датчиков, Дата_Создания
        )
        VALUES (
            @Устройство_ID, @Карта_ID, @СобытиеВремя, @Тип_События, @Направление,
            @Зона_Доступа, @Результат, @ПричинаЗапрета, @Температура, @Фото_URL,
            @Данные_Датчиков, GETDATE()
        );

        DECLARE @Событие_ID BIGINT = SCOPE_IDENTITY();

        IF @Тип_События = N'Вход_разрешен' AND @Студент_ID IS NOT NULL
        BEGIN
            SELECT TOP 1 @Занятие_ID = з.Занятие_ID
            FROM dbo.Занятие з
            INNER JOIN dbo.Расписание р ON з.Расписание_ID = р.Расписание_ID
            INNER JOIN dbo.Студент с ON р.Группа_ID = с.Группа_ID
            WHERE с.Студент_ID = @Студент_ID
              AND з.Дата_Занятия = CAST(@СобытиеВремя AS DATE)
              AND з.Статус IN (N'Запланировано', N'Проведено')
              AND CAST(@СобытиеВремя AS TIME) BETWEEN
                  DATEADD(MINUTE, -30, р.Время_Начала)
                  AND DATEADD(MINUTE, 30, р.Время_Окончания)
            ORDER BY ABS(DATEDIFF(MINUTE, @СобытиеВремя,
                      DATEADD(MINUTE, DATEDIFF(MINUTE, CAST('00:00' AS TIME), р.Время_Начала), CAST(з.Дата_Занятия AS DATETIME))));

            IF @Занятие_ID IS NOT NULL
            BEGIN
                DECLARE @Посещаемость_ID INT;

                SELECT @Посещаемость_ID = Посещаемость_ID
                FROM dbo.Посещаемость WITH (UPDLOCK, HOLDLOCK)
                WHERE Занятие_ID = @Занятие_ID
                  AND Студент_ID = @Студент_ID;

                IF @Посещаемость_ID IS NULL
                BEGIN
                    INSERT INTO dbo.Посещаемость
                        (Занятие_ID, Студент_ID, Статус, Тип_Отметки, Примечание, Кто_Отметил, Дата_Отметки)
                    VALUES
                        (@Занятие_ID, @Студент_ID, N'Присутствовал', N'СКУД', N'Автоматическая отметка через СКУД', NULL, GETDATE());

                    SET @Посещаемость_ID = SCOPE_IDENTITY();
                END
                ELSE
                BEGIN
                    UPDATE dbo.Посещаемость
                    SET Статус = N'Присутствовал',
                        Тип_Отметки = CASE WHEN Тип_Отметки = N'QR' THEN Тип_Отметки ELSE N'СКУД' END,
                        Примечание = ISNULL(Примечание, N'Автоматическая отметка через СКУД'),
                        Дата_Обновления = GETDATE()
                    WHERE Посещаемость_ID = @Посещаемость_ID;
                END;

                UPDATE dbo.СКУД_Событие
                SET Результат = N'Привязано к занятию ' + CAST(@Занятие_ID AS NVARCHAR(20))
                WHERE Событие_ID = @Событие_ID;

                SET @Результат = N'Привязано к занятию ' + CAST(@Занятие_ID AS NVARCHAR(20));
            END;
        END;

        COMMIT TRANSACTION;

        SELECT
            @Событие_ID AS Событие_ID,
            @Результат AS Результат,
            @Карта_ID AS Карта_ID,
            @Студент_ID AS Студент_ID,
            @Занятие_ID AS Занятие_ID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьДисциплиныПреподавателя
    @Преподаватель_ID INT = NULL,
    @Семестр TINYINT = NULL,
    @Статус NVARCHAR(20) = N'Активна'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Дисциплина_ID,
        d.Название,
        d.[краткое наименование] AS Код_Дисциплины,
        d.[краткое наименование],
        d.Преподаватель_ID,
        d.Часы_Теории,
        d.Часы_Практики,
        d.Семестр,
        d.Статус,
        d.Описание,
        d.Дата_Создания,
        p.ФИО AS ФИО_Преподавателя,
        p.Кафедра,
        COUNT(DISTINCT r.Группа_ID) AS КоличествоГрупп
    FROM dbo.Дисциплина d
    INNER JOIN dbo.Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    LEFT JOIN dbo.Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID
    WHERE (@Преподаватель_ID IS NULL OR d.Преподаватель_ID = @Преподаватель_ID)
      AND (@Семестр IS NULL OR d.Семестр = @Семестр)
      AND (@Статус IS NULL OR d.Статус = @Статус)
    GROUP BY
        d.Дисциплина_ID, d.Название, d.[краткое наименование], d.Преподаватель_ID,
        d.Часы_Теории, d.Часы_Практики, d.Семестр, d.Статус, d.Описание, d.Дата_Создания,
        p.ФИО, p.Кафедра
    ORDER BY d.Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьРасписаниеПоГруппе
    @Группа_ID INT,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL,
    @Дата_Начала DATE = NULL,
    @Дата_Конца DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Дата_Начала IS NOT NULL OR @Дата_Конца IS NOT NULL
    BEGIN
        IF @Дата_Начала IS NULL SET @Дата_Начала = DATEADD(DAY, -7, CAST(GETDATE() AS DATE));
        IF @Дата_Конца IS NULL SET @Дата_Конца = DATEADD(DAY, 7, CAST(GETDATE() AS DATE));

        SELECT
            r.Расписание_ID,
            z.Занятие_ID,
            z.Дата_Занятия,
            z.Статус,
            r.День_Недели,
            r.Время_Начала,
            r.Время_Окончания,
            r.Тип_Занятия,
            r.[числ/знамен],
            COALESCE(z.Кабинет, r.Кабинет) AS Кабинет,
            d.Дисциплина_ID,
            d.Название AS Название_Дисциплины,
            d.[краткое наименование] AS Код_Дисциплины,
            d.[краткое наименование],
            d.Семестр,
            p.Преподаватель_ID,
            p.ФИО AS ФИО_Преподавателя,
            p.Кафедра,
            g.Название AS Название_Группы
        FROM dbo.Расписание r
        INNER JOIN dbo.Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
        INNER JOIN dbo.Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
        INNER JOIN dbo.Учебная_Группа g ON r.Группа_ID = g.Группа_ID
        INNER JOIN dbo.Занятие z ON r.Расписание_ID = z.Расписание_ID
        WHERE r.Группа_ID = @Группа_ID
          AND z.Дата_Занятия BETWEEN @Дата_Начала AND @Дата_Конца
          AND (@День_Недели IS NULL OR r.День_Недели = @День_Недели)
          AND (@Семестр IS NULL OR d.Семестр = @Семестр)
        ORDER BY z.Дата_Занятия, r.Время_Начала;
        RETURN;
    END;

    SELECT
        r.Расписание_ID,
        r.День_Недели,
        r.Время_Начала,
        r.Время_Окончания,
        r.Тип_Занятия,
        r.[числ/знамен],
        r.Кабинет,
        d.Дисциплина_ID,
        d.Название AS Название_Дисциплины,
        d.[краткое наименование] AS Код_Дисциплины,
        d.[краткое наименование],
        d.Семестр,
        p.Преподаватель_ID,
        p.ФИО AS ФИО_Преподавателя,
        p.Кафедра,
        g.Название AS Название_Группы
    FROM dbo.Расписание r
    INNER JOIN dbo.Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN dbo.Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    INNER JOIN dbo.Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    WHERE r.Группа_ID = @Группа_ID
      AND (@День_Недели IS NULL OR r.День_Недели = @День_Недели)
      AND (@Семестр IS NULL OR d.Семестр = @Семестр)
    ORDER BY r.День_Недели, r.Время_Начала;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьДисциплину
    @Название NVARCHAR(100),
    @Код_Дисциплины NVARCHAR(20) = NULL,
    @Преподаватель_ID INT,
    @Часы_Теории INT = 0,
    @Часы_Практики INT = 0,
    @Семестр TINYINT = 1,
    @Описание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Преподаватель WHERE Преподаватель_ID = @Преподаватель_ID)
            RAISERROR(N'Преподаватель не найден', 16, 1);

        IF @Код_Дисциплины IS NOT NULL
            AND EXISTS (SELECT 1 FROM dbo.Дисциплина WHERE [краткое наименование] = @Код_Дисциплины)
            RAISERROR(N'Дисциплина с таким кодом уже существует', 16, 1);

        INSERT INTO dbo.Дисциплина (
            Название, [краткое наименование], Преподаватель_ID,
            Часы_Теории, Часы_Практики, Семестр, Статус, Описание, Дата_Создания
        )
        VALUES (
            @Название, @Код_Дисциплины, @Преподаватель_ID,
            @Часы_Теории, @Часы_Практики, @Семестр, N'Активна', @Описание, GETDATE()
        );

        DECLARE @НовыйID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание дисциплины', N'Дисциплина', @НовыйID, N'Успешно');

        COMMIT TRANSACTION;

        SELECT
            @НовыйID AS Дисциплина_ID,
            @Код_Дисциплины AS Код_Дисциплины,
            @Код_Дисциплины AS [краткое наименование],
            N'Дисциплина успешно создана' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьУчебнуюГруппу
    @Название NVARCHAR(50),
    @Год_Поступления INT,
    @Куратор_ID INT = NULL,
    @Специальность_ID INT = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.Учебная_Группа WHERE Название = @Название)
            RAISERROR(N'Группа с таким названием уже существует', 16, 1);

        IF @Куратор_ID IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM dbo.Преподаватель WHERE Преподаватель_ID = @Куратор_ID)
            RAISERROR(N'Куратор не найден', 16, 1);

        IF @Специальность_ID IS NULL
            SELECT TOP 1 @Специальность_ID = Специальность_ID FROM dbo.Специальность ORDER BY Специальность_ID;

        IF @Специальность_ID IS NULL
            RAISERROR(N'Специальность не найдена', 16, 1);

        INSERT INTO dbo.Учебная_Группа (Название, Год_Поступления, Статус, Куратор_ID, Примечание, Дата_Создания, Специальность_ID)
        VALUES (@Название, @Год_Поступления, N'Активна', @Куратор_ID, @Примечание, GETDATE(), @Специальность_ID);

        DECLARE @НовыйID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание учебной группы', N'Учебная_Группа', @НовыйID, N'Успешно');

        COMMIT TRANSACTION;

        SELECT @НовыйID AS Группа_ID, N'Учебная группа успешно создана' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьРасписание
    @Группа_ID INT,
    @Дисциплина_ID INT,
    @День_Недели TINYINT,
    @Время_Начала TIME,
    @Время_Окончания TIME,
    @Тип_Занятия NVARCHAR(30) = NULL,
    @Кабинет NVARCHAR(50) = NULL,
    @Примечание NVARCHAR(300) = NULL,
    @КтоСоздал INT,
    @Числ_Знамен NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Учебная_Группа WHERE Группа_ID = @Группа_ID)
            RAISERROR(N'Группа не найдена', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM dbo.Дисциплина WHERE Дисциплина_ID = @Дисциплина_ID)
            RAISERROR(N'Дисциплина не найдена', 16, 1);

        IF @Числ_Знамен IS NOT NULL AND @Числ_Знамен NOT IN (N'числитель', N'знаменатель', N'каждая')
            RAISERROR(N'Недопустимое значение числ/знамен', 16, 1);

        IF EXISTS (
            SELECT 1 FROM dbo.Расписание
            WHERE Группа_ID = @Группа_ID
              AND День_Недели = @День_Недели
              AND (
                  ISNULL([числ/знамен], N'каждая') = N'каждая'
                  OR ISNULL(@Числ_Знамен, N'каждая') = N'каждая'
                  OR [числ/знамен] = @Числ_Знамен
              )
              AND (
                  (@Время_Начала < Время_Окончания AND @Время_Окончания > Время_Начала)
              )
        )
        BEGIN
            RAISERROR(N'Найдено пересечение с существующим расписанием', 16, 1);
            RETURN;
        END;

        INSERT INTO dbo.Расписание (
            Группа_ID, Дисциплина_ID, День_Недели,
            Время_Начала, Время_Окончания, Тип_Занятия, [числ/знамен], Кабинет, Примечание
        )
        VALUES (
            @Группа_ID, @Дисциплина_ID, @День_Недели,
            @Время_Начала, @Время_Окончания, @Тип_Занятия, @Числ_Знамен, @Кабинет, @Примечание
        );

        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        DECLARE @Группа NVARCHAR(50);
        DECLARE @Дисциплина NVARCHAR(100);
        DECLARE @ПреподавательПользователь_ID INT;

        SELECT @Группа = Название FROM dbo.Учебная_Группа WHERE Группа_ID = @Группа_ID;
        SELECT
            @Дисциплина = d.Название,
            @ПреподавательПользователь_ID = p.Пользователь_ID
        FROM dbo.Дисциплина d
        INNER JOIN dbo.Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
        WHERE d.Дисциплина_ID = @Дисциплина_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание расписания', N'Расписание', @НовыйID, N'Успешно');

        INSERT INTO dbo.Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
        SELECT s.Пользователь_ID, N'Информация', N'Изменение расписания',
               CONCAT(N'Добавлено занятие: ', @Дисциплина, N', группа ', @Группа),
               N'/student/schedule.php'
        FROM dbo.Студент s
        WHERE s.Группа_ID = @Группа_ID
          AND s.Пользователь_ID IS NOT NULL;

        IF @ПреподавательПользователь_ID IS NOT NULL
        BEGIN
            INSERT INTO dbo.Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
            VALUES (
                @ПреподавательПользователь_ID,
                N'Информация',
                N'Изменение расписания',
                CONCAT(N'Добавлено занятие: ', @Дисциплина, N', группа ', @Группа),
                N'/teacher/dashboard.php'
            );
        END;

        COMMIT TRANSACTION;

        SELECT @НовыйID AS Расписание_ID, N'Расписание успешно создано' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

