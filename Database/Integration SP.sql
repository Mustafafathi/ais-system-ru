USE Улучшенная;
GO

CREATE OR ALTER PROCEDURE ИмпортГруппИзCSV
    @CSV_Содержимое NVARCHAR(MAX),
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- سجل بداية العملية
    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
    VALUES (@КтоСоздал, N'Импорт групп из CSV', N'Успешно', N'Начало импорта');
    
    -- جدول مؤقت لأسطر CSV
    DECLARE @Lines TABLE (LineNumber INT, Line NVARCHAR(MAX));
    
    -- تقسيم CSV إلى أسطر (باستخدام ordinal في SQL Server 2022)
    INSERT INTO @Lines (LineNumber, Line)
    SELECT ordinal, value
    FROM STRING_SPLIT(@CSV_Содержимое, CHAR(13) + CHAR(10), 1);
    
    -- تخطي السطر الأول إذا كان رأساً (يحتوي على 'Название' مثلاً)
    DECLARE @SkipHeader BIT = 0;
    IF EXISTS (SELECT 1 FROM @Lines WHERE LineNumber = 1 AND Line LIKE N'%Название%')
        SET @SkipHeader = 1;
    
    -- جدول للبيانات المجزأة
    DECLARE @Parsed TABLE (LineNumber INT, Название NVARCHAR(50), Год_Поступления INT, Код_Специальности NVARCHAR(20));
    
    -- معالجة كل سطر
    DECLARE @LineNumber INT, @Line NVARCHAR(MAX);
    DECLARE @Название NVARCHAR(50), @ГодПоступления INT, @КодСпециальности NVARCHAR(20);
    
    DECLARE line_cursor CURSOR FOR
        SELECT LineNumber, Line FROM @Lines 
        WHERE LineNumber > CASE WHEN @SkipHeader = 1 THEN 1 ELSE 0 END
        ORDER BY LineNumber;
    
    OPEN line_cursor;
    FETCH NEXT FROM line_cursor INTO @LineNumber, @Line;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- تقسيم السطر إلى أعمدة باستخدام STRING_SPLIT مع ordinal
        DECLARE @Cols TABLE (ColNumber INT, Value NVARCHAR(MAX));
        INSERT INTO @Cols (ColNumber, Value)
        SELECT ordinal, value FROM STRING_SPLIT(@Line, ';', 1);
        
        -- استخراج القيم حسب الترتيب (1: Название, 2: ГодПоступления, 3: КодСпециальности)
        SELECT @Название = Value FROM @Cols WHERE ColNumber = 1;
        SELECT @ГодПоступления = TRY_CAST(Value AS INT) FROM @Cols WHERE ColNumber = 2;
        SELECT @КодСпециальности = Value FROM @Cols WHERE ColNumber = 3;
        
        IF @Название IS NOT NULL AND @ГодПоступления IS NOT NULL
        BEGIN
            INSERT INTO @Parsed (LineNumber, Название, Год_Поступления, Код_Специальности)
            VALUES (@LineNumber, @Название, @ГодПоступления, @КодСпециальности);
        END
        
        DELETE FROM @Cols;
        FETCH NEXT FROM line_cursor INTO @LineNumber, @Line;
    END
    
    CLOSE line_cursor;
    DEALLOCATE line_cursor;
    
    -- إدراج المجموعات الجديدة (تجنب التكرار)
    DECLARE @Добавлено INT = 0;
    DECLARE @Пропущено INT = 0;
    
    INSERT INTO Учебная_Группа (Название, Год_Поступления, Примечание)
    SELECT 
        p.Название,
        p.Год_Поступления,
        N'Импортировано из CSV: ' + CAST(GETDATE() AS NVARCHAR)
    FROM @Parsed p
    WHERE NOT EXISTS (SELECT 1 FROM Учебная_Группа WHERE Название = p.Название);
    
    SET @Добавлено = @@ROWCOUNT;
    SET @Пропущено = (SELECT COUNT(*) FROM @Parsed) - @Добавлено;
    
    -- تسجيل النتيجة
    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
    VALUES (@КтоСоздал, N'Импорт групп из CSV', N'Успешно', 
            CONCAT(N'Добавлено: ', @Добавлено, N', Пропущено: ', @Пропущено));
    
    SELECT @Добавлено AS Добавлено, @Пропущено AS Пропущено;
