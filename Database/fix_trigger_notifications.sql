-- ============================================================================
-- FIX: Trigger TRG_УведомленияОПропусках
--
-- Problem: Original trigger uses a CTE (ПропускиСтудента) referenced by
-- TWO INSERT statements, but in T-SQL a CTE is only valid for the
-- immediately following statement. The second INSERT fails with:
-- "Invalid object name 'ПропускиСтудента'"
--
-- Fix: Duplicate the CTE definition for the second INSERT statement.
-- ============================================================================

ALTER TRIGGER [dbo].[TRG_УведомленияОПропусках]
ON [dbo].[Посещаемость]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ПорогПропусков INT = 3;
    DECLARE @ПериодДней INT = 7;

    -- 1. Уведомления для куратора
    ;WITH ПропускиСтудента AS (
        SELECT
            i.Студент_ID,
            COUNT(*) AS КоличествоПропусков
        FROM inserted i
        INNER JOIN Занятие z ON i.Занятие_ID = z.Занятие_ID
        WHERE i.Статус = N'Отсутствовал'
        AND z.Дата_Занятия >= DATEADD(DAY, -@ПериодДней, GETDATE())
        GROUP BY i.Студент_ID
        HAVING COUNT(*) >= @ПорогПропусков
    )
    INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Срок_Действия)
    SELECT
        p.Пользователь_ID,
        N'Предупреждение',
        N'Студент с частыми пропусками',
        CONCAT(
            N'Студент ', s.ФИО, N' (группа ', g.Название,
            N') пропустил ', ps.КоличествоПропусков,
            N' занятий за последние ', @ПериодДней, N' дней'
        ),
        DATEADD(DAY, 3, GETDATE())
    FROM ПропускиСтудента ps
    INNER JOIN Студент s ON ps.Студент_ID = s.Студент_ID
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    INNER JOIN Преподаватель p ON g.Куратор_ID = p.Преподаватель_ID
    WHERE NOT EXISTS (
        SELECT 1
        FROM Уведомления ув
        WHERE ув.Пользователь_ID = p.Пользователь_ID
        AND ув.Заголовок LIKE N'%Студент с частыми пропусками%'
        AND ув.Время_Создания > DATEADD(DAY, -1, GETDATE())
    );

    -- 2. Уведомления для самого студента (CTE повторён, т.к. область видимости — 1 оператор)
    ;WITH ПропускиСтудента AS (
        SELECT
            i.Студент_ID,
            COUNT(*) AS КоличествоПропусков
        FROM inserted i
        INNER JOIN Занятие z ON i.Занятие_ID = z.Занятие_ID
        WHERE i.Статус = N'Отсутствовал'
        AND z.Дата_Занятия >= DATEADD(DAY, -@ПериодДней, GETDATE())
        GROUP BY i.Студент_ID
        HAVING COUNT(*) >= @ПорогПропусков
    )
    INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Срок_Действия)
    SELECT
        u.Пользователь_ID,
        N'Предупреждение',
        N'Частые пропуски занятий',
        CONCAT(
            N'Вы пропустили ', ps.КоличествоПропусков,
            N' занятий за последние ', @ПериодДней, N' дней. ',
            N'Обратитесь к куратору для уточнения причин.'
        ),
        DATEADD(DAY, 7, GETDATE())
    FROM ПропускиСтудента ps
    INNER JOIN Студент s ON ps.Студент_ID = s.Студент_ID
    INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    WHERE NOT EXISTS (
        SELECT 1
        FROM Уведомления ув
        WHERE ув.Пользователь_ID = u.Пользователь_ID
        AND ув.Заголовок LIKE N'%Частые пропуски занятий%'
        AND ув.Время_Создания > DATEADD(DAY, -1, GETDATE())
    );
END;
GO

