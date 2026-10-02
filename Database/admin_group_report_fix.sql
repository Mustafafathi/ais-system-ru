USE [Улучшенная];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*
    Fixes admin group attendance reports.

    The baseline database script used CROSS JOIN Дисциплина in
    СформироватьОтчетПоГруппе, which inflated rows and repeated students for
    every discipline. This version returns one summary row per student in the
    selected group for the requested period, with the result shape consumed by
    admin/reports.php.
*/
CREATE OR ALTER PROCEDURE dbo.СформироватьОтчетПоГруппе
    @Группа_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL,
    @Дисциплина_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Группа_ID IS NULL
        THROW 52001, N'Группа_ID обязателен для отчета по группе.', 1;

    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE));

    IF @КонецПериода IS NULL
        SET @КонецПериода = CAST(GETDATE() AS DATE);

    ;WITH GroupLessons AS (
        SELECT DISTINCT
            z.Занятие_ID
        FROM dbo.Расписание r
        INNER JOIN dbo.Занятие z ON z.Расписание_ID = r.Расписание_ID
        WHERE r.Группа_ID = @Группа_ID
          AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
          AND (@Дисциплина_ID IS NULL OR r.Дисциплина_ID = @Дисциплина_ID)
    )
    SELECT
        s.Студент_ID,
        s.ФИО AS ФИО_Студента,
        g.Название AS Группа,
        COUNT(DISTINCT gl.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN p.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN p.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN p.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(
            COALESCE(
                SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 /
                NULLIF(COUNT(DISTINCT gl.Занятие_ID), 0),
                0
            ) AS DECIMAL(5,2)
        ) AS ПроцентПосещаемости
    FROM dbo.Студент s
    INNER JOIN dbo.Учебная_Группа g ON g.Группа_ID = s.Группа_ID
    LEFT JOIN GroupLessons gl ON 1 = 1
    LEFT JOIN dbo.Посещаемость p ON p.Занятие_ID = gl.Занятие_ID
        AND p.Студент_ID = s.Студент_ID
    WHERE s.Группа_ID = @Группа_ID
    GROUP BY
        s.Студент_ID,
        s.ФИО,
        g.Название
    ORDER BY
        s.ФИО;
END;
GO

