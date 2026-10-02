USE [Улучшенная];
GO

IF COL_LENGTH(N'dbo.Расписание', N'Тип_Недели') IS NULL
BEGIN
    ALTER TABLE dbo.Расписание
    ADD Тип_Недели NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Расписание_Тип_Недели DEFAULT N'Обе';
END;
GO

IF COL_LENGTH(N'dbo.Расписание', N'числ/знамен') IS NOT NULL
BEGIN
    -- Column exists: run UPDATE that also inspects the legacy [числ/знамен] column
    EXEC sp_executesql N'
        UPDATE dbo.Расписание
        SET Тип_Недели =
            CASE
                WHEN Тип_Недели IN (N''''Числитель'''', N''''числитель'''') THEN N''''Числитель''''
                WHEN Тип_Недели IN (N''''Знаменатель'''', N''''знаменатель'''') THEN N''''Знаменатель''''
                WHEN [числ/знамен] = N''''числитель'''' THEN N''''Числитель''''
                WHEN [числ/знамен] = N''''знаменатель'''' THEN N''''Знаменатель''''
                ELSE N''''Обе''''
            END
        WHERE Тип_Недели IS NULL
           OR Тип_Недели NOT IN (N''''Обе'''', N''''Числитель'''', N''''Знаменатель'''')
           OR [числ/знамен] IN (N''''числитель'''', N''''знаменатель'''');
    '
END
ELSE
BEGIN
    -- Column missing: update based only on existing Тип_Недели values
    UPDATE dbo.Расписание
    SET Тип_Недели =
        CASE
            WHEN Тип_Недели IN (N'Числитель', N'числитель') THEN N'Числитель'
            WHEN Тип_Недели IN (N'Знаменатель', N'знаменатель') THEN N'Знаменатель'
            ELSE N'Обе'
        END
    WHERE Тип_Недели IS NULL
       OR Тип_Недели NOT IN (N'Обе', N'Числитель', N'Знаменатель');
END;
GO

ALTER TABLE dbo.Расписание ALTER COLUMN Тип_Недели NVARCHAR(20) NOT NULL;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c
      ON c.object_id = dc.parent_object_id
     AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Расписание')
      AND c.name = N'Тип_Недели'
)
BEGIN
    ALTER TABLE dbo.Расписание
    ADD CONSTRAINT DF_Расписание_Тип_Недели DEFAULT N'Обе' FOR Тип_Недели;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CHK_Расписание_Тип_Недели'
      AND parent_object_id = OBJECT_ID(N'dbo.Расписание')
)
BEGIN
    ALTER TABLE dbo.Расписание WITH CHECK
    ADD CONSTRAINT CHK_Расписание_Тип_Недели
    CHECK (Тип_Недели IN (N'Обе', N'Числитель', N'Знаменатель'));
END;
GO

UPDATE dbo.Расписание
SET [числ/знамен] =
    CASE Тип_Недели
        WHEN N'Числитель' THEN N'числитель'
        WHEN N'Знаменатель' THEN N'знаменатель'
        ELSE N'каждая'
    END
WHERE COL_LENGTH(N'dbo.Расписание', N'числ/знамен') IS NOT NULL;
GO

CREATE OR ALTER FUNCTION dbo.AIS_НомерУчебнойНедели(@Дата DATE)
RETURNS INT
AS
BEGIN
    DECLARE @УчебныйГод INT =
        CASE WHEN MONTH(@Дата) >= 9 THEN YEAR(@Дата) ELSE YEAR(@Дата) - 1 END;
    DECLARE @Начало DATE = DATEFROMPARTS(@УчебныйГод, 9, 1);
    DECLARE @ПонедельникНачала DATE =
        DATEADD(DAY, -(DATEDIFF(DAY, CONVERT(DATE, '19000101'), @Начало) % 7), @Начало);

    RETURN DATEDIFF(DAY, @ПонедельникНачала, @Дата) / 7 + 1;
END;
GO

CREATE OR ALTER FUNCTION dbo.AIS_ТипНеделиДляДаты(@Дата DATE)
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CASE
        WHEN dbo.AIS_НомерУчебнойНедели(@Дата) % 2 = 1 THEN N'Числитель'
        ELSE N'Знаменатель'
    END;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьКорпуса
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Корпус_ID,
        Название,
        Адрес,
        Описание,
        Дата_Создания
    FROM dbo.Корпус
    ORDER BY Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьАудитории
    @Корпус_ID INT = NULL,
    @Статус NVARCHAR(20) = N'Активна',
    @Поиск NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Search NVARCHAR(120) = NULLIF(LTRIM(RTRIM(@Поиск)), N'');
    IF @Search IS NOT NULL SET @Search = N'%' + @Search + N'%';

    SELECT
        a.Аудитория_ID,
        a.Номер,
        a.Номер AS Кабинет,
        a.Тип,
        a.Корпус_ID,
        COALESCE(k.Название, a.Корпус) AS Корпус,
        a.Вместимость,
        a.Статус,
        a.Примечание
    FROM dbo.Аудитория a
    LEFT JOIN dbo.Корпус k ON k.Корпус_ID = a.Корпус_ID
    WHERE (@Корпус_ID IS NULL OR a.Корпус_ID = @Корпус_ID)
      AND (@Статус IS NULL OR a.Статус = @Статус)
      AND (
          @Search IS NULL
          OR a.Номер LIKE @Search
          OR a.Тип LIKE @Search
          OR COALESCE(k.Название, a.Корпус) LIKE @Search
      )
    ORDER BY COALESCE(k.Название, a.Корпус), a.Номер;
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
        d.Название AS Дисциплина,
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
        p.ФИО AS Преподаватель,
        p.Кафедра,
        COUNT(DISTINCT r.Группа_ID) AS КоличествоГрупп
    FROM dbo.Дисциплина d
    INNER JOIN dbo.Преподаватель p ON p.Преподаватель_ID = d.Преподаватель_ID
    LEFT JOIN dbo.Расписание r ON r.Дисциплина_ID = d.Дисциплина_ID
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

CREATE OR ALTER PROCEDURE dbo.ПолучитьРасписаниеОбзор
    @Группа_ID INT = NULL,
    @Преподаватель_ID INT = NULL,
    @Куратор_ID INT = NULL,
    @Корпус_ID INT = NULL,
    @Аудитория_ID INT = NULL,
    @Кабинет NVARCHAR(50) = NULL,
    @Тип_Недели NVARCHAR(20) = NULL,
    @Тип_Занятия NVARCHAR(30) = NULL,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL,
    @Дата_Начала DATE = NULL,
    @Дата_Конца DATE = NULL,
    @Поиск NVARCHAR(200) = NULL,
    @Страница INT = 1,
    @Размер_Страницы INT = 200
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Сегодня DATE = CAST(GETDATE() AS DATE);
    DECLARE @Понедельник DATE =
        DATEADD(DAY, -(DATEDIFF(DAY, CONVERT(DATE, '19000101'), @Сегодня) % 7), @Сегодня);

    IF @Дата_Начала IS NULL SET @Дата_Начала = @Понедельник;
    IF @Дата_Конца IS NULL SET @Дата_Конца = DATEADD(DAY, 6, @Дата_Начала);

    IF @Дата_Конца < @Дата_Начала
        THROW 51000, N'Дата_Конца не может быть раньше Дата_Начала', 1;

    IF DATEDIFF(DAY, @Дата_Начала, @Дата_Конца) > 370
        THROW 51001, N'Период расписания не должен превышать 370 дней', 1;

    IF @Страница IS NULL OR @Страница < 1 SET @Страница = 1;
    IF @Размер_Страницы IS NULL OR @Размер_Страницы < 1 SET @Размер_Страницы = 200;
    IF @Размер_Страницы > 1000 SET @Размер_Страницы = 1000;

    DECLARE @NormWeek NVARCHAR(20) = NULLIF(LTRIM(RTRIM(@Тип_Недели)), N'');
    SET @NormWeek =
        CASE
            WHEN @NormWeek IN (N'Обе', N'каждая') THEN N'Обе'
            WHEN @NormWeek IN (N'Числитель', N'числитель') THEN N'Числитель'
            WHEN @NormWeek IN (N'Знаменатель', N'знаменатель') THEN N'Знаменатель'
            ELSE @NormWeek
        END;

    IF @NormWeek IS NOT NULL AND @NormWeek NOT IN (N'Обе', N'Числитель', N'Знаменатель')
        THROW 51002, N'Недопустимое значение Тип_Недели', 1;

    DECLARE @Search NVARCHAR(220) = NULLIF(LTRIM(RTRIM(@Поиск)), N'');
    IF @Search IS NOT NULL SET @Search = N'%' + @Search + N'%';

    DECLARE @RoomSearch NVARCHAR(80) = NULLIF(LTRIM(RTRIM(@Кабинет)), N'');
    IF @RoomSearch IS NOT NULL SET @RoomSearch = N'%' + @RoomSearch + N'%';

    ;WITH Даты AS (
        SELECT @Дата_Начала AS Дата
        UNION ALL
        SELECT DATEADD(DAY, 1, Дата)
        FROM Даты
        WHERE Дата < @Дата_Конца
    ),
    База AS (
        SELECT
            r.Расписание_ID,
            z.Занятие_ID,
            dt.Дата AS Дата_Занятия,
            dt.Дата AS Дата,
            r.День_Недели,
            CASE r.День_Недели
                WHEN 1 THEN N'Понедельник'
                WHEN 2 THEN N'Вторник'
                WHEN 3 THEN N'Среда'
                WHEN 4 THEN N'Четверг'
                WHEN 5 THEN N'Пятница'
                WHEN 6 THEN N'Суббота'
                WHEN 7 THEN N'Воскресенье'
                ELSE N''
            END AS День_Недели_Название,
            dbo.AIS_НомерУчебнойНедели(dt.Дата) AS Номер_Учебной_Недели,
            dbo.AIS_ТипНеделиДляДаты(dt.Дата) AS Текущий_Тип_Недели,
            ISNULL(r.Тип_Недели, N'Обе') AS Тип_Недели,
            r.[числ/знамен],
            r.Время_Начала,
            r.Время_Окончания,
            CONCAT(CONVERT(NVARCHAR(5), r.Время_Начала, 108), N'–', CONVERT(NVARCHAR(5), r.Время_Окончания, 108)) AS Время,
            r.Тип_Занятия,
            ISNULL(z.Статус, N'Запланировано') AS Статус,
            COALESCE(z.Кабинет, r.Кабинет, a.Номер) AS Кабинет,
            r.Аудитория_ID,
            COALESCE(a.Номер, z.Кабинет, r.Кабинет) AS Аудитория,
            a.Номер AS Номер_Аудитории,
            a.Тип AS Тип_Аудитории,
            COALESCE(a.Корпус_ID, k.Корпус_ID) AS Корпус_ID,
            COALESCE(k.Название, a.Корпус) AS Корпус,
            d.Дисциплина_ID,
            d.Название AS Название_Дисциплины,
            d.Название AS Дисциплина,
            d.[краткое наименование] AS Код_Дисциплины,
            d.[краткое наименование],
            d.Семестр,
            p.Преподаватель_ID,
            p.ФИО AS ФИО_Преподавателя,
            p.ФИО AS Преподаватель,
            p.Кафедра,
            g.Группа_ID,
            g.Название AS Название_Группы,
            g.Название AS Группа,
            COUNT(*) OVER() AS Всего_Строк
        FROM dbo.Расписание r
        INNER JOIN Даты dt
            ON ((DATEDIFF(DAY, CONVERT(DATE, '19000101'), dt.Дата) % 7) + 1) = r.День_Недели
        INNER JOIN dbo.Дисциплина d ON d.Дисциплина_ID = r.Дисциплина_ID
        INNER JOIN dbo.Преподаватель p ON p.Преподаватель_ID = d.Преподаватель_ID
        INNER JOIN dbo.Учебная_Группа g ON g.Группа_ID = r.Группа_ID
        LEFT JOIN dbo.Аудитория a ON a.Аудитория_ID = r.Аудитория_ID
        LEFT JOIN dbo.Корпус k ON k.Корпус_ID = a.Корпус_ID
        LEFT JOIN dbo.Занятие z
            ON z.Расписание_ID = r.Расписание_ID
           AND z.Дата_Занятия = dt.Дата
        WHERE (@Группа_ID IS NULL OR r.Группа_ID = @Группа_ID)
          AND (@Преподаватель_ID IS NULL OR d.Преподаватель_ID = @Преподаватель_ID)
          AND (@Куратор_ID IS NULL OR g.Куратор_ID = @Куратор_ID)
          AND (@Корпус_ID IS NULL OR COALESCE(a.Корпус_ID, k.Корпус_ID) = @Корпус_ID)
          AND (@Аудитория_ID IS NULL OR r.Аудитория_ID = @Аудитория_ID)
          AND (@День_Недели IS NULL OR r.День_Недели = @День_Недели)
          AND (@Семестр IS NULL OR d.Семестр = @Семестр)
          AND (@Тип_Занятия IS NULL OR r.Тип_Занятия = @Тип_Занятия)
          AND (
              ISNULL(r.Тип_Недели, N'Обе') = N'Обе'
              OR ISNULL(r.Тип_Недели, N'Обе') = dbo.AIS_ТипНеделиДляДаты(dt.Дата)
          )
          AND (
              @NormWeek IS NULL
              OR (@NormWeek = N'Обе' AND ISNULL(r.Тип_Недели, N'Обе') = N'Обе')
              OR (@NormWeek <> N'Обе' AND ISNULL(r.Тип_Недели, N'Обе') IN (N'Обе', @NormWeek))
          )
          AND (
              @RoomSearch IS NULL
              OR COALESCE(z.Кабинет, r.Кабинет, a.Номер) LIKE @RoomSearch
              OR a.Номер LIKE @RoomSearch
          )
          AND (
              @Search IS NULL
              OR d.Название LIKE @Search
              OR d.[краткое наименование] LIKE @Search
              OR p.ФИО LIKE @Search
              OR g.Название LIKE @Search
              OR COALESCE(z.Кабинет, r.Кабинет, a.Номер) LIKE @Search
              OR COALESCE(k.Название, a.Корпус) LIKE @Search
              OR r.Тип_Занятия LIKE @Search
              OR ISNULL(r.Тип_Недели, N'Обе') LIKE @Search
              OR CONVERT(NVARCHAR(5), r.Время_Начала, 108) LIKE @Search
          )
    ),
    Нумерация AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                ORDER BY Дата_Занятия, Время_Начала, Название_Группы, Название_Дисциплины
            ) AS Номер_Строки
        FROM База
    )
    SELECT *
    FROM Нумерация
    WHERE Номер_Строки BETWEEN ((@Страница - 1) * @Размер_Страницы + 1)
                          AND (@Страница * @Размер_Страницы)
    ORDER BY Номер_Строки
    OPTION (MAXRECURSION 400);
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьРасписаниеПоГруппе
    @Группа_ID INT,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL,
    @Дата_Начала DATE = NULL,
    @Дата_Конца DATE = NULL,
    @Тип_Недели NVARCHAR(20) = NULL,
    @Поиск NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.ПолучитьРасписаниеОбзор
        @Группа_ID = @Группа_ID,
        @День_Недели = @День_Недели,
        @Семестр = @Семестр,
        @Дата_Начала = @Дата_Начала,
        @Дата_Конца = @Дата_Конца,
        @Тип_Недели = @Тип_Недели,
        @Поиск = @Поиск,
        @Размер_Страницы = 1000;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ПолучитьРасписаниеПоПреподавателю
    @Преподаватель_ID INT,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL,
    @Дата_Начала DATE = NULL,
    @Дата_Конца DATE = NULL,
    @Тип_Недели NVARCHAR(20) = NULL,
    @Поиск NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.ПолучитьРасписаниеОбзор
        @Преподаватель_ID = @Преподаватель_ID,
        @День_Недели = @День_Недели,
        @Семестр = @Семестр,
        @Дата_Начала = @Дата_Начала,
        @Дата_Конца = @Дата_Конца,
        @Тип_Недели = @Тип_Недели,
        @Поиск = @Поиск,
        @Размер_Страницы = 1000;
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
            THROW 51010, N'Преподаватель не найден', 1;

        IF @Код_Дисциплины IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.Дисциплина WHERE [краткое наименование] = @Код_Дисциплины)
            THROW 51011, N'Дисциплина с таким кодом уже существует', 1;

        INSERT INTO dbo.Дисциплина (
            Название, [краткое наименование], Преподаватель_ID,
            Часы_Теории, Часы_Практики, Семестр, Статус, Описание, Дата_Создания
        )
        VALUES (
            @Название, @Код_Дисциплины, @Преподаватель_ID,
            @Часы_Теории, @Часы_Практики, @Семестр, N'Активна', @Описание, GETDATE()
        );

        DECLARE @НовыйID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, [Таблица], Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание дисциплины', N'Дисциплина', @НовыйID, N'Успешно');

        COMMIT TRANSACTION;

        SELECT
            @НовыйID AS Дисциплина_ID,
            @Код_Дисциплины AS Код_Дисциплины,
            N'Дисциплина успешно создана' AS Сообщение;
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
    @Тип_Недели NVARCHAR(20) = N'Обе',
    @Аудитория_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NormWeek NVARCHAR(20) =
            CASE
                WHEN @Тип_Недели IS NULL OR LTRIM(RTRIM(@Тип_Недели)) = N'' THEN N'Обе'
                WHEN @Тип_Недели IN (N'Обе', N'каждая') THEN N'Обе'
                WHEN @Тип_Недели IN (N'Числитель', N'числитель') THEN N'Числитель'
                WHEN @Тип_Недели IN (N'Знаменатель', N'знаменатель') THEN N'Знаменатель'
                ELSE @Тип_Недели
            END;

        IF @NormWeek NOT IN (N'Обе', N'Числитель', N'Знаменатель')
            THROW 51020, N'Недопустимое значение Тип_Недели', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Учебная_Группа WHERE Группа_ID = @Группа_ID)
            THROW 51021, N'Группа не найдена', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Дисциплина WHERE Дисциплина_ID = @Дисциплина_ID)
            THROW 51022, N'Дисциплина не найдена', 1;

        IF @День_Недели NOT BETWEEN 1 AND 7
            THROW 51023, N'Недопустимый день недели', 1;

        IF @Время_Начала >= @Время_Окончания
            THROW 51024, N'Время окончания должно быть позже времени начала', 1;

        IF @Тип_Занятия IS NOT NULL
           AND @Тип_Занятия NOT IN (N'Лекция', N'Практика', N'Лабораторная', N'Семинар')
            THROW 51025, N'Недопустимый тип занятия', 1;

        IF @Аудитория_ID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.Аудитория WHERE Аудитория_ID = @Аудитория_ID)
                THROW 51026, N'Аудитория не найдена', 1;

            IF @Кабинет IS NULL OR LTRIM(RTRIM(@Кабинет)) = N''
                SELECT @Кабинет = Номер FROM dbo.Аудитория WHERE Аудитория_ID = @Аудитория_ID;
        END;

        IF EXISTS (
            SELECT 1
            FROM dbo.Расписание r
            WHERE r.Группа_ID = @Группа_ID
              AND r.День_Недели = @День_Недели
              AND (
                  ISNULL(r.Тип_Недели, N'Обе') = N'Обе'
                  OR @NormWeek = N'Обе'
                  OR ISNULL(r.Тип_Недели, N'Обе') = @NormWeek
              )
              AND @Время_Начала < r.Время_Окончания
              AND @Время_Окончания > r.Время_Начала
        )
            THROW 51027, N'Найдено пересечение с существующим расписанием группы', 1;

        DECLARE @CompatWeek NVARCHAR(20) =
            CASE @NormWeek
                WHEN N'Числитель' THEN N'числитель'
                WHEN N'Знаменатель' THEN N'знаменатель'
                ELSE N'каждая'
            END;

        INSERT INTO dbo.Расписание (
            Группа_ID, Дисциплина_ID, День_Недели,
            Время_Начала, Время_Окончания, Тип_Занятия,
            Кабинет, Примечание, Аудитория_ID, Тип_Недели, [числ/знамен]
        )
        VALUES (
            @Группа_ID, @Дисциплина_ID, @День_Недели,
            @Время_Начала, @Время_Окончания, @Тип_Занятия,
            @Кабинет, @Примечание, @Аудитория_ID, @NormWeek, @CompatWeek
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
        INNER JOIN dbo.Преподаватель p ON p.Преподаватель_ID = d.Преподаватель_ID
        WHERE d.Дисциплина_ID = @Дисциплина_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, [Таблица], Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание расписания', N'Расписание', @НовыйID, N'Успешно');

        INSERT INTO dbo.Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
        SELECT s.Пользователь_ID, N'Информация', N'Изменение расписания',
               CONCAT(N'Добавлено занятие: ', @Дисциплина, N', группа ', @Группа, N' (', @NormWeek, N')'),
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
                CONCAT(N'Добавлено занятие: ', @Дисциплина, N', группа ', @Группа, N' (', @NormWeek, N')'),
                N'/teacher/schedule.php'
            );
        END;

        COMMIT TRANSACTION;

        SELECT
            @НовыйID AS Расписание_ID,
            @NormWeek AS Тип_Недели,
            N'Расписание успешно создано' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетПоГруппе
    @Группа_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL,
    @Дисциплина_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @НачалоПериода IS NULL SET @НачалоПериода = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE));
    IF @КонецПериода IS NULL SET @КонецПериода = CAST(GETDATE() AS DATE);

    SELECT
        s.Студент_ID,
        s.ФИО AS ФИО_Студента,
        d.Название AS Дисциплина,
        d.[краткое наименование] AS Код_Дисциплины,
        p.ФИО AS Преподаватель,
        COUNT(z.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
    FROM dbo.Студент s
    INNER JOIN dbo.Расписание r ON r.Группа_ID = s.Группа_ID
    INNER JOIN dbo.Дисциплина d ON d.Дисциплина_ID = r.Дисциплина_ID
    INNER JOIN dbo.Преподаватель p ON p.Преподаватель_ID = d.Преподаватель_ID
    LEFT JOIN dbo.Занятие z ON r.Расписание_ID = z.Расписание_ID
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN dbo.Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE s.Группа_ID = @Группа_ID
      AND (@Дисциплина_ID IS NULL OR d.Дисциплина_ID = @Дисциплина_ID)
    GROUP BY
        s.Студент_ID, s.ФИО,
        d.Дисциплина_ID, d.Название, d.[краткое наименование],
        p.ФИО
    ORDER BY s.ФИО, d.Название;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетПоСтуденту
    @Студент_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @НачалоПериода IS NULL SET @НачалоПериода = DATEADD(MONTH, -3, CAST(GETDATE() AS DATE));
    IF @КонецПериода IS NULL SET @КонецПериода = CAST(GETDATE() AS DATE);

    SELECT
        s.ФИО,
        g.Название AS Группа,
        COUNT(DISTINCT z.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(DISTINCT z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ОбщийПроцентПосещаемости
    FROM dbo.Студент s
    INNER JOIN dbo.Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    LEFT JOIN dbo.Расписание r ON s.Группа_ID = r.Группа_ID
    LEFT JOIN dbo.Занятие z ON r.Расписание_ID = z.Расписание_ID
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN dbo.Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID = @Студент_ID
    GROUP BY s.Студент_ID, s.ФИО, g.Название;

    SELECT
        d.Название AS Дисциплина,
        d.[краткое наименование] AS Код_Дисциплины,
        p.ФИО AS Преподаватель,
        p.Кафедра,
        COUNT(z.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
    FROM dbo.Студент s
    INNER JOIN dbo.Расписание r ON s.Группа_ID = r.Группа_ID
    INNER JOIN dbo.Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN dbo.Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    LEFT JOIN dbo.Занятие z ON r.Расписание_ID = z.Расписание_ID
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN dbo.Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID = @Студент_ID
    GROUP BY
        d.Дисциплина_ID, d.Название, d.[краткое наименование],
        p.Преподаватель_ID, p.ФИО, p.Кафедра
    ORDER BY d.Название;
END;
GO

CREATE OR ALTER TRIGGER dbo.TRG_АвтоСозданиеЗанятий
ON dbo.Расписание
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @НедельВперед INT = 8;
    DECLARE @ДатаНачала DATE = CAST(GETDATE() AS DATE);
    DECLARE @ДатаКонца DATE = DATEADD(WEEK, @НедельВперед, @ДатаНачала);

    ;WITH Даты AS (
        SELECT @ДатаНачала AS Дата
        UNION ALL
        SELECT DATEADD(DAY, 1, Дата)
        FROM Даты
        WHERE Дата < @ДатаКонца
    )
    INSERT INTO dbo.Занятие (
        Расписание_ID, Дата_Занятия, Статус, Тема_Занятия, Кабинет, Дата_Создания
    )
    SELECT
        i.Расписание_ID,
        d.Дата,
        N'Запланировано',
        CONCAT(ISNULL(i.Тип_Занятия, N'Занятие'), N': ', disc.Название),
        i.Кабинет,
        GETDATE()
    FROM inserted i
    INNER JOIN dbo.Дисциплина disc ON disc.Дисциплина_ID = i.Дисциплина_ID
    CROSS JOIN Даты d
    WHERE ((DATEDIFF(DAY, CONVERT(DATE, '19000101'), d.Дата) % 7) + 1) = i.День_Недели
      AND (
          ISNULL(i.Тип_Недели, N'Обе') = N'Обе'
          OR ISNULL(i.Тип_Недели, N'Обе') = dbo.AIS_ТипНеделиДляДаты(d.Дата)
      )
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Занятие z
          WHERE z.Расписание_ID = i.Расписание_ID
            AND z.Дата_Занятия = d.Дата
      )
    OPTION (MAXRECURSION 120);
END;
GO

