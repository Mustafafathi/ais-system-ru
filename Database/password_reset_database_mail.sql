USE [Улучшенная]
GO

IF OBJECT_ID(N'dbo.Восстановление_Пароля', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Восстановление_Пароля (
        Восстановление_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Восстановление_Пароля PRIMARY KEY,
        Пользователь_ID INT NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Токен_Хэш NVARCHAR(64) NOT NULL,
        Истекает_В DATETIME NOT NULL,
        Использован BIT NOT NULL CONSTRAINT DF_Восстановление_Пароля_Использован DEFAULT (0),
        Использован_В DATETIME NULL,
        Попыток INT NOT NULL CONSTRAINT DF_Восстановление_Пароля_Попыток DEFAULT (0),
        Отправлено BIT NOT NULL CONSTRAINT DF_Восстановление_Пароля_Отправлено DEFAULT (0),
        MailItemId INT NULL,
        Ошибка_Отправки NVARCHAR(MAX) NULL,
        IP_Адрес NVARCHAR(45) NULL,
        Устройство NVARCHAR(100) NULL,
        Браузер NVARCHAR(200) NULL,
        Дата_Создания DATETIME NOT NULL CONSTRAINT DF_Восстановление_Пароля_Создано DEFAULT (GETDATE()),
        Дата_Обновления DATETIME NULL
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Восстановление_Пароля_Пользователь'
      AND parent_object_id = OBJECT_ID(N'dbo.Восстановление_Пароля')
)
BEGIN
    ALTER TABLE dbo.Восстановление_Пароля WITH CHECK ADD CONSTRAINT FK_Восстановление_Пароля_Пользователь
    FOREIGN KEY (Пользователь_ID) REFERENCES dbo.Пользователь (Пользователь_ID);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_Восстановление_Пароля_Токен'
      AND object_id = OBJECT_ID(N'dbo.Восстановление_Пароля')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Восстановление_Пароля_Токен
    ON dbo.Восстановление_Пароля (Токен_Хэш);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Восстановление_Пароля_Пользователь_Активные'
      AND object_id = OBJECT_ID(N'dbo.Восстановление_Пароля')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Восстановление_Пароля_Пользователь_Активные
    ON dbo.Восстановление_Пароля (Пользователь_ID, Использован, Истекает_В DESC)
    INCLUDE (Попыток, Отправлено);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Восстановление_Пароля_Истекает'
      AND object_id = OBJECT_ID(N'dbo.Восстановление_Пароля')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Восстановление_Пароля_Истекает
    ON dbo.Восстановление_Пароля (Истекает_В, Использован);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Система.PublicBaseUrl')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Система.PublicBaseUrl', N'http://localhost/ais-system', N'Строка', N'Общие', NULL, N'Публичный базовый URL для ссылок в системных письмах', 1, 0, GETDATE(), NULL, GETDATE());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Безопасность.ВосстановлениеПароля.DatabaseMailProfile')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Безопасность.ВосстановлениеПароля.DatabaseMailProfile', N'AIS Database Mail', N'Строка', N'Безопасность', N'Восстановление пароля', N'Профиль Database Mail для писем восстановления пароля', 1, 0, GETDATE(), NULL, GETDATE());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Настройки_Системы WHERE Ключ = N'Безопасность.ВосстановлениеПароля.СрокМинут')
BEGIN
    INSERT INTO dbo.Настройки_Системы (Ключ, Значение, Тип, Категория, Подкатегория, Описание, ТолькоДляАдмина, ТолькоДляЧтения, Дата_Изменения, Кто_Изменил, Дата_Создания)
    VALUES (N'Безопасность.ВосстановлениеПароля.СрокМинут', N'30', N'Число', N'Безопасность', N'Восстановление пароля', N'Срок действия ссылки восстановления пароля в минутах', 1, 0, GETDATE(), NULL, GETDATE());
END
GO

