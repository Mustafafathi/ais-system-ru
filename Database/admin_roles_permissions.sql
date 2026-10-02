SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

CREATE OR ALTER PROCEDURE dbo.ПолучитьРазрешенияРоли
    @Роль_ID INT = NULL,
    @ТолькоРазрешенные BIT = NULL,
    @КтоЗапросил INT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоЗапросил;

    SELECT
        rp.Разрешение_ID,
        rp.Роль_ID,
        r.Название AS Роль,
        rp.Объект,
        rp.Действие,
        rp.Разрешено,
        rp.Условие,
        rp.Описание,
        rp.Дата_Создания,
        rp.Кто_Создал,
        rp.Дата_Обновления,
        rp.Кто_Обновил
    FROM dbo.Разрешения_Ролей rp
    INNER JOIN dbo.Роль r ON r.Роль_ID = rp.Роль_ID
    WHERE (@Роль_ID IS NULL OR rp.Роль_ID = @Роль_ID)
      AND (@ТолькоРазрешенные IS NULL OR rp.Разрешено = @ТолькоРазрешенные)
    ORDER BY r.Уровень_Доступа DESC, r.Название, rp.Объект, rp.Действие;
END;
GO

CREATE OR ALTER PROCEDURE dbo.СохранитьРазрешениеРоли
    @Роль_ID INT,
    @Объект NVARCHAR(100),
    @Действие NVARCHAR(50),
    @Разрешено BIT = 1,
    @Условие NVARCHAR(MAX) = NULL,
    @Описание NVARCHAR(300) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоОбновил;

        SET @Объект = NULLIF(LTRIM(RTRIM(@Объект)), N'');
        SET @Действие = NULLIF(LTRIM(RTRIM(@Действие)), N'');

        IF @Объект IS NULL OR @Действие IS NULL
        BEGIN
            RAISERROR(N'Объект и действие обязательны', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Роль WHERE Роль_ID = @Роль_ID)
        BEGIN
            RAISERROR(N'Роль не найдена', 16, 1);
            RETURN;
        END

        DECLARE @Разрешение_ID INT;
        SELECT @Разрешение_ID = Разрешение_ID
        FROM dbo.Разрешения_Ролей
        WHERE Роль_ID = @Роль_ID
          AND Объект = @Объект
          AND Действие = @Действие;

        IF @Разрешение_ID IS NULL
        BEGIN
            INSERT INTO dbo.Разрешения_Ролей (
                Роль_ID, Объект, Действие, Разрешено, Условие, Описание,
                Дата_Создания, Кто_Создал
            )
            VALUES (
                @Роль_ID, @Объект, @Действие, ISNULL(@Разрешено, 1), @Условие, @Описание,
                GETDATE(), @КтоОбновил
            );

            SET @Разрешение_ID = SCOPE_IDENTITY();

            INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
            VALUES (@КтоОбновил, N'Создание разрешения роли', N'Разрешения_Ролей', @Разрешение_ID, N'Успешно',
                    N'Роль_ID=' + CAST(@Роль_ID AS NVARCHAR(20)) + N'; Объект=' + @Объект + N'; Действие=' + @Действие);

            SELECT @Разрешение_ID AS Разрешение_ID, N'Разрешение создано' AS Сообщение;
        END
        ELSE
        BEGIN
            UPDATE dbo.Разрешения_Ролей
            SET
                Разрешено = ISNULL(@Разрешено, Разрешено),
                Условие = @Условие,
                Описание = @Описание,
                Дата_Обновления = GETDATE(),
                Кто_Обновил = @КтоОбновил
            WHERE Разрешение_ID = @Разрешение_ID;

            INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
            VALUES (@КтоОбновил, N'Обновление разрешения роли', N'Разрешения_Ролей', @Разрешение_ID, N'Успешно',
                    N'Роль_ID=' + CAST(@Роль_ID AS NVARCHAR(20)) + N'; Объект=' + @Объект + N'; Действие=' + @Действие);

            SELECT @Разрешение_ID AS Разрешение_ID, N'Разрешение обновлено' AS Сообщение;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.УдалитьРазрешениеРоли
    @Разрешение_ID INT,
    @КтоУдалил INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоУдалил;

        IF NOT EXISTS (SELECT 1 FROM dbo.Разрешения_Ролей WHERE Разрешение_ID = @Разрешение_ID)
        BEGIN
            RAISERROR(N'Разрешение не найдено', 16, 1);
            RETURN;
        END

        DELETE FROM dbo.Разрешения_Ролей
        WHERE Разрешение_ID = @Разрешение_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоУдалил, N'Удаление разрешения роли', N'Разрешения_Ролей', @Разрешение_ID, N'Успешно');

        SELECT 1 AS Удалено, N'Разрешение удалено' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.СоздатьРоль
    @Название NVARCHAR(50),
    @Описание NVARCHAR(200) = NULL,
    @Уровень_Доступа INT = 1,
    @Можно_Удалять BIT = 1,
    @КтоСоздал INT,
    @КопироватьПраваСРоли_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоСоздал;

        SET @Название = NULLIF(LTRIM(RTRIM(@Название)), N'');
        IF @Название IS NULL
        BEGIN
            RAISERROR(N'Название роли обязательно', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Роль WHERE Название = @Название)
        BEGIN
            RAISERROR(N'Роль с таким названием уже существует', 16, 1);
            RETURN;
        END

        IF @КопироватьПраваСРоли_ID IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM dbo.Роль WHERE Роль_ID = @КопироватьПраваСРоли_ID)
        BEGIN
            RAISERROR(N'Роль-источник для копирования прав не найдена', 16, 1);
            RETURN;
        END

        INSERT INTO dbo.Роль (Название, Описание, Уровень_Доступа, Можно_Удалять, Дата_Создания)
        VALUES (@Название, @Описание, ISNULL(@Уровень_Доступа, 1), ISNULL(@Можно_Удалять, 1), GETDATE());

        DECLARE @НоваяРольID INT = SCOPE_IDENTITY();

        IF @КопироватьПраваСРоли_ID IS NOT NULL
        BEGIN
            INSERT INTO dbo.Разрешения_Ролей (
                Роль_ID, Объект, Действие, Разрешено, Условие, Описание,
                Дата_Создания, Кто_Создал
            )
            SELECT
                @НоваяРольID, Объект, Действие, Разрешено, Условие, Описание,
                GETDATE(), @КтоСоздал
            FROM dbo.Разрешения_Ролей
            WHERE Роль_ID = @КопироватьПраваСРоли_ID;
        END

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
        VALUES (@КтоСоздал, N'Создание роли', N'Роль', @НоваяРольID, N'Успешно',
                N'Название=' + @Название);

        SELECT @НоваяРольID AS Роль_ID, N'Роль успешно создана' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ОбновитьРоль
    @Роль_ID INT,
    @Название NVARCHAR(50) = NULL,
    @Описание NVARCHAR(200) = NULL,
    @Уровень_Доступа INT = NULL,
    @Можно_Удалять BIT = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоОбновил;

        DECLARE @ТекущееНазвание NVARCHAR(50);
        SELECT @ТекущееНазвание = Название
        FROM dbo.Роль
        WHERE Роль_ID = @Роль_ID;

        IF @ТекущееНазвание IS NULL
        BEGIN
            RAISERROR(N'Роль не найдена', 16, 1);
            RETURN;
        END

        SET @Название = NULLIF(LTRIM(RTRIM(@Название)), N'');

        IF @ТекущееНазвание IN (N'Admin', N'Студент', N'Преподаватель', N'Методист', N'Куратор')
           AND @Название IS NOT NULL
           AND @Название <> @ТекущееНазвание
        BEGIN
            RAISERROR(N'Нельзя переименовывать системную роль: это нарушит маршрутизацию интерфейса', 16, 1);
            RETURN;
        END

        IF @ТекущееНазвание IN (N'Admin', N'Студент', N'Преподаватель', N'Методист', N'Куратор')
           AND @Можно_Удалять = 1
        BEGIN
            RAISERROR(N'Системную роль нельзя помечать как удаляемую', 16, 1);
            RETURN;
        END

        IF @Название IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.Роль WHERE Название = @Название AND Роль_ID <> @Роль_ID)
        BEGIN
            RAISERROR(N'Роль с таким названием уже существует', 16, 1);
            RETURN;
        END

        UPDATE dbo.Роль
        SET
            Название = ISNULL(@Название, Название),
            Описание = @Описание,
            Уровень_Доступа = ISNULL(@Уровень_Доступа, Уровень_Доступа),
            Можно_Удалять = ISNULL(@Можно_Удалять, Можно_Удалять)
        WHERE Роль_ID = @Роль_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоОбновил, N'Обновление роли', N'Роль', @Роль_ID, N'Успешно');

        SELECT 1 AS Обновлено, N'Роль обновлена' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.УдалитьРоль
    @Роль_ID INT,
    @КтоУдалил INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC dbo.ПроверитьАдминистратора @Пользователь_ID = @КтоУдалил;

        DECLARE @НазваниеРоли NVARCHAR(50);
        DECLARE @МожноУдалять BIT;

        SELECT
            @НазваниеРоли = Название,
            @МожноУдалять = Можно_Удалять
        FROM dbo.Роль
        WHERE Роль_ID = @Роль_ID;

        IF @НазваниеРоли IS NULL
        BEGIN
            RAISERROR(N'Роль не найдена', 16, 1);
            RETURN;
        END

        IF @МожноУдалять = 0
        BEGIN
            RAISERROR(N'Эту роль нельзя удалить', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Пользователь WHERE Роль_ID = @Роль_ID)
        BEGIN
            RAISERROR(N'Нельзя удалить роль, к которой привязаны пользователи', 16, 1);
            RETURN;
        END

        DELETE FROM dbo.Разрешения_Ролей WHERE Роль_ID = @Роль_ID;
        DELETE FROM dbo.Роль WHERE Роль_ID = @Роль_ID;

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоУдалил, N'Удаление роли', N'Роль', @Роль_ID, N'Успешно');

        SELECT 1 AS Удалено, N'Роль удалена' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