END;
GO


USE Улучшенная;
GO

CREATE OR ALTER PROCEDURE ИмпортСтудентовИзCSV
    @CSV_Содержимое NVARCHAR(MAX),
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @НормализованныйCSV NVARCHAR(MAX) = ISNULL(@CSV_Содержимое, N'');
    SET @НормализованныйCSV = REPLACE(@НормализованныйCSV, NCHAR(65279), N'');
    SET @НормализованныйCSV = REPLACE(@НормализованныйCSV, CHAR(13), N'');
    SET @НормализованныйCSV = REPLACE(@НормализованныйCSV, CHAR(9), N' ');

    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
    VALUES (@КтоСоздал, N'Импорт студентов из CSV', N'Успешно', N'Начало импорта');

    DECLARE @Lines TABLE (
        LineNumber INT IDENTITY(1,1) PRIMARY KEY,
        Line NVARCHAR(MAX) NOT NULL
    );

    INSERT INTO @Lines (Line)
    SELECT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@НормализованныйCSV, CHAR(10), 1)
    WHERE LTRIM(RTRIM(value)) <> N'';

    DECLARE @HasHeader BIT = 0;
    IF EXISTS (
        SELECT 1
        FROM @Lines
        WHERE LineNumber = 1
          AND Line LIKE N'%ФИО%'
          AND Line LIKE N'%ГРУПП%'
          AND Line LIKE N'%ЛОГИН%'
    )
    BEGIN
        SET @HasHeader = 1;
    END

    DECLARE @TotalRows INT = (
        SELECT COUNT(*)
        FROM @Lines
        WHERE LineNumber > CASE WHEN @HasHeader = 1 THEN 1 ELSE 0 END
    );

    DECLARE @Added INT = 0;
    DECLARE @Skipped INT = 0;
    DECLARE @Errors INT = 0;

    DECLARE @ErrorRows TABLE (
        LineNumber INT,
        Ошибка NVARCHAR(4000),
        Строка NVARCHAR(MAX)
    );

    DECLARE @LineNumber INT;
    DECLARE @Line NVARCHAR(MAX);

    DECLARE student_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT LineNumber, Line
        FROM @Lines
        WHERE LineNumber > CASE WHEN @HasHeader = 1 THEN 1 ELSE 0 END
        ORDER BY LineNumber;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @LineNumber, @Line;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            DECLARE @Cols TABLE (
                ColNumber INT,
                Value NVARCHAR(MAX)
            );

            INSERT INTO @Cols (ColNumber, Value)
            SELECT ordinal, LTRIM(RTRIM(REPLACE(value, NCHAR(65279), N'')))
            FROM STRING_SPLIT(@Line, ';', 1);

            DECLARE @ФИО NVARCHAR(150) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 1 THEN Value END) FROM @Cols), N'');
            DECLARE @ГруппаToken NVARCHAR(100) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 2 THEN Value END) FROM @Cols), N'');
            DECLARE @Логин NVARCHAR(50) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 3 THEN Value END) FROM @Cols), N'');
            DECLARE @Пароль NVARCHAR(255) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 4 THEN Value END) FROM @Cols), N'');
            DECLARE @EmailRaw NVARCHAR(100) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 5 THEN Value END) FROM @Cols), N'');
            DECLARE @ДатаПоступленияRaw NVARCHAR(50) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 6 THEN Value END) FROM @Cols), N'');
            DECLARE @ДатаРожденияRaw NVARCHAR(50) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 7 THEN Value END) FROM @Cols), N'');
            DECLARE @Пол NVARCHAR(10) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 8 THEN Value END) FROM @Cols), N'');
            DECLARE @Адрес NVARCHAR(300) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 9 THEN Value END) FROM @Cols), N'');
            DECLARE @ТелефонРодителей NVARCHAR(20) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 10 THEN Value END) FROM @Cols), N'');
            DECLARE @Примечание NVARCHAR(500) = NULLIF((SELECT MAX(CASE WHEN ColNumber = 11 THEN Value END) FROM @Cols), N'');

            IF @ФИО IS NULL OR @ГруппаToken IS NULL OR @Логин IS NULL OR @Пароль IS NULL
                THROW 50001, N'Не заполнены обязательные поля CSV (ФИО, Группа, Логин, Пароль).', 1;

            DECLARE @Email NVARCHAR(100) = @EmailRaw;
            IF @Email IS NOT NULL AND @Email NOT LIKE N'%_@_%._%'
                THROW 50002, N'Некорректный формат Email.', 1;

            DECLARE @Группа_ID INT = NULL;
            DECLARE @AsInt INT = TRY_CAST(@ГруппаToken AS INT);
            IF @AsInt IS NOT NULL
            BEGIN
                SELECT @Группа_ID = Группа_ID
                FROM Учебная_Группа
                WHERE Группа_ID = @AsInt;
            END

            IF @Группа_ID IS NULL
            BEGIN
                SELECT TOP 1 @Группа_ID = Группа_ID
                FROM Учебная_Группа
                WHERE LTRIM(RTRIM(Название)) = LTRIM(RTRIM(@ГруппаToken));
            END

            IF @Группа_ID IS NULL
                THROW 50003, N'Группа не найдена.', 1;

            DECLARE @Роль_ID INT;
            SELECT @Роль_ID = Роль_ID
            FROM Роль
            WHERE Название = N'Студент';

            IF @Роль_ID IS NULL
                THROW 50004, N'Роль Студент не найдена.', 1;

            IF EXISTS (SELECT 1 FROM Пользователь WHERE Логин = @Логин)
                THROW 50005, N'Логин уже существует.', 1;

            DECLARE @ДатаПоступления DATE = COALESCE(
                TRY_CONVERT(DATE, @ДатаПоступленияRaw, 23),
                TRY_CONVERT(DATE, @ДатаПоступленияRaw, 104),
                CAST(GETDATE() AS DATE)
            );

            DECLARE @ДатаРождения DATE = COALESCE(
                TRY_CONVERT(DATE, @ДатаРожденияRaw, 23),
                TRY_CONVERT(DATE, @ДатаРожденияRaw, 104)
            );

            DECLARE @Соль NVARCHAR(32) = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
            DECLARE @Хэш NVARCHAR(64) = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Пароль + @Соль), 2);

            BEGIN TRANSACTION;

            INSERT INTO Пользователь (
                Логин, Хэш_Пароля, Соль, Email, Роль_ID, Активен, Примечание
            )
            VALUES (
                @Логин, @Хэш, @Соль, @Email, @Роль_ID, 1, CONCAT(N'Импорт CSV; ', ISNULL(@Примечание, N''))
            );

            DECLARE @Пользователь_ID INT = CAST(SCOPE_IDENTITY() AS INT);

            INSERT INTO Студент (
                Пользователь_ID, ФИО, Группа_ID, Дата_Поступления,
                Дата_Рождения, Пол, Адрес, Телефон_Родителей, Примечание
            )
            VALUES (
                @Пользователь_ID, @ФИО, @Группа_ID, @ДатаПоступления,
                @ДатаРождения, @Пол, @Адрес, @ТелефонРодителей, @Примечание
            );

            COMMIT TRANSACTION;

            SET @Added = @Added + 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            SET @Errors = @Errors + 1;
            INSERT INTO @ErrorRows (LineNumber, Ошибка, Строка)
            VALUES (
                @LineNumber,
                LEFT(ERROR_MESSAGE(), 4000),
                @Line
            );
        END CATCH;

        FETCH NEXT FROM student_cursor INTO @LineNumber, @Line;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;

    SET @Skipped = @TotalRows - @Added;

    DECLARE @Status NVARCHAR(30) = CASE WHEN @Errors > 0 THEN N'Частично' ELSE N'Успешно' END;
    DECLARE @Summary NVARCHAR(500) = CONCAT(
        N'Импорт завершён. Добавлено: ', @Added,
        N'; Пропущено: ', @Skipped,
        N'; Ошибок: ', @Errors
    );

    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
    VALUES (@КтоСоздал, N'Импорт студентов из CSV', @Status, @Summary);

    SELECT
        @Added AS Добавлено,
        @Skipped AS Пропущено,
        @Errors AS Ошибок,
        @Summary AS Сообщение;

    IF EXISTS (SELECT 1 FROM @ErrorRows)
    BEGIN
        SELECT LineNumber, Ошибка, Строка
        FROM @ErrorRows
        ORDER BY LineNumber;
    END
END;
GO