CREATE OR ALTER PROCEDURE dbo.ВосстановитьПароль
    @Email NVARCHAR(100),
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PublicMessage NVARCHAR(300) = N'Если учетная запись с таким email существует, на него отправлена ссылка для восстановления пароля.';
    DECLARE @CleanEmail NVARCHAR(100) = NULLIF(LTRIM(RTRIM(@Email)), N'');

    IF @CleanEmail IS NULL
    BEGIN
        SELECT 0 AS Успешно, N'Укажите email для восстановления пароля.' AS Сообщение;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @Пользователь_ID INT,
            @Логин NVARCHAR(50),
            @Token NVARCHAR(128),
            @TokenHash NVARCHAR(64),
            @ExpiresMinutes INT = 30,
            @ExpiresAt DATETIME,
            @BaseUrl NVARCHAR(400),
            @ResetUrl NVARCHAR(700),
            @MailProfile NVARCHAR(200),
            @Body NVARCHAR(MAX),
            @MailItemId INT = NULL,
            @MailError NVARCHAR(MAX) = NULL,
            @Восстановление_ID BIGINT = NULL;

        SELECT TOP 1
            @Пользователь_ID = Пользователь_ID,
            @Логин = Логин
        FROM dbo.Пользователь
        WHERE Email = @CleanEmail
          AND Активен = 1;

        IF @Пользователь_ID IS NULL
        BEGIN
            INSERT INTO dbo.Лог_Действий (Уровень_Лога, Действие, Параметры, Статус, IP_Адрес, Устройство, Браузер, Время_Действия, Дата_Создания)
            VALUES (N'Информация', N'Запрос восстановления пароля', N'Email не найден или учетная запись неактивна', N'Успешно', @IP_Адрес, @Устройство, @Браузер, GETDATE(), GETDATE());

            COMMIT TRANSACTION;
            SELECT 1 AS Успешно, @PublicMessage AS Сообщение;
            RETURN;
        END

        SELECT @ExpiresMinutes = TRY_CONVERT(INT, Значение)
        FROM dbo.Настройки_Системы
        WHERE Ключ = N'Безопасность.ВосстановлениеПароля.СрокМинут';

        SET @ExpiresMinutes = ISNULL(NULLIF(@ExpiresMinutes, 0), 30);
        IF @ExpiresMinutes < 5 SET @ExpiresMinutes = 5;
        IF @ExpiresMinutes > 120 SET @ExpiresMinutes = 120;
        SET @ExpiresAt = DATEADD(MINUTE, @ExpiresMinutes, GETDATE());

        UPDATE dbo.Восстановление_Пароля
        SET Использован = 1,
            Использован_В = ISNULL(Использован_В, GETDATE()),
            Дата_Обновления = GETDATE()
        WHERE Пользователь_ID = @Пользователь_ID
          AND Использован = 0
          AND Истекает_В > GETDATE();

        SET @Token = CONVERT(NVARCHAR(128), CRYPT_GEN_RANDOM(32), 2);
        SET @TokenHash = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Token), 2);

        INSERT INTO dbo.Восстановление_Пароля (
            Пользователь_ID, Email, Токен_Хэш, Истекает_В, IP_Адрес, Устройство, Браузер
        )
        VALUES (
            @Пользователь_ID, @CleanEmail, @TokenHash, @ExpiresAt, @IP_Адрес, @Устройство, @Браузер
        );

        SET @Восстановление_ID = SCOPE_IDENTITY();

        SELECT @BaseUrl = NULLIF(LTRIM(RTRIM(Значение)), N'')
        FROM dbo.Настройки_Системы
        WHERE Ключ = N'Система.PublicBaseUrl';

        SET @BaseUrl = ISNULL(@BaseUrl, N'http://localhost/ais-system');
        WHILE RIGHT(@BaseUrl, 1) = N'/'
            SET @BaseUrl = LEFT(@BaseUrl, LEN(@BaseUrl) - 1);

        SET @ResetUrl = @BaseUrl + N'/login/index.php?reset_token=' + @Token;

        SELECT @MailProfile = NULLIF(LTRIM(RTRIM(Значение)), N'')
        FROM dbo.Настройки_Системы
        WHERE Ключ = N'Безопасность.ВосстановлениеПароля.DatabaseMailProfile';

        IF @MailProfile IS NULL
        BEGIN
            SELECT @MailProfile = NULLIF(LTRIM(RTRIM(Значение)), N'')
            FROM dbo.Настройки_Системы
            WHERE Ключ = N'Отчеты.DatabaseMailProfile';
        END

        SET @MailProfile = ISNULL(@MailProfile, N'AIS Database Mail');

        SET @Body =
            N'<h2>Восстановление пароля АИС</h2>' +
            N'<p>Для учетной записи <strong>' + ISNULL(@Логин, N'') + N'</strong> был запрошен сброс пароля.</p>' +
            N'<p><a href="' + @ResetUrl + N'">Установить новый пароль</a></p>' +
            N'<p>Ссылка действует ' + CAST(@ExpiresMinutes AS NVARCHAR(10)) + N' минут. Если вы не запрашивали восстановление, просто проигнорируйте это письмо.</p>';

        BEGIN TRY
            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = @MailProfile,
                @recipients = @CleanEmail,
                @subject = N'Восстановление пароля АИС',
                @body = @Body,
                @body_format = 'HTML',
                @mailitem_id = @MailItemId OUTPUT;

            UPDATE dbo.Восстановление_Пароля
            SET Отправлено = 1,
                MailItemId = @MailItemId,
                Дата_Обновления = GETDATE()
            WHERE Восстановление_ID = @Восстановление_ID;
        END TRY
        BEGIN CATCH
            SET @MailError = ERROR_MESSAGE();

            UPDATE dbo.Восстановление_Пароля
            SET Отправлено = 0,
                Ошибка_Отправки = LEFT(@MailError, 4000),
                Дата_Обновления = GETDATE()
            WHERE Восстановление_ID = @Восстановление_ID;
        END CATCH

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Уровень_Лога, Действие, Таблица, Запись_ID, Параметры, Результат, Статус, IP_Адрес, Устройство, Браузер, Время_Действия, Дата_Создания)
        VALUES (
            @Пользователь_ID,
            CASE WHEN @MailError IS NULL THEN N'Информация' ELSE N'Предупреждение' END,
            N'Запрос восстановления пароля',
            N'Восстановление_Пароля',
            CASE WHEN @Восстановление_ID <= 2147483647 THEN CONVERT(INT, @Восстановление_ID) ELSE NULL END,
            N'Email: ' + @CleanEmail,
            CASE WHEN @MailError IS NULL THEN N'Письмо поставлено в Database Mail' ELSE LEFT(@MailError, 4000) END,
            CASE WHEN @MailError IS NULL THEN N'Успешно' ELSE N'Ошибка' END,
            @IP_Адрес,
            @Устройство,
            @Браузер,
            GETDATE(),
            GETDATE()
        );

        COMMIT TRANSACTION;
        SELECT 1 AS Успешно, @PublicMessage AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.ПодтвердитьВосстановлениеПароля
    @Токен NVARCHAR(128) = NULL,
    @НовыйПароль NVARCHAR(255) = NULL,
    @КодВосстановления NVARCHAR(128) = NULL,
    @Новый_Пароль NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EffectiveToken NVARCHAR(128) = COALESCE(NULLIF(LTRIM(RTRIM(@Токен)), N''), NULLIF(LTRIM(RTRIM(@КодВосстановления)), N''));
    DECLARE @EffectivePassword NVARCHAR(255) = COALESCE(@НовыйПароль, @Новый_Пароль);

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @TokenHash NVARCHAR(64),
            @Восстановление_ID BIGINT,
            @Пользователь_ID INT,
            @Попыток INT,
            @MinLength INT = 8,
            @Complexity NVARCHAR(50) = N'medium',
            @NewSalt NVARCHAR(32),
            @NewHash NVARCHAR(64);

        IF @EffectiveToken IS NULL
        BEGIN
            SELECT 0 AS Успешно, N'Неверная или просроченная ссылка восстановления.' AS Сообщение;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @EffectivePassword IS NULL OR LEN(@EffectivePassword) = 0
        BEGIN
            SELECT 0 AS Успешно, N'Введите новый пароль.' AS Сообщение;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @TokenHash = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @EffectiveToken), 2);

        SELECT TOP 1
            @Восстановление_ID = Восстановление_ID,
            @Пользователь_ID = Пользователь_ID,
            @Попыток = Попыток
        FROM dbo.Восстановление_Пароля WITH (UPDLOCK, ROWLOCK)
        WHERE Токен_Хэш = @TokenHash
          AND Использован = 0
          AND Истекает_В > GETDATE();

        IF @Восстановление_ID IS NULL OR @Попыток >= 5
        BEGIN
            SELECT 0 AS Успешно, N'Неверная или просроченная ссылка восстановления.' AS Сообщение;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SELECT @MinLength = TRY_CONVERT(INT, Значение)
        FROM dbo.Настройки_Системы
        WHERE Ключ = N'Безопасность.ДлинаПароляМин';

        SET @MinLength = ISNULL(NULLIF(@MinLength, 0), 8);

        SELECT @Complexity = LOWER(ISNULL(NULLIF(LTRIM(RTRIM(Значение)), N''), N'medium'))
        FROM dbo.Настройки_Системы
        WHERE Ключ = N'Безопасность.СложностьПароля';

        IF LEN(@EffectivePassword) < @MinLength
        BEGIN
            UPDATE dbo.Восстановление_Пароля
            SET Попыток = Попыток + 1,
                Дата_Обновления = GETDATE()
            WHERE Восстановление_ID = @Восстановление_ID;

            SELECT 0 AS Успешно, N'Пароль слишком короткий.' AS Сообщение;
            COMMIT TRANSACTION;
            RETURN;
        END

        IF @Complexity IN (N'medium', N'high')
           AND (@EffectivePassword NOT LIKE N'%[0-9]%' OR @EffectivePassword NOT LIKE N'%[A-Za-zА-Яа-я]%')
        BEGIN
            UPDATE dbo.Восстановление_Пароля
            SET Попыток = Попыток + 1,
                Дата_Обновления = GETDATE()
            WHERE Восстановление_ID = @Восстановление_ID;

            SELECT 0 AS Успешно, N'Пароль должен содержать буквы и цифры.' AS Сообщение;
            COMMIT TRANSACTION;
            RETURN;
        END

        IF @Complexity = N'high'
           AND (@EffectivePassword NOT LIKE N'%[A-ZА-Я]%' OR @EffectivePassword NOT LIKE N'%[a-zа-я]%' OR @EffectivePassword NOT LIKE N'%[^A-Za-zА-Яа-я0-9]%')
        BEGIN
            UPDATE dbo.Восстановление_Пароля
            SET Попыток = Попыток + 1,
                Дата_Обновления = GETDATE()
            WHERE Восстановление_ID = @Восстановление_ID;

            SELECT 0 AS Успешно, N'Пароль должен содержать строчные и прописные буквы, цифры и специальный символ.' AS Сообщение;
            COMMIT TRANSACTION;
            RETURN;
        END

        SET @NewSalt = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
        SET @NewHash = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @EffectivePassword + @NewSalt), 2);

        UPDATE dbo.Пользователь
        SET Хэш_Пароля = @NewHash,
            Соль = @NewSalt
        WHERE Пользователь_ID = @Пользователь_ID;

        EXEC dbo.ЗавершитьВсеСессииПользователя @Пользователь_ID, N'Восстановление пароля';

        UPDATE dbo.Восстановление_Пароля
        SET Использован = 1,
            Использован_В = GETDATE(),
            Попыток = Попыток + 1,
            Дата_Обновления = GETDATE()
        WHERE Восстановление_ID = @Восстановление_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Уровень_Лога, Действие, Таблица, Запись_ID, Статус, Время_Действия, Дата_Создания)
        VALUES (
            @Пользователь_ID,
            N'Информация',
            N'Восстановление пароля',
            N'Восстановление_Пароля',
            CASE WHEN @Восстановление_ID <= 2147483647 THEN CONVERT(INT, @Восстановление_ID) ELSE NULL END,
            N'Успешно',
            GETDATE(),
            GETDATE()
        );

        COMMIT TRANSACTION;
        SELECT 1 AS Успешно, N'Пароль успешно изменён. Войдите с новым паролем.' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

