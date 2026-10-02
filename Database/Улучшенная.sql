USE [master]
GO
/****** Object:  Database [Улучшенная]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE DATABASE [Улучшенная]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Улучшенная', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Улучшенная.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Улучшенная_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Улучшенная_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Улучшенная] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Улучшенная].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Улучшенная] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Улучшенная] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Улучшенная] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Улучшенная] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Улучшенная] SET ARITHABORT OFF 
GO
ALTER DATABASE [Улучшенная] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Улучшенная] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Улучшенная] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Улучшенная] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Улучшенная] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Улучшенная] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Улучшенная] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Улучшенная] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Улучшенная] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Улучшенная] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Улучшенная] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Улучшенная] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Улучшенная] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Улучшенная] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Улучшенная] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Улучшенная] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Улучшенная] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Улучшенная] SET RECOVERY FULL 
GO
ALTER DATABASE [Улучшенная] SET  MULTI_USER 
GO
ALTER DATABASE [Улучшенная] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Улучшенная] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Улучшенная] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Улучшенная] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Улучшенная] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Улучшенная] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Улучшенная', N'ON'
GO
ALTER DATABASE [Улучшенная] SET QUERY_STORE = ON
GO
ALTER DATABASE [Улучшенная] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Улучшенная]
GO
/****** Object:  User [php_user]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE USER [php_user] FOR LOGIN [php_user] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [php_user]
GO
/****** Object:  FullTextCatalog [ftCatalog]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE FULLTEXT CATALOG [ftCatalog] AS DEFAULT
GO
/****** Object:  PartitionFunction [pf_LogDate]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE PARTITION FUNCTION [pf_LogDate](datetime) AS RANGE RIGHT FOR VALUES (N'2023-01-01T00:00:00.000', N'2023-07-01T00:00:00.000', N'2024-01-01T00:00:00.000', N'2024-07-01T00:00:00.000', N'2025-01-01T00:00:00.000')
GO
/****** Object:  PartitionScheme [ps_LogDate]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE PARTITION SCHEME [ps_LogDate] AS PARTITION [pf_LogDate] TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO
/****** Object:  Table [dbo].[QR_Сессия]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QR_Сессия](
	[QR_Сессия_ID] [int] IDENTITY(1,1) NOT NULL,
	[Занятие_ID] [int] NOT NULL,
	[Название_Сессии] [nvarchar](100) NULL,
	[QR_Код] [nvarchar](500) NOT NULL,
	[Время_Создания] [datetime] NOT NULL,
	[Время_Действия_Начало] [datetime] NOT NULL,
	[Время_Действия_Конец] [datetime] NOT NULL,
	[Срок_Действия_Минут] [int] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Кто_Создал] [int] NOT NULL,
	[Примечание] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[QR_Сессия_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QR_Сканирование]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QR_Сканирование](
	[Сканирование_ID] [int] IDENTITY(1,1) NOT NULL,
	[QR_Сессия_ID] [int] NOT NULL,
	[Студент_ID] [int] NOT NULL,
	[Время_Сканирования] [datetime] NOT NULL,
	[Устройство] [nvarchar](100) NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Статус] [nvarchar](30) NOT NULL,
	[Примечание] [nvarchar](300) NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Сканирование_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Аудитория]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Аудитория](
	[Аудитория_ID] [int] IDENTITY(1,1) NOT NULL,
	[Номер] [nvarchar](20) NOT NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Корпус] [nvarchar](100) NOT NULL,
	[Вместимость] [int] NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Примечание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Корпус_ID] [int] NULL,
 CONSTRAINT [PK_Аудитория] PRIMARY KEY CLUSTERED 
(
	[Аудитория_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Временные_Данные]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Временные_Данные](
	[Данные_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Тип_Данных] [nvarchar](50) NOT NULL,
	[Ключ] [nvarchar](200) NOT NULL,
	[Значение] [nvarchar](max) NOT NULL,
	[Истекает_В] [datetime] NOT NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Дата_Обновления] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Данные_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Восстановление_Пароля]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Восстановление_Пароля](
	[Восстановление_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Пользователь_ID] [int] NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Токен_Хэш] [nvarchar](64) NOT NULL,
	[Истекает_В] [datetime] NOT NULL,
	[Использован] [bit] NOT NULL CONSTRAINT [DF_Восстановление_Пароля_Использован] DEFAULT ((0)),
	[Использован_В] [datetime] NULL,
	[Попыток] [int] NOT NULL CONSTRAINT [DF_Восстановление_Пароля_Попыток] DEFAULT ((0)),
	[Отправлено] [bit] NOT NULL CONSTRAINT [DF_Восстановление_Пароля_Отправлено] DEFAULT ((0)),
	[MailItemId] [int] NULL,
	[Ошибка_Отправки] [nvarchar](max) NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Устройство] [nvarchar](100) NULL,
	[Браузер] [nvarchar](200) NULL,
	[Дата_Создания] [datetime] NOT NULL CONSTRAINT [DF_Восстановление_Пароля_Создано] DEFAULT (getdate()),
	[Дата_Обновления] [datetime] NULL,
 CONSTRAINT [PK_Восстановление_Пароля] PRIMARY KEY CLUSTERED
(
	[Восстановление_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Дисциплина]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Дисциплина](
	[Дисциплина_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[краткое наименование] [nvarchar](20) NULL,
	[Преподаватель_ID] [int] NOT NULL,
	[Часы_Теории] [int] NOT NULL,
	[Часы_Практики] [int] NOT NULL,
	[Семестр] [tinyint] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Описание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Дисциплина_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Журнал_Импорта_CSV]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Журнал_Импорта_CSV](
	[Импорт_ID] [int] IDENTITY(1,1) NOT NULL,
	[Тип_Данных] [nvarchar](50) NOT NULL,
	[Дата_Импорта] [datetime] NOT NULL,
	[Имя_Файла] [nvarchar](500) NOT NULL,
	[Количество_Записей] [int] NOT NULL,
	[Количество_Успешно] [int] NOT NULL,
	[Количество_Ошибок] [int] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Пользователь_ID] [int] NULL,
	[Примечание] [nvarchar](max) NULL,
 CONSTRAINT [PK_Журнал_Импорта_CSV] PRIMARY KEY CLUSTERED 
(
	[Импорт_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Журнал_Экспорта_CSV]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Журнал_Экспорта_CSV](
	[Экспорт_ID] [int] IDENTITY(1,1) NOT NULL,
	[Тип_Данных] [nvarchar](50) NOT NULL,
	[Дата_Экспорта] [datetime] NOT NULL,
	[Путь_К_Файлу] [nvarchar](500) NOT NULL,
	[Размер_Файла_КБ] [int] NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Пользователь_ID] [int] NULL,
	[Примечание] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Экспорт_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Занятие](
	[Занятие_ID] [int] IDENTITY(1,1) NOT NULL,
	[Расписание_ID] [int] NOT NULL,
	[Дата_Занятия] [date] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Тема_Занятия] [nvarchar](300) NULL,
	[Кабинет] [nvarchar](50) NULL,
	[Примечание] [nvarchar](500) NULL,
	[Время_Начала_Факт] [datetime] NULL,
	[Время_Окончания_Факт] [datetime] NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Кто_Создал] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Занятие_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Корпус]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Корпус](
	[Корпус_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[Адрес] [nvarchar](200) NULL,
	[Описание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Корпус_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Лог_Действий]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Лог_Действий](
	[Лог_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Пользователь_ID] [int] NULL,
	[Уровень_Лога] [nvarchar](20) NOT NULL,
	[Действие] [nvarchar](200) NOT NULL,
	[Таблица] [nvarchar](100) NULL,
	[Запись_ID] [int] NULL,
	[Время_Действия] [datetime] NOT NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Устройство] [nvarchar](100) NULL,
	[Браузер] [nvarchar](100) NULL,
	[Параметры] [nvarchar](max) NULL,
	[Результат] [nvarchar](max) NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Время_Выполнения_Мс] [int] NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Лог_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Мониторинг_Триггеров]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Мониторинг_Триггеров](
	[Мониторинг_ID] [int] IDENTITY(1,1) NOT NULL,
	[Триггер_Имя] [nvarchar](200) NOT NULL,
	[Таблица] [nvarchar](100) NOT NULL,
	[Тип_Операции] [nvarchar](50) NOT NULL,
	[КоличествоЗаписей] [int] NOT NULL,
	[Время_Запуска] [datetime] NOT NULL,
	[Длительность_Мс] [int] NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Ошибка] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Мониторинг_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Настройки_Системы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Настройки_Системы](
	[Настройка_ID] [int] IDENTITY(1,1) NOT NULL,
	[Ключ] [nvarchar](100) NOT NULL,
	[Значение] [nvarchar](max) NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Категория] [nvarchar](50) NOT NULL,
	[Подкатегория] [nvarchar](50) NULL,
	[Описание] [nvarchar](300) NULL,
	[ТолькоДляАдмина] [bit] NOT NULL,
	[ТолькоДляЧтения] [bit] NOT NULL,
	[Дата_Изменения] [datetime] NOT NULL,
	[Кто_Изменил] [int] NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Настройка_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Обоснования_Отсутствия]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Обоснования_Отсутствия](
	[Обоснование_ID] [int] IDENTITY(1,1) NOT NULL,
	[Студент_ID] [int] NOT NULL,
	[Занятие_ID] [int] NOT NULL,
	[Дата_Подачи] [datetime] NOT NULL,
	[Причина] [nvarchar](max) NOT NULL,
	[Файл] [nvarchar](500) NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Комментарий_Модератора] [nvarchar](max) NULL,
	[Кто_Рассмотрел] [int] NULL,
	[Дата_Рассмотрения] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Обоснование_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ошибки_Системы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ошибки_Системы](
	[Ошибка_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Код_Ошибки] [nvarchar](50) NULL,
	[Уровень_Ошибки] [nvarchar](20) NOT NULL,
	[Источник] [nvarchar](200) NOT NULL,
	[Сообщение] [nvarchar](max) NOT NULL,
	[Стек_Трейс] [nvarchar](max) NULL,
	[Пользователь_ID] [int] NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Устройство] [nvarchar](100) NULL,
	[Браузер] [nvarchar](100) NULL,
	[URL_Запроса] [nvarchar](500) NULL,
	[Параметры_Запроса] [nvarchar](max) NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Дата_Возникновения] [datetime] NOT NULL,
	[Дата_Исправления] [datetime] NULL,
	[Кто_Исправил] [int] NULL,
	[Решение] [nvarchar](max) NULL,
	[Повторяется] [bit] NOT NULL,
	[Количество_Повторов] [int] NOT NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Ошибка_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Пользователь]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Пользователь](
	[Пользователь_ID] [int] IDENTITY(1,1) NOT NULL,
	[Логин] [nvarchar](50) NOT NULL,
	[Хэш_Пароля] [nvarchar](64) NOT NULL,
	[Соль] [nvarchar](32) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[Роль_ID] [int] NOT NULL,
	[Телефон] [nvarchar](20) NULL,
	[Аватар_URL] [nvarchar](500) NULL,
	[Активен] [bit] NOT NULL,
	[Последний_Вход] [datetime] NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Примечание] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Пользователь_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Посещаемость]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Посещаемость](
	[Посещаемость_ID] [int] IDENTITY(1,1) NOT NULL,
	[Занятие_ID] [int] NOT NULL,
	[Студент_ID] [int] NOT NULL,
	[Статус] [nvarchar](30) NOT NULL,
	[Тип_Отметки] [nvarchar](30) NOT NULL,
	[Примечание] [nvarchar](300) NULL,
	[Кто_Отметил] [int] NULL,
	[Дата_Отметки] [datetime] NOT NULL,
	[Дата_Обновления] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Посещаемость_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Преподаватель]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Преподаватель](
	[Преподаватель_ID] [int] IDENTITY(1,1) NOT NULL,
	[Пользователь_ID] [int] NOT NULL,
	[ФИО] [nvarchar](150) NOT NULL,
	[Кафедра] [nvarchar](100) NULL,
	[Ученая_Степень] [nvarchar](100) NULL,
	[Должность] [nvarchar](100) NULL,
	[Телефон_Рабочий] [nvarchar](20) NULL,
	[Email_Рабочий] [nvarchar](100) NULL,
	[Примечание] [nvarchar](500) NULL,
	[Дата_Найма] [date] NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Преподаватель_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Разрешения_Ролей]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Разрешения_Ролей](
	[Разрешение_ID] [int] IDENTITY(1,1) NOT NULL,
	[Роль_ID] [int] NOT NULL,
	[Объект] [nvarchar](100) NOT NULL,
	[Действие] [nvarchar](50) NOT NULL,
	[Разрешено] [bit] NOT NULL,
	[Условие] [nvarchar](max) NULL,
	[Описание] [nvarchar](300) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Кто_Создал] [int] NULL,
	[Дата_Обновления] [datetime] NULL,
	[Кто_Обновил] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Разрешение_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Расписание]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Расписание](
	[Расписание_ID] [int] IDENTITY(1,1) NOT NULL,
	[Группа_ID] [int] NOT NULL,
	[Дисциплина_ID] [int] NOT NULL,
	[День_Недели] [tinyint] NOT NULL,
	[Время_Начала] [time](7) NOT NULL,
	[Время_Окончания] [time](7) NOT NULL,
	[Тип_Занятия] [nvarchar](30) NULL,
	[числ/знамен] [nvarchar](20) NULL,
	[Кабинет] [nvarchar](50) NULL,
	[Примечание] [nvarchar](300) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Дата_Обновления] [datetime] NULL,
	[Аудитория_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Расписание_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Резервные_Копии]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Резервные_Копии](
	[Копия_ID] [int] IDENTITY(1,1) NOT NULL,
	[Тип_Копии] [nvarchar](50) NOT NULL,
	[Название_Файла] [nvarchar](255) NOT NULL,
	[Размер_Файла_MB] [decimal](10, 2) NULL,
	[Путь_Хранения] [nvarchar](500) NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Дата_Начала] [datetime] NOT NULL,
	[Дата_Завершения] [datetime] NULL,
	[Время_Выполнения_Сек] [int] NULL,
	[Кто_Создал] [int] NULL,
	[Примечание] [nvarchar](500) NULL,
	[Хэш_Файла] [nvarchar](128) NULL,
	[Версия_БД] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Копия_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Роль]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Роль](
	[Роль_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](50) NOT NULL,
	[Описание] [nvarchar](200) NULL,
	[Уровень_Доступа] [int] NOT NULL,
	[Можно_Удалять] [bit] NOT NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Роль_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Сессия_Пользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Сессия_Пользователя](
	[Сессия_ID] [uniqueidentifier] NOT NULL,
	[Пользователь_ID] [int] NOT NULL,
	[Токен] [nvarchar](500) NOT NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Устройство] [nvarchar](100) NULL,
	[Браузер] [nvarchar](100) NULL,
	[Время_Создания] [datetime] NOT NULL,
	[Время_Истечения] [datetime] NOT NULL,
	[Активна] [bit] NOT NULL,
	[Причина_Завершения] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Сессия_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Система_Интеграция]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Система_Интеграция](
	[Интеграция_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название_Системы] [nvarchar](100) NOT NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Описание] [nvarchar](500) NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Дата_Последней_Синхронизации] [datetime] NULL,
	[Последняя_Ошибка] [nvarchar](max) NULL,
	[Интервал_Синхронизации_Мин] [int] NOT NULL,
	[Время_Следующей_Синхронизации] [datetime] NULL,
	[Активна_Синхронизация] [bit] NOT NULL,
	[Параметры_Подключения] [nvarchar](max) NULL,
	[Ключ_API] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Дата_Обновления] [datetime] NULL,
	[Кто_Настроил] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Интеграция_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[СКУД_Карта]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[СКУД_Карта](
	[Карта_ID] [int] IDENTITY(1,1) NOT NULL,
	[Студент_ID] [int] NOT NULL,
	[Номер_Карты] [nvarchar](50) NOT NULL,
	[Тип_Карты] [nvarchar](30) NOT NULL,
	[PIN_Код] [nvarchar](64) NULL,
	[Фото_URL] [nvarchar](500) NULL,
	[Дата_Выдачи] [date] NOT NULL,
	[Дата_Истечения] [date] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Примечание] [nvarchar](300) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Кто_Выдал] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Карта_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[СКУД_Событие]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[СКУД_Событие](
	[Событие_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Устройство_ID] [int] NOT NULL,
	[Карта_ID] [int] NOT NULL,
	[Время_События] [datetime] NOT NULL,
	[Тип_События] [nvarchar](30) NOT NULL,
	[Направление] [nvarchar](20) NULL,
	[Зона_Доступа] [nvarchar](100) NULL,
	[Результат] [nvarchar](50) NULL,
	[Причина_Запрета] [nvarchar](200) NULL,
	[Температура] [decimal](4, 1) NULL,
	[Фото_URL] [nvarchar](500) NULL,
	[Данные_Датчиков] [nvarchar](max) NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Событие_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[СКУД_Устройство]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[СКУД_Устройство](
	[Устройство_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Местоположение] [nvarchar](200) NOT NULL,
	[IP_Адрес] [nvarchar](45) NULL,
	[Порт] [int] NULL,
	[Серийный_Номер] [nvarchar](100) NULL,
	[Модель] [nvarchar](100) NULL,
	[Производитель] [nvarchar](100) NULL,
	[Версия_ПО] [nvarchar](50) NULL,
	[Ответственный_ID] [int] NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Дата_Установки] [date] NOT NULL,
	[Дата_Последнего_Обслуживания] [date] NULL,
	[Примечание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Аудитория_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Устройство_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Специальность]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Специальность](
	[Специальность_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](150) NOT NULL,
	[Код] [nvarchar](20) NULL,
	[Факультет_ID] [int] NOT NULL,
	[Описание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
 CONSTRAINT [PK_Специальность] PRIMARY KEY CLUSTERED 
(
	[Специальность_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Статистика_Системы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Статистика_Системы](
	[Статистика_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Дата_Статистики] [date] NOT NULL,
	[Тип_Статистики] [nvarchar](50) NOT NULL,
	[Подтип_Статистики] [nvarchar](50) NULL,
	[Значение_1] [decimal](18, 2) NULL,
	[Значение_2] [decimal](18, 2) NULL,
	[Значение_3] [decimal](18, 2) NULL,
	[Значение_4] [decimal](18, 2) NULL,
	[Значение_5] [decimal](18, 2) NULL,
	[Текст_Значение] [nvarchar](max) NULL,
	[JSON_Данные] [nvarchar](max) NULL,
	[Время_Создания] [datetime] NOT NULL,
	[Время_Обновления] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Статистика_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Студент]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Студент](
	[Студент_ID] [int] IDENTITY(1,1) NOT NULL,
	[Пользователь_ID] [int] NOT NULL,
	[ФИО] [nvarchar](150) NOT NULL,
	[Группа_ID] [int] NOT NULL,
	[Дата_Поступления] [date] NOT NULL,
	[Дата_Рождения] [date] NULL,
	[Пол] [nvarchar](10) NULL,
	[Адрес] [nvarchar](300) NULL,
	[Телефон_Родителей] [nvarchar](20) NULL,
	[Примечание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Студент_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Уведомления]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Уведомления](
	[Уведомление_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Пользователь_ID] [int] NOT NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Заголовок] [nvarchar](200) NOT NULL,
	[Сообщение] [nvarchar](max) NOT NULL,
	[Ссылка] [nvarchar](500) NULL,
	[Прочитано] [bit] NOT NULL,
	[Время_Создания] [datetime] NOT NULL,
	[Время_Прочтения] [datetime] NULL,
	[Срок_Действия] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Уведомление_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Учебная_Группа]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Учебная_Группа](
	[Группа_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](50) NOT NULL,
	[Год_Поступления] [int] NOT NULL,
	[Статус] [nvarchar](20) NOT NULL,
	[Куратор_ID] [int] NULL,
	[Примечание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Специальность_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Группа_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Факультет]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Факультет](
	[Факультет_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[Описание] [nvarchar](500) NULL,
	[Дата_Создания] [datetime] NOT NULL,
 CONSTRAINT [PK_Факультет] PRIMARY KEY CLUSTERED 
(
	[Факультет_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Шаблоны_Отчетов]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Шаблоны_Отчетов](
	[Шаблон_ID] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[Тип] [nvarchar](50) NOT NULL,
	[Код_Шаблона] [nvarchar](50) NULL,
	[SQL_Запрос] [nvarchar](max) NOT NULL,
	[Параметры] [nvarchar](max) NULL,
	[Сортировка] [nvarchar](200) NULL,
	[Формат] [nvarchar](20) NOT NULL,
	[Кто_Создал] [int] NOT NULL,
	[Дата_Создания] [datetime] NOT NULL,
	[Дата_Обновления] [datetime] NULL,
	[Активен] [bit] NOT NULL,
	[Общедоступный] [bit] NOT NULL,
	[Описание] [nvarchar](500) NULL,
	[Иконка] [nvarchar](100) NULL,
	[Цвет] [nvarchar](20) NULL,
	[Порядок] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Шаблон_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Аудитория] ON 
GO
INSERT [dbo].[Аудитория] ([Аудитория_ID], [Номер], [Тип], [Корпус], [Вместимость], [Статус], [Примечание], [Дата_Создания], [Корпус_ID]) VALUES (1, N'Г-221', N'лекционная', N'Главный корпус', 100, N'активна', NULL, CAST(N'2026-03-26T04:47:35.797' AS DateTime), NULL)
GO
INSERT [dbo].[Аудитория] ([Аудитория_ID], [Номер], [Тип], [Корпус], [Вместимость], [Статус], [Примечание], [Дата_Создания], [Корпус_ID]) VALUES (2, N'А-103', N'компьютерная', N'Корпус А', 30, N'активна', NULL, CAST(N'2026-03-27T01:01:20.597' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[Аудитория] OFF
GO
SET IDENTITY_INSERT [dbo].[Лог_Действий] ON 
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (30, 1, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T05:47:18.193' AS DateTime), NULL, NULL, NULL, N'Неверный пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:47:18.193' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (40, 1, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T05:49:12.860' AS DateTime), NULL, NULL, NULL, N'Неверный пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:49:12.860' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (41, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T05:49:12.880' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:49:12.880' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (42, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T05:50:08.480' AS DateTime), NULL, NULL, NULL, N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T05:50:08.480' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (43, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T05:57:16.807' AS DateTime), N'127.0.0.1', N'Chrome', N'Windows', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T05:57:16.807' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (44, 1, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T05:59:00.087' AS DateTime), NULL, NULL, NULL, N'Неверный пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:59:00.087' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (45, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T05:59:00.097' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:59:00.097' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (46, NULL, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T05:59:00.107' AS DateTime), NULL, NULL, NULL, N'Логин: php_user', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:59:00.107' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (47, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T05:59:00.110' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T05:59:00.110' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (48, 1, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T06:14:34.703' AS DateTime), NULL, NULL, NULL, N'Неверный пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:14:34.703' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (49, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T06:14:34.713' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:14:34.713' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (50, NULL, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T06:14:34.717' AS DateTime), NULL, NULL, NULL, N'Логин: php_user', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:14:34.717' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (51, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T06:14:34.717' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:14:34.717' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (52, 1, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T06:15:39.773' AS DateTime), NULL, NULL, NULL, N'Неверный пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:15:39.773' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (53, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T06:15:39.783' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:15:39.783' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (54, NULL, N'Информация', N'Неудачная попытка входа', NULL, NULL, CAST(N'2026-04-21T06:15:39.810' AS DateTime), NULL, NULL, NULL, N'Логин: php_user', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:15:39.810' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (55, NULL, N'Информация', N'Ошибка авторизации', NULL, NULL, CAST(N'2026-04-21T06:15:39.810' AS DateTime), NULL, NULL, NULL, N'Неверный логин или пароль', NULL, N'Ошибка', NULL, CAST(N'2026-04-21T06:15:39.810' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (56, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:18:11.013' AS DateTime), NULL, NULL, NULL, N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:18:11.013' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (57, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:22:29.170' AS DateTime), N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:22:29.170' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (58, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:22:29.190' AS DateTime), N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:22:29.190' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (59, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:24:43.810' AS DateTime), N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:24:43.810' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (60, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:24:43.840' AS DateTime), N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:24:43.840' AS DateTime))
GO
INSERT [dbo].[Лог_Действий] ([Лог_ID], [Пользователь_ID], [Уровень_Лога], [Действие], [Таблица], [Запись_ID], [Время_Действия], [IP_Адрес], [Устройство], [Браузер], [Параметры], [Результат], [Статус], [Время_Выполнения_Мс], [Дата_Создания]) VALUES (61, 1, N'Информация', N'Успешный вход в систему', NULL, NULL, CAST(N'2026-04-21T06:29:53.337' AS DateTime), N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', N'Логин: admin', NULL, N'Успешно', NULL, CAST(N'2026-04-21T06:29:53.337' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Лог_Действий] OFF
GO
SET IDENTITY_INSERT [dbo].[Настройки_Системы] ON 
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (1, N'Система.Название', N'Система управления посещаемостью вуза', N'Строка', N'Общие', NULL, N'Название системы', 0, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (2, N'Система.Версия', N'2.0.0', N'Строка', N'Общие', NULL, N'Версия системы', 0, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (3, N'Система.Язык', N'ru-RU', N'Строка', N'Общие', NULL, N'Язык интерфейса', 0, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (4, N'Система.ЧасовойПояс', N'Europe/Moscow', N'Строка', N'Общие', NULL, N'Часовой пояс', 0, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (5, N'QR.ДлительностьПоУмолчанию', N'15', N'Число', N'QR', NULL, N'Длительность QR в минутах', 0, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (6, N'QR.АвтоЗакрытие', N'true', N'Булево', N'QR', NULL, N'Автозакрытие QR', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (7, N'QR.Формат', N'PNG', N'Строка', N'QR', NULL, N'Формат QR изображения', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (8, N'QR.Размер', N'300', N'Число', N'QR', NULL, N'Размер QR в пикселях', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (9, N'СКУД.ВремяНачалаРабочее', N'08:00', N'Строка', N'СКУД', NULL, N'Начало рабочего времени', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (10, N'СКУД.ВремяОкончанияРабочее', N'22:00', N'Строка', N'СКУД', NULL, N'Окончание рабочего времени', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (11, N'СКУД.АвтоСвязьСЗанятиями', N'true', N'Булево', N'СКУД', NULL, N'Автоматическая связь событий СКУД с занятиями', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (12, N'СКУД.РазрешенныеЗоны', N'Главный вход,Корпус А,Корпус Б', N'Строка', N'СКУД', NULL, N'Разрешенные зоны доступа', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (13, N'Посещаемость.АвтоотметкаОпоздания', N'true', N'Булево', N'Посещаемость', NULL, N'Автоматическая отметка опозданий', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (14, N'Посещаемость.ВремяОпозданияМинут', N'10', N'Число', N'Посещаемость', NULL, N'Время опоздания в минутах', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (15, N'Посещаемость.РазрешённыеСтатусы', N'Присутствовал,Отсутствовал,Опоздал,Уважительная причина', N'Строка', N'Посещаемость', NULL, N'Разрешенные статусы посещаемости', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (16, N'Отчеты.ХранениеДляПользователей', N'365', N'Число', N'Отчеты', NULL, N'Дней хранения для пользователей', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (17, N'Отчеты.ХранениеДляАдмина', N'3650', N'Число', N'Отчеты', NULL, N'Дней хранения для админа', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (18, N'Отчеты.АвтоСборСтатистики', N'true', N'Булево', N'Отчеты', NULL, N'Автосбор статистики', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (19, N'Отчеты.ВремяСбораСтатистики', N'23:00', N'Строка', N'Отчеты', NULL, N'Время сбора статистики', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (20, N'Безопасность.МаксПопытокВхода', N'5', N'Число', N'Безопасность', NULL, N'Макс попыток входа', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (21, N'Безопасность.БлокировкаНаМинут', N'15', N'Число', N'Безопасность', NULL, N'Блокировка в минутах', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (22, N'Безопасность.ДлинаПароляМин', N'8', N'Число', N'Безопасность', NULL, N'Минимальная длина пароля', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (23, N'Безопасность.СложностьПароля', N'medium', N'Строка', N'Безопасность', NULL, N'Сложность пароля', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (24, N'Интеграция.1С.АвтоЭкспорт', N'false', N'Булево', N'Интеграция', NULL, N'Автоэкспорт в 1С', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (25, N'Интеграция.1С.ИнтервалЭкспорта', N'1440', N'Число', N'Интеграция', NULL, N'Интервал экспорта в 1С (минуты)', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (26, N'Интеграция.1С.URL', N'http://1c-server:8080/export', N'Строка', N'Интеграция', NULL, N'URL 1С сервера', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (27, N'Интеграция.1С.Логин', N'admin', N'Строка', N'Интеграция', NULL, N'Логин для 1С', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (28, N'Почта.SMTP.Сервер', N'smtp.gmail.com', N'Строка', N'Почта', NULL, N'SMTP сервер', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (29, N'Почта.SMTP.Порт', N'587', N'Число', N'Почта', NULL, N'SMTP порт', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (30, N'Почта.SMTP.Логин', N'email@domain.com', N'Строка', N'Почта', NULL, N'SMTP логин', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (31, N'Почта.SMTP.ИспользуйтеSSL', N'true', N'Булево', N'Почта', NULL, N'Использовать SSL', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (32, N'РезервноеКопирование.АвтоКопирование', N'true', N'Булево', N'РезервноеКопирование', NULL, N'Автоматическое копирование', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (33, N'РезервноеКопирование.Интервал', N'daily', N'Строка', N'РезервноеКопирование', NULL, N'Интервал копирования', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (34, N'РезервноеКопирование.Время', N'02:00', N'Строка', N'РезервноеКопирование', NULL, N'Время копирования', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (35, N'РезервноеКопирование.ХранитьКопий', N'30', N'Число', N'РезервноеКопирование', NULL, N'Хранить копий', 1, 0, CAST(N'2026-02-24T09:05:35.020' AS DateTime), NULL, CAST(N'2026-02-24T09:05:35.020' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (36, N'Триггеры.АвтоСозданиеЗанятий.НедельВперед', N'4', N'Число', N'Триггеры', NULL, N'На сколько недель вперёд создавать занятия автоматически', 0, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (37, N'Триггеры.УведомленияОПропусках.Порог', N'3', N'Число', N'Триггеры', NULL, N'Порог пропусков для создания уведомления', 0, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (38, N'Триггеры.УведомленияОПропусках.ПериодДней', N'7', N'Число', N'Триггеры', NULL, N'За какой период считать пропуски', 0, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (39, N'Триггеры.АвтоЗакрытиеQR.ЗапасМинут', N'5', N'Число', N'Триггеры', NULL, N'Через сколько минут после окончания автоматически закрывать QR', 0, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (40, N'Триггеры.ПериодическоеВыполнение.ИнтервалМинут', N'60', N'Число', N'Триггеры', NULL, N'Интервал выполнения периодических триггеров', 0, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (41, N'Система.PublicBaseUrl', N'http://localhost/ais-system', N'Строка', N'Общие', NULL, N'Публичный базовый URL для ссылок в системных письмах', 1, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (42, N'Безопасность.ВосстановлениеПароля.DatabaseMailProfile', N'AIS Database Mail', N'Строка', N'Безопасность', N'Восстановление пароля', N'Профиль Database Mail для писем восстановления пароля', 1, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
INSERT [dbo].[Настройки_Системы] ([Настройка_ID], [Ключ], [Значение], [Тип], [Категория], [Подкатегория], [Описание], [ТолькоДляАдмина], [ТолькоДляЧтения], [Дата_Изменения], [Кто_Изменил], [Дата_Создания]) VALUES (43, N'Безопасность.ВосстановлениеПароля.СрокМинут', N'30', N'Число', N'Безопасность', N'Восстановление пароля', N'Срок действия ссылки восстановления пароля в минутах', 1, 0, CAST(N'2026-02-24T09:06:55.560' AS DateTime), NULL, CAST(N'2026-02-24T09:06:55.560' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Настройки_Системы] OFF
GO
SET IDENTITY_INSERT [dbo].[Пользователь] ON 
GO
INSERT [dbo].[Пользователь] ([Пользователь_ID], [Логин], [Хэш_Пароля], [Соль], [Email], [Роль_ID], [Телефон], [Аватар_URL], [Активен], [Последний_Вход], [Дата_Создания], [Примечание]) VALUES (1, N'admin', N'3453CF2E5AF19F00F15E58F416703042E3B7756ADA820758B2904D3FD83A0A40', N'A3D3CA18BC806006A59E33336AF2CCD0', N'admin@university.ru', 1, NULL, NULL, 1, CAST(N'2026-04-21T06:29:53.337' AS DateTime), CAST(N'2026-02-24T09:05:35.030' AS DateTime), NULL)
GO
INSERT [dbo].[Пользователь] ([Пользователь_ID], [Логин], [Хэш_Пароля], [Соль], [Email], [Роль_ID], [Телефон], [Аватар_URL], [Активен], [Последний_Вход], [Дата_Создания], [Примечание]) VALUES (2, N'system', N'', N'', NULL, 1, NULL, NULL, 1, NULL, CAST(N'2026-02-24T09:08:19.070' AS DateTime), N'Системный пользователь для автоматических действий')
GO
INSERT [dbo].[Пользователь] ([Пользователь_ID], [Логин], [Хэш_Пароля], [Соль], [Email], [Роль_ID], [Телефон], [Аватар_URL], [Активен], [Последний_Вход], [Дата_Создания], [Примечание]) VALUES (5, N'curator', N'EF864BBDC2FF5D949230FDD3E72A639DC2436FEF819E378A3C2CCCE139E9B2F6', N'AC56364EC4FB3B40C30F8FDAE1089AB8', NULL, 6, NULL, NULL, 1, NULL, CAST(N'2026-03-26T04:47:35.797' AS DateTime), NULL)
GO
INSERT [dbo].[Пользователь] ([Пользователь_ID], [Логин], [Хэш_Пароля], [Соль], [Email], [Роль_ID], [Телефон], [Аватар_URL], [Активен], [Последний_Вход], [Дата_Создания], [Примечание]) VALUES (6, N'director', N'0745E85AFA416A9C87341DD04C24E73C2477CD2650F6AB994ECCD11A03B91513', N'48B195F5A09E9227461FC86FFA67F9BC', NULL, 7, NULL, NULL, 1, NULL, CAST(N'2026-03-26T04:47:35.800' AS DateTime), NULL)
GO
INSERT [dbo].[Пользователь] ([Пользователь_ID], [Логин], [Хэш_Пароля], [Соль], [Email], [Роль_ID], [Телефон], [Аватар_URL], [Активен], [Последний_Вход], [Дата_Создания], [Примечание]) VALUES (7, N'metodist', N'3F3E2D133939E751DA9EB4FCECDBAE1E0BC58EA6AE2772F2D8272465DE84FF62', N'08A25FD7789E9C3E58DC0224E9EB9BF7', NULL, 2, NULL, NULL, 1, NULL, CAST(N'2026-03-26T04:47:35.800' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[Пользователь] OFF
GO
SET IDENTITY_INSERT [dbo].[Разрешения_Ролей] ON 
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (1, 1, N'Пользователь', N'Чтение', 1, NULL, N'Просмотр пользователей', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (2, 1, N'Пользователь', N'Создание', 1, NULL, N'Создание пользователей', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (3, 1, N'Пользователь', N'Редактирование', 1, NULL, N'Редактирование пользователей', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (4, 1, N'Пользователь', N'Удаление', 1, NULL, N'Удаление пользователей', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (5, 1, N'Студент', N'Чтение', 1, NULL, N'Просмотр студентов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (6, 1, N'Студент', N'Создание', 1, NULL, N'Создание студентов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (7, 1, N'Студент', N'Редактирование', 1, NULL, N'Редактирование студентов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (8, 1, N'Студент', N'Удаление', 1, NULL, N'Удаление студентов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (9, 1, N'Посещаемость', N'Чтение', 1, NULL, N'Просмотр посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (10, 1, N'Посещаемость', N'Создание', 1, NULL, N'Создание посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (11, 1, N'Посещаемость', N'Редактирование', 1, NULL, N'Редактирование посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (12, 1, N'Посещаемость', N'Удаление', 1, NULL, N'Удаление посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (13, 1, N'Отчеты', N'Просмотр', 1, NULL, N'Просмотр отчетов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (14, 1, N'Отчеты', N'Экспорт', 1, NULL, N'Экспорт отчетов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (15, 1, N'Система', N'Настройки', 1, NULL, N'Изменение настроек системы', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (16, 3, N'Студент', N'Чтение', 1, NULL, N'Просмотр своих студентов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (17, 3, N'Посещаемость', N'Чтение', 1, NULL, N'Просмотр посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (18, 3, N'Посещаемость', N'Создание', 1, NULL, N'Создание посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (19, 3, N'Посещаемость', N'Редактирование', 1, NULL, N'Редактирование посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (20, 3, N'QR', N'Создание', 1, NULL, N'Создание QR кодов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (21, 3, N'QR', N'Управление', 1, NULL, N'Управление QR кодами', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (22, 3, N'Отчеты', N'Просмотр', 1, NULL, N'Просмотр отчетов по своим группам', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (23, 4, N'Посещаемость', N'Чтение', 1, NULL, N'Просмотр своей посещаемости', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (24, 4, N'QR', N'Сканирование', 1, NULL, N'Сканирование QR кодов', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (25, 4, N'Расписание', N'Чтение', 1, NULL, N'Просмотр расписания', CAST(N'2026-02-24T09:05:35.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (26, 6, N'Обоснования', N'Управление', 1, NULL, N'Управление обоснованиями своей группы', CAST(N'2026-03-26T04:47:35.803' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Разрешения_Ролей] ([Разрешение_ID], [Роль_ID], [Объект], [Действие], [Разрешено], [Условие], [Описание], [Дата_Создания], [Кто_Создал], [Дата_Обновления], [Кто_Обновил]) VALUES (27, 7, N'Отчеты', N'Просмотр', 1, NULL, N'Просмотр всех отчетов', CAST(N'2026-03-26T04:47:35.803' AS DateTime), NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Разрешения_Ролей] OFF
GO
SET IDENTITY_INSERT [dbo].[Роль] ON 
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (1, N'Admin', N'Администратор системы', 100, 0, CAST(N'2026-02-24T09:05:35.010' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (2, N'Методист', N'Методист учебного отдела', 80, 0, CAST(N'2026-02-24T09:05:35.010' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (3, N'Преподаватель', N'Преподаватель', 60, 0, CAST(N'2026-02-24T09:05:35.010' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (4, N'Студент', N'Студент', 40, 0, CAST(N'2026-02-24T09:05:35.010' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (5, N'Гость', N'Гостевой доступ', 10, 0, CAST(N'2026-02-24T09:05:35.010' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (6, N'Куратор', N'Куратор учебной группы', 70, 0, CAST(N'2026-03-26T04:47:35.790' AS DateTime))
GO
INSERT [dbo].[Роль] ([Роль_ID], [Название], [Описание], [Уровень_Доступа], [Можно_Удалять], [Дата_Создания]) VALUES (7, N'Директор', N'Руководитель института', 90, 0, CAST(N'2026-03-26T04:47:35.793' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Роль] OFF
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'c4e71ab2-8a82-48ce-882e-0e9f4bf1281a', 1, N'CA3043C9959D653706C65CED8D8D020E7EBBCBF5129FD10A514F4D4F28BDE08A', N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', CAST(N'2026-04-21T06:24:43.830' AS DateTime), CAST(N'2026-04-21T08:24:43.957' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'9de004f2-83f2-4f17-9f1a-12d862ecec78', 1, N'C4D58D0BAA550AC5BF804CDDE17096DB33F4A6C55A7BA95B6B3D9CFA6A2EA71B', NULL, NULL, NULL, CAST(N'2026-02-24T19:22:04.277' AS DateTime), CAST(N'2026-02-24T21:23:04.220' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'76546619-1a09-4892-b094-199ce3bfdebf', 1, N'4780A29E9A398A1ED37A5E796BFFD6D61BA3367F08B02B6288B2E891A1EA6E62', NULL, NULL, NULL, CAST(N'2026-02-24T19:13:49.500' AS DateTime), CAST(N'2026-02-24T21:13:49.657' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'0b139412-c547-4f81-8cd9-19aaf35ba261', 1, N'92A024140707A365F704F315E95D70871E660018E08F0CA0FA32560C40623C74', NULL, NULL, NULL, CAST(N'2026-02-24T19:20:15.350' AS DateTime), CAST(N'2026-02-24T21:20:23.850' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'3d8b0d96-4bc4-4e04-b454-1ba8d7e741d4', 1, N'20494CCD4C8C803E55D2AAE94BD3BB5F1E8F1E2DC4658D0512AFAE2BA008B0D2', NULL, NULL, NULL, CAST(N'2026-02-24T21:16:56.107' AS DateTime), CAST(N'2026-02-24T23:17:56.887' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'b9663aa8-2a4e-4611-8b12-1d06e9ed4640', 1, N'91586521A76484F32C60CCFD77518D4DEA3B2D1D4C020B82ABAC39B921A578C1', N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', CAST(N'2026-04-21T06:22:29.167' AS DateTime), CAST(N'2026-04-21T14:22:29.167' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'89ce5ed0-f486-4e05-82ec-397d0f081f0f', 1, N'2CCA0299E4B6AAFC51BBB55883E5E4F0B9EAAD74FFB7E474125D8E96FB5560D7', NULL, NULL, NULL, CAST(N'2026-02-24T19:16:28.353' AS DateTime), CAST(N'2026-02-24T19:17:27.223' AS DateTime), 0, N'1')
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'cc048f52-7546-4da3-9985-3a4c83a9929d', 1, N'F5900516CDE79CA51521B40446636393922639C0536171F50A4ADD1BF37B8BFB', NULL, NULL, NULL, CAST(N'2026-04-21T06:18:11.010' AS DateTime), CAST(N'2026-04-21T14:18:11.010' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'7e5bd2a7-c5d0-4cdc-aaa3-67c2ef1a9f95', 1, N'4049FE97D911E9B9AE5EBCA50CFA8CE7DB7989A7E3599B407EE307850903937C', NULL, NULL, NULL, CAST(N'2026-02-24T19:13:22.470' AS DateTime), CAST(N'2026-02-25T03:13:22.470' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'8ce2ff4b-45b5-4639-85a7-73556af403ca', 1, N'B96BB6B881EFDAF585A99D76EC27B8389CEAF9C9D6CE918BD27BA13560039533', N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', CAST(N'2026-04-21T06:24:43.800' AS DateTime), CAST(N'2026-04-21T14:24:43.800' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'2879980c-5c7e-44a7-b627-89bdde1ddce4', 1, N'F4C1E6ABEB94E33D4E61C9060FD7995C65A57164E98FF1155AE3AA01224DA308', N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', CAST(N'2026-04-21T06:22:29.190' AS DateTime), CAST(N'2026-04-21T08:22:29.317' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'fc945e59-43bd-4ad4-bb51-95cfcf613c23', 1, N'15C2841DE31593AEFA0D9CA11DB4A9C397D37F00CEA5D7B6D2C731C7F1540786', NULL, NULL, NULL, CAST(N'2026-02-24T19:17:34.293' AS DateTime), CAST(N'2026-02-24T21:19:51.430' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'e404d487-3578-4e86-b2d1-ac59f34d1097', 1, N'259C395E2FBF4FCC48952409C604D8F86D32DF0BA57027E9098352D52094747B', NULL, NULL, NULL, CAST(N'2026-02-24T19:13:29.340' AS DateTime), CAST(N'2026-02-25T03:13:29.340' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'c2310ab7-1b13-43fc-a260-b0ed1dc96342', 1, N'47BC9531645B2FDA09B84CF015BD7C14978F5376ECCB56AECEEDDC5E769768F9', N'127.0.0.1', N'Chrome', N'Windows', CAST(N'2026-04-21T05:57:16.793' AS DateTime), CAST(N'2026-04-21T13:57:16.793' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'33ecf439-2cbc-465a-b116-ce0a877c2b2a', 1, N'0B46CF0ABBEFBB1D5ED2D5BD6270F508ED321B35960F724583075EFAC5EC4874', NULL, NULL, NULL, CAST(N'2026-04-21T05:50:08.473' AS DateTime), CAST(N'2026-04-21T13:50:08.473' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'7d70d931-e22d-461c-9ac8-d8d484a1b0e8', 1, N'43BDAB48EF47DA25D9D9E52F2D8D1B4D4239436C40D72BD0384736AEECA2DFB4', NULL, NULL, NULL, CAST(N'2026-02-24T19:14:38.690' AS DateTime), CAST(N'2026-02-24T21:14:38.803' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'2422ea09-a5f3-41bd-b77f-e36ff323e3e3', 1, N'ED784EAF0F46739CD899FF9B31A78D7C1D99E3EE2BFF471C98ED2EC07BE7CD48', N'127.0.0.1', N'PHP Test Script', N'Mozilla/5.0 (Test)', CAST(N'2026-04-21T06:29:53.330' AS DateTime), CAST(N'2026-04-21T08:29:53.817' AS DateTime), 1, NULL)
GO
INSERT [dbo].[Сессия_Пользователя] ([Сессия_ID], [Пользователь_ID], [Токен], [IP_Адрес], [Устройство], [Браузер], [Время_Создания], [Время_Истечения], [Активна], [Причина_Завершения]) VALUES (N'e16cf24a-21dd-4e6a-8bb2-f3adf0c84e03', 1, N'670E58CF3ABA7BD11605E5969BBB77EDC2B56E68209A5964BFD9D9EA50C1DB1A', NULL, NULL, NULL, CAST(N'2026-02-24T21:11:42.467' AS DateTime), CAST(N'2026-02-24T23:12:15.587' AS DateTime), 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[Специальность] ON 
GO
INSERT [dbo].[Специальность] ([Специальность_ID], [Название], [Код], [Факультет_ID], [Описание], [Дата_Создания]) VALUES (1, N'Информационные системы и технологии', N'09.03.02', 1, NULL, CAST(N'2026-03-26T04:47:35.793' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Специальность] OFF
GO
SET IDENTITY_INSERT [dbo].[Статистика_Системы] ON 
GO
INSERT [dbo].[Статистика_Системы] ([Статистика_ID], [Дата_Статистики], [Тип_Статистики], [Подтип_Статистики], [Значение_1], [Значение_2], [Значение_3], [Значение_4], [Значение_5], [Текст_Значение], [JSON_Данные], [Время_Создания], [Время_Обновления]) VALUES (105, CAST(N'2026-04-21' AS Date), N'Активность', NULL, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, N'Добавлено логов: 1, Разных пользователей: 1', NULL, CAST(N'2026-04-21T06:29:53.350' AS DateTime), NULL)
GO
INSERT [dbo].[Статистика_Системы] ([Статистика_ID], [Дата_Статистики], [Тип_Статистики], [Подтип_Статистики], [Значение_1], [Значение_2], [Значение_3], [Значение_4], [Значение_5], [Текст_Значение], [JSON_Данные], [Время_Создания], [Время_Обновления]) VALUES (106, CAST(N'2026-04-21' AS Date), N'Активность', N'Уровень: Информация', CAST(1.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2026-04-21T06:29:53.350' AS DateTime), NULL)
GO
INSERT [dbo].[Статистика_Системы] ([Статистика_ID], [Дата_Статистики], [Тип_Статистики], [Подтип_Статистики], [Значение_1], [Значение_2], [Значение_3], [Значение_4], [Значение_5], [Текст_Значение], [JSON_Данные], [Время_Создания], [Время_Обновления]) VALUES (107, CAST(N'2026-04-21' AS Date), N'Активность', N'Статус: Успешно', CAST(1.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2026-04-21T06:29:53.350' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[Статистика_Системы] OFF
GO
SET IDENTITY_INSERT [dbo].[Факультет] ON 
GO
INSERT [dbo].[Факультет] ([Факультет_ID], [Название], [Описание], [Дата_Создания]) VALUES (1, N'Факультет автоматизации и информационных технологий', NULL, CAST(N'2026-03-26T04:47:35.793' AS DateTime))
GO
INSERT [dbo].[Факультет] ([Факультет_ID], [Название], [Описание], [Дата_Создания]) VALUES (2, N'Инженерно-экономический факультет', NULL, CAST(N'2026-03-26T04:47:35.793' AS DateTime))
GO
INSERT [dbo].[Факультет] ([Факультет_ID], [Название], [Описание], [Дата_Создания]) VALUES (3, N'Факультет металлургических и машиностроительных технологий', NULL, CAST(N'2026-03-26T04:47:35.793' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Факультет] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_QR_Сессия_Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_QR_Сессия_Занятие] ON [dbo].[QR_Сессия]
(
	[Занятие_ID] ASC,
	[Статус] ASC
)
INCLUDE([QR_Код],[Время_Действия_Конец]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_QR_Сессия_Код]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_QR_Сессия_Код] ON [dbo].[QR_Сессия]
(
	[QR_Код] ASC
)
WHERE ([Статус]=N'Активен')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_QR_Сессия_Статус_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_QR_Сессия_Статус_Время] ON [dbo].[QR_Сессия]
(
	[Статус] ASC,
	[Время_Действия_Начало] ASC,
	[Время_Действия_Конец] ASC
)
INCLUDE([QR_Сессия_ID],[Занятие_ID],[QR_Код]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_QR_Сканирование]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[QR_Сканирование] ADD  CONSTRAINT [UQ_QR_Сканирование] UNIQUE NONCLUSTERED 
(
	[QR_Сессия_ID] ASC,
	[Студент_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_QR_Сканирование_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_QR_Сканирование_Время] ON [dbo].[QR_Сканирование]
(
	[Время_Сканирования] DESC
)
INCLUDE([QR_Сессия_ID],[Студент_ID],[Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Аудитория_Номер]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Аудитория] ADD  CONSTRAINT [UQ_Аудитория_Номер] UNIQUE NONCLUSTERED 
(
	[Номер] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Временные_Данные_Истекает]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Временные_Данные_Истекает] ON [dbo].[Временные_Данные]
(
	[Истекает_В] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Временные_Данные_Ключ]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Временные_Данные_Ключ] ON [dbo].[Временные_Данные]
(
	[Ключ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Восстановление_Пароля_Токен]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Восстановление_Пароля_Токен] ON [dbo].[Восстановление_Пароля]
(
	[Токен_Хэш] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Восстановление_Пароля_Пользователь_Активные]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Восстановление_Пароля_Пользователь_Активные] ON [dbo].[Восстановление_Пароля]
(
	[Пользователь_ID] ASC,
	[Использован] ASC,
	[Истекает_В] DESC
)
INCLUDE([Попыток],[Отправлено]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Восстановление_Пароля_Истекает]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Восстановление_Пароля_Истекает] ON [dbo].[Восстановление_Пароля]
(
	[Истекает_В] ASC,
	[Использован] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Дисципли__DC28B39CDA0CC1F1]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Дисциплина] ADD UNIQUE NONCLUSTERED 
(
	[краткое наименование] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Дисциплина_Код]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Дисциплина_Код] ON [dbo].[Дисциплина]
(
	[краткое наименование] ASC
)
WHERE ([краткое наименование] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Дисциплина_Название_Преподаватель]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Дисциплина_Название_Преподаватель] ON [dbo].[Дисциплина]
(
	[Название] ASC,
	[Преподаватель_ID] ASC
)
INCLUDE([Дисциплина_ID],[краткое наименование],[Статус],[Семестр]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Дисциплина_Преподаватель_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Дисциплина_Преподаватель_Статус] ON [dbo].[Дисциплина]
(
	[Преподаватель_ID] ASC,
	[Статус] ASC
)
INCLUDE([Название],[краткое наименование],[Семестр]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Оптимизация_Преподаватель_Отчеты]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Преподаватель_Отчеты] ON [dbo].[Дисциплина]
(
	[Преподаватель_ID] ASC,
	[Статус] ASC
)
INCLUDE([Дисциплина_ID],[Название],[Семестр]) 
WHERE ([Статус]=N'Активна')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Занятие] ADD  CONSTRAINT [UQ_Занятие] UNIQUE NONCLUSTERED 
(
	[Расписание_ID] ASC,
	[Дата_Занятия] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Занятие_ВремяНачалаФакт]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Занятие_ВремяНачалаФакт] ON [dbo].[Занятие]
(
	[Время_Начала_Факт] ASC
)
WHERE ([Время_Начала_Факт] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Занятие_Дата_ДляОтчетов]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Занятие_Дата_ДляОтчетов] ON [dbo].[Занятие]
(
	[Дата_Занятия] ASC
)
INCLUDE([Расписание_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Занятие_Дата_Расписание]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Занятие_Дата_Расписание] ON [dbo].[Занятие]
(
	[Дата_Занятия] ASC,
	[Расписание_ID] ASC
)
INCLUDE([Статус],[Тема_Занятия],[Кабинет]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Занятие_Статус_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Занятие_Статус_Дата] ON [dbo].[Занятие]
(
	[Статус] ASC,
	[Дата_Занятия] ASC
)
INCLUDE([Расписание_ID],[Тема_Занятия],[Время_Начала_Факт]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Занятия_Последние_2_Месяца]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Занятия_Последние_2_Месяца] ON [dbo].[Занятие]
(
	[Дата_Занятия] DESC,
	[Статус] ASC
)
INCLUDE([Расписание_ID],[Тема_Занятия]) 
WHERE ([Дата_Занятия]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Конкурентный_Доступ_Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Конкурентный_Доступ_Занятие] ON [dbo].[Занятие]
(
	[Расписание_ID] ASC,
	[Дата_Занятия] ASC
)
INCLUDE([Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Время_Реальное]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Время_Реальное] ON [dbo].[Занятие]
(
	[Время_Начала_Факт] DESC
)
WHERE ([Время_Начала_Факт] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Занятие_Расписание_Дисциплина]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Занятие_Расписание_Дисциплина] ON [dbo].[Занятие]
(
	[Дата_Занятия] DESC
)
INCLUDE([Расписание_ID],[Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Оптимизация_Занятия_Нагрузка]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Занятия_Нагрузка] ON [dbo].[Занятие]
(
	[Дата_Занятия] ASC,
	[Статус] ASC
)
INCLUDE([Расписание_ID],[Тема_Занятия],[Кабинет]) 
WHERE ([Статус] IN (N'Запланировано', N'Проведено'))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Занятия_Последние3Месяца]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Занятия_Последние3Месяца] ON [dbo].[Занятие]
(
	[Дата_Занятия] DESC
)
INCLUDE([Расписание_ID],[Статус],[Тема_Занятия],[Кабинет]) 
WHERE ([Дата_Занятия]>='2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Отчетов_Группа]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Отчетов_Группа] ON [dbo].[Занятие]
(
	[Дата_Занятия] ASC,
	[Расписание_ID] ASC
)
INCLUDE([Статус],[Тема_Занятия]) 
WHERE ([Статус]=N'Проведено')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ПолучитьЗанятияПоДате]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_ПолучитьЗанятияПоДате] ON [dbo].[Занятие]
(
	[Дата_Занятия] DESC,
	[Статус] ASC
)
INCLUDE([Расписание_ID],[Тема_Занятия],[Кабинет],[Время_Начала_Факт]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Корпус__38DA8035DA64C782]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Корпус] ADD UNIQUE NONCLUSTERED 
(
	[Название] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Лог_Действий_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Лог_Действий_Время] ON [dbo].[Лог_Действий]
(
	[Время_Действия] DESC
)
INCLUDE([Пользователь_ID],[Действие],[Статус],[Таблица]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_Лог_Действий_Пользователь_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Лог_Действий_Пользователь_Время] ON [dbo].[Лог_Действий]
(
	[Пользователь_ID] ASC,
	[Время_Действия] DESC
)
WHERE ([Пользователь_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Лог_Действий_Статус_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Лог_Действий_Статус_Время] ON [dbo].[Лог_Действий]
(
	[Статус] ASC,
	[Время_Действия] DESC
)
INCLUDE([Пользователь_ID],[Действие],[Таблица]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Лог_Действий_Таблица_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Лог_Действий_Таблица_Время] ON [dbo].[Лог_Действий]
(
	[Таблица] ASC,
	[Время_Действия] DESC
)
WHERE ([Таблица] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Настройк__04C85F6BAA886DC2]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Настройки_Системы] ADD UNIQUE NONCLUSTERED 
(
	[Ключ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Настройки_Системы_Категория_Ключ]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Настройки_Системы_Категория_Ключ] ON [dbo].[Настройки_Системы]
(
	[Категория] ASC,
	[Ключ] ASC
)
INCLUDE([Значение],[Тип],[ТолькоДляАдмина]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Обоснования_Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Обоснования_Занятие] ON [dbo].[Обоснования_Отсутствия]
(
	[Занятие_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Обоснования_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Обоснования_Статус] ON [dbo].[Обоснования_Отсутствия]
(
	[Статус] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Обоснования_Студент]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Обоснования_Студент] ON [dbo].[Обоснования_Отсутствия]
(
	[Студент_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Обоснования_Студент_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Обоснования_Студент_Дата] ON [dbo].[Обоснования_Отсутствия]
(
	[Студент_ID] ASC,
	[Дата_Подачи] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Пользова__BC2217D34B43A664]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Пользователь] ADD UNIQUE NONCLUSTERED 
(
	[Логин] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Горячие_Данные_Пользователи]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Горячие_Данные_Пользователи] ON [dbo].[Пользователь]
(
	[Дата_Создания] DESC,
	[Активен] ASC
)
INCLUDE([Пользователь_ID],[Логин],[Email],[Последний_Вход]) 
WHERE ([Активен]=(1) AND [Дата_Создания]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Конкурентный_Доступ_Пользователь]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Конкурентный_Доступ_Пользователь] ON [dbo].[Пользователь]
(
	[Логин] ASC
)
INCLUDE([Пользователь_ID],[Хэш_Пароля],[Активен]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Высокая_Нагрузка]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Высокая_Нагрузка] ON [dbo].[Пользователь]
(
	[Активен] ASC,
	[Роль_ID] ASC
)
INCLUDE([Пользователь_ID],[Логин],[Email],[Последний_Вход]) 
WHERE ([Активен]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Пользователь_Логин]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Пользователь_Логин] ON [dbo].[Пользователь]
(
	[Логин] ASC
)
INCLUDE([Хэш_Пароля],[Соль],[Роль_ID],[Активен],[Email]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Пользователь_ПоследнийВход]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Пользователь_ПоследнийВход] ON [dbo].[Пользователь]
(
	[Последний_Вход] DESC
)
WHERE ([Последний_Вход] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Пользователь_Роль_Активен]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Пользователь_Роль_Активен] ON [dbo].[Пользователь]
(
	[Роль_ID] ASC,
	[Активен] ASC
)
INCLUDE([Логин],[Email],[Последний_Вход]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Посещаемость]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Посещаемость] ADD  CONSTRAINT [UQ_Посещаемость] UNIQUE NONCLUSTERED 
(
	[Занятие_ID] ASC,
	[Студент_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Комплексный_Отчет_Посещаемости]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Комплексный_Отчет_Посещаемости] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC,
	[Студент_ID] ASC,
	[Дата_Отметки] DESC
)
INCLUDE([Статус],[Тип_Отметки],[Кто_Отметил]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Конкурентный_Доступ_Посещаемость]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Конкурентный_Доступ_Посещаемость] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC
)
INCLUDE([Студент_ID],[Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Для_Отчетов_Месячные]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Для_Отчетов_Месячные] ON [dbo].[Посещаемость]
(
	[Дата_Отметки] DESC,
	[Занятие_ID] ASC,
	[Студент_ID] ASC
)
INCLUDE([Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_ДляСвязиСЗанятиями]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_ДляСвязиСЗанятиями] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC,
	[Студент_ID] ASC
)
INCLUDE([Дата_Отметки],[Статус],[Тип_Отметки]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Занятие]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Занятие] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC
)
INCLUDE([Студент_ID],[Статус],[Дата_Отметки]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Занятие_Студент_Cover]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Занятие_Студент_Cover] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC,
	[Студент_ID] ASC
)
INCLUDE([Статус],[Тип_Отметки],[Дата_Отметки]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_ИсторическиеДанные]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_ИсторическиеДанные] ON [dbo].[Посещаемость]
(
	[Дата_Отметки] DESC,
	[Студент_ID] ASC
)
INCLUDE([Занятие_ID],[Статус]) 
WHERE ([Дата_Отметки]<'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Последние_6_Месяцев]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Последние_6_Месяцев] ON [dbo].[Посещаемость]
(
	[Занятие_ID] ASC,
	[Дата_Отметки] DESC
)
INCLUDE([Студент_ID],[Статус]) 
WHERE ([Дата_Отметки]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Посещаемость_Статус_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Статус_Дата] ON [dbo].[Посещаемость]
(
	[Статус] ASC,
	[Дата_Отметки] DESC
)
WHERE ([Статус] IN (N'Присутствовал', N'Отсутствовал', N'Опоздал'))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Студент_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Студент_Дата] ON [dbo].[Посещаемость]
(
	[Студент_ID] ASC,
	[Дата_Отметки] DESC
)
INCLUDE([Занятие_ID],[Статус],[Тип_Отметки]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Посещаемость_Студент_ДляОтчетов]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_Студент_ДляОтчетов] ON [dbo].[Посещаемость]
(
	[Студент_ID] ASC,
	[Занятие_ID] ASC,
	[Дата_Отметки] DESC
)
INCLUDE([Статус],[Примечание]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Посещаемость_ТипОтметки_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Посещаемость_ТипОтметки_Дата] ON [dbo].[Посещаемость]
(
	[Тип_Отметки] ASC,
	[Дата_Отметки] DESC
)
INCLUDE([Занятие_ID],[Студент_ID],[Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_СформироватьОтчетПоСтуденту]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СформироватьОтчетПоСтуденту] ON [dbo].[Посещаемость]
(
	[Студент_ID] ASC,
	[Дата_Отметки] DESC,
	[Занятие_ID] ASC
)
INCLUDE([Статус],[Тип_Отметки],[Кто_Отметил]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Экспорт_1C_Данные]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Экспорт_1C_Данные] ON [dbo].[Посещаемость]
(
	[Дата_Отметки] DESC,
	[Тип_Отметки] ASC
)
INCLUDE([Занятие_ID],[Студент_ID],[Статус]) 
WHERE ([Тип_Отметки]<>N'Ручная' AND [Дата_Отметки]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Преподав__7889B594AACAC85E]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Преподаватель] ADD UNIQUE NONCLUSTERED 
(
	[Пользователь_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Преподаватель_Кафедра]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Преподаватель_Кафедра] ON [dbo].[Преподаватель]
(
	[Кафедра] ASC
)
WHERE ([Кафедра] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Преподаватель_ФИО]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Преподаватель_ФИО] ON [dbo].[Преподаватель]
(
	[ФИО] ASC
)
INCLUDE([Преподаватель_ID],[Кафедра],[Должность],[Пользователь_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Разрешения]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Разрешения_Ролей] ADD  CONSTRAINT [UQ_Разрешения] UNIQUE NONCLUSTERED 
(
	[Роль_ID] ASC,
	[Объект] ASC,
	[Действие] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Комплексный_Расписание_Преподаватель]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Комплексный_Расписание_Преподаватель] ON [dbo].[Расписание]
(
	[Дисциплина_ID] ASC,
	[Группа_ID] ASC
)
INCLUDE([День_Недели],[Время_Начала],[Время_Окончания]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Расписание_Группа_День]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Расписание_Группа_День] ON [dbo].[Расписание]
(
	[Группа_ID] ASC,
	[День_Недели] ASC
)
INCLUDE([Дисциплина_ID],[Время_Начала],[Время_Окончания],[Кабинет]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Расписание_Дисциплина]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Расписание_Дисциплина] ON [dbo].[Расписание]
(
	[Дисциплина_ID] ASC
)
INCLUDE([Группа_ID],[День_Недели],[Время_Начала]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Роль__38DA80350F783584]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Роль] ADD UNIQUE NONCLUSTERED 
(
	[Название] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Роль_УровеньДоступа]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Роль_УровеньДоступа] ON [dbo].[Роль]
(
	[Уровень_Доступа] DESC
)
INCLUDE([Название],[Описание],[Можно_Удалять]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Горячие_Данные_Сессии]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Горячие_Данные_Сессии] ON [dbo].[Сессия_Пользователя]
(
	[Время_Создания] DESC,
	[Активна] ASC
)
INCLUDE([Сессия_ID],[Пользователь_ID],[Токен],[Время_Истечения]) 
WHERE ([Активна]=(1) AND [Время_Создания]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Оптимизация_Сессии_Нагрузка]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Оптимизация_Сессии_Нагрузка] ON [dbo].[Сессия_Пользователя]
(
	[Активна] ASC,
	[Время_Истечения] DESC
)
INCLUDE([Сессия_ID],[Пользователь_ID],[Токен],[Время_Создания]) 
WHERE ([Активна]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Сессии_Последние_30_Дней]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Сессии_Последние_30_Дней] ON [dbo].[Сессия_Пользователя]
(
	[Время_Создания] DESC
)
INCLUDE([Пользователь_ID],[Активна],[Токен],[Время_Истечения]) 
WHERE ([Время_Создания]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Сессия_Пользователя_ВремяИстечения]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Сессия_Пользователя_ВремяИстечения] ON [dbo].[Сессия_Пользователя]
(
	[Время_Истечения] ASC
)
WHERE ([Активна]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Сессия_Пользователя_Пользователь_Активна]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Сессия_Пользователя_Пользователь_Активна] ON [dbo].[Сессия_Пользователя]
(
	[Пользователь_ID] ASC,
	[Активна] ASC
)
INCLUDE([Сессия_ID],[Время_Истечения],[Токен]) 
WHERE ([Активна]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Сессия_Пользователя_Токен]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Сессия_Пользователя_Токен] ON [dbo].[Сессия_Пользователя]
(
	[Токен] ASC
)
WHERE ([Активна]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Комплексный_Система_Интеграция]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Комплексный_Система_Интеграция] ON [dbo].[Система_Интеграция]
(
	[Статус] ASC,
	[Активна_Синхронизация] ASC
)
INCLUDE([Тип],[Название_Системы],[Дата_Последней_Синхронизации]) 
WHERE ([Статус]=N'Активна')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Система_Интеграция_Тип_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Система_Интеграция_Тип_Статус] ON [dbo].[Система_Интеграция]
(
	[Тип] ASC,
	[Статус] ASC
)
INCLUDE([Интеграция_ID],[Название_Системы],[Дата_Последней_Синхронизации]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__СКУД_Кар__3DE99696B8DAE62C]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[СКУД_Карта] ADD UNIQUE NONCLUSTERED 
(
	[Студент_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__СКУД_Кар__E86C44A5702B0A25]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[СКУД_Карта] ADD UNIQUE NONCLUSTERED 
(
	[Номер_Карты] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Карта_Активна_ДатаИстечения]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Карта_Активна_ДатаИстечения] ON [dbo].[СКУД_Карта]
(
	[Статус] ASC,
	[Дата_Истечения] ASC
)
WHERE ([Статус]=N'Активна')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Карта_ДатаИстечения]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Карта_ДатаИстечения] ON [dbo].[СКУД_Карта]
(
	[Дата_Истечения] ASC,
	[Статус] ASC
)
INCLUDE([Карта_ID],[Студент_ID],[Номер_Карты]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Карта_Номер]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_СКУД_Карта_Номер] ON [dbo].[СКУД_Карта]
(
	[Номер_Карты] ASC
)
WHERE ([Статус]=N'Активна')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Карта_Студент_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Карта_Студент_Статус] ON [dbo].[СКУД_Карта]
(
	[Студент_ID] ASC,
	[Статус] ASC
)
INCLUDE([Номер_Карты],[Дата_Истечения]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_СКУД_Реальное_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Реальное_Время] ON [dbo].[СКУД_Событие]
(
	[Время_События] DESC
)
INCLUDE([Устройство_ID],[Карта_ID],[Тип_События],[Температура]) 
WHERE ([Время_События]>'2025-01-01')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_СКУД_Событие_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Событие_Время] ON [dbo].[СКУД_Событие]
(
	[Время_События] DESC
)
INCLUDE([Устройство_ID],[Карта_ID],[Тип_События],[Результат]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_СКУД_Событие_Карта]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Событие_Карта] ON [dbo].[СКУД_Событие]
(
	[Карта_ID] ASC,
	[Время_События] DESC
)
INCLUDE([Устройство_ID],[Тип_События],[Направление]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Событие_Карта_Время_Тип]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Событие_Карта_Время_Тип] ON [dbo].[СКУД_Событие]
(
	[Карта_ID] ASC,
	[Время_События] DESC,
	[Тип_События] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Событие_Тип_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Событие_Тип_Время] ON [dbo].[СКУД_Событие]
(
	[Тип_События] ASC,
	[Время_События] DESC
)
WHERE ([Тип_События] IN (N'Вход_разрешен', N'Вход_запрещен', N'Неизвестная_карта'))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_СКУД_Событие_Устройство]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Событие_Устройство] ON [dbo].[СКУД_Событие]
(
	[Устройство_ID] ASC,
	[Время_События] DESC
)
INCLUDE([Карта_ID],[Тип_События],[Результат]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__СКУД_Уст__81B07D88EA160A31]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[СКУД_Устройство] ADD UNIQUE NONCLUSTERED 
(
	[Серийный_Номер] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_СКУД_Устройство_Местоположение_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_СКУД_Устройство_Местоположение_Статус] ON [dbo].[СКУД_Устройство]
(
	[Местоположение] ASC,
	[Статус] ASC
)
INCLUDE([Устройство_ID],[Тип],[IP_Адрес]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Специальность_Название]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Специальность] ADD  CONSTRAINT [UQ_Специальность_Название] UNIQUE NONCLUSTERED 
(
	[Название] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Статистика]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Статистика_Системы] ADD  CONSTRAINT [UQ_Статистика] UNIQUE NONCLUSTERED 
(
	[Дата_Статистики] ASC,
	[Тип_Статистики] ASC,
	[Подтип_Статистики] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Статистика_Системы_Дата_Тип]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Статистика_Системы_Дата_Тип] ON [dbo].[Статистика_Системы]
(
	[Дата_Статистики] DESC,
	[Тип_Статистики] ASC
)
INCLUDE([Подтип_Статистики],[Значение_1],[Значение_2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Статистика_Системы_Тип_Дата]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Статистика_Системы_Тип_Дата] ON [dbo].[Статистика_Системы]
(
	[Тип_Статистики] ASC,
	[Дата_Статистики] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Студент__7889B59406307817]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Студент] ADD UNIQUE NONCLUSTERED 
(
	[Пользователь_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Студент_Группа]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Студент_Группа] ON [dbo].[Студент]
(
	[Группа_ID] ASC
)
INCLUDE([Студент_ID],[ФИО],[Пользователь_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Студент_Группа_ДатаПоступления]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Студент_Группа_ДатаПоступления] ON [dbo].[Студент]
(
	[Группа_ID] ASC,
	[Дата_Поступления] DESC
)
INCLUDE([ФИО],[Дата_Рождения]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Студент_ФИО]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Студент_ФИО] ON [dbo].[Студент]
(
	[ФИО] ASC
)
INCLUDE([Группа_ID],[Дата_Поступления],[Пользователь_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Уведомления_Пользователь_Прочитано]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Уведомления_Пользователь_Прочитано] ON [dbo].[Уведомления]
(
	[Пользователь_ID] ASC,
	[Прочитано] ASC,
	[Время_Создания] DESC
)
INCLUDE([Тип],[Заголовок],[Ссылка]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Уведомления_СрокДействия]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Уведомления_СрокДействия] ON [dbo].[Уведомления]
(
	[Срок_Действия] ASC
)
WHERE ([Срок_Действия] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Уведомления_Тип_Время]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Уведомления_Тип_Время] ON [dbo].[Уведомления]
(
	[Тип] ASC,
	[Время_Создания] DESC
)
INCLUDE([Срок_Действия],[Прочитано],[Заголовок],[Пользователь_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Учебная___38DA803560219961]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Учебная_Группа] ADD UNIQUE NONCLUSTERED 
(
	[Название] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Учебная_Группа_Год_Статус]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Учебная_Группа_Год_Статус] ON [dbo].[Учебная_Группа]
(
	[Год_Поступления] ASC,
	[Статус] ASC
)
INCLUDE([Группа_ID],[Название],[Куратор_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Учебная_Группа_Название]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Учебная_Группа_Название] ON [dbo].[Учебная_Группа]
(
	[Название] ASC
)
INCLUDE([Группа_ID],[Год_Поступления],[Статус]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Учебная_Группа_Специальность]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Учебная_Группа_Специальность] ON [dbo].[Учебная_Группа]
(
	[Специальность_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Факультет_Название]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Факультет] ADD  CONSTRAINT [UQ_Факультет_Название] UNIQUE NONCLUSTERED 
(
	[Название] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Шаблоны___7E614E2C0BECD8A3]    Script Date: 22-Apr-26 1:48:06 ******/
ALTER TABLE [dbo].[Шаблоны_Отчетов] ADD UNIQUE NONCLUSTERED 
(
	[Код_Шаблона] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Шаблоны_Отчетов_КтоСоздал]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Шаблоны_Отчетов_КтоСоздал] ON [dbo].[Шаблоны_Отчетов]
(
	[Кто_Создал] ASC,
	[Активен] ASC
)
INCLUDE([Название],[Тип],[Общедоступный]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Шаблоны_Отчетов_Тип_Активен]    Script Date: 22-Apr-26 1:48:06 ******/
CREATE NONCLUSTERED INDEX [IX_Шаблоны_Отчетов_Тип_Активен] ON [dbo].[Шаблоны_Отчетов]
(
	[Тип] ASC,
	[Активен] ASC
)
INCLUDE([Шаблон_ID],[Название],[Код_Шаблона],[Формат]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QR_Сессия]  WITH CHECK ADD  CONSTRAINT [FK_QR_Сессия_Занятие] FOREIGN KEY([Занятие_ID])
REFERENCES [dbo].[Занятие] ([Занятие_ID])
GO
ALTER TABLE [dbo].[QR_Сессия] CHECK CONSTRAINT [FK_QR_Сессия_Занятие]
GO
ALTER TABLE [dbo].[QR_Сессия]  WITH CHECK ADD  CONSTRAINT [FK_QR_Сессия_КтоСоздал] FOREIGN KEY([Кто_Создал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[QR_Сессия] CHECK CONSTRAINT [FK_QR_Сессия_КтоСоздал]
GO
ALTER TABLE [dbo].[QR_Сканирование]  WITH CHECK ADD  CONSTRAINT [FK_QR_Сканирование_Сессия] FOREIGN KEY([QR_Сессия_ID])
REFERENCES [dbo].[QR_Сессия] ([QR_Сессия_ID])
GO
ALTER TABLE [dbo].[QR_Сканирование] CHECK CONSTRAINT [FK_QR_Сканирование_Сессия]
GO
ALTER TABLE [dbo].[QR_Сканирование]  WITH CHECK ADD  CONSTRAINT [FK_QR_Сканирование_Студент] FOREIGN KEY([Студент_ID])
REFERENCES [dbo].[Студент] ([Студент_ID])
GO
ALTER TABLE [dbo].[QR_Сканирование] CHECK CONSTRAINT [FK_QR_Сканирование_Студент]
GO
ALTER TABLE [dbo].[Аудитория]  WITH CHECK ADD  CONSTRAINT [FK_Аудитория_Корпус] FOREIGN KEY([Корпус_ID])
REFERENCES [dbo].[Корпус] ([Корпус_ID])
GO
ALTER TABLE [dbo].[Аудитория] CHECK CONSTRAINT [FK_Аудитория_Корпус]
GO
ALTER TABLE [dbo].[Дисциплина]  WITH CHECK ADD  CONSTRAINT [FK_Дисциплина_Преподаватель] FOREIGN KEY([Преподаватель_ID])
REFERENCES [dbo].[Преподаватель] ([Преподаватель_ID])
GO
ALTER TABLE [dbo].[Дисциплина] CHECK CONSTRAINT [FK_Дисциплина_Преподаватель]
GO
ALTER TABLE [dbo].[Журнал_Импорта_CSV]  WITH CHECK ADD  CONSTRAINT [FK_Журнал_Импорта_CSV_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Журнал_Импорта_CSV] CHECK CONSTRAINT [FK_Журнал_Импорта_CSV_Пользователь]
GO
ALTER TABLE [dbo].[Журнал_Экспорта_CSV]  WITH CHECK ADD  CONSTRAINT [FK_Экспорт_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Журнал_Экспорта_CSV] CHECK CONSTRAINT [FK_Экспорт_Пользователь]
GO
ALTER TABLE [dbo].[Восстановление_Пароля]  WITH CHECK ADD  CONSTRAINT [FK_Восстановление_Пароля_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Восстановление_Пароля] CHECK CONSTRAINT [FK_Восстановление_Пароля_Пользователь]
GO
ALTER TABLE [dbo].[Занятие]  WITH CHECK ADD  CONSTRAINT [FK_Занятие_КтоСоздал] FOREIGN KEY([Кто_Создал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Занятие] CHECK CONSTRAINT [FK_Занятие_КтоСоздал]
GO
ALTER TABLE [dbo].[Занятие]  WITH CHECK ADD  CONSTRAINT [FK_Занятие_Расписание] FOREIGN KEY([Расписание_ID])
REFERENCES [dbo].[Расписание] ([Расписание_ID])
GO
ALTER TABLE [dbo].[Занятие] CHECK CONSTRAINT [FK_Занятие_Расписание]
GO
ALTER TABLE [dbo].[Лог_Действий]  WITH CHECK ADD  CONSTRAINT [FK_Лог_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Лог_Действий] CHECK CONSTRAINT [FK_Лог_Пользователь]
GO
ALTER TABLE [dbo].[Настройки_Системы]  WITH CHECK ADD  CONSTRAINT [FK_Настройки_Пользователь] FOREIGN KEY([Кто_Изменил])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Настройки_Системы] CHECK CONSTRAINT [FK_Настройки_Пользователь]
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия]  WITH CHECK ADD  CONSTRAINT [FK_Обоснования_Занятие] FOREIGN KEY([Занятие_ID])
REFERENCES [dbo].[Занятие] ([Занятие_ID])
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия] CHECK CONSTRAINT [FK_Обоснования_Занятие]
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия]  WITH CHECK ADD  CONSTRAINT [FK_Обоснования_КтоРассмотрел] FOREIGN KEY([Кто_Рассмотрел])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия] CHECK CONSTRAINT [FK_Обоснования_КтоРассмотрел]
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия]  WITH CHECK ADD  CONSTRAINT [FK_Обоснования_Студент] FOREIGN KEY([Студент_ID])
REFERENCES [dbo].[Студент] ([Студент_ID])
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия] CHECK CONSTRAINT [FK_Обоснования_Студент]
GO
ALTER TABLE [dbo].[Ошибки_Системы]  WITH CHECK ADD  CONSTRAINT [FK_Ошибки_Пользователь_Возникла] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Ошибки_Системы] CHECK CONSTRAINT [FK_Ошибки_Пользователь_Возникла]
GO
ALTER TABLE [dbo].[Ошибки_Системы]  WITH CHECK ADD  CONSTRAINT [FK_Ошибки_Пользователь_Исправил] FOREIGN KEY([Кто_Исправил])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Ошибки_Системы] CHECK CONSTRAINT [FK_Ошибки_Пользователь_Исправил]
GO
ALTER TABLE [dbo].[Пользователь]  WITH CHECK ADD  CONSTRAINT [FK_Пользователь_Роль] FOREIGN KEY([Роль_ID])
REFERENCES [dbo].[Роль] ([Роль_ID])
GO
ALTER TABLE [dbo].[Пользователь] CHECK CONSTRAINT [FK_Пользователь_Роль]
GO
ALTER TABLE [dbo].[Посещаемость]  WITH CHECK ADD  CONSTRAINT [FK_Посещаемость_Занятие] FOREIGN KEY([Занятие_ID])
REFERENCES [dbo].[Занятие] ([Занятие_ID])
GO
ALTER TABLE [dbo].[Посещаемость] CHECK CONSTRAINT [FK_Посещаемость_Занятие]
GO
ALTER TABLE [dbo].[Посещаемость]  WITH CHECK ADD  CONSTRAINT [FK_Посещаемость_КтоОтметил] FOREIGN KEY([Кто_Отметил])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Посещаемость] CHECK CONSTRAINT [FK_Посещаемость_КтоОтметил]
GO
ALTER TABLE [dbo].[Посещаемость]  WITH CHECK ADD  CONSTRAINT [FK_Посещаемость_Студент] FOREIGN KEY([Студент_ID])
REFERENCES [dbo].[Студент] ([Студент_ID])
GO
ALTER TABLE [dbo].[Посещаемость] CHECK CONSTRAINT [FK_Посещаемость_Студент]
GO
ALTER TABLE [dbo].[Преподаватель]  WITH CHECK ADD  CONSTRAINT [FK_Преподаватель_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Преподаватель] CHECK CONSTRAINT [FK_Преподаватель_Пользователь]
GO
ALTER TABLE [dbo].[Разрешения_Ролей]  WITH CHECK ADD  CONSTRAINT [FK_Разрешения_Обновил] FOREIGN KEY([Кто_Обновил])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Разрешения_Ролей] CHECK CONSTRAINT [FK_Разрешения_Обновил]
GO
ALTER TABLE [dbo].[Разрешения_Ролей]  WITH CHECK ADD  CONSTRAINT [FK_Разрешения_Роль] FOREIGN KEY([Роль_ID])
REFERENCES [dbo].[Роль] ([Роль_ID])
GO
ALTER TABLE [dbo].[Разрешения_Ролей] CHECK CONSTRAINT [FK_Разрешения_Роль]
GO
ALTER TABLE [dbo].[Разрешения_Ролей]  WITH CHECK ADD  CONSTRAINT [FK_Разрешения_Создал] FOREIGN KEY([Кто_Создал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Разрешения_Ролей] CHECK CONSTRAINT [FK_Разрешения_Создал]
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD  CONSTRAINT [FK_Расписание_Аудитория] FOREIGN KEY([Аудитория_ID])
REFERENCES [dbo].[Аудитория] ([Аудитория_ID])
GO
ALTER TABLE [dbo].[Расписание] CHECK CONSTRAINT [FK_Расписание_Аудитория]
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD  CONSTRAINT [FK_Расписание_Группа] FOREIGN KEY([Группа_ID])
REFERENCES [dbo].[Учебная_Группа] ([Группа_ID])
GO
ALTER TABLE [dbo].[Расписание] CHECK CONSTRAINT [FK_Расписание_Группа]
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD  CONSTRAINT [FK_Расписание_Дисциплина] FOREIGN KEY([Дисциплина_ID])
REFERENCES [dbo].[Дисциплина] ([Дисциплина_ID])
GO
ALTER TABLE [dbo].[Расписание] CHECK CONSTRAINT [FK_Расписание_Дисциплина]
GO
ALTER TABLE [dbo].[Резервные_Копии]  WITH CHECK ADD  CONSTRAINT [FK_РезервныеКопии_Пользователь] FOREIGN KEY([Кто_Создал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Резервные_Копии] CHECK CONSTRAINT [FK_РезервныеКопии_Пользователь]
GO
ALTER TABLE [dbo].[Сессия_Пользователя]  WITH CHECK ADD  CONSTRAINT [FK_Сессия_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Сессия_Пользователя] CHECK CONSTRAINT [FK_Сессия_Пользователь]
GO
ALTER TABLE [dbo].[Система_Интеграция]  WITH CHECK ADD  CONSTRAINT [FK_Интеграция_Пользователь] FOREIGN KEY([Кто_Настроил])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Система_Интеграция] CHECK CONSTRAINT [FK_Интеграция_Пользователь]
GO
ALTER TABLE [dbo].[СКУД_Карта]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Карта_КтоВыдал] FOREIGN KEY([Кто_Выдал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[СКУД_Карта] CHECK CONSTRAINT [FK_СКУД_Карта_КтоВыдал]
GO
ALTER TABLE [dbo].[СКУД_Карта]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Карта_Студент] FOREIGN KEY([Студент_ID])
REFERENCES [dbo].[Студент] ([Студент_ID])
GO
ALTER TABLE [dbo].[СКУД_Карта] CHECK CONSTRAINT [FK_СКУД_Карта_Студент]
GO
ALTER TABLE [dbo].[СКУД_Событие]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Событие_Карта] FOREIGN KEY([Карта_ID])
REFERENCES [dbo].[СКУД_Карта] ([Карта_ID])
GO
ALTER TABLE [dbo].[СКУД_Событие] CHECK CONSTRAINT [FK_СКУД_Событие_Карта]
GO
ALTER TABLE [dbo].[СКУД_Событие]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Событие_Устройство] FOREIGN KEY([Устройство_ID])
REFERENCES [dbo].[СКУД_Устройство] ([Устройство_ID])
GO
ALTER TABLE [dbo].[СКУД_Событие] CHECK CONSTRAINT [FK_СКУД_Событие_Устройство]
GO
ALTER TABLE [dbo].[СКУД_Устройство]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Устройство_Аудитория] FOREIGN KEY([Аудитория_ID])
REFERENCES [dbo].[Аудитория] ([Аудитория_ID])
GO
ALTER TABLE [dbo].[СКУД_Устройство] CHECK CONSTRAINT [FK_СКУД_Устройство_Аудитория]
GO
ALTER TABLE [dbo].[СКУД_Устройство]  WITH CHECK ADD  CONSTRAINT [FK_СКУД_Устройство_Ответственный] FOREIGN KEY([Ответственный_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[СКУД_Устройство] CHECK CONSTRAINT [FK_СКУД_Устройство_Ответственный]
GO
ALTER TABLE [dbo].[Специальность]  WITH CHECK ADD  CONSTRAINT [FK_Специальность_Факультет] FOREIGN KEY([Факультет_ID])
REFERENCES [dbo].[Факультет] ([Факультет_ID])
GO
ALTER TABLE [dbo].[Специальность] CHECK CONSTRAINT [FK_Специальность_Факультет]
GO
ALTER TABLE [dbo].[Студент]  WITH CHECK ADD  CONSTRAINT [FK_Студент_Группа] FOREIGN KEY([Группа_ID])
REFERENCES [dbo].[Учебная_Группа] ([Группа_ID])
GO
ALTER TABLE [dbo].[Студент] CHECK CONSTRAINT [FK_Студент_Группа]
GO
ALTER TABLE [dbo].[Студент]  WITH CHECK ADD  CONSTRAINT [FK_Студент_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Студент] CHECK CONSTRAINT [FK_Студент_Пользователь]
GO
ALTER TABLE [dbo].[Уведомления]  WITH CHECK ADD  CONSTRAINT [FK_Уведомления_Пользователь] FOREIGN KEY([Пользователь_ID])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Уведомления] CHECK CONSTRAINT [FK_Уведомления_Пользователь]
GO
ALTER TABLE [dbo].[Учебная_Группа]  WITH CHECK ADD  CONSTRAINT [FK_Группа_Куратор] FOREIGN KEY([Куратор_ID])
REFERENCES [dbo].[Преподаватель] ([Преподаватель_ID])
GO
ALTER TABLE [dbo].[Учебная_Группа] CHECK CONSTRAINT [FK_Группа_Куратор]
GO
ALTER TABLE [dbo].[Учебная_Группа]  WITH CHECK ADD  CONSTRAINT [FK_Учебная_Группа_Специальность] FOREIGN KEY([Специальность_ID])
REFERENCES [dbo].[Специальность] ([Специальность_ID])
GO
ALTER TABLE [dbo].[Учебная_Группа] CHECK CONSTRAINT [FK_Учебная_Группа_Специальность]
GO
ALTER TABLE [dbo].[Шаблоны_Отчетов]  WITH CHECK ADD  CONSTRAINT [FK_Шаблоны_Пользователь] FOREIGN KEY([Кто_Создал])
REFERENCES [dbo].[Пользователь] ([Пользователь_ID])
GO
ALTER TABLE [dbo].[Шаблоны_Отчетов] CHECK CONSTRAINT [FK_Шаблоны_Пользователь]
GO
ALTER TABLE [dbo].[QR_Сессия]  WITH CHECK ADD  CONSTRAINT [CHK_QR_Время_Действия] CHECK  (([Время_Действия_Конец]>[Время_Действия_Начало]))
GO
ALTER TABLE [dbo].[QR_Сессия] CHECK CONSTRAINT [CHK_QR_Время_Действия]
GO
ALTER TABLE [dbo].[QR_Сессия]  WITH CHECK ADD CHECK  (([Статус]=N'Отменен' OR [Статус]=N'Завершен' OR [Статус]=N'Активен'))
GO
ALTER TABLE [dbo].[QR_Сканирование]  WITH CHECK ADD CHECK  (([Статус]=N'Ошибка' OR [Статус]=N'Повторное_сканирование' OR [Статус]=N'Вне_времени' OR [Статус]=N'Недействительный_QR' OR [Статус]=N'Успешно'))
GO
ALTER TABLE [dbo].[Аудитория]  WITH CHECK ADD  CONSTRAINT [CHK_Аудитория_Статус] CHECK  (([Статус]=N'закрыта' OR [Статус]=N'ремонт' OR [Статус]=N'активна'))
GO
ALTER TABLE [dbo].[Аудитория] CHECK CONSTRAINT [CHK_Аудитория_Статус]
GO
ALTER TABLE [dbo].[Аудитория]  WITH CHECK ADD  CONSTRAINT [CHK_Аудитория_Тип] CHECK  (([Тип]=N'семинарская' OR [Тип]=N'компьютерная' OR [Тип]=N'спортзал' OR [Тип]=N'лаборатория' OR [Тип]=N'лекционная'))
GO
ALTER TABLE [dbo].[Аудитория] CHECK CONSTRAINT [CHK_Аудитория_Тип]
GO
ALTER TABLE [dbo].[Дисциплина]  WITH CHECK ADD CHECK  (([Статус]=N'Архивная' OR [Статус]=N'Неактивна' OR [Статус]=N'Активна'))
GO
ALTER TABLE [dbo].[Журнал_Импорта_CSV]  WITH CHECK ADD  CONSTRAINT [CHK_Журнал_Импорта_CSV_Статус] CHECK  (([Статус]=N'Частично' OR [Статус]=N'Ошибка' OR [Статус]=N'Успешно'))
GO
ALTER TABLE [dbo].[Журнал_Импорта_CSV] CHECK CONSTRAINT [CHK_Журнал_Импорта_CSV_Статус]
GO
ALTER TABLE [dbo].[Журнал_Экспорта_CSV]  WITH CHECK ADD CHECK  (([Статус]=N'Ошибка' OR [Статус]=N'Успешно'))
GO
ALTER TABLE [dbo].[Занятие]  WITH CHECK ADD CHECK  (([Статус]=N'Перенесено' OR [Статус]=N'Отменено' OR [Статус]=N'Проведено' OR [Статус]=N'Запланировано'))
GO
ALTER TABLE [dbo].[Лог_Действий]  WITH CHECK ADD CHECK  (([Статус]=N'Частично' OR [Статус]=N'Предупреждение' OR [Статус]=N'Ошибка' OR [Статус]=N'Успешно'))
GO
ALTER TABLE [dbo].[Лог_Действий]  WITH CHECK ADD CHECK  (([Уровень_Лога]=N'Критическая' OR [Уровень_Лога]=N'Ошибка' OR [Уровень_Лога]=N'Предупреждение' OR [Уровень_Лога]=N'Информация'))
GO
ALTER TABLE [dbo].[Настройки_Системы]  WITH CHECK ADD CHECK  (([Тип]=N'XML' OR [Тип]=N'JSON' OR [Тип]=N'Булево' OR [Тип]=N'Дата' OR [Тип]=N'Число' OR [Тип]=N'Строка'))
GO
ALTER TABLE [dbo].[Обоснования_Отсутствия]  WITH CHECK ADD CHECK  (([Статус]=N'Отклонено' OR [Статус]=N'Одобрено' OR [Статус]=N'На рассмотрении'))
GO
ALTER TABLE [dbo].[Ошибки_Системы]  WITH CHECK ADD CHECK  (([Статус]=N'Повторяется' OR [Статус]=N'Игнорируется' OR [Статус]=N'Исправлена' OR [Статус]=N'В обработке' OR [Статус]=N'Новая'))
GO
ALTER TABLE [dbo].[Ошибки_Системы]  WITH CHECK ADD CHECK  (([Уровень_Ошибки]=N'Критический' OR [Уровень_Ошибки]=N'Высокий' OR [Уровень_Ошибки]=N'Средний' OR [Уровень_Ошибки]=N'Низкий'))
GO
ALTER TABLE [dbo].[Посещаемость]  WITH CHECK ADD CHECK  (([Статус]=N'Уважительная причина' OR [Статус]=N'Опоздал' OR [Статус]=N'Отсутствовал' OR [Статус]=N'Присутствовал'))
GO
ALTER TABLE [dbo].[Посещаемость]  WITH CHECK ADD CHECK  (([Тип_Отметки]=N'Авто' OR [Тип_Отметки]=N'СКУД' OR [Тип_Отметки]=N'QR' OR [Тип_Отметки]=N'Ручная'))
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD CHECK  (([День_Недели]>=(1) AND [День_Недели]<=(7)))
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD  CONSTRAINT [CHK_Расписание_ЧислЗнамен] CHECK  (([числ/знамен] IS NULL OR [числ/знамен]=N'каждая' OR [числ/знамен]=N'знаменатель' OR [числ/знамен]=N'числитель'))
GO
ALTER TABLE [dbo].[Расписание] CHECK CONSTRAINT [CHK_Расписание_ЧислЗнамен]
GO
ALTER TABLE [dbo].[Расписание]  WITH CHECK ADD CHECK  (([Тип_Занятия]=N'Семинар' OR [Тип_Занятия]=N'Лабораторная' OR [Тип_Занятия]=N'Практика' OR [Тип_Занятия]=N'Лекция'))
GO
ALTER TABLE [dbo].[Резервные_Копии]  WITH CHECK ADD CHECK  (([Статус]=N'Частично' OR [Статус]=N'В процессе' OR [Статус]=N'Ошибка' OR [Статус]=N'Успешно'))
GO
ALTER TABLE [dbo].[Резервные_Копии]  WITH CHECK ADD CHECK  (([Тип_Копии]=N'Данные' OR [Тип_Копии]=N'Транзакционная' OR [Тип_Копии]=N'Дифференциальная' OR [Тип_Копии]=N'Полная'))
GO
ALTER TABLE [dbo].[Система_Интеграция]  WITH CHECK ADD CHECK  (([Статус]=N'Тестирование' OR [Статус]=N'Ошибка' OR [Статус]=N'Неактивна' OR [Статус]=N'Активна'))
GO
ALTER TABLE [dbo].[Система_Интеграция]  WITH CHECK ADD CHECK  (([Тип]=N'Другое' OR [Тип]=N'Портал' OR [Тип]=N'Кампус' OR [Тип]=N'Электронный_журнал' OR [Тип]=N'1С' OR [Тип]=N'СКУД'))
GO
ALTER TABLE [dbo].[СКУД_Карта]  WITH CHECK ADD  CONSTRAINT [CHK_СКУД_Дата_Истечения] CHECK  (([Дата_Истечения]>[Дата_Выдачи]))
GO
ALTER TABLE [dbo].[СКУД_Карта] CHECK CONSTRAINT [CHK_СКУД_Дата_Истечения]
GO
ALTER TABLE [dbo].[СКУД_Карта]  WITH CHECK ADD CHECK  (([Статус]=N'Уничтожена' OR [Статус]=N'Истекла' OR [Статус]=N'Утеряна' OR [Статус]=N'Заблокирована' OR [Статус]=N'Активна'))
GO
ALTER TABLE [dbo].[СКУД_Карта]  WITH CHECK ADD CHECK  (([Тип_Карты]=N'Служебная' OR [Тип_Карты]=N'Гостевая' OR [Тип_Карты]=N'Преподавательская' OR [Тип_Карты]=N'Студенческая'))
GO
ALTER TABLE [dbo].[СКУД_Событие]  WITH CHECK ADD CHECK  (([Направление]=N'Неизвестно' OR [Направление]=N'Выход' OR [Направление]=N'Вход'))
GO
ALTER TABLE [dbo].[СКУД_Событие]  WITH CHECK ADD CHECK  (([Тип_События]=N'Тест_устройства' OR [Тип_События]=N'Нарушение_доступа' OR [Тип_События]=N'Ошибка_чтения' OR [Тип_События]=N'Неизвестная_карта' OR [Тип_События]=N'Выход_запрещен' OR [Тип_События]=N'Выход_разрешен' OR [Тип_События]=N'Вход_запрещен' OR [Тип_События]=N'Вход_разрешен'))
GO
ALTER TABLE [dbo].[СКУД_Устройство]  WITH CHECK ADD CHECK  (([Статус]=N'Выключен' OR [Статус]=N'На_ремонте' OR [Статус]=N'Неактивен' OR [Статус]=N'Активен'))
GO
ALTER TABLE [dbo].[СКУД_Устройство]  WITH CHECK ADD CHECK  (([Тип]=N'Камера' OR [Тип]=N'Считыватель' OR [Тип]=N'Шлагбаум' OR [Тип]=N'Дверь' OR [Тип]=N'Турникет'))
GO
ALTER TABLE [dbo].[Статистика_Системы]  WITH CHECK ADD CHECK  (([Тип_Статистики]=N'Активность' OR [Тип_Статистики]=N'Ошибки' OR [Тип_Статистики]=N'Производительность' OR [Тип_Статистики]=N'Общая' OR [Тип_Статистики]=N'QR' OR [Тип_Статистики]=N'СКУД' OR [Тип_Статистики]=N'Пользователи' OR [Тип_Статистики]=N'Посещаемость'))
GO
ALTER TABLE [dbo].[Студент]  WITH CHECK ADD CHECK  (([Пол]=N'Женский' OR [Пол]=N'Мужской'))
GO
ALTER TABLE [dbo].[Уведомления]  WITH CHECK ADD CHECK  (([Тип]=N'Ошибка' OR [Тип]=N'Предупреждение' OR [Тип]=N'Информация' OR [Тип]=N'Важное' OR [Тип]=N'Системное'))
GO
ALTER TABLE [dbo].[Учебная_Группа]  WITH CHECK ADD CHECK  (([Статус]=N'Расформирована' OR [Статус]=N'Выпущена' OR [Статус]=N'Неактивна' OR [Статус]=N'Активна'))
GO
ALTER TABLE [dbo].[Шаблоны_Отчетов]  WITH CHECK ADD CHECK  (([Формат]=N'XML' OR [Формат]=N'JSON' OR [Формат]=N'Excel' OR [Формат]=N'PDF' OR [Формат]=N'CSV' OR [Формат]=N'HTML'))
GO
ALTER TABLE [dbo].[Шаблоны_Отчетов]  WITH CHECK ADD CHECK  (([Тип]=N'Административный' OR [Тип]=N'Кастомный' OR [Тип]=N'Общий' OR [Тип]=N'Преподаватель' OR [Тип]=N'Студент' OR [Тип]=N'Группа'))
GO
/****** Object:  StoredProcedure [dbo].[Авторизация]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Авторизация]
    @Логин NVARCHAR(50),
    @Пароль NVARCHAR(255),
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ПользовательID INT, @Активен BIT, @Соль NVARCHAR(32), @ХэшБД NVARCHAR(64), @ХэшВвода NVARCHAR(64),
            @СессияID UNIQUEIDENTIFIER, @Токен NVARCHAR(500), @СлучайнаяЧасть NVARCHAR(100), @ВремяЧасть NVARCHAR(30), @ДанныеДляХэша NVARCHAR(300);
    BEGIN TRY
        SELECT @ПользовательID = Пользователь_ID, @Активен = Активен, @Соль = Соль, @ХэшБД = Хэш_Пароля
        FROM Пользователь WHERE Логин = @Логин;
        IF @ПользовательID IS NULL OR @Активен = 0
        BEGIN
            INSERT INTO Лог_Действий (Действие, Статус, Параметры, IP_Адрес, Устройство, Браузер)
            VALUES (N'Неудачная попытка входа', N'Ошибка', N'Логин: ' + ISNULL(@Логин, N'NULL'), @IP_Адрес, @Устройство, @Браузер);
            RAISERROR(N'Неверный логин или пароль', 16, 1);
            RETURN;
        END
        SET @ХэшВвода = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Пароль + @Соль), 2);
        IF @ХэшВвода != @ХэшБД
        BEGIN
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры, IP_Адрес, Устройство, Браузер)
            VALUES (@ПользовательID, N'Неудачная попытка входа', N'Ошибка', N'Неверный пароль', @IP_Адрес, @Устройство, @Браузер);
            RAISERROR(N'Неверный логин или пароль', 16, 1);
            RETURN;
        END
        UPDATE Пользователь SET Последний_Вход = GETDATE() WHERE Пользователь_ID = @ПользовательID;
        SET @СессияID = NEWID();
        SET @СлучайнаяЧасть = CAST(NEWID() AS NVARCHAR(36));
        SET @ВремяЧасть = REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(30), GETDATE(), 120), '-', ''), ':', ''), ' ', '');
        SET @ДанныеДляХэша = CAST(@ПользовательID AS NVARCHAR(20)) + '_' + @СлучайнаяЧасть + '_' + @ВремяЧасть;
        SET @Токен = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @ДанныеДляХэша), 2);
        INSERT INTO Сессия_Пользователя (Сессия_ID, Пользователь_ID, Токен, IP_Адрес, Устройство, Браузер, Время_Истечения)
        VALUES (@СессияID, @ПользовательID, @Токен, @IP_Адрес, @Устройство, @Браузер, DATEADD(HOUR, 8, GETDATE()));
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры, IP_Адрес, Устройство, Браузер)
        VALUES (@ПользовательID, N'Успешный вход в систему', N'Успешно', N'Логин: ' + @Логин, @IP_Адрес, @Устройство, @Браузер);
        SELECT u.Пользователь_ID, u.Логин, u.Email, u.Телефон, u.Аватар_URL, u.Активен, u.Дата_Создания, u.Последний_Вход,
               r.Название AS Роль, r.Уровень_Доступа, s.Студент_ID, s.ФИО AS ФИО_Студента, s.Группа_ID,
               p.Преподаватель_ID, p.ФИО AS ФИО_Преподавателя, @Токен AS Токен_Сессии, @СессияID AS ID_Сессии
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        LEFT JOIN Студент s ON u.Пользователь_ID = s.Пользователь_ID
        LEFT JOIN Преподаватель p ON u.Пользователь_ID = p.Пользователь_ID
        WHERE u.Пользователь_ID = @ПользовательID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        INSERT INTO Лог_Действий (Действие, Статус, Параметры, IP_Адрес, Устройство, Браузер)
        VALUES (N'Ошибка авторизации', N'Ошибка', LEFT(@ErrorMessage, 400), @IP_Адрес, @Устройство, @Браузер);
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[ВосстановитьПароль]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ВосстановитьПароль]
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
/****** Object:  StoredProcedure [dbo].[ВыполнитьШаблонОтчета]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 58. ВыполнитьШаблонОтчета (возвращает SQL для выполнения)
CREATE PROCEDURE [dbo].[ВыполнитьШаблонОтчета]
    @Шаблон_ID INT,
    @ПараметрыJSON NVARCHAR(MAX) = NULL,
    @Пользователь_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL_Запрос NVARCHAR(MAX);
    DECLARE @Параметры NVARCHAR(MAX);
    DECLARE @Активен BIT;
    DECLARE @Общедоступный BIT;
    DECLARE @КтоСоздал INT;
    
    SELECT 
        @SQL_Запрос = SQL_Запрос,
        @Параметры = Параметры,
        @Активен = Активен,
        @Общедоступный = Общедоступный,
        @КтоСоздал = Кто_Создал
    FROM Шаблоны_Отчетов
    WHERE Шаблон_ID = @Шаблон_ID;
    
    IF @SQL_Запрос IS NULL
        RAISERROR(N'Шаблон не найден', 16, 1);
    
    IF @Активен = 0
        RAISERROR(N'Шаблон не активен', 16, 1);
    
    -- Проверка прав доступа
    IF @Общедоступный = 0 AND @КтоСоздал != @Пользователь_ID
    BEGIN
        DECLARE @УровеньДоступа INT;
        SELECT @УровеньДоступа = r.Уровень_Доступа
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        WHERE u.Пользователь_ID = @Пользователь_ID AND u.Активен = 1;
        
        IF @УровеньДоступа < 80
            RAISERROR(N'Доступ к этому шаблону запрещен', 16, 1);
    END
    
    -- В реальной системе здесь нужно безопасно выполнить запрос, например, через sp_executesql
    -- Возвращаем запрос для выполнения на стороне приложения
    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
    VALUES (@Пользователь_ID, N'Выполнение шаблона отчета', N'Шаблоны_Отчетов', @Шаблон_ID, N'Успешно', 
            @ПараметрыJSON);
    
    SELECT @SQL_Запрос AS SQL_Запрос, @Параметры AS ПараметрыШаблона;
END;
GO
/****** Object:  StoredProcedure [dbo].[ДеактивироватьПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 10. ДеактивироватьПользователя
CREATE PROCEDURE [dbo].[ДеактивироватьПользователя]
    @Пользователь_ID INT,
    @КтоДеактивировал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Пользователь 
        SET Активен = 0
        WHERE Пользователь_ID = @Пользователь_ID;
        
        EXEC ЗавершитьВсеСессииПользователя @Пользователь_ID, N'Деактивация учётной записи';
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоДеактивировал, N'Деактивация пользователя', N'Пользователь', @Пользователь_ID, N'Успешно');
        
        SELECT 1 AS Деактивирован, N'Пользователь деактивирован' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ДиагностикаАвторизации]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Диагностика авторизации
-- =============================================
CREATE PROCEDURE [dbo].[ДиагностикаАвторизации]
    @Логин NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Логин IS NOT NULL
    BEGIN
        SELECT 
            Пользователь_ID,
            Логин,
            LEN(Логин) AS ДлинаЛогина,
            Активен,
            Роль_ID
        FROM Пользователь 
        WHERE Логин = @Логин;
    END
    
    -- Последние попытки входа
    SELECT TOP 20
        Время_Действия,
        Действие,
        Параметры,
        Статус,
        IP_Адрес
    FROM Лог_Действий 
    WHERE Действие LIKE N'%вход%' OR Действие LIKE N'%авториз%'
    ORDER BY Время_Действия DESC;
    
    -- Активные сессии
    SELECT 
        COUNT(*) AS АктивныеСессии,
        MIN(Время_Создания) AS СамаяРанняяСессия,
        MAX(Время_Создания) AS СамаяПоздняяСессия
    FROM Сессия_Пользователя
    WHERE Активна = 1 AND Время_Истечения > GETDATE();
END;
GO
/****** Object:  StoredProcedure [dbo].[ЕжедневноеОбслуживаниеСистемы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ежедневное обслуживание (процедура)
CREATE PROCEDURE [dbo].[ЕжедневноеОбслуживаниеСистемы]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @НачалоВыполнения DATETIME = GETDATE();
    
    BEGIN TRY
        -- 1. Сбор статистики за вчера
        DECLARE @Вчера DATE = DATEADD(DAY, -1, GETDATE());
        EXEC СобратьСтатистикуСистемы @Дата = @Вчера;
        
        -- 2. Создание занятий на следующую неделю
        DECLARE @НачалоНедели DATE = GETDATE();
        DECLARE @КонецНедели DATE = DATEADD(DAY, 7, @НачалоНедели);
        DECLARE @ТекущийДень DATE = @НачалоНедели;
        
        WHILE @ТекущийДень <= @КонецНедели
        BEGIN
            INSERT INTO Занятие (Расписание_ID, Дата_Занятия, Статус)
            SELECT 
                r.Расписание_ID,
                @ТекущийДень,
                N'Запланировано'
            FROM Расписание r
            WHERE DATEPART(WEEKDAY, @ТекущийДень) = r.День_Недели
            AND NOT EXISTS (
                SELECT 1 
                FROM Занятие z 
                WHERE z.Расписание_ID = r.Расписание_ID 
                AND z.Дата_Занятия = @ТекущийДень
            );
            SET @ТекущийДень = DATEADD(DAY, 1, @ТекущийДень);
        END;
        
        -- 3. Очистка старых логов (старше 180 дней)
        DELETE FROM Лог_Действий 
        WHERE Время_Действия < DATEADD(DAY, -180, GETDATE());
        
        -- 4. Уведомления о картах, срок которых истекает через месяц
        INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Срок_Действия)
        SELECT DISTINCT
            u.Пользователь_ID,
            N'Информация',
            N'Срок действия карты истекает через месяц',
            CONCAT(
                N'Карта СКУД №', sk.Номер_Карты, 
                N' истекает ', FORMAT(sk.Дата_Истечения, N'dd.MM.yyyy')
            ),
            DATEADD(DAY, 30, GETDATE())
        FROM СКУД_Карта sk
        INNER JOIN Студент s ON sk.Студент_ID = s.Студент_ID
        INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
        WHERE sk.Статус = N'Активна'
        AND sk.Дата_Истечения BETWEEN GETDATE() AND DATEADD(MONTH, 1, GETDATE());
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Время_Выполнения_Мс)
        VALUES (
            1,
            N'Ежедневное обслуживание системы',
            N'Успешно',
            DATEDIFF(MILLISECOND, @НачалоВыполнения, GETDATE())
        );
    END TRY
    BEGIN CATCH
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
        VALUES (1, N'Ошибка ежедневного обслуживания', N'Ошибка', ERROR_MESSAGE());
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ЗавершитьQRСессию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 39. ЗавершитьQRСессию
CREATE PROCEDURE [dbo].[ЗавершитьQRСессию]
    @QR_Сессия_ID INT,
    @КтоЗавершил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM QR_Сессия WHERE QR_Сессия_ID = @QR_Сессия_ID)
            RAISERROR(N'QR сессия не найдена', 16, 1);
        
        UPDATE QR_Сессия 
        SET 
            Статус = N'Завершен',
            Время_Действия_Конец = GETDATE()
        WHERE QR_Сессия_ID = @QR_Сессия_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоЗавершил, N'Завершение QR сессии', N'QR_Сессия', @QR_Сессия_ID, N'Успешно');
        
        SELECT 1 AS Завершено, N'QR сессия завершена' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ЗавершитьВсеСессииПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ЗавершитьВсеСессииПользователя]
    @Пользователь_ID INT,
    @Причина NVARCHAR(100) = N'Принудительное завершение'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Сессия_Пользователя
    SET Активна = 0,
        Причина_Завершения = @Причина,
        Время_Истечения = GETDATE()
    WHERE Пользователь_ID = @Пользователь_ID
      AND Активна = 1;

    DECLARE @Количество INT = @@ROWCOUNT;

    IF @Количество > 0
    BEGIN
        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
        VALUES (@Пользователь_ID, N'Завершение всех сессий пользователя', N'Успешно', 
                N'Причина: ' + @Причина);
    END

    SELECT @Количество AS ЗавершеноСессий;
END;
GO
/****** Object:  StoredProcedure [dbo].[ЗавершитьСессию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ЗавершитьСессию]
    @Сессия_ID UNIQUEIDENTIFIER,
    @Причина NVARCHAR(100) = N'Выход пользователя',
    @Пользователь_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Пользователь_ID IS NOT NULL
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Сессия_Пользователя
            WHERE Сессия_ID = @Сессия_ID
              AND Пользователь_ID = @Пользователь_ID
              AND Активна = 1
        )
        BEGIN
            RAISERROR(N'Сессия не принадлежит пользователю или уже неактивна', 16, 1);
            RETURN;
        END
    END

    UPDATE dbo.Сессия_Пользователя
    SET Активна = 0,
        Причина_Завершения = @Причина,
        Время_Истечения = GETDATE()
    WHERE Сессия_ID = @Сессия_ID
      AND Активна = 1;

    SELECT @@ROWCOUNT AS ЗавершеноСессий;
END;
GO
/****** Object:  StoredProcedure [dbo].[ИзменитьСтатусОбоснования]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ИзменитьСтатусОбоснования]
    @Обоснование_ID INT,
    @НовыйСтатус NVARCHAR(20),
    @КтоИзменил INT,
    @Комментарий NVARCHAR(MAX) = NULL,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Проверка статуса
        IF @НовыйСтатус NOT IN (N'Одобрено', N'Отклонено')
        BEGIN
            RAISERROR(N'Неверный статус', 16, 1);
            RETURN;
        END
        
        DECLARE @Студент_ID INT, @Занятие_ID INT, @Пользователь_ID INT;
        SELECT @Студент_ID = Студент_ID, @Занятие_ID = Занятие_ID
        FROM Обоснования_Отсутствия WHERE Обоснование_ID = @Обоснование_ID;
        
        IF @Студент_ID IS NULL
        BEGIN
            RAISERROR(N'Обоснование не найдено', 16, 1);
            RETURN;
        END
        
        -- Получаем пользователя студента
        SELECT @Пользователь_ID = Пользователь_ID FROM Студент WHERE Студент_ID = @Студент_ID;
        
        -- Получаем дату занятия для сообщения
        DECLARE @ДатаЗанятия DATE;
        SELECT @ДатаЗанятия = Дата_Занятия FROM Занятие WHERE Занятие_ID = @Занятие_ID;
        
        -- Обновляем статус
        UPDATE Обоснования_Отсутствия
        SET Статус = @НовыйСтатус,
            Комментарий_Модератора = @Комментарий,
            Кто_Рассмотрел = @КтоИзменил,
            Дата_Рассмотрения = GETDATE()
        WHERE Обоснование_ID = @Обоснование_ID;
        
        -- Если одобрено, меняем статус посещаемости
        IF @НовыйСтатус = N'Одобрено'
        BEGIN
            UPDATE Посещаемость
            SET Статус = N'Уважительная причина',
                Примечание = N'Одобрено обоснование №' + CAST(@Обоснование_ID AS NVARCHAR),
                Дата_Обновления = GETDATE()
            WHERE Занятие_ID = @Занятие_ID AND Студент_ID = @Студент_ID;
        END
        
        -- Отправляем уведомление студенту (с исправленным преобразованием даты)
        DECLARE @ДатаСтрока NVARCHAR(20) = CONVERT(NVARCHAR(20), @ДатаЗанятия, 104);
        
        INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
        VALUES (
            @Пользователь_ID,
            CASE WHEN @НовыйСтатус = N'Одобрено' THEN N'Информация' ELSE N'Предупреждение' END,
            CASE WHEN @НовыйСтатус = N'Одобрено' THEN N'Ваше обоснование принято' ELSE N'Ваше обоснование отклонено' END,
            CASE WHEN @НовыйСтатус = N'Одобрено' THEN 
                N'Ваше обоснование отсутствия на занятии от ' + @ДатаСтрока + N' было принято.'
            ELSE 
                N'Ваше обоснование отсутствия на занятии от ' + @ДатаСтрока + 
                N' было отклонено. Причина: ' + ISNULL(@Комментарий, N'не указана')
            END,
            CONCAT('/student/excuses.php?id=', @Обоснование_ID)
        );
        
        -- Логирование
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер, Параметры)
        VALUES (@КтоИзменил, N'Изменение статуса обоснования', N'Обоснования_Отсутствия', @Обоснование_ID, N'Успешно',
                @IP_Адрес, @Устройство, @Браузер, N'Новый статус: ' + @НовыйСтатус);
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Обновлено, N'Статус обоснования изменён, уведомление отправлено' AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ИмпортГруппИзCSV]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ИмпортГруппИзCSV]
    @CSV_Содержимое NVARCHAR(MAX),
    @Имя_Файла NVARCHAR(500),
    @Пользователь_ID INT,
    @IP_Адрес NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @КоличествоЗаписей INT = 0, @КоличествоУспешно INT = 0, @КоличествоОшибок INT = 0;
        DECLARE @Примечание NVARCHAR(MAX) = N'';
        
        -- Разбор CSV (формат: Название;Год_Поступления;Специальность_Код)
        DECLARE @xml XML = CAST(N'<rows><row>' + REPLACE(REPLACE(@CSV_Содержимое, CHAR(13), ''), CHAR(10), '</row><row>') + '</row></rows>' AS XML);
        
        DECLARE @Название NVARCHAR(50), @Год INT, @КодСпециальности NVARCHAR(20), @Специальность_ID INT;
        
        DECLARE cur CURSOR LOCAL FOR
            SELECT 
                r.value('@col1', 'NVARCHAR(50)'),
                r.value('@col2', 'INT'),
                r.value('@col3', 'NVARCHAR(20)')
            FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num, 
                       t.c.value('.', 'NVARCHAR(MAX)') AS val
                FROM @xml.nodes('/rows/row') t(c)
            ) src
            PIVOT (MAX(val) FOR row_num IN ([1],[2],[3])) p;
        
        OPEN cur;
        FETCH NEXT FROM cur INTO @Название, @Год, @КодСпециальности;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @КоличествоЗаписей = @КоличествоЗаписей + 1;
            BEGIN TRY
                -- Поиск специальности по коду
                SELECT @Специальность_ID = Специальность_ID FROM Специальность WHERE Код = @КодСпециальности;
                IF @Специальность_ID IS NULL
                    RAISERROR(N'Специальность с кодом "%s" не найдена', 16, 1, @КодСпециальности);
                
                -- Проверка существования группы
                IF EXISTS (SELECT 1 FROM Учебная_Группа WHERE Название = @Название)
                BEGIN
                    -- Обновляем, если нужно (по желанию)
                    UPDATE Учебная_Группа SET Год_Поступления = @Год, Специальность_ID = @Специальность_ID WHERE Название = @Название;
                    SET @КоличествоУспешно = @КоличествоУспешно + 1;
                END
                ELSE
                BEGIN
                    INSERT INTO Учебная_Группа (Название, Год_Поступления, Специальность_ID, Статус)
                    VALUES (@Название, @Год, @Специальность_ID, N'Активна');
                    SET @КоличествоУспешно = @КоличествоУспешно + 1;
                END
            END TRY
            BEGIN CATCH
                SET @КоличествоОшибок = @КоличествоОшибок + 1;
                SET @Примечание = @Примечание + N'Ошибка при импорте группы "' + @Название + N'": ' + ERROR_MESSAGE() + CHAR(13);
            END CATCH
            FETCH NEXT FROM cur INTO @Название, @Год, @КодСпециальности;
        END
        
        CLOSE cur;
        DEALLOCATE cur;
        
        -- Запись в журнал импорта
        INSERT INTO Журнал_Импорта_CSV (Тип_Данных, Имя_Файла, Количество_Записей, Количество_Успешно, Количество_Ошибок, Статус, Пользователь_ID, Примечание)
        VALUES (N'Группы', @Имя_Файла, @КоличествоЗаписей, @КоличествоУспешно, @КоличествоОшибок, 
                CASE WHEN @КоличествоОшибок = 0 THEN N'Успешно' ELSE N'Частично' END, @Пользователь_ID, @Примечание);
        
        COMMIT TRANSACTION;
        
        SELECT 
            @КоличествоЗаписей AS ВсегоЗаписей,
            @КоличествоУспешно AS УспешноЗаписей,
            @КоличествоОшибок AS ОшибокЗаписей,
            @Примечание AS Примечание;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ИсправитьНекорректныеСтатусы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Исправление некорректных статусов
-- =============================================
CREATE PROCEDURE [dbo].[ИсправитьНекорректныеСтатусы]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Занятия с истекшей датой, но статус "Запланировано"
    UPDATE Занятие
    SET Статус = N'Проведено',
        Примечание = ISNULL(Примечание, N'') + N' | Статус исправлен автоматически'
    WHERE Дата_Занятия < CAST(GETDATE() AS DATE)
    AND Статус = N'Запланировано';
    
    -- QR-сессии с истекшим сроком, но статус "Активен"
    UPDATE QR_Сессия
    SET Статус = N'Завершен',
        Примечание = ISNULL(Примечание, N'') + N' | Статус исправлен автоматически'
    WHERE Время_Действия_Конец < GETDATE()
    AND Статус = N'Активен';
    
    -- Карты с истекшим сроком, но статус "Активна"
    UPDATE СКУД_Карта
    SET Статус = N'Истекла',
        Примечание = ISNULL(Примечание, N'') + N' | Статус исправлен автоматически'
    WHERE Дата_Истечения < GETDATE()
    AND Статус = N'Активна';
    
    SELECT @@ROWCOUNT AS ИсправленоЗаписей;
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьДатыВИндексах]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Установка начальных значений для индексов с датами
-- =============================================
CREATE PROCEDURE [dbo].[ОбновитьДатыВИндексах]
    @НовыйГраничныйГод INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НовыйГраничныйГод IS NULL
        SET @НовыйГраничныйГод = YEAR(GETDATE());
    
    DECLARE @ГраничнаяДата NVARCHAR(10) = CAST(@НовыйГраничныйГод AS NVARCHAR) + '-01-01';
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Здесь можно пересоздать индексы с новой граничной датой
    -- Для примера выводим информацию
    PRINT N'Для обновления фильтрованных индексов выполните:';
    PRINT N'DROP INDEX IX_Занятия_Последние_2_Месяца ON Занятие;';
    PRINT N'CREATE INDEX IX_Занятия_Последние_2_Месяца ON Занятие(Дата_Занятия DESC, Статус) INCLUDE (Расписание_ID, Тема_Занятия) WHERE Дата_Занятия > ''' + @ГраничнаяДата + ''';';
    -- и так для других индексов
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьЗанятиеСУведомлением]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ОбновитьЗанятиеСУведомлением]
    @Занятие_ID INT,
    @НоваяДата DATE = NULL,
    @НовыйКабинет NVARCHAR(50) = NULL,
    @НовоеВремяНачала TIME = NULL,
    @НовоеВремяОкончания TIME = NULL,
    @КтоОбновил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Сохраняем старые значения для уведомления
        DECLARE @СтараяДата DATE, @СтарыйКабинет NVARCHAR(50), @СтароеВремяНачала TIME, @СтароеВремяОкончания TIME;
        SELECT 
            @СтараяДата = з.Дата_Занятия,
            @СтарыйКабинет = з.Кабинет,
            @СтароеВремяНачала = р.Время_Начала,
            @СтароеВремяОкончания = р.Время_Окончания
        FROM Занятие з
        INNER JOIN Расписание р ON з.Расписание_ID = р.Расписание_ID
        WHERE з.Занятие_ID = @Занятие_ID;
        
        -- Обновляем занятие
        UPDATE Занятие
        SET 
            Дата_Занятия = ISNULL(@НоваяДата, Дата_Занятия),
            Кабинет = ISNULL(@НовыйКабинет, Кабинет)
        WHERE Занятие_ID = @Занятие_ID;
        
        -- Если изменилось время, обновляем расписание (если это постоянное изменение)
        IF @НовоеВремяНачала IS NOT NULL OR @НовоеВремяОкончания IS NOT NULL
        BEGIN
            UPDATE р
            SET 
                Время_Начала = ISNULL(@НовоеВремяНачала, р.Время_Начала),
                Время_Окончания = ISNULL(@НовоеВремяОкончания, р.Время_Окончания),
                Дата_Обновления = GETDATE()
            FROM Расписание р
            INNER JOIN Занятие з ON р.Расписание_ID = з.Расписание_ID
            WHERE з.Занятие_ID = @Занятие_ID;
        END
        
        -- Формируем сообщение об изменениях
        DECLARE @Сообщение NVARCHAR(MAX) = N'В расписании произошли изменения:';
        IF @НоваяДата IS NOT NULL AND @НоваяДата <> @СтараяДата
            SET @Сообщение = @Сообщение + N' Дата перенесена с ' + CONVERT(NVARCHAR(10), @СтараяДата, 104) + N' на ' + CONVERT(NVARCHAR(10), @НоваяДата, 104) + N'.';
        IF @НовыйКабинет IS NOT NULL AND @НовыйКабинет <> @СтарыйКабинет
            SET @Сообщение = @Сообщение + N' Аудитория изменена с "' + ISNULL(@СтарыйКабинет, N'не указана') + N'" на "' + @НовыйКабинет + N'".';
        IF @НовоеВремяНачала IS NOT NULL AND @НовоеВремяНачала <> @СтароеВремяНачала
            SET @Сообщение = @Сообщение + N' Время начала изменено с ' + CONVERT(NVARCHAR(5), @СтароеВремяНачала) + N' на ' + CONVERT(NVARCHAR(5), @НовоеВремяНачала) + N'.';
        IF @НовоеВремяОкончания IS NOT NULL AND @НовоеВремяОкончания <> @СтароеВремяОкончания
            SET @Сообщение = @Сообщение + N' Время окончания изменено с ' + CONVERT(NVARCHAR(5), @СтароеВремяОкончания) + N' на ' + CONVERT(NVARCHAR(5), @НовоеВремяОкончания) + N'.';
        
        -- Отправляем уведомления всем студентам группы
        IF @Сообщение <> N'В расписании произошли изменения:'
        BEGIN
            INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка)
            SELECT 
                u.Пользователь_ID,
                N'Важное',
                N'Изменение в расписании занятия',
                @Сообщение,
                CONCAT('/student/schedule.php?lesson=', @Занятие_ID)
            FROM Занятие з
            INNER JOIN Расписание р ON з.Расписание_ID = р.Расписание_ID
            INNER JOIN Учебная_Группа г ON р.Группа_ID = г.Группа_ID
            INNER JOIN Студент s ON г.Группа_ID = s.Группа_ID
            INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
            WHERE з.Занятие_ID = @Занятие_ID;
        END
        
        -- Логирование
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер, Параметры)
        VALUES (@КтоОбновил, N'Обновление занятия с уведомлением', N'Занятие', @Занятие_ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер, @Сообщение);
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Обновлено, @Сообщение AS Сообщение;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьНастройку]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 52. ОбновитьНастройку
CREATE PROCEDURE [dbo].[ОбновитьНастройку]
    @Ключ NVARCHAR(100),
    @Значение NVARCHAR(MAX),
    @Пользователь_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Проверка существования настройки
        IF NOT EXISTS (SELECT 1 FROM Настройки_Системы WHERE Ключ = @Ключ)
            RAISERROR(N'Настройка не найдена', 16, 1);
        
        -- Проверка прав
        DECLARE @ТолькоДляЧтения BIT, @ТолькоДляАдмина BIT, @Настройка_ID INT;
        SELECT 
            @ТолькоДляЧтения = ТолькоДляЧтения,
            @ТолькоДляАдмина = ТолькоДляАдмина,
            @Настройка_ID = Настройка_ID
        FROM Настройки_Системы 
        WHERE Ключ = @Ключ;
        
        IF @ТолькоДляЧтения = 1
            RAISERROR(N'Эта настройка только для чтения', 16, 1);
        
        IF @ТолькоДляАдмина = 1
        BEGIN
            DECLARE @УровеньДоступа INT;
            SELECT @УровеньДоступа = r.Уровень_Доступа
            FROM Пользователь u
            INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
            WHERE u.Пользователь_ID = @Пользователь_ID AND u.Активен = 1;
            
            IF @УровеньДоступа < 100
                RAISERROR(N'Только администратор может изменять эту настройку', 16, 1);
        END
        
        -- Обновление
        UPDATE Настройки_Системы 
        SET 
            Значение = @Значение,
            Дата_Изменения = GETDATE(),
            Кто_Изменил = @Пользователь_ID
        WHERE Ключ = @Ключ;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@Пользователь_ID, N'Обновление настройки', N'Настройки_Системы', @Настройка_ID, N'Успешно');
        
        SELECT 1 AS Обновлено, N'Настройка обновлена' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьПарольПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ОбновитьПарольПользователя]
    @Пользователь_ID INT,
    @НовыйПароль NVARCHAR(255),
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Проверка существования пользователя
        IF NOT EXISTS (SELECT 1 FROM dbo.Пользователь WHERE Пользователь_ID = @Пользователь_ID)
        BEGIN
            RAISERROR(N'Пользователь не найден', 16, 1);
            RETURN;
        END

        -- Генерация новой соли и хеша
        DECLARE @Соль NVARCHAR(32) = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
        DECLARE @Хэш NVARCHAR(64) = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @НовыйПароль + @Соль), 2);

        UPDATE dbo.Пользователь
        SET Хэш_Пароля = @Хэш,
            Соль = @Соль
        WHERE Пользователь_ID = @Пользователь_ID;

        -- Завершаем все активные сессии пользователя
        EXEC dbo.ЗавершитьВсеСессииПользователя @Пользователь_ID, N'Смена пароля';

        INSERT INTO dbo.Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоОбновил, N'Смена пароля пользователя', N'Пользователь', @Пользователь_ID, N'Успешно');

        COMMIT TRANSACTION;

        SELECT 1 AS Обновлено, N'Пароль успешно изменён' AS Сообщение;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 8. ОбновитьПользователя
CREATE PROCEDURE [dbo].[ОбновитьПользователя]
    @Пользователь_ID INT,
    @Логин NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Роль_ID INT = NULL,
    @Телефон NVARCHAR(20) = NULL,
    @Аватар_URL NVARCHAR(500) = NULL,
    @Активен BIT = NULL,
    @Примечание NVARCHAR(MAX) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Пользователь WHERE Пользователь_ID = @Пользователь_ID)
        BEGIN
            RAISERROR(N'Пользователь не найден', 16, 1);
            RETURN;
        END
        
        -- Проверка уникальности логина, если он меняется
        IF @Логин IS NOT NULL 
            AND EXISTS (SELECT 1 FROM Пользователь WHERE Логин = @Логин AND Пользователь_ID <> @Пользователь_ID)
        BEGIN
            RAISERROR(N'Логин уже используется другим пользователем', 16, 1);
            RETURN;
        END
        
        UPDATE Пользователь 
        SET 
            Логин = ISNULL(@Логин, Логин),
            Email = ISNULL(@Email, Email),
            Роль_ID = ISNULL(@Роль_ID, Роль_ID),
            Телефон = ISNULL(@Телефон, Телефон),
            Аватар_URL = ISNULL(@Аватар_URL, Аватар_URL),
            Активен = ISNULL(@Активен, Активен),
            Примечание = ISNULL(@Примечание, Примечание)
        WHERE Пользователь_ID = @Пользователь_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоОбновил, N'Обновление пользователя', N'Пользователь', @Пользователь_ID, N'Успешно');
        
        SELECT 1 AS Обновлено, N'Данные пользователя обновлены' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьРоль]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 14. ОбновитьРоль
CREATE PROCEDURE [dbo].[ОбновитьРоль]
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
        
        DECLARE @ТекущееНазвание NVARCHAR(50);
        SELECT @ТекущееНазвание = Название FROM Роль WHERE Роль_ID = @Роль_ID;
        
        IF @ТекущееНазвание IN (N'Admin', N'Студент', N'Преподаватель')
        BEGIN
            RAISERROR(N'Нельзя изменять системные роли', 16, 1);
            RETURN;
        END
        
        IF @Название IS NOT NULL 
            AND EXISTS (SELECT 1 FROM Роль WHERE Название = @Название AND Роль_ID <> @Роль_ID)
        BEGIN
            RAISERROR(N'Роль с таким названием уже существует', 16, 1);
            RETURN;
        END
        
        UPDATE Роль 
        SET 
            Название = ISNULL(@Название, Название),
            Описание = ISNULL(@Описание, Описание),
            Уровень_Доступа = ISNULL(@Уровень_Доступа, Уровень_Доступа),
            Можно_Удалять = ISNULL(@Можно_Удалять, Можно_Удалять)
        WHERE Роль_ID = @Роль_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
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
/****** Object:  StoredProcedure [dbo].[ОбновитьСтатусЗанятия]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 33. ОбновитьСтатусЗанятия
CREATE PROCEDURE [dbo].[ОбновитьСтатусЗанятия]
    @Занятие_ID INT,
    @Статус NVARCHAR(20),
    @Время_Начала_Факт DATETIME = NULL,
    @Время_Окончания_Факт DATETIME = NULL,
    @Тема_Занятия NVARCHAR(300) = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Занятие WHERE Занятие_ID = @Занятие_ID)
            RAISERROR(N'Занятие не найдено', 16, 1);
        
        UPDATE Занятие 
        SET 
            Статус = @Статус,
            Время_Начала_Факт = ISNULL(@Время_Начала_Факт, Время_Начала_Факт),
            Время_Окончания_Факт = ISNULL(@Время_Окончания_Факт, Время_Окончания_Факт),
            Тема_Занятия = ISNULL(@Тема_Занятия, Тема_Занятия),
            Примечание = ISNULL(@Примечание, Примечание)
        WHERE Занятие_ID = @Занятие_ID;
        
        IF @Статус = N'Проведено'
        BEGIN
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
            VALUES (@КтоОбновил, N'Завершение занятия', N'Занятие', @Занятие_ID, N'Успешно');
        END
        
        SELECT 1 AS Обновлено, N'Статус занятия обновлен' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьСтудента]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 17. ОбновитьСтудента
CREATE PROCEDURE [dbo].[ОбновитьСтудента]
    @Студент_ID INT,
    @ФИО NVARCHAR(150) = NULL,
    @Группа_ID INT = NULL,
    @Дата_Рождения DATE = NULL,
    @Пол NVARCHAR(10) = NULL,
    @Адрес NVARCHAR(300) = NULL,
    @Телефон_Родителей NVARCHAR(20) = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Студент WHERE Студент_ID = @Студент_ID)
            RAISERROR(N'Студент не найден', 16, 1);
        
        IF @Группа_ID IS NOT NULL 
            AND NOT EXISTS (SELECT 1 FROM Учебная_Группа WHERE Группа_ID = @Группа_ID)
            RAISERROR(N'Группа не найдена', 16, 1);
        
        UPDATE Студент 
        SET 
            ФИО = ISNULL(@ФИО, ФИО),
            Группа_ID = ISNULL(@Группа_ID, Группа_ID),
            Дата_Рождения = ISNULL(@Дата_Рождения, Дата_Рождения),
            Пол = ISNULL(@Пол, Пол),
            Адрес = ISNULL(@Адрес, Адрес),
            Телефон_Родителей = ISNULL(@Телефон_Родителей, Телефон_Родителей),
            Примечание = ISNULL(@Примечание, Примечание)
        WHERE Студент_ID = @Студент_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоОбновил, N'Обновление студента', N'Студент', @Студент_ID, N'Успешно');
        
        SELECT 1 AS Обновлено, N'Данные студента обновлены' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьУчебнуюГруппу]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 22. ОбновитьУчебнуюГруппу
CREATE PROCEDURE [dbo].[ОбновитьУчебнуюГруппу]
    @Группа_ID INT,
    @Название NVARCHAR(50) = NULL,
    @Статус NVARCHAR(20) = NULL,
    @Куратор_ID INT = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоОбновил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Учебная_Группа WHERE Группа_ID = @Группа_ID)
            RAISERROR(N'Группа не найдена', 16, 1);
        
        IF @Название IS NOT NULL 
            AND EXISTS (SELECT 1 FROM Учебная_Группа WHERE Название = @Название AND Группа_ID <> @Группа_ID)
            RAISERROR(N'Группа с таким названием уже существует', 16, 1);
        
        IF @Куратор_ID IS NOT NULL 
            AND NOT EXISTS (SELECT 1 FROM Преподаватель WHERE Преподаватель_ID = @Куратор_ID)
            RAISERROR(N'Куратор не найден', 16, 1);
        
        UPDATE Учебная_Группа 
        SET 
            Название = ISNULL(@Название, Название),
            Статус = ISNULL(@Статус, Статус),
            Куратор_ID = @Куратор_ID,
            Примечание = ISNULL(@Примечание, Примечание)
        WHERE Группа_ID = @Группа_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоОбновил, N'Обновление учебной группы', N'Учебная_Группа', @Группа_ID, N'Успешно');
        
        SELECT 1 AS Обновлено, N'Группа обновлена' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ОбновитьФакультет]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[ОбновитьФакультет]
    @Факультет_ID INT,
    @Название NVARCHAR(100) = NULL,
    @Описание NVARCHAR(500) = NULL,
    @КтоОбновил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Проверка прав (Admin/Методист)
        DECLARE @РольПользователя NVARCHAR(50);
        SELECT @РольПользователя = r.Название
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        WHERE u.Пользователь_ID = @КтоОбновил AND u.Активен = 1;
        IF @РольПользователя NOT IN (N'Admin', N'Методист')
        BEGIN
            RAISERROR(N'Недостаточно прав для обновления факультета', 16, 1);
            RETURN;
        END

        UPDATE Факультет
        SET Название = ISNULL(@Название, Название),
            Описание = ISNULL(@Описание, Описание)
        WHERE Факультет_ID = @Факультет_ID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Факультет не найден', 16, 1);
            RETURN;
        END

        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
        VALUES (@КтоОбновил, N'Обновление факультета', N'Факультет', @Факультет_ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);

        SELECT 1 AS Обновлено, N'Факультет обновлён' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[ОбслуживаниеИндексов]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ОбслуживаниеИндексов]
    @ПерестроитьПриФрагментации INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Таблица NVARCHAR(255);
    DECLARE @Индекс NVARCHAR(255);
    DECLARE @Фрагментация DECIMAL(5,2);
    DECLARE @SQL NVARCHAR(MAX);
    
    DECLARE индексы CURSOR FOR
    SELECT 
        OBJECT_NAME(ips.object_id) AS Таблица,
        si.name AS Индекс,
        ips.avg_fragmentation_in_percent AS Фрагментация
    FROM sys.dm_db_index_physical_stats(
        DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes si ON ips.object_id = si.object_id 
        AND ips.index_id = si.index_id
    WHERE ips.avg_fragmentation_in_percent > 5
        AND si.name IS NOT NULL
        AND OBJECT_NAME(ips.object_id) NOT LIKE 'sys%'
    ORDER BY ips.avg_fragmentation_in_percent DESC;
    
    OPEN индексы;
    FETCH NEXT FROM индексы INTO @Таблица, @Индекс, @Фрагментация;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Фрагментация > @ПерестроитьПриФрагментации
        BEGIN
            SET @SQL = 'ALTER INDEX [' + @Индекс + '] ON [' + @Таблица + '] REBUILD WITH (ONLINE = ON, MAXDOP = 4)';
            EXEC sp_executesql @SQL;
            
            INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
            VALUES (N'Обслуживание индексов: перестроение', @Таблица, N'Успешно', 
                   N'Индекс: ' + @Индекс + N', Фрагментация: ' + CAST(@Фрагментация AS NVARCHAR) + N'%');
        END
        ELSE
        BEGIN
            SET @SQL = 'ALTER INDEX [' + @Индекс + '] ON [' + @Таблица + '] REORGANIZE';
            EXEC sp_executesql @SQL;
            
            INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
            VALUES (N'Обслуживание индексов: реорганизация', @Таблица, N'Успешно', 
                   N'Индекс: ' + @Индекс + N', Фрагментация: ' + CAST(@Фрагментация AS NVARCHAR) + N'%');
        END
        
        FETCH NEXT FROM индексы INTO @Таблица, @Индекс, @Фрагментация;
    END
    
    CLOSE индексы;
    DEALLOCATE индексы;
    
    EXEC sp_updatestats;
    
    INSERT INTO Лог_Действий (Действие, Статус)
    VALUES (N'Обслуживание индексов завершено', N'Успешно');
END;
GO
/****** Object:  StoredProcedure [dbo].[ОтметитьПосещаемость]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ОтметитьПосещаемость]
    @Занятие_ID INT,
    @Студент_ID INT,
    @Статус NVARCHAR(30),
    @Примечание NVARCHAR(300) = NULL,
    @КтоОтметил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Статус NOT IN (N'Присутствовал', N'Отсутствовал', N'Опоздал', N'Уважительная причина')
        BEGIN
            RAISERROR(N'Неверный статус посещаемости', 16, 1);
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM Занятие WHERE Занятие_ID = @Занятие_ID) RAISERROR(N'Занятие не найдено', 16, 1);
        IF NOT EXISTS (SELECT 1 FROM Студент WHERE Студент_ID = @Студент_ID) RAISERROR(N'Студент не найден', 16, 1);
        DECLARE @СуществующаяЗапись INT;
        SELECT @СуществующаяЗапись = Посещаемость_ID FROM Посещаемость WHERE Занятие_ID = @Занятие_ID AND Студент_ID = @Студент_ID;
        IF @СуществующаяЗапись IS NOT NULL
        BEGIN
            UPDATE Посещаемость SET Статус = @Статус, Примечание = ISNULL(@Примечание, Примечание), Кто_Отметил = @КтоОтметил, Дата_Обновления = GETDATE()
            WHERE Посещаемость_ID = @СуществующаяЗапись;
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
            VALUES (@КтоОтметил, N'Обновление посещаемости', N'Посещаемость', @СуществующаяЗапись, N'Успешно', @IP_Адрес, @Устройство, @Браузер);
            SELECT @СуществующаяЗапись AS Посещаемость_ID, 1 AS Отмечено, N'Обновлено' AS Сообщение;
        END
        ELSE
        BEGIN
            INSERT INTO Посещаемость (Занятие_ID, Студент_ID, Статус, Тип_Отметки, Примечание, Кто_Отметил)
            VALUES (@Занятие_ID, @Студент_ID, @Статус, N'Ручная', @Примечание, @КтоОтметил);
            DECLARE @НовыйID INT = SCOPE_IDENTITY();
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
            VALUES (@КтоОтметил, N'Создание посещаемости', N'Посещаемость', @НовыйID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);
            SELECT @НовыйID AS Посещаемость_ID, 1 AS Отмечено, N'Создано' AS Сообщение;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[ОчиститьДублирующиесяСессии]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Исправление дублирующихся сессий (очистка)
-- =============================================
CREATE PROCEDURE [dbo].[ОчиститьДублирующиесяСессии]
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH Дубли AS (
        SELECT 
            Пользователь_ID,
            Токен,
            MIN(Сессия_ID) AS ПерваяСессия
        FROM Сессия_Пользователя
        WHERE Активна = 1
        GROUP BY Пользователь_ID, Токен
        HAVING COUNT(*) > 1
    )
    UPDATE sp
    SET Активна = 0,
        Причина_Завершения = N'Дубликат сессии (очистка)'
    FROM Сессия_Пользователя sp
    INNER JOIN Дубли d ON sp.Пользователь_ID = d.Пользователь_ID AND sp.Токен = d.Токен
    WHERE sp.Сессия_ID <> d.ПерваяСессия;
    
    SELECT @@ROWCOUNT AS ОчищеноДубликатов;
END;
GO
/****** Object:  StoredProcedure [dbo].[ОчиститьСтарыеЛоги]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 62. ОчиститьСтарыеЛоги
CREATE PROCEDURE [dbo].[ОчиститьСтарыеЛоги]
    @СтаршеДней INT = 90,
    @КтоОчистил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ДатаОчистки DATETIME = DATEADD(DAY, -@СтаршеДней, GETDATE());
        DECLARE @УдаленоЗаписей INT;
        
        DELETE FROM Лог_Действий 
        WHERE Время_Действия < @ДатаОчистки;
        
        SET @УдаленоЗаписей = @@ROWCOUNT;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
        VALUES (@КтоОчистил, N'Очистка старых логов', N'Успешно', 
                N'Удалено записей: ' + CAST(@УдаленоЗаписей AS NVARCHAR) + 
                N', Старше дней: ' + CAST(@СтаршеДней AS NVARCHAR));
        
        SELECT @УдаленоЗаписей AS УдаленоЗаписей;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ПодтвердитьВосстановлениеПароля]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ПодтвердитьВосстановлениеПароля]
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
/****** Object:  StoredProcedure [dbo].[ПоискСтудентов]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 20. ПоискСтудентов
CREATE PROCEDURE [dbo].[ПоискСтудентов]
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
            s.ФИО,
            s.Группа_ID,
            g.Название AS Название_Группы,
            u.Логин,
            u.Email,
            u.Активен,
            s.Дата_Поступления,
            ROW_NUMBER() OVER (ORDER BY s.ФИО) AS Номер
        FROM Студент s
        INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
        INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
        WHERE (@ТолькоАктивные = 0 OR u.Активен = 1)
        AND (@Группа_ID IS NULL OR s.Группа_ID = @Группа_ID)
        AND (
            @ПоисковыйЗапрос IS NULL 
            OR s.ФИО LIKE '%' + @ПоисковыйЗапрос + '%'
            OR u.Логин LIKE '%' + @ПоисковыйЗапрос + '%'
            OR u.Email LIKE '%' + @ПоисковыйЗапрос + '%'
            OR g.Название LIKE '%' + @ПоисковыйЗапрос + '%'
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
/****** Object:  StoredProcedure [dbo].[ПолучитьАктивнуюQRСессию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 38. ПолучитьАктивнуюQRСессию
CREATE PROCEDURE [dbo].[ПолучитьАктивнуюQRСессию]
    @Занятие_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1 
        qr.*,
        z.Дата_Занятия,
        d.Название AS Название_Дисциплины,
        p.ФИО AS ФИО_Преподавателя,
        g.Название AS Название_Группы,
        u.Логин AS Логин_Создателя,
        COALESCE(преподаватель_созд.ФИО, студент_созд.ФИО, u.Логин) AS ФИО_Создателя
    FROM QR_Сессия qr
    INNER JOIN Занятие z ON qr.Занятие_ID = z.Занятие_ID
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    INNER JOIN Пользователь u ON qr.Кто_Создал = u.Пользователь_ID
    LEFT JOIN Преподаватель преподаватель_созд ON u.Пользователь_ID = преподаватель_созд.Пользователь_ID
    LEFT JOIN Студент студент_созд ON u.Пользователь_ID = студент_созд.Пользователь_ID
    WHERE qr.Занятие_ID = @Занятие_ID 
    AND qr.Статус = N'Активен'
    AND qr.Время_Действия_Конец > GETDATE()
    ORDER BY qr.Время_Создания DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьГруппыКуратора]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[ПолучитьГруппыКуратора]
    @Куратор_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT g.*, sp.Название AS Специальность, f.Название AS Факультет
    FROM Учебная_Группа g
    LEFT JOIN Специальность sp ON g.Специальность_ID = sp.Специальность_ID
    LEFT JOIN Факультет f ON sp.Факультет_ID = f.Факультет_ID
    WHERE g.Куратор_ID = @Куратор_ID
    ORDER BY g.Название;
END
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьДашбордПреподавателя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 65. ПолучитьДашбордПреподавателя
CREATE PROCEDURE [dbo].[ПолучитьДашбордПреподавателя]
    @Преподаватель_ID INT,
    @ПериодДней INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @НачалоПериода DATE = DATEADD(DAY, -@ПериодДней, GETDATE());
    DECLARE @КонецПериода DATE = GETDATE();
    
    -- 1. Информация о преподавателе
    SELECT 
        p.ФИО,
        p.Кафедра,
        p.Должность,
        u.Email AS Email_Рабочий,
        COUNT(DISTINCT d.Дисциплина_ID) AS КоличествоДисциплин,
        COUNT(DISTINCT r.Группа_ID) AS КоличествоГрупп
    FROM Преподаватель p
    INNER JOIN Пользователь u ON p.Пользователь_ID = u.Пользователь_ID
    LEFT JOIN Дисциплина d ON p.Преподаватель_ID = d.Преподаватель_ID
    LEFT JOIN Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID
    WHERE p.Преподаватель_ID = @Преподаватель_ID
    GROUP BY p.ФИО, p.Кафедра, p.Должность, u.Email;
    
    -- 2. Ближайшие занятия
    SELECT 
        z.Занятие_ID,
        z.Дата_Занятия,
        r.Время_Начала,
        r.Время_Окончания,
        d.Название AS Дисциплина,
        g.Название AS Группа,
        r.Кабинет,
        z.Тема_Занятия
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    WHERE d.Преподаватель_ID = @Преподаватель_ID
    AND z.Дата_Занятия BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, GETDATE())
    AND z.Статус = N'Запланировано'
    ORDER BY z.Дата_Занятия, r.Время_Начала;
    
    -- 3. Статистика посещаемости за период
    SELECT 
        d.Название AS Дисциплина,
        g.Название AS Группа,
        COUNT(DISTINCT z.Занятие_ID) AS ВсегоЗанятий,
        COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентов,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(DISTINCT s.Студент_ID) * COUNT(DISTINCT z.Занятие_ID), 0) AS DECIMAL(5,2)) AS СреднийПроцент
    FROM Дисциплина d
    INNER JOIN Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    INNER JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID
    LEFT JOIN Студент s ON r.Группа_ID = s.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE d.Преподаватель_ID = @Преподаватель_ID
    AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    GROUP BY d.Дисциплина_ID, d.Название, g.Группа_ID, g.Название
    ORDER BY d.Название, g.Название;
    
    -- 4. Последние уведомления
    SELECT TOP 10 
        ув.Заголовок,
        ув.Сообщение,
        ув.Тип,
        ув.Время_Создания,
        ув.Прочитано
    FROM Уведомления ув
    WHERE ув.Пользователь_ID = (SELECT Пользователь_ID FROM Преподаватель WHERE Преподаватель_ID = @Преподаватель_ID)
    ORDER BY ув.Время_Создания DESC;
    
    -- 5. Быстрая сводка по сегодняшним занятиям
    SELECT 
        COUNT(*) AS ЗанятийСегодня,
        SUM(CASE WHEN z.Статус = N'Проведено' THEN 1 ELSE 0 END) AS Проведено,
        SUM(CASE WHEN z.Статус = N'Запланировано' THEN 1 ELSE 0 END) AS Запланировано,
        (SELECT COUNT(DISTINCT пос.Студент_ID) 
         FROM Занятие z2
         INNER JOIN Расписание r2 ON z2.Расписание_ID = r2.Расписание_ID
         INNER JOIN Дисциплина d2 ON r2.Дисциплина_ID = d2.Дисциплина_ID
         LEFT JOIN Посещаемость пос ON z2.Занятие_ID = пос.Занятие_ID
         WHERE d2.Преподаватель_ID = @Преподаватель_ID
         AND z2.Дата_Занятия = CAST(GETDATE() AS DATE)) AS СтудентовОтмеченоСегодня
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    WHERE d.Преподаватель_ID = @Преподаватель_ID
    AND z.Дата_Занятия = CAST(GETDATE() AS DATE);
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьДетальныйОтчетПоСтуденту]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ПолучитьДетальныйОтчетПоСтуденту]
    @Студент_ID INT,
    @ДатаНачала DATE = NULL,
    @ДатаКонца DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ДатаНачала IS NULL SET @ДатаНачала = DATEADD(MONTH, -3, GETDATE());
    IF @ДатаКонца IS NULL SET @ДатаКонца = GETDATE();
    
    SELECT 
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
    FROM Занятие з
    INNER JOIN Расписание р ON з.Расписание_ID = р.Расписание_ID
    INNER JOIN Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    INNER JOIN Преподаватель преп ON д.Преподаватель_ID = преп.Преподаватель_ID
    INNER JOIN Учебная_Группа г ON р.Группа_ID = г.Группа_ID
    INNER JOIN Студент с ON г.Группа_ID = с.Группа_ID
    LEFT JOIN Посещаемость п ON з.Занятие_ID = п.Занятие_ID AND п.Студент_ID = с.Студент_ID
    LEFT JOIN Обоснования_Отсутствия о ON з.Занятие_ID = о.Занятие_ID AND о.Студент_ID = с.Студент_ID
    WHERE с.Студент_ID = @Студент_ID
      AND з.Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца
    ORDER BY з.Дата_Занятия DESC, р.Время_Начала;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьДисциплиныПреподавателя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 27. ПолучитьДисциплиныПреподавателя
CREATE PROCEDURE [dbo].[ПолучитьДисциплиныПреподавателя]
    @Преподаватель_ID INT,
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
    FROM Дисциплина d
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    LEFT JOIN Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID
    WHERE d.Преподаватель_ID = @Преподаватель_ID
    AND (@Семестр IS NULL OR d.Семестр = @Семестр)
    AND d.Статус = @Статус
    GROUP BY 
        d.Дисциплина_ID, d.Название, d.[краткое наименование], d.Преподаватель_ID,
        d.Часы_Теории, d.Часы_Практики, d.Семестр, d.Статус, d.Описание, d.Дата_Создания,
        p.ФИО, p.Кафедра
    ORDER BY d.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьЗанятияПоДате]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 32. ПолучитьЗанятияПоДате
CREATE PROCEDURE [dbo].[ПолучитьЗанятияПоДате]
    @Дата_Занятия DATE = NULL,
    @Группа_ID INT = NULL,
    @Преподаватель_ID INT = NULL,
    @Статус NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Дата_Занятия IS NULL
        SET @Дата_Занятия = CAST(GETDATE() AS DATE);
    
    SELECT 
        z.Занятие_ID,
        z.Дата_Занятия,
        z.Статус,
        z.Тема_Занятия,
        z.Кабинет,
        z.Время_Начала_Факт,
        z.Время_Окончания_Факт,
        r.Расписание_ID,
        r.День_Недели,
        r.Время_Начала AS Время_Начала_План,
        r.Время_Окончания AS Время_Окончания_План,
        r.Тип_Занятия,
        d.Дисциплина_ID,
        d.Название AS Название_Дисциплины,
        p.Преподаватель_ID,
        p.ФИО AS ФИО_Преподавателя,
        g.Группа_ID,
        g.Название AS Название_Группы,
        COUNT(DISTINCT пос.Студент_ID) AS КоличествоСтудентов,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID
    WHERE z.Дата_Занятия = @Дата_Занятия
    AND (@Группа_ID IS NULL OR r.Группа_ID = @Группа_ID)
    AND (@Преподаватель_ID IS NULL OR d.Преподаватель_ID = @Преподаватель_ID)
    AND (@Статус IS NULL OR z.Статус = @Статус)
    GROUP BY 
        z.Занятие_ID, z.Дата_Занятия, z.Статус, z.Тема_Занятия, z.Кабинет,
        z.Время_Начала_Факт, z.Время_Окончания_Факт,
        r.Расписание_ID, r.День_Недели, r.Время_Начала, r.Время_Окончания, r.Тип_Занятия,
        d.Дисциплина_ID, d.Название,
        p.Преподаватель_ID, p.ФИО,
        g.Группа_ID, g.Название
    ORDER BY r.Время_Начала;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьИсториюQRСканирований]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 40. ПолучитьИсториюQRСканирований
CREATE PROCEDURE [dbo].[ПолучитьИсториюQRСканирований]
    @QR_Сессия_ID INT = NULL,
    @Занятие_ID INT = NULL,
    @Студент_ID INT = NULL,
    @Статус NVARCHAR(30) = NULL,
    @НачалоПериода DATETIME = NULL,
    @КонецПериода DATETIME = NULL,
    @Страница INT = 1,
    @РазмерСтраницы INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(DAY, -7, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    DECLARE @Начало INT = (@Страница - 1) * @РазмерСтраницы;
    
    WITH Сканирования AS (
        SELECT 
            qrs.Сканирование_ID,
            qrs.QR_Сессия_ID,
            qrs.Студент_ID,
            qrs.Время_Сканирования,
            qrs.Устройство,
            qrs.IP_Адрес,
            qrs.Статус,
            qrs.Примечание,
            s.ФИО AS ФИО_Студента,
            g.Название AS Группа_Студента,
            qr.QR_Код,
            qr.Занятие_ID,
            z.Дата_Занятия,
            d.Название AS Дисциплина,
            p.ФИО AS Преподаватель,
            ROW_NUMBER() OVER (ORDER BY qrs.Время_Сканирования DESC) AS Номер
        FROM QR_Сканирование qrs
        INNER JOIN Студент s ON qrs.Студент_ID = s.Студент_ID
        INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
        INNER JOIN QR_Сессия qr ON qrs.QR_Сессия_ID = qr.QR_Сессия_ID
        INNER JOIN Занятие z ON qr.Занятие_ID = z.Занятие_ID
        INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
        INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
        INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
        WHERE (@QR_Сессия_ID IS NULL OR qrs.QR_Сессия_ID = @QR_Сессия_ID)
        AND (@Занятие_ID IS NULL OR qr.Занятие_ID = @Занятие_ID)
        AND (@Студент_ID IS NULL OR qrs.Студент_ID = @Студент_ID)
        AND (@Статус IS NULL OR qrs.Статус = @Статус)
        AND qrs.Время_Сканирования BETWEEN @НачалоПериода AND @КонецПериода
    )
    SELECT 
        *,
        (SELECT COUNT(*) FROM Сканирования) AS ВсегоЗаписей,
        @Страница AS ТекущаяСтраница,
        @РазмерСтраницы AS РазмерСтраницы
    FROM Сканирования
    WHERE Номер BETWEEN @Начало + 1 AND @Начало + @РазмерСтраницы
    ORDER BY Номер;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьЛогДействий]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 61. ПолучитьЛогДействий
CREATE PROCEDURE [dbo].[ПолучитьЛогДействий]
    @Пользователь_ID INT = NULL,
    @Таблица NVARCHAR(100) = NULL,
    @Статус NVARCHAR(20) = NULL,
    @Уровень_Лога NVARCHAR(20) = NULL,
    @НачалоПериода DATETIME = NULL,
    @КонецПериода DATETIME = NULL,
    @Страница INT = 1,
    @РазмерСтраницы INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(DAY, -7, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    DECLARE @Начало INT = (@Страница - 1) * @РазмерСтраницы;
    
    WITH Логи AS (
        SELECT 
            л.Лог_ID,
            л.Пользователь_ID,
            u.Логин AS ЛогинПользователя,
            COALESCE(p.ФИО, s.ФИО, u.Логин) AS ФИОПользователя,
            л.Уровень_Лога,
            л.Действие,
            л.Таблица,
            л.Запись_ID,
            л.Время_Действия,
            л.IP_Адрес,
            л.Устройство,
            л.Статус,
            л.Время_Выполнения_Мс,
            ROW_NUMBER() OVER (ORDER BY л.Время_Действия DESC) AS Номер
        FROM Лог_Действий л
        LEFT JOIN Пользователь u ON л.Пользователь_ID = u.Пользователь_ID
        LEFT JOIN Преподаватель p ON u.Пользователь_ID = p.Пользователь_ID
        LEFT JOIN Студент s ON u.Пользователь_ID = s.Пользователь_ID
        WHERE (@Пользователь_ID IS NULL OR л.Пользователь_ID = @Пользователь_ID)
        AND (@Таблица IS NULL OR л.Таблица = @Таблица)
        AND (@Статус IS NULL OR л.Статус = @Статус)
        AND (@Уровень_Лога IS NULL OR л.Уровень_Лога = @Уровень_Лога)
        AND л.Время_Действия BETWEEN @НачалоПериода AND @КонецПериода
    )
    SELECT 
        *,
        (SELECT COUNT(*) FROM Логи) AS ВсегоЗаписей,
        @Страница AS ТекущаяСтраница,
        @РазмерСтраницы AS РазмерСтраницы
    FROM Логи
    WHERE Номер BETWEEN @Начало + 1 AND @Начало + @РазмерСтраницы
    ORDER BY Номер;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьНастройки]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 51. ПолучитьНастройки
CREATE PROCEDURE [dbo].[ПолучитьНастройки]
    @Категория NVARCHAR(50) = NULL,
    @ТолькоНеАдмин BIT = 0,
    @Пользователь_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Определяем, является ли пользователь администратором
    DECLARE @УровеньДоступа INT = 0;
    IF @Пользователь_ID IS NOT NULL
    BEGIN
        SELECT @УровеньДоступа = r.Уровень_Доступа
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        WHERE u.Пользователь_ID = @Пользователь_ID AND u.Активен = 1;
    END
    
    SELECT 
        Ключ,
        Значение,
        Тип,
        Категория,
        Подкатегория,
        Описание,
        ТолькоДляАдмина,
        ТолькоДляЧтения,
        Дата_Изменения,
        Кто_Изменил,
        изм.Логин AS КтоИзменилЛогин
    FROM Настройки_Системы ns
    LEFT JOIN Пользователь изм ON ns.Кто_Изменил = изм.Пользователь_ID
    WHERE (@Категория IS NULL OR ns.Категория = @Категория)
    AND (@ТолькоНеАдмин = 0 OR ns.ТолькоДляАдмина = 0 OR @УровеньДоступа >= 100)
    ORDER BY ns.Категория, ns.Подкатегория, ns.Ключ;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьОбщуюСтатистику]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4.6 Процедуры для Директора
CREATE   PROCEDURE [dbo].[ПолучитьОбщуюСтатистику]
    @ДатаНачала DATE = NULL,
    @ДатаКонца DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ДатаНачала IS NULL SET @ДатаНачала = DATEADD(MONTH, -1, GETDATE());
    IF @ДатаКонца IS NULL SET @ДатаКонца = GETDATE();
    SELECT 
        (SELECT COUNT(*) FROM Студент) AS ВсегоСтудентов,
        (SELECT COUNT(*) FROM Преподаватель) AS ВсегоПреподавателей,
        (SELECT COUNT(DISTINCT Группа_ID) FROM Студент) AS КоличествоГрупп,
        (SELECT COUNT(*) FROM Занятие WHERE Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца) AS ВсегоЗанятий,
        (SELECT AVG(Процент) FROM (
            SELECT 
                s.Студент_ID,
                CAST(SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / COUNT(p.Посещаемость_ID) AS DECIMAL(5,2)) AS Процент
            FROM Посещаемость p
            INNER JOIN Занятие z ON p.Занятие_ID = z.Занятие_ID
            INNER JOIN Студент s ON p.Студент_ID = s.Студент_ID
            WHERE z.Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца
            GROUP BY s.Студент_ID
        ) t) AS СреднийПроцентПосещаемости;
END
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьПолнуюИсторию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 49. ПолучитьПолнуюИсторию (только для администратора)
CREATE PROCEDURE [dbo].[ПолучитьПолнуюИсторию]
    @Пользователь_ID INT,
    @ТипОтчета NVARCHAR(50) = N'Общий',
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Проверка прав администратора
    DECLARE @УровеньДоступа INT;
    
    SELECT @УровеньДоступа = r.Уровень_Доступа
    FROM Пользователь u
    INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
    WHERE u.Пользователь_ID = @Пользователь_ID AND u.Активен = 1;
    
    IF @УровеньДоступа < 100
    BEGIN
        SELECT NULL AS Результат, N'Доступ запрещен. Требуются права администратора' AS Сообщение;
        RETURN;
    END
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(YEAR, -1, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    IF @ТипОтчета = N'Общий'
    BEGIN
        SELECT 
            N'Всего студентов' AS Показатель,
            COUNT(*) AS Значение
        FROM Студент
        WHERE Дата_Поступления BETWEEN @НачалоПериода AND @КонецПериода
        
        UNION ALL
        
        SELECT 
            N'Всего преподавателей' AS Показатель,
            COUNT(*) AS Значение
        FROM Преподаватель
        
        UNION ALL
        
        SELECT 
            N'Всего занятий' AS Показатель,
            COUNT(*) AS Значение
        FROM Занятие
        WHERE Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
        
        UNION ALL
        
        SELECT 
            N'Всего отметок посещаемости' AS Показатель,
            COUNT(*) AS Значение
        FROM Посещаемость пос
        INNER JOIN Занятие z ON пос.Занятие_ID = z.Занятие_ID
        WHERE z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода;
    END
    ELSE IF @ТипОтчета = N'Посещаемость'
    BEGIN
        SELECT 
            g.Название AS Группа,
            s.ФИО AS Студент,
            d.Название AS Дисциплина,
            z.Дата_Занятия,
            пос.Статус,
            пос.Тип_Отметки,
            пос.Дата_Отметки,
            отмет.Логин AS Отметил,
            CASE 
                WHEN пос.Статус = N'Присутствовал' THEN N'✓'
                WHEN пос.Статус = N'Отсутствовал' THEN N'✗'
                WHEN пос.Статус = N'Опоздал' THEN N'↯'
                ELSE N'~'
            END AS СтатусСимвол
        FROM Посещаемость пос
        INNER JOIN Занятие z ON пос.Занятие_ID = z.Занятие_ID
        INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
        INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
        INNER JOIN Студент s ON пос.Студент_ID = s.Студент_ID
        INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
        LEFT JOIN Пользователь отмет ON пос.Кто_Отметил = отмет.Пользователь_ID
        WHERE z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
        ORDER BY z.Дата_Занятия DESC, g.Название, s.ФИО;
    END
    
    INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Статус, Параметры)
    VALUES (@Пользователь_ID, N'Запрос полной истории', N'Система', N'Успешно', 
            N'Тип=' + @ТипОтчета + N', Период=' + CONVERT(NVARCHAR, @НачалоПериода, 120) + N'-' + CONVERT(NVARCHAR, @КонецПериода, 120));
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьПользователяПоID]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. ПолучитьПользователяПоID
CREATE PROCEDURE [dbo].[ПолучитьПользователяПоID]
    @Пользователь_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.*,
        r.Название AS Название_Роли,
        r.Уровень_Доступа,
        r.Описание AS Описание_Роли,
        s.Студент_ID,
        s.ФИО AS ФИО_Студента,
        p.Преподаватель_ID,
        p.ФИО AS ФИО_Преподавателя
    FROM Пользователь u
    INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
    LEFT JOIN Студент s ON u.Пользователь_ID = s.Пользователь_ID
    LEFT JOIN Преподаватель p ON u.Пользователь_ID = p.Пользователь_ID
    WHERE u.Пользователь_ID = @Пользователь_ID;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьПосещаемостьПоЗанятию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 35. ПолучитьПосещаемостьПоЗанятию
CREATE PROCEDURE [dbo].[ПолучитьПосещаемостьПоЗанятию]
    @Занятие_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        пос.Посещаемость_ID,
        пос.Статус,
        пос.Тип_Отметки,
        пос.Примечание AS ПримечаниеПосещаемости,
        пос.Дата_Отметки,
        s.Студент_ID,
        s.ФИО AS ФИО_Студента,
        s.Группа_ID,
        g.Название AS Название_Группы,
        u.Логин AS Логин_Студента,
        u.Активен AS АктивенСтудент,
        отм.Логин AS Логин_Отметившего,
        COALESCE(преподаватель_отм.ФИО, студент_отм.ФИО, отм.Логин) AS ФИО_Отметившего
    FROM Посещаемость пос
    INNER JOIN Студент s ON пос.Студент_ID = s.Студент_ID
    INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    LEFT JOIN Пользователь отм ON пос.Кто_Отметил = отм.Пользователь_ID
    LEFT JOIN Преподаватель преподаватель_отм ON отм.Пользователь_ID = преподаватель_отм.Пользователь_ID
    LEFT JOIN Студент студент_отм ON отм.Пользователь_ID = студент_отм.Пользователь_ID
    WHERE пос.Занятие_ID = @Занятие_ID
    ORDER BY s.ФИО;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьПреподавателей]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 25. ПолучитьПреподавателей
CREATE PROCEDURE [dbo].[ПолучитьПреподавателей]
    @Кафедра NVARCHAR(100) = NULL,
    @ТолькоАктивные BIT = 1,
    @Сортировка NVARCHAR(50) = N'ФИО'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.Преподаватель_ID,
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
    FROM Преподаватель p
    INNER JOIN Пользователь u ON p.Пользователь_ID = u.Пользователь_ID
    LEFT JOIN Дисциплина d ON p.Преподаватель_ID = d.Преподаватель_ID
    LEFT JOIN Учебная_Группа g ON p.Преподаватель_ID = g.Куратор_ID
    WHERE (@Кафедра IS NULL OR p.Кафедра = @Кафедра)
    AND (@ТолькоАктивные = 0 OR u.Активен = 1)
    GROUP BY 
        p.Преподаватель_ID, p.ФИО, p.Кафедра, p.Ученая_Степень, p.Должность,
        p.Телефон_Рабочий, p.Email_Рабочий, p.Дата_Найма,
        u.Логин, u.Email, u.Телефон, u.Активен
ORDER BY 
        CASE WHEN @Сортировка = N'ФИО' THEN p.ФИО END,
        CASE WHEN @Сортировка = N'Кафедра' THEN p.Кафедра END,
        CASE WHEN @Сортировка = N'ДатаНайма' THEN p.Дата_Найма END DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьРасписаниеПоГруппе]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 29. ПолучитьРасписаниеПоГруппе
CREATE PROCEDURE [dbo].[ПолучитьРасписаниеПоГруппе]
    @Группа_ID INT,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
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
    FROM Расписание r
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    WHERE r.Группа_ID = @Группа_ID
    AND (@День_Недели IS NULL OR r.День_Недели = @День_Недели)
    AND (@Семестр IS NULL OR d.Семестр = @Семестр)
    ORDER BY r.День_Недели, r.Время_Начала;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьРасписаниеПоПреподавателю]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 30. ПолучитьРасписаниеПоПреподавателю
CREATE PROCEDURE [dbo].[ПолучитьРасписаниеПоПреподавателю]
    @Преподаватель_ID INT,
    @День_Недели TINYINT = NULL,
    @Семестр TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.Расписание_ID,
        r.День_Недели,
        r.Время_Начала,
        r.Время_Окончания,
        r.Тип_Занятия,
        r.Кабинет,
        d.Дисциплина_ID,
        d.Название AS Название_Дисциплины,
        d.Семестр,
        g.Группа_ID,
        g.Название AS Название_Группы,
        g.Год_Поступления
    FROM Расписание r
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    WHERE d.Преподаватель_ID = @Преподаватель_ID
    AND (@День_Недели IS NULL OR r.День_Недели = @День_Недели)
    AND (@Семестр IS NULL OR d.Семестр = @Семестр)
    ORDER BY r.День_Недели, r.Время_Начала, g.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьРоли]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 12. ПолучитьРоли
CREATE PROCEDURE [dbo].[ПолучитьРоли]
    @ТолькоАктивные BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Роль_ID,
        Название,
        Описание,
        Уровень_Доступа,
        Можно_Удалять,
        Дата_Создания
    FROM Роль
    WHERE (@ТолькоАктивные = 0 OR Уровень_Доступа > 0)
    ORDER BY Уровень_Доступа DESC, Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСпециальности]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4.2 ПолучитьСпециальности
CREATE   PROCEDURE [dbo].[ПолучитьСпециальности]
    @Факультет_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sp.*, f.Название AS ФакультетНазвание
    FROM Специальность sp
    LEFT JOIN Факультет f ON sp.Факультет_ID = f.Факультет_ID
    WHERE (@Факультет_ID IS NULL OR sp.Факультет_ID = @Факультет_ID)
    ORDER BY sp.Название;
END
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСписокПользователей]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 11. ПолучитьСписокПользователей
CREATE PROCEDURE [dbo].[ПолучитьСписокПользователей]
    @ТолькоАктивные BIT = 1,
    @Роль_ID INT = NULL,
    @Поиск NVARCHAR(100) = NULL,
    @Страница INT = 1,
    @РазмерСтраницы INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Начало INT = (@Страница - 1) * @РазмерСтраницы;
    
    WITH Пользователи AS (
        SELECT 
            u.Пользователь_ID,
            u.Логин,
            u.Email,
            u.Телефон,
            u.Активен,
            u.Дата_Создания,
            u.Последний_Вход,
            r.Роль_ID,
            r.Название AS Роль,
            r.Уровень_Доступа,
            s.Студент_ID,
            s.ФИО AS ФИО_Студента,
            p.Преподаватель_ID,
            p.ФИО AS ФИО_Преподавателя,
            ROW_NUMBER() OVER (ORDER BY u.Дата_Создания DESC) AS Номер
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        LEFT JOIN Студент s ON u.Пользователь_ID = s.Пользователь_ID
        LEFT JOIN Преподаватель p ON u.Пользователь_ID = p.Пользователь_ID
        WHERE (@ТолькоАктивные = 0 OR u.Активен = 1)
        AND (@Роль_ID IS NULL OR u.Роль_ID = @Роль_ID)
        AND (
            @Поиск IS NULL 
            OR u.Логин LIKE '%' + @Поиск + '%'
            OR u.Email LIKE '%' + @Поиск + '%'
            OR s.ФИО LIKE '%' + @Поиск + '%'
            OR p.ФИО LIKE '%' + @Поиск + '%'
        )
    )
    SELECT 
        *,
        (SELECT COUNT(*) FROM Пользователи) AS ВсегоЗаписей,
        @Страница AS ТекущаяСтраница,
        @РазмерСтраницы AS РазмерСтраницы
    FROM Пользователи
    WHERE Номер BETWEEN @Начало + 1 AND @Начало + @РазмерСтраницы
    ORDER BY Номер;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСтатистикуГрупп]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- إجراء: ПолучитьСтатистикуГрупп
-- الوصف: إحصائيات الحضور لكل مجموعة دراسية (لوحة البيانات)
-- المعاملات:
--   @ДатаНачала   (اختياري) -- بداية الفترة
--   @ДатаКонца    (اختياري) -- نهاية الفترة
--   @ТолькоАктивныеГруппы BIT = 1 -- فقط المجموعات النشطة
-- ============================================================
CREATE PROCEDURE [dbo].[ПолучитьСтатистикуГрупп]
    @ДатаНачала DATE = NULL,
    @ДатаКонца  DATE = NULL,
    @ТолькоАктивныеГруппы BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- إذا لم تحدد فترة، نأخذ الشهر الحالي افتراضياً
    IF @ДатаНачала IS NULL
        SET @ДатаНачала = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    IF @ДатаКонца IS NULL
        SET @ДатаКонца = EOMONTH(@ДатаНачала);

    SELECT
        g.Группа_ID,
        g.Название,
        g.Год_Поступления,
        g.Статус AS СтатусГруппы,
        COUNT(DISTINCT s.Студент_ID) AS КоличествоСтудентов,
        COUNT(DISTINCT z.Занятие_ID) AS ВсегоЗанятий,
        -- إجمالي الحضور والغياب على مستوى المجموعة
        ISNULL(SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END), 0) AS Присутствовал,
        ISNULL(SUM(CASE WHEN p.Статус = N'Отсутствовал' THEN 1 ELSE 0 END), 0) AS Отсутствовал,
        ISNULL(SUM(CASE WHEN p.Статус = N'Опоздал' THEN 1 ELSE 0 END), 0) AS Опоздал,
        ISNULL(SUM(CASE WHEN p.Статус = N'Уважительная причина' THEN 1 ELSE 0 END), 0) AS УважительнаяПричина,
        -- متوسط الحضور لكل طالب (يمكن أن يكون مفيداً)
        CAST(
            ISNULL(SUM(CASE WHEN p.Статус IN (N'Присутствовал', N'Опоздал') THEN 1 ELSE 0 END) * 100.0
                 / NULLIF(COUNT(DISTINCT s.Студент_ID) * COUNT(DISTINCT z.Занятие_ID), 0), 0)
        AS DECIMAL(5,2)) AS СреднийПроцентПосещаемости
    FROM Учебная_Группа g
    LEFT JOIN Студент s ON g.Группа_ID = s.Группа_ID
    LEFT JOIN Расписание r ON g.Группа_ID = r.Группа_ID
    LEFT JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID
                        AND z.Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца
    LEFT JOIN Посещаемость p ON z.Занятие_ID = p.Занятие_ID
                            AND p.Студент_ID = s.Студент_ID
    WHERE (@ТолькоАктивныеГруппы = 0 OR g.Статус = N'Активна')
    GROUP BY g.Группа_ID, g.Название, g.Год_Поступления, g.Статус
    ORDER BY СреднийПроцентПосещаемости ASC;  -- الأسوأ أولاً (لدعم اتخاذ القرارات)
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСтудентаПоID]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 18. ПолучитьСтудентаПоID
CREATE PROCEDURE [dbo].[ПолучитьСтудентаПоID]
    @Студент_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.*,
        u.Логин,
        u.Email,
        u.Телефон,
        u.Активен AS АктивенПользователь,
        g.Название AS Название_Группы,
        g.Год_Поступления,
        g.Статус AS СтатусГруппы,
        prep.ФИО AS ФИО_Куратора
    FROM Студент s
    INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    LEFT JOIN Преподаватель prep ON g.Куратор_ID = prep.Преподаватель_ID
    WHERE s.Студент_ID = @Студент_ID;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСтудентовПоГруппе]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 19. ПолучитьСтудентовПоГруппе
CREATE PROCEDURE [dbo].[ПолучитьСтудентовПоГруппе]
    @Группа_ID INT,
    @ТолькоАктивные BIT = 1,
    @Сортировка NVARCHAR(50) = N'ФИО'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.Студент_ID,
        s.ФИО,
        s.Дата_Рождения,
        s.Пол,
        s.Дата_Поступления,
        s.Адрес,
        s.Телефон_Родителей,
        u.Логин,
        u.Email,
        u.Телефон AS Телефон_Студента,
        u.Активен,
        g.Название AS Название_Группы
    FROM Студент s
    INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    WHERE s.Группа_ID = @Группа_ID
    AND (@ТолькоАктивные = 0 OR u.Активен = 1)
ORDER BY 
        CASE WHEN @Сортировка = N'ФИО' THEN s.ФИО END,
        CASE WHEN @Сортировка = N'ДатаПоступления' THEN s.Дата_Поступления END DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьСтудентовПоКуратору]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4.5 Процедуры для Куратора
CREATE   PROCEDURE [dbo].[ПолучитьСтудентовПоКуратору]
    @Куратор_ID INT,
    @ТолькоАктивные BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.*, u.Логин, u.Email, u.Телефон, u.Активен
    FROM Студент s
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    WHERE g.Куратор_ID = @Куратор_ID
    AND (@ТолькоАктивные = 0 OR u.Активен = 1)
    ORDER BY s.ФИО;
END
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьУведомленияПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 54. ПолучитьУведомленияПользователя
CREATE PROCEDURE [dbo].[ПолучитьУведомленияПользователя]
    @Пользователь_ID INT,
    @ТолькоНепрочитанные BIT = 1,
    @Тип NVARCHAR(50) = NULL,
    @Лимит INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@Лимит) 
        ув.*,
        CASE 
            WHEN ув.Тип = N'Важное' THEN 'urgent'
            WHEN ув.Тип = N'Ошибка' THEN 'error'
            WHEN ув.Тип = N'Предупреждение' THEN 'warning'
            WHEN ув.Тип = N'Информация' THEN 'info'
            ELSE 'system'
        END AS КлассCSS
    FROM Уведомления ув
    WHERE ув.Пользователь_ID = @Пользователь_ID
    AND (@ТолькоНепрочитанные = 0 OR ув.Прочитано = 0)
    AND (@Тип IS NULL OR ув.Тип = @Тип)
    AND (ув.Срок_Действия IS NULL OR ув.Срок_Действия > GETDATE())
    ORDER BY ув.Время_Создания DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьУчебныеГруппы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 23. ПолучитьУчебныеГруппы
CREATE PROCEDURE [dbo].[ПолучитьУчебныеГруппы]
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
        g.Примечание,
        g.Дата_Создания,
        COUNT(s.Студент_ID) AS КоличествоСтудентов
    FROM Учебная_Группа g
    LEFT JOIN Преподаватель p ON g.Куратор_ID = p.Преподаватель_ID
    LEFT JOIN Студент s ON g.Группа_ID = s.Группа_ID
    WHERE (@Год_Поступления IS NULL OR g.Год_Поступления = @Год_Поступления)
    AND (@Статус IS NULL OR g.Статус = @Статус)
    GROUP BY 
        g.Группа_ID, g.Название, g.Год_Поступления, g.Статус, 
        g.Куратор_ID, p.ФИО, g.Примечание, g.Дата_Создания
ORDER BY 
        CASE WHEN @Сортировка = N'Название' THEN g.Название END,
        CASE WHEN @Сортировка = N'ГодПоступления' THEN g.Год_Поступления END DESC,
        CASE WHEN @Сортировка = N'Статус' THEN g.Статус END;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьФакультеты]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[ПолучитьФакультеты]
    @ТолькоАктивные BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Факультет_ID, Название, Описание, Дата_Создания
    FROM Факультет
    WHERE (@ТолькоАктивные = 0 OR 1=1) -- В данной версии нет флага активности, можно добавить позже
    ORDER BY Название;
END
GO
/****** Object:  StoredProcedure [dbo].[ПолучитьШаблоныОтчетов]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 57. ПолучитьШаблоныОтчетов
CREATE PROCEDURE [dbo].[ПолучитьШаблоныОтчетов]
    @Тип NVARCHAR(50) = NULL,
    @ТолькоАктивные BIT = 1,
    @Общедоступные BIT = NULL,
    @Пользователь_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ш.*,
        u.Логин AS ЛогинСоздателя,
        COALESCE(p.ФИО, s.ФИО, u.Логин) AS ФИОСоздателя
    FROM Шаблоны_Отчетов ш
    INNER JOIN Пользователь u ON ш.Кто_Создал = u.Пользователь_ID
    LEFT JOIN Преподаватель p ON u.Пользователь_ID = p.Пользователь_ID
    LEFT JOIN Студент s ON u.Пользователь_ID = s.Пользователь_ID
    WHERE (@Тип IS NULL OR ш.Тип = @Тип)
    AND (@ТолькоАктивные = 0 OR ш.Активен = 1)
    AND (
        @Общедоступные IS NULL 
        OR ш.Общедоступный = @Общедоступные
        OR (@Пользователь_ID IS NOT NULL AND ш.Кто_Создал = @Пользователь_ID)
    )
    ORDER BY ш.Порядок, ш.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПометитьУведомленияПрочитанными]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 55. ПометитьУведомленияПрочитанными
CREATE PROCEDURE [dbo].[ПометитьУведомленияПрочитанными]
    @Пользователь_ID INT,
    @Уведомление_ID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Уведомления
        SET Прочитано = 1,
            Время_Прочтения = GETDATE()
        WHERE Пользователь_ID = @Пользователь_ID
        AND Прочитано = 0
        AND (@Уведомление_ID IS NULL OR Уведомление_ID = @Уведомление_ID)
        AND (Срок_Действия IS NULL OR Срок_Действия > GETDATE());
        
        DECLARE @ОбновленоУведомлений INT = @@ROWCOUNT;
        
        IF @ОбновленоУведомлений > 0
        BEGIN
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Статус)
            VALUES (@Пользователь_ID, N'Пометка уведомлений прочитанными', N'Уведомления', N'Успешно');
        END
        
        SELECT @ОбновленоУведомлений AS ОбновленоУведомлений;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ПринятьСобытиеСКУД]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 41. ПринятьСобытиеСКУД
CREATE PROCEDURE [dbo].[ПринятьСобытиеСКУД]
    @Устройство_ID INT,
    @Номер_Карты NVARCHAR(50),
    @Тип_События NVARCHAR(30),
    @Направление NVARCHAR(20) = NULL,
    @Температура DECIMAL(4,1) = NULL,
    @Фото_URL NVARCHAR(500) = NULL,
    @Данные_Датчиков NVARCHAR(MAX) = NULL,
    @Зона_Доступа NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @Карта_ID INT;
        DECLARE @Студент_ID INT;
        DECLARE @Результат NVARCHAR(50) = N'Обработано';
        DECLARE @ПричинаЗапрета NVARCHAR(200) = NULL;
        
        -- Поиск карты
        SELECT 
            @Карта_ID = Карта_ID, 
            @Студент_ID = Студент_ID
        FROM СКУД_Карта
        WHERE Номер_Карты = @Номер_Карты 
        AND Статус = N'Активна'
        AND Дата_Истечения > GETDATE();
        
        IF @Карта_ID IS NULL
        BEGIN
            SET @Результат = N'Карта не найдена или неактивна';
            SET @ПричинаЗапрета = N'Недействительная карта';
            SET @Тип_События = N'Неизвестная_карта';
        END
        
        -- Запись события
        INSERT INTO СКУД_Событие (
            Устройство_ID, Карта_ID, Тип_События, Направление, Зона_Доступа,
            Результат, Причина_Запрета, Температура, Фото_URL, Данные_Датчиков
        )
        VALUES (
            @Устройство_ID, @Карта_ID, @Тип_События, @Направление, @Зона_Доступа,
            @Результат, @ПричинаЗапрета, @Температура, @Фото_URL, @Данные_Датчиков
        );
        
        DECLARE @Событие_ID BIGINT = SCOPE_IDENTITY();
        
        -- Если вход разрешён, пытаемся связать с занятием
        IF @Тип_События = N'Вход_разрешен' AND @Студент_ID IS NOT NULL
        BEGIN
            DECLARE @ТекущееВремя DATETIME = GETDATE();
            DECLARE @Занятие_ID INT;
            
            -- Поиск активного занятия для студента
            SELECT TOP 1 @Занятие_ID = z.Занятие_ID
            FROM Занятие z
            INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
            INNER JOIN Студент s ON r.Группа_ID = s.Группа_ID
            WHERE s.Студент_ID = @Студент_ID
            AND z.Дата_Занятия = CAST(@ТекущееВремя AS DATE)
            AND z.Статус = N'Проведено'
            AND CAST(@ТекущееВремя AS TIME) BETWEEN 
                DATEADD(MINUTE, -30, r.Время_Начала) AND DATEADD(MINUTE, 30, r.Время_Окончания)
            ORDER BY ABS(DATEDIFF(MINUTE, @ТекущееВремя, 
                      CAST(z.Дата_Занятия AS DATETIME) + CAST(r.Время_Начала AS DATETIME)));
            
            IF @Занятие_ID IS NOT NULL
            BEGIN
                EXEC ОтметитьПосещаемость 
                    @Занятие_ID = @Занятие_ID,
                    @Студент_ID = @Студент_ID,
                    @Статус = N'Присутствовал',
                    @Примечание = N'Автоматическая отметка через СКУД',
                    @КтоОтметил = 0; -- системный пользователь
                
                UPDATE СКУД_Событие 
                SET Результат = N'Привязано к занятию ' + CAST(@Занятие_ID AS NVARCHAR)
                WHERE Событие_ID = @Событие_ID;
            END
        END
        
        COMMIT TRANSACTION;
        
        SELECT 
            @Событие_ID AS Событие_ID, 
            @Результат AS Результат,
            @Карта_ID AS Карта_ID,
            @Студент_ID AS Студент_ID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьQRИОтметить]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

        CREATE PROCEDURE [dbo].[ПроверитьQRИОтметить]
            @QR_Код NVARCHAR(500),
            @Студент_ID INT,
            @Устройство NVARCHAR(100) = NULL,
            @IP_Адрес NVARCHAR(45) = NULL
        AS
        BEGIN
            SET NOCOUNT ON;
            
            BEGIN TRY
                BEGIN TRANSACTION;
                
                DECLARE @QR_Сессия_ID INT;
                DECLARE @Занятие_ID INT;
                DECLARE @ВремяНачала DATETIME;
                DECLARE @ВремяКонца DATETIME;
                DECLARE @СтатусСессии NVARCHAR(20);
                DECLARE @КтоСоздал INT;
                DECLARE @Результат NVARCHAR(30) = N'Ошибка';
                DECLARE @Сообщение NVARCHAR(200) = N'';
                
                -- Поиск сессии по QR-коду
                SELECT 
                    @QR_Сессия_ID = QR_Сессия_ID, 
                    @Занятие_ID = Занятие_ID,
                    @ВремяНачала = Время_Действия_Начало,
                    @ВремяКонца = Время_Действия_Конец,
                    @СтатусСессии = Статус,
                    @КтоСоздал = Кто_Создал
                FROM QR_Сессия 
                WHERE QR_Код = @QR_Код;
                
                IF @QR_Сессия_ID IS NULL
                BEGIN
                    SET @Результат = N'Недействительный_QR';
                    SET @Сообщение = N'QR код не найден';
                    GOTO ЗаписьРезультата;
                END
                
                IF @СтатусСессии != N'Активен'
                BEGIN
                    SET @Результат = N'Недействительный_QR';
                    SET @Сообщение = N'QR сессия не активна';
                    GOTO ЗаписьРезультата;
                END
                
                DECLARE @ТекущееВремя DATETIME = GETDATE();
                IF @ТекущееВремя < @ВремяНачала
                BEGIN
                    SET @Результат = N'Вне_времени';
                    SET @Сообщение = N'QR код ещё не активен';
                    GOTO ЗаписьРезультата;
                END
                
                IF @ТекущееВремя > @ВремяКонца
                BEGIN
                    SET @Результат = N'Вне_времени';
                    SET @Сообщение = N'Время действия QR кода истекло';
                    
                    UPDATE QR_Сессия 
                    SET Статус = N'Завершен'
                    WHERE QR_Сессия_ID = @QR_Сессия_ID;
                    
                    GOTO ЗаписьРезультата;
                END
                
                -- Проверка на повторное сканирование
                IF EXISTS (SELECT 1 FROM QR_Сканирование 
                          WHERE QR_Сессия_ID = @QR_Сессия_ID AND Студент_ID = @Студент_ID)
                BEGIN
                    SET @Результат = N'Повторное_сканирование';
                    SET @Сообщение = N'Студент уже отсканировал этот QR код';
                    GOTO ЗаписьРезультата;
                END
                
                -- ============================================================
                -- НОВАЯ ПРОВЕРКА: наличие студента в здании через СКУД
                -- ============================================================
                DECLARE @Карта_ID INT;
                SELECT @Карта_ID = Карта_ID FROM СКУД_Карта WHERE Студент_ID = @Студент_ID;
                
                IF @Карта_ID IS NOT NULL
                BEGIN
                    DECLARE @ПоследнийВход DATETIME;
                    DECLARE @ПоследнийВыход DATETIME;
                    
                    -- Последний вход
                    SELECT TOP 1 @ПоследнийВход = Время_События
                    FROM СКУД_Событие
                    WHERE Карта_ID = @Карта_ID AND Тип_События = N'Вход_разрешен'
                    ORDER BY Время_События DESC;
                    
                    -- Последний выход после последнего входа
                    SELECT TOP 1 @ПоследнийВыход = Время_События
                    FROM СКУД_Событие
                    WHERE Карта_ID = @Карта_ID AND Тип_События = N'Выход_разрешен'
                      AND Время_События > @ПоследнийВход
                    ORDER BY Время_События DESC;
                    
                    -- Если нет входа за последние 30 минут или есть выход после входа
                    IF @ПоследнийВход IS NULL 
                       OR @ПоследнийВход < DATEADD(MINUTE, -30, GETDATE())
                       OR (@ПоследнийВыход IS NOT NULL AND @ПоследнийВыход > @ПоследнийВход)
                    BEGIN
                        SET @Результат = N'Вне_здания';
                        SET @Сообщение = N'Студент должен находиться в здании для сканирования QR';
                        GOTO ЗаписьРезультата;
                    END
                END
                -- Если у студента нет карты, то пропускаем проверку (или можно запретить)
                
                -- Проверка принадлежности студента к группе занятия
                DECLARE @ГруппаIDЗанятия INT;
                SELECT @ГруппаIDЗанятия = r.Группа_ID
                FROM Занятие z
                INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
                WHERE z.Занятие_ID = @Занятие_ID;
                
                DECLARE @ГруппаIDСтудента INT;
                SELECT @ГруппаIDСтудента = Группа_ID
                FROM Студент
                WHERE Студент_ID = @Студент_ID;
                
                IF @ГруппаIDЗанятия != @ГруппаIDСтудента
                BEGIN
                    SET @Результат = N'Ошибка';
                    SET @Сообщение = N'Студент не принадлежит к группе этого занятия';
                    GOTO ЗаписьРезультата;
                END
                
                -- Автоматическая отметка посещаемости
                DECLARE @РезультатПосещаемости TABLE (Посещаемость_ID INT, Отмечено INT, Сообщение NVARCHAR(200));
                
                INSERT INTO @РезультатПосещаемости
                EXEC ОтметитьПосещаемость 
                    @Занятие_ID = @Занятие_ID,
                    @Студент_ID = @Студент_ID,
                    @Статус = N'Присутствовал',
                    @Примечание = N'Автоматическая отметка через QR',
                    @КтоОтметил = @КтоСоздал;
                
                DECLARE @Успешно INT;
                SELECT @Успешно = Отмечено FROM @РезультатПосещаемости;
                
                IF @Успешно = 1
                BEGIN
                    SET @Результат = N'Успешно';
                    SET @Сообщение = N'Посещаемость успешно отмечена';
                END
                ELSE
                BEGIN
                    SET @Результат = N'Ошибка';
                    SET @Сообщение = N'Ошибка при отметке посещаемости';
                END
                
                ЗаписьРезультата:
                -- Запись сканирования
                INSERT INTO QR_Сканирование (
                    QR_Сессия_ID, Студент_ID, Устройство, IP_Адрес, Статус, Примечание
                )
                VALUES (
                    @QR_Сессия_ID, @Студент_ID, @Устройство, @IP_Адрес, @Результат, @Сообщение
                );
                
                DECLARE @СканированиеID INT = SCOPE_IDENTITY();
                
                INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
                VALUES (@Студент_ID, N'Сканирование QR кода', N'QR_Сканирование', @СканированиеID, 
                        @Результат, N'QR=' + @QR_Код + N', Сообщение=' + @Сообщение);
                
                SELECT 
                    @Результат AS Статус,
                    @Сообщение AS Сообщение,
                    @СканированиеID AS Сканирование_ID,
                    @Занятие_ID AS Занятие_ID,
                    @QR_Сессия_ID AS QR_Сессия_ID;
                
                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                
                INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
                VALUES (N'Ошибка сканирования QR', N'QR_Сканирование', N'Ошибка', 
                        N'QR=' + @QR_Код + N', Студент_ID=' + CAST(@Студент_ID AS NVARCHAR));
                
                THROW;
            END CATCH
        END
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьДоступПоРоли]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. ПроверитьДоступПоРоли
CREATE PROCEDURE [dbo].[ПроверитьДоступПоРоли]
    @Пользователь_ID INT,
    @ТребуемаяРоль NVARCHAR(50) = NULL,
    @МинимальныйУровень INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @РольПользователя NVARCHAR(50);
    DECLARE @УровеньПользователя INT;
    
    SELECT 
        @РольПользователя = r.Название,
        @УровеньПользователя = r.Уровень_Доступа
    FROM Пользователь u
    INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
    WHERE u.Пользователь_ID = @Пользователь_ID
    AND u.Активен = 1;
    
    IF @РольПользователя IS NULL
    BEGIN
        SELECT 0 AS ДоступРазрешен, N'Пользователь не найден или неактивен' AS Сообщение;
        RETURN;
    END
    
    DECLARE @Разрешен BIT = 0;
    
    IF @ТребуемаяРоль IS NOT NULL AND @РольПользователя = @ТребуемаяРоль
        SET @Разрешен = 1;
    ELSE IF @МинимальныйУровень IS NOT NULL AND @УровеньПользователя >= @МинимальныйУровень
        SET @Разрешен = 1;
    
    SELECT 
        @Разрешен AS ДоступРазрешен,
        @РольПользователя AS РольПользователя,
        @УровеньПользователя AS УровеньДоступа;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьПорогПосещаемости]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ПроверитьПорогПосещаемости]
    @ПорогПроцентов INT = 30,
    @Семестр TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ТекущийСеместр TINYINT = ISNULL(@Семестр, 
        CASE WHEN MONTH(GETDATE()) BETWEEN 9 AND 12 THEN 1 ELSE 2 END);
    
    -- Временная таблица для студентов, превысивших порог
    WITH СтудентыПропуски AS (
        SELECT 
            s.Студент_ID,
            s.Пользователь_ID,
            s.ФИО,
            g.Название AS Группа,
            d.Дисциплина_ID,
            d.Название AS Дисциплина,
            COUNT(z.Занятие_ID) AS ВсегоЗанятий,
            SUM(CASE WHEN p.Статус IN (N'Отсутствовал', N'Опоздал') THEN 1 ELSE 0 END) AS Пропуски,
            CAST(SUM(CASE WHEN p.Статус IN (N'Отсутствовал', N'Опоздал') THEN 1.0 ELSE 0 END) * 100.0 
                 / NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ПроцентПропусков
        FROM Студент s
        INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
        INNER JOIN Расписание r ON g.Группа_ID = r.Группа_ID
        INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
        INNER JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID
        LEFT JOIN Посещаемость p ON z.Занятие_ID = p.Занятие_ID AND p.Студент_ID = s.Студент_ID
        WHERE d.Семестр = @ТекущийСеместр
          AND z.Дата_Занятия BETWEEN DATEFROMPARTS(YEAR(GETDATE()), 1, 1) AND GETDATE()
        GROUP BY s.Студент_ID, s.Пользователь_ID, s.ФИО, g.Название,
                 d.Дисциплина_ID, d.Название
        HAVING COUNT(z.Занятие_ID) > 0
           AND CAST(SUM(CASE WHEN p.Статус IN (N'Отсутствовал', N'Опоздал') THEN 1.0 ELSE 0 END) * 100.0 
                 / NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) >= @ПорогПроцентов
    )
    INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Срок_Действия)
    SELECT 
        sp.Пользователь_ID,
        N'Предупреждение',
        CONCAT(N'Превышение порога пропусков по предмету "', sp.Дисциплина, N'"'),
        CONCAT(
            N'Вы пропустили ', sp.Пропуски, N' из ', sp.ВсегоЗанятий, 
            N' занятий (', sp.ПроцентПропусков, N'%). ',
            N'Обратитесь к куратору для выяснения причин.'
        ),
        DATEADD(DAY, 7, GETDATE())
    FROM СтудентыПропуски sp
    WHERE NOT EXISTS (
        SELECT 1 FROM Уведомления у
        WHERE у.Пользователь_ID = sp.Пользователь_ID
          AND у.Заголовок LIKE N'%Превышение порога пропусков%'
          AND у.Время_Создания > DATEADD(DAY, -7, GETDATE())
    );
    
    SELECT @@ROWCOUNT AS СозданоУведомлений;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьСессию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ПроверитьСессию]
    @Сессия_ID UNIQUEIDENTIFIER,
    @Токен NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Пользователь_ID INT,
            @Активна BIT,
            @ВремяИстечения DATETIME,
            @Роль NVARCHAR(50);

    SELECT 
        @Пользователь_ID = sp.Пользователь_ID,
        @Активна = sp.Активна,
        @ВремяИстечения = sp.Время_Истечения,
        @Роль = r.Название
    FROM dbo.Сессия_Пользователя sp
    INNER JOIN dbo.Пользователь u ON sp.Пользователь_ID = u.Пользователь_ID
    INNER JOIN dbo.Роль r ON u.Роль_ID = r.Роль_ID
    WHERE sp.Сессия_ID = @Сессия_ID
      AND sp.Токен = @Токен;

    IF @Пользователь_ID IS NOT NULL 
       AND @Активна = 1 
       AND @ВремяИстечения > GETDATE()
    BEGIN
        -- Продлеваем сессию на 2 часа
        UPDATE dbo.Сессия_Пользователя
        SET Время_Истечения = DATEADD(HOUR, 2, GETDATE())
        WHERE Сессия_ID = @Сессия_ID;

        SELECT 
            1 AS Действительна,
            @Пользователь_ID AS Пользователь_ID,
            @Роль AS Роль,
            DATEADD(HOUR, 2, GETDATE()) AS НовоеВремяИстечения;
    END
    ELSE
    BEGIN
        -- Если сессия недействительна, завершаем её
        IF @Пользователь_ID IS NOT NULL AND @Активна = 1
        BEGIN
            UPDATE dbo.Сессия_Пользователя
            SET Активна = 0,
                Причина_Завершения = N'Истек срок действия'
            WHERE Сессия_ID = @Сессия_ID;
        END

        SELECT 0 AS Действительна, NULL AS Пользователь_ID, NULL AS Роль, NULL AS НовоеВремяИстечения;
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьСостояниеСистемы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 64. ПроверитьСостояниеСистемы
CREATE PROCEDURE [dbo].[ПроверитьСостояниеСистемы]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Результат TABLE (
        Компонент NVARCHAR(100),
        Статус NVARCHAR(50),
        Значение NVARCHAR(200),
        Приоритет INT
    );
    
    -- 1. База данных
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'База данных',
        N'Работает',
        N'Версия: ' + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)),
        1;
    
    -- 2. Активные пользователи
    DECLARE @АктивныхПользователей INT;
    SELECT @АктивныхПользователей = COUNT(*)
    FROM Пользователь 
    WHERE Активен = 1;
    
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'Пользователи',
        CASE WHEN @АктивныхПользователей > 0 THEN N'Активны' ELSE N'Нет активных' END,
        N'Активных: ' + CAST(@АктивныхПользователей AS NVARCHAR),
        2;
    
    -- 3. Активные сессии
    DECLARE @АктивныхСессий INT;
    SELECT @АктивныхСессий = COUNT(*)
    FROM Сессия_Пользователя 
    WHERE Активна = 1 AND Время_Истечения > GETDATE();
    
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'Сессии',
        CASE WHEN @АктивныхСессий > 0 THEN N'Активны' ELSE N'Нет активных' END,
        N'Активных сессий: ' + CAST(@АктивныхСессий AS NVARCHAR),
        3;
    
    -- 4. Занятия сегодня
    DECLARE @ЗанятийСегодня INT;
    SELECT @ЗанятийСегодня = COUNT(*)
    FROM Занятие 
    WHERE Дата_Занятия = CAST(GETDATE() AS DATE);
    
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'Занятия сегодня',
        CASE WHEN @ЗанятийСегодня > 0 THEN N'Есть занятия' ELSE N'Нет занятий' END,
        N'Количество: ' + CAST(@ЗанятийСегодня AS NVARCHAR),
        4;
    
    -- 5. Последняя ошибка
    DECLARE @ПоследняяОшибка NVARCHAR(MAX);
    DECLARE @ВремяОшибки DATETIME;
    
    SELECT TOP 1 
        @ПоследняяОшибка = Сообщение,
        @ВремяОшибки = Дата_Возникновения
    FROM Ошибки_Системы 
    WHERE Уровень_Ошибки IN (N'Высокий', N'Критический')
    ORDER BY Дата_Возникновения DESC;
    
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'Последняя ошибка',
        CASE WHEN @ПоследняяОшибка IS NULL THEN N'Ошибок нет' ELSE N'Были ошибки' END,
        CASE 
            WHEN @ПоследняяОшибка IS NULL THEN N'Нет критических ошибок'
            ELSE N'Была: ' + LEFT(@ПоследняяОшибка, 100) + N'... в ' + CONVERT(NVARCHAR, @ВремяОшибки, 120)
        END,
        5;
    
    -- 6. Резервное копирование
    DECLARE @ПоследняяКопия DATETIME;
    SELECT TOP 1 @ПоследняяКопия = Дата_Создания
    FROM Резервные_Копии 
    WHERE Статус = N'Успешно'
    ORDER BY Дата_Создания DESC;
    
    DECLARE @ДнейСПоследнейКопии INT = DATEDIFF(DAY, ISNULL(@ПоследняяКопия, '1900-01-01'), GETDATE());
    
    INSERT INTO @Результат (Компонент, Статус, Значение, Приоритет)
    SELECT 
        N'Резервное копирование',
        CASE 
            WHEN @ПоследняяКопия IS NULL THEN N'Не выполнялось'
            WHEN @ДнейСПоследнейКопии > 7 THEN N'Тревога'
            WHEN @ДнейСПоследнейКопии > 3 THEN N'Внимание'
            ELSE N'Норма'
        END,
        CASE 
            WHEN @ПоследняяКопия IS NULL THEN N'Копии не создавались'
            ELSE N'Последняя: ' + CONVERT(NVARCHAR, @ПоследняяКопия, 104) + N' (' + CAST(@ДнейСПоследнейКопии AS NVARCHAR) + N' дн. назад)'
        END,
        6;
    
    SELECT * FROM @Результат ORDER BY Приоритет;
END;
GO
/****** Object:  StoredProcedure [dbo].[ПроверитьЦелостностьДанных]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Проверка целостности данных
-- =============================================
CREATE PROCEDURE [dbo].[ПроверитьЦелостностьДанных]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Результаты TABLE (
        Проверка NVARCHAR(200),
        Статус NVARCHAR(20),
        Сообщение NVARCHAR(MAX)
    );
    
    -- 1. Студенты без пользователей
    INSERT INTO @Результаты
    SELECT 
        N'Студенты без пользователей',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено студентов без привязки к пользователю: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM Студент s
    LEFT JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
    WHERE u.Пользователь_ID IS NULL;
    
    -- 2. Пользователи без роли
    INSERT INTO @Результаты
    SELECT 
        N'Пользователи без роли',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено пользователей без роли: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM Пользователь u
    LEFT JOIN Роль r ON u.Роль_ID = r.Роль_ID
    WHERE r.Роль_ID IS NULL;
    
    -- 3. Занятия без расписания
    INSERT INTO @Результаты
    SELECT 
        N'Занятия без расписания',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено занятий без расписания: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM Занятие z
    LEFT JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    WHERE r.Расписание_ID IS NULL;
    
    -- 4. Посещаемость без студентов или занятий
    INSERT INTO @Результаты
    SELECT 
        N'Посещаемость без студентов',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено записей посещаемости без студентов: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM Посещаемость p
    LEFT JOIN Студент s ON p.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID IS NULL;
    
    INSERT INTO @Результаты
    SELECT 
        N'Посещаемость без занятий',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено записей посещаемости без занятий: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM Посещаемость p
    LEFT JOIN Занятие z ON p.Занятие_ID = z.Занятие_ID
    WHERE z.Занятие_ID IS NULL;
    
    -- 5. QR-сессии без занятий
    INSERT INTO @Результаты
    SELECT 
        N'QR-сессии без занятий',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено QR-сессий без занятий: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM QR_Сессия qr
    LEFT JOIN Занятие z ON qr.Занятие_ID = z.Занятие_ID
    WHERE z.Занятие_ID IS NULL;
    
    -- 6. Карты СКУД без студентов
    INSERT INTO @Результаты
    SELECT 
        N'Карты СКУД без студентов',
        CASE WHEN COUNT(*) = 0 THEN N'OK' ELSE N'Ошибка' END,
        N'Найдено карт СКУД без студентов: ' + CAST(COUNT(*) AS NVARCHAR)
    FROM СКУД_Карта sk
    LEFT JOIN Студент s ON sk.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID IS NULL;
    
    SELECT * FROM @Результаты;
END;
GO
/****** Object:  StoredProcedure [dbo].[СгенерироватьQRДляЗанятия]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 36. СгенерироватьQRДляЗанятия
CREATE PROCEDURE [dbo].[СгенерироватьQRДляЗанятия]
    @Занятие_ID INT,
    @Название_Сессии NVARCHAR(100) = NULL,
    @Срок_Действия_Минут INT = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Проверка существования занятия
        IF NOT EXISTS (SELECT 1 FROM Занятие WHERE Занятие_ID = @Занятие_ID)
            RAISERROR(N'Занятие не найдено', 16, 1);
        
        -- Получение настройки длительности по умолчанию
        DECLARE @ДлительностьПоУмолчанию INT;
        SELECT @ДлительностьПоУмолчанию = CAST(Значение AS INT)
        FROM Настройки_Системы 
        WHERE Ключ = N'QR.ДлительностьПоУмолчанию';
        
        SET @Срок_Действия_Минут = ISNULL(@Срок_Действия_Минут, @ДлительностьПоУмолчанию);
        
        -- Генерация уникального QR-кода (хеш от занятия + время + случайное число)
        DECLARE @QR_Код NVARCHAR(500);
        DECLARE @СлучайнаяЧасть NVARCHAR(100) = CAST(NEWID() AS NVARCHAR(36));
        DECLARE @ВремяЧасть NVARCHAR(30) = REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(30), GETDATE(), 120), '-', ''), ':', ''), ' ', '');
        DECLARE @ДанныеДляХэша NVARCHAR(300) = CAST(@Занятие_ID AS NVARCHAR(20)) + '_' + @СлучайнаяЧасть + '_' + @ВремяЧасть;
        SET @QR_Код = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @ДанныеДляХэша), 2);
        
        -- Временные рамки
        DECLARE @ВремяНачала DATETIME = GETDATE();
        DECLARE @ВремяКонца DATETIME = DATEADD(MINUTE, @Срок_Действия_Минут, @ВремяНачала);
        
        -- Завершение предыдущих активных сессий для этого занятия
        UPDATE QR_Сессия 
        SET Статус = N'Отменен',
            Примечание = ISNULL(Примечание, '') + ' | Автоматически отменено при создании новой сессии'
        WHERE Занятие_ID = @Занятие_ID AND Статус = N'Активен';
        
        -- Создание новой QR-сессии
        INSERT INTO QR_Сессия (
            Занятие_ID, Название_Сессии, QR_Код, Время_Действия_Начало, Время_Действия_Конец,
            Срок_Действия_Минут, Кто_Создал
        )
        VALUES (
            @Занятие_ID, @Название_Сессии, @QR_Код, @ВремяНачала, @ВремяКонца,
            @Срок_Действия_Минут, @КтоСоздал
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        -- Логирование
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Генерация QR кода', N'QR_Сессия', @НовыйID, N'Успешно');
        
        -- Возврат данных
        SELECT 
            @QR_Код AS QR_Код,
            @НовыйID AS QR_Сессия_ID,
            @ВремяНачала AS Время_Создания,
            @ВремяКонца AS Время_Истечения,
            @Срок_Действия_Минут AS Срок_Действия_Минут,
            N'QR код успешно создан' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СобратьСтатистикуСистемы]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 50. СобратьСтатистикуСистемы
CREATE PROCEDURE [dbo].[СобратьСтатистикуСистемы]
    @Дата DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Дата IS NULL
        SET @Дата = CAST(GETDATE() AS DATE);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Удаляем старую статистику за эту дату
        DELETE FROM Статистика_Системы 
        WHERE Дата_Статистики = @Дата;
        
        -- 1. Статистика пользователей
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3, Значение_4)
        SELECT 
            @Дата,
            N'Пользователи',
            COUNT(*) AS ВсегоПользователей,
            SUM(CASE WHEN Активен = 1 THEN 1 ELSE 0 END) AS Активных,
            SUM(CASE WHEN Последний_Вход >= DATEADD(DAY, -7, GETDATE()) THEN 1 ELSE 0 END) AS АктивноЗаНеделю,
            COUNT(DISTINCT Роль_ID) AS РазличныхРолей
        FROM Пользователь;
        
        -- 2. Статистика студентов
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3)
        SELECT 
            @Дата,
            N'Студенты',
            COUNT(*) AS ВсегоСтудентов,
            COUNT(DISTINCT Группа_ID) AS КоличествоГрупп,
            AVG(DATEDIFF(YEAR, Дата_Рождения, GETDATE())) AS СреднийВозраст
        FROM Студент;
        
        -- 3. Статистика посещаемости за день
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3)
        SELECT 
            @Дата,
            N'Посещаемость',
            COUNT(DISTINCT z.Занятие_ID) AS ВсегоЗанятий,
            COUNT(DISTINCT пос.Студент_ID) AS СтудентовСОтметками,
            SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало
        FROM Занятие z
        LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID
        WHERE z.Дата_Занятия = @Дата;
        
        -- 4. Статистика QR
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3)
        SELECT 
            @Дата,
            N'QR',
            COUNT(*) AS ВсегоСессий,
            SUM(CASE WHEN Статус = N'Активен' THEN 1 ELSE 0 END) AS АктивныхСессий,
            (SELECT COUNT(*) FROM QR_Сканирование qrs
             INNER JOIN QR_Сессия qr ON qrs.QR_Сессия_ID = qr.QR_Сессия_ID
             WHERE CAST(qr.Время_Создания AS DATE) = @Дата 
               AND qrs.Статус = N'Успешно') AS УспешныхСканирований
        FROM QR_Сессия
        WHERE CAST(Время_Создания AS DATE) = @Дата;
        
        -- 5. Общая статистика
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Текст_Значение)
        SELECT 
            @Дата,
            N'Общая',
            (SELECT COUNT(*) FROM Лог_Действий WHERE CAST(Время_Действия AS DATE) = @Дата) AS ДействийВЛоге,
            (SELECT COUNT(*) FROM Уведомления WHERE CAST(Время_Создания AS DATE) = @Дата AND Прочитано = 0) AS НовыхУведомлений,
            (SELECT TOP 1 Название FROM Учебная_Группа ORDER BY NEWID()) AS СлучайнаяГруппа;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS СтатистикаСобрана, @Дата AS ДатаСтатистики;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьДисциплину]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 26. СоздатьДисциплину
CREATE PROCEDURE [dbo].[СоздатьДисциплину]
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
        
        IF NOT EXISTS (SELECT 1 FROM Преподаватель WHERE Преподаватель_ID = @Преподаватель_ID)
            RAISERROR(N'Преподаватель не найден', 16, 1);
        
        IF @Код_Дисциплины IS NOT NULL 
            AND EXISTS (SELECT 1 FROM Дисциплина WHERE [краткое наименование] = @Код_Дисциплины)
            RAISERROR(N'Дисциплина с таким кодом уже существует', 16, 1);
        
        INSERT INTO Дисциплина (
            Название, [краткое наименование], Преподаватель_ID,
            Часы_Теории, Часы_Практики, Семестр, Статус, Описание, Дата_Создания
        )
        VALUES (
            @Название, @Код_Дисциплины, @Преподаватель_ID,
            @Часы_Теории, @Часы_Практики, @Семестр, N'Активна', @Описание, GETDATE()
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание дисциплины', N'Дисциплина', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Дисциплина_ID, N'Дисциплина успешно создана' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьЗанятие]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 31. СоздатьЗанятие
CREATE PROCEDURE [dbo].[СоздатьЗанятие]
    @Расписание_ID INT,
    @Дата_Занятия DATE,
    @Тема_Занятия NVARCHAR(300) = NULL,
    @Кабинет NVARCHAR(50) = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Расписание WHERE Расписание_ID = @Расписание_ID)
            RAISERROR(N'Расписание не найдено', 16, 1);
        
        IF EXISTS (SELECT 1 FROM Занятие WHERE Расписание_ID = @Расписание_ID AND Дата_Занятия = @Дата_Занятия)
            RAISERROR(N'Занятие на эту дату уже существует', 16, 1);
        
        INSERT INTO Занятие (
            Расписание_ID, Дата_Занятия, Тема_Занятия, Кабинет, Примечание, Кто_Создал
        )
        VALUES (
            @Расписание_ID, @Дата_Занятия, @Тема_Занятия, @Кабинет, @Примечание, @КтоСоздал
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание занятия', N'Занятие', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Занятие_ID, N'Занятие успешно создано' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьПользователя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 7. СоздатьПользователя (с хешированием пароля)
CREATE PROCEDURE [dbo].[СоздатьПользователя]
    @Логин NVARCHAR(50),
    @Пароль NVARCHAR(255),
    @Email NVARCHAR(100) = NULL,
    @Роль_ID INT,
    @Телефон NVARCHAR(20) = NULL,
    @Аватар_URL NVARCHAR(500) = NULL,
    @Активен BIT = 1,
    @Примечание NVARCHAR(MAX) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Проверка уникальности логина
        IF EXISTS (SELECT 1 FROM Пользователь WHERE Логин = @Логин)
        BEGIN
            RAISERROR(N'Логин уже существует', 16, 1);
            RETURN;
        END
        
        -- Генерация соли и хеша пароля
        DECLARE @Соль NVARCHAR(32) = CONVERT(NVARCHAR(32), CRYPT_GEN_RANDOM(16), 2);
        DECLARE @Хэш NVARCHAR(64) = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Пароль + @Соль), 2);
        
        -- Вставка пользователя
        INSERT INTO Пользователь (
            Логин, Хэш_Пароля, Соль, Email, Роль_ID, Телефон, Аватар_URL, Активен, Примечание
        )
        VALUES (
            @Логин, @Хэш, @Соль, @Email, @Роль_ID, @Телефон, @Аватар_URL, @Активен, @Примечание
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        -- Логирование
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание пользователя', N'Пользователь', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Пользователь_ID, N'Пользователь успешно создан' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьПреподавателя]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 24. СоздатьПреподавателя
CREATE PROCEDURE [dbo].[СоздатьПреподавателя]
    @Пользователь_ID INT,
    @ФИО NVARCHAR(150),
    @Кафедра NVARCHAR(100) = NULL,
    @Ученая_Степень NVARCHAR(100) = NULL,
    @Должность NVARCHAR(100) = NULL,
    @Телефон_Рабочий NVARCHAR(20) = NULL,
    @Email_Рабочий NVARCHAR(100) = NULL,
    @Дата_Найма DATE = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Пользователь WHERE Пользователь_ID = @Пользователь_ID)
            RAISERROR(N'Пользователь не найден', 16, 1);
        
        IF EXISTS (SELECT 1 FROM Преподаватель WHERE Пользователь_ID = @Пользователь_ID)
            RAISERROR(N'Преподаватель уже существует для этого пользователя', 16, 1);
        
        INSERT INTO Преподаватель (
            Пользователь_ID, ФИО, Кафедра, Ученая_Степень, Должность,
            Телефон_Рабочий, Email_Рабочий, Дата_Найма, Примечание
        )
        VALUES (
            @Пользователь_ID, @ФИО, @Кафедра, @Ученая_Степень, @Должность,
            @Телефон_Рабочий, @Email_Рабочий, @Дата_Найма, @Примечание
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание преподавателя', N'Преподаватель', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Преподаватель_ID, N'Преподаватель успешно создан' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьРасписание]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 28. СоздатьРасписание
CREATE PROCEDURE [dbo].[СоздатьРасписание]
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
        
        IF NOT EXISTS (SELECT 1 FROM Учебная_Группа WHERE Группа_ID = @Группа_ID)
            RAISERROR(N'Группа не найдена', 16, 1);
        
        IF NOT EXISTS (SELECT 1 FROM Дисциплина WHERE Дисциплина_ID = @Дисциплина_ID)
            RAISERROR(N'Дисциплина не найдена', 16, 1);

        IF @Числ_Знамен IS NOT NULL AND @Числ_Знамен NOT IN (N'числитель', N'знаменатель', N'каждая')
            RAISERROR(N'Недопустимое значение числ/знамен', 16, 1);
        
        -- Проверка пересечений
        IF EXISTS (
            SELECT 1 FROM Расписание 
            WHERE Группа_ID = @Группа_ID 
            AND День_Недели = @День_Недели
            AND (
                ISNULL([числ/знамен], N'каждая') = N'каждая'
                OR ISNULL(@Числ_Знамен, N'каждая') = N'каждая'
                OR [числ/знамен] = @Числ_Знамен
            )
            AND (
                (@Время_Начала BETWEEN Время_Начала AND Время_Окончания)
                OR (@Время_Окончания BETWEEN Время_Начала AND Время_Окончания)
                OR (Время_Начала BETWEEN @Время_Начала AND @Время_Окончания)
            )
        )
        BEGIN
            RAISERROR(N'Найдено пересечение с существующим расписанием', 16, 1);
            RETURN;
        END
        
        INSERT INTO Расписание (
            Группа_ID, Дисциплина_ID, День_Недели,
            Время_Начала, Время_Окончания, Тип_Занятия, [числ/знамен], Кабинет, Примечание
        )
        VALUES (
            @Группа_ID, @Дисциплина_ID, @День_Недели,
            @Время_Начала, @Время_Окончания, @Тип_Занятия, @Числ_Знамен, @Кабинет, @Примечание
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание расписания', N'Расписание', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Расписание_ID, N'Расписание успешно создано' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьРезервнуюКопию]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 63. СоздатьРезервнуюКопию (исправленная версия)
CREATE PROCEDURE [dbo].[СоздатьРезервнуюКопию]
    @Тип_Копии NVARCHAR(50) = N'Полная',
    @Название_Файла NVARCHAR(255),
    @Путь_Хранения NVARCHAR(500),
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ДатаНачала DATETIME = GETDATE();
        
        INSERT INTO Резервные_Копии (
            Тип_Копии, Название_Файла, Путь_Хранения, Статус, Дата_Начала, Кто_Создал
        )
        VALUES (
            @Тип_Копии, @Название_Файла, @Путь_Хранения, N'В процессе', @ДатаНачала, @КтоСоздал
        );
        
        DECLARE @Копия_ID INT = SCOPE_IDENTITY();
        
        -- Здесь в реальности выполняется BACKUP DATABASE
        -- Для демонстрации используем задержку
        WAITFOR DELAY '00:00:02';
        
        DECLARE @ДатаЗавершения DATETIME = GETDATE();
        DECLARE @ВремяВыполнения INT = DATEDIFF(SECOND, @ДатаНачала, @ДатаЗавершения);
        
        -- Примерный размер (можно запросить из sys.master_files)
        DECLARE @РазмерФайла DECIMAL(10,2) = 
            (SELECT SUM(size) * 8.0 / 1024 
             FROM sys.master_files 
             WHERE database_id = DB_ID('Улучшенная')) / 2;
        
        UPDATE Резервные_Копии 
        SET 
            Статус = N'Успешно',
            Дата_Завершения = @ДатаЗавершения,
            Время_Выполнения_Сек = @ВремяВыполнения,
            Размер_Файла_MB = @РазмерФайла,
            Примечание = N'Резервная копия создана успешно'
        WHERE Копия_ID = @Копия_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, Параметры)
        VALUES (@КтоСоздал, N'Создание резервной копии', N'Резервные_Копии', @Копия_ID, N'Успешно', 
                N'Тип: ' + @Тип_Копии + N', Файл: ' + @Название_Файла + N', Размер: ' + CAST(@РазмерФайла AS NVARCHAR) + N' MB');
        
        SELECT 
            @Копия_ID AS Копия_ID,
            N'Резервная копия успешно создана' AS Сообщение,
            @ДатаЗавершения AS Дата_Создания,
            @ВремяВыполнения AS Время_Выполнения_Сек,
            @РазмерФайла AS Размер_Файла_MB;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
            
            IF @Копия_ID IS NOT NULL
            BEGIN
                UPDATE Резервные_Копии 
                SET 
                    Статус = N'Ошибка',
                    Дата_Завершения = GETDATE(),
                    Примечание = N'Ошибка: ' + LEFT(ERROR_MESSAGE(), 400)
                WHERE Копия_ID = @Копия_ID;
            END;
            
            INSERT INTO Лог_Действий (Пользователь_ID, Действие, Статус, Параметры)
            VALUES (@КтоСоздал, N'Ошибка создания резервной копии', N'Ошибка', 
                    N'Тип: ' + @Тип_Копии + N', Файл: ' + @Название_Файла + N', Ошибка: ' + LEFT(ERROR_MESSAGE(), 400));
        END;
        
        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьРоль]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 13. СоздатьРоль
CREATE PROCEDURE [dbo].[СоздатьРоль]
    @Название NVARCHAR(50),
    @Описание NVARCHAR(200) = NULL,
    @Уровень_Доступа INT = 1,
    @Можно_Удалять BIT = 0,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM Роль WHERE Название = @Название)
        BEGIN
            RAISERROR(N'Роль с таким названием уже существует', 16, 1);
            RETURN;
        END
        
        INSERT INTO Роль (Название, Описание, Уровень_Доступа, Можно_Удалять)
        VALUES (@Название, @Описание, @Уровень_Доступа, @Можно_Удалять);
        
        DECLARE @НоваяРольID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание роли', N'Роль', @НоваяРольID, N'Успешно');
        
        SELECT @НоваяРольID AS Роль_ID, N'Роль успешно создана' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьСпециальность]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 4. Создание новых хранимых процедур (CRUD для новых таблиц)
-- =============================================

-- 4.1 СоздатьСпециальность
CREATE   PROCEDURE [dbo].[СоздатьСпециальность]
    @Название NVARCHAR(150),
    @Код NVARCHAR(20) = NULL,
    @Факультет_ID INT,
    @Описание NVARCHAR(500) = NULL,
    @КтоСоздал INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM Факультет WHERE Факультет_ID = @Факультет_ID)
        BEGIN
            RAISERROR(N'Факультет не найден', 16, 1);
            RETURN;
        END
        INSERT INTO Специальность (Название, Код, Факультет_ID, Описание)
        VALUES (@Название, @Код, @Факультет_ID, @Описание);
        DECLARE @ID INT = SCOPE_IDENTITY();
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
        VALUES (@КтоСоздал, N'Создание специальности', N'Специальность', @ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);
        SELECT @ID AS Специальность_ID, N'Специальность создана' AS Сообщение;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[СоздатьСтудента]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 16. СоздатьСтудента
CREATE PROCEDURE [dbo].[СоздатьСтудента]
    @Пользователь_ID INT,
    @ФИО NVARCHAR(150),
    @Группа_ID INT,
    @Дата_Поступления DATE,
    @Дата_Рождения DATE = NULL,
    @Пол NVARCHAR(10) = NULL,
    @Адрес NVARCHAR(300) = NULL,
    @Телефон_Родителей NVARCHAR(20) = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Пользователь WHERE Пользователь_ID = @Пользователь_ID)
            RAISERROR(N'Пользователь не найден', 16, 1);
        
        IF NOT EXISTS (SELECT 1 FROM Учебная_Группа WHERE Группа_ID = @Группа_ID)
            RAISERROR(N'Группа не найдена', 16, 1);
        
        IF EXISTS (SELECT 1 FROM Студент WHERE Пользователь_ID = @Пользователь_ID)
            RAISERROR(N'Студент уже существует для этого пользователя', 16, 1);
        
        INSERT INTO Студент (
            Пользователь_ID, ФИО, Группа_ID, Дата_Поступления,
            Дата_Рождения, Пол, Адрес, Телефон_Родителей, Примечание
        )
        VALUES (
            @Пользователь_ID, @ФИО, @Группа_ID, @Дата_Поступления,
            @Дата_Рождения, @Пол, @Адрес, @Телефон_Родителей, @Примечание
        );
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание студента', N'Студент', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Студент_ID, N'Студент успешно создан' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьУведомление]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 53. СоздатьУведомление
CREATE PROCEDURE [dbo].[СоздатьУведомление]
    @Пользователь_ID INT,
    @Тип NVARCHAR(50),
    @Заголовок NVARCHAR(200),
    @Сообщение NVARCHAR(MAX),
    @Ссылка NVARCHAR(500) = NULL,
    @Срок_Действия_Часов INT = 24,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Уведомления (
            Пользователь_ID, Тип, Заголовок, Сообщение, Ссылка, Срок_Действия
        )
        VALUES (
            @Пользователь_ID, @Тип, @Заголовок, @Сообщение, @Ссылка,
            DATEADD(HOUR, @Срок_Действия_Часов, GETDATE())
        );
        
        DECLARE @Уведомление_ID BIGINT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание уведомления', N'Уведомления', @Уведомление_ID, N'Успешно');
        
        SELECT @Уведомление_ID AS Уведомление_ID, N'Уведомление создано' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьУчебнуюГруппу]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 21. СоздатьУчебнуюГруппу
CREATE PROCEDURE [dbo].[СоздатьУчебнуюГруппу]
    @Название NVARCHAR(50),
    @Год_Поступления INT,
    @Куратор_ID INT = NULL,
    @Примечание NVARCHAR(500) = NULL,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM Учебная_Группа WHERE Название = @Название)
            RAISERROR(N'Группа с таким названием уже существует', 16, 1);
        
        IF @Куратор_ID IS NOT NULL 
            AND NOT EXISTS (SELECT 1 FROM Преподаватель WHERE Преподаватель_ID = @Куратор_ID)
            RAISERROR(N'Куратор не найден', 16, 1);
        
        INSERT INTO Учебная_Группа (Название, Год_Поступления, Куратор_ID, Примечание)
        VALUES (@Название, @Год_Поступления, @Куратор_ID, @Примечание);
        
        DECLARE @НовыйID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание учебной группы', N'Учебная_Группа', @НовыйID, N'Успешно');
        
        SELECT @НовыйID AS Группа_ID, N'Учебная группа успешно создана' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СоздатьФакультет]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[СоздатьФакультет]
    @Название NVARCHAR(100),
    @Описание NVARCHAR(500) = NULL,
    @КтоСоздал INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Проверка прав (только Admin или Методист?)
        DECLARE @РольПользователя NVARCHAR(50);
        SELECT @РольПользователя = r.Название
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        WHERE u.Пользователь_ID = @КтоСоздал AND u.Активен = 1;
        IF @РольПользователя NOT IN (N'Admin', N'Методист')
        BEGIN
            RAISERROR(N'Недостаточно прав для создания факультета', 16, 1);
            RETURN;
        END

        INSERT INTO Факультет (Название, Описание)
        VALUES (@Название, @Описание);
        DECLARE @ID INT = SCOPE_IDENTITY();

        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
        VALUES (@КтоСоздал, N'Создание факультета', N'Факультет', @ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);

        SELECT @ID AS Факультет_ID, N'Факультет создан' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[СоздатьШаблонОтчета]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 56. СоздатьШаблонОтчета
CREATE PROCEDURE [dbo].[СоздатьШаблонОтчета]
    @Название NVARCHAR(100),
    @Тип NVARCHAR(50),
    @Код_Шаблона NVARCHAR(50) = NULL,
    @SQL_Запрос NVARCHAR(MAX),
    @Параметры NVARCHAR(MAX) = NULL,
    @Сортировка NVARCHAR(200) = NULL,
    @Формат NVARCHAR(20) = N'HTML',
    @Описание NVARCHAR(500) = NULL,
    @Иконка NVARCHAR(100) = NULL,
    @Цвет NVARCHAR(20) = NULL,
    @Общедоступный BIT = 0,
    @КтоСоздал INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @Код_Шаблона IS NOT NULL 
            AND EXISTS (SELECT 1 FROM Шаблоны_Отчетов WHERE Код_Шаблона = @Код_Шаблона)
            RAISERROR(N'Шаблон с таким кодом уже существует', 16, 1);
        
        INSERT INTO Шаблоны_Отчетов (
            Название, Тип, Код_Шаблона, SQL_Запрос, Параметры, Сортировка, Формат,
            Описание, Иконка, Цвет, Общедоступный, Кто_Создал
        )
        VALUES (
            @Название, @Тип, @Код_Шаблона, @SQL_Запрос, @Параметры, @Сортировка, @Формат,
            @Описание, @Иконка, @Цвет, @Общедоступный, @КтоСоздал
        );
        
        DECLARE @Шаблон_ID INT = SCOPE_IDENTITY();
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
        VALUES (@КтоСоздал, N'Создание шаблона отчета', N'Шаблоны_Отчетов', @Шаблон_ID, N'Успешно');
        
        SELECT @Шаблон_ID AS Шаблон_ID, N'Шаблон отчета создан' AS Сообщение;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоГруппе]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 42. СформироватьОтчетПоГруппе
CREATE PROCEDURE [dbo].[СформироватьОтчетПоГруппе]
    @Группа_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL,
    @Дисциплина_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(MONTH, -1, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    SELECT 
        s.Студент_ID,
        s.ФИО AS ФИО_Студента,
        d.Название AS Дисциплина,
        d.[краткое наименование] AS Код_Дисциплины,
        d.[краткое наименование],
        p.ФИО AS Преподаватель,
        COUNT(z.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
    FROM Студент s
    CROSS JOIN Дисциплина d
    LEFT JOIN Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID AND r.Группа_ID = s.Группа_ID
    LEFT JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID 
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    WHERE s.Группа_ID = @Группа_ID
    AND (@Дисциплина_ID IS NULL OR d.Дисциплина_ID = @Дисциплина_ID)
    GROUP BY 
        s.Студент_ID, s.ФИО, 
        d.Дисциплина_ID, d.Название, d.[краткое наименование],
        p.ФИО
    ORDER BY s.ФИО, d.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоДням]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 45. СформироватьОтчетПоДням
CREATE PROCEDURE [dbo].[СформироватьОтчетПоДням]
    @Дата DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Дата IS NULL
        SET @Дата = CAST(GETDATE() AS DATE);
    
    SELECT 
        g.Название AS Группа,
        d.Название AS Дисциплина,
        p.ФИО AS Преподаватель,
        COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентовВГруппе,
        COUNT(DISTINCT пос.Студент_ID) AS ОтмеченоСтудентов,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(DISTINCT s.Студент_ID), 0) AS DECIMAL(5,2)) AS СреднийПроцентПосещаемости
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    LEFT JOIN Студент s ON r.Группа_ID = s.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE z.Дата_Занятия = @Дата
    GROUP BY 
        g.Группа_ID, g.Название, 
        d.Дисциплина_ID, d.Название, 
        p.ФИО
    ORDER BY g.Название, d.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоМесяцам]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 47. СформироватьОтчетПоМесяцам
CREATE PROCEDURE [dbo].[СформироватьОтчетПоМесяцам]
    @Месяц INT = NULL,
    @Год INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Месяц IS NULL
        SET @Месяц = MONTH(GETDATE());
    
    IF @Год IS NULL
        SET @Год = YEAR(GETDATE());
    
    DECLARE @НачалоМесяца DATE = DATEFROMPARTS(@Год, @Месяц, 1);
    DECLARE @КонецМесяца DATE = EOMONTH(@НачалоМесяца);
    
    SELECT 
        g.Название AS Группа,
        COUNT(DISTINCT z.Занятие_ID) AS КоличествоЗанятийВМесяце,
        COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентовВГруппе,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS ВсегоПрисутствий,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS ВсегоОтсутствий,
        AVG(CASE WHEN пос.Статус = N'Присутствовал' THEN 1.0 ELSE 0.0 END) * 100 AS СреднийПроцентПосещаемости,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS ВсегоОпозданий
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    LEFT JOIN Студент s ON r.Группа_ID = s.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE z.Дата_Занятия BETWEEN @НачалоМесяца AND @КонецМесяца
    GROUP BY g.Группа_ID, g.Название
    ORDER BY СреднийПроцентПосещаемости DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоНеделям]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 46. СформироватьОтчетПоНеделям
CREATE PROCEDURE [dbo].[СформироватьОтчетПоНеделям]
    @НачалоНедели DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоНедели IS NULL
        SET @НачалоНедели = DATEADD(DAY, -DATEPART(WEEKDAY, GETDATE()) + 1, CAST(GETDATE() AS DATE));
    
    DECLARE @КонецНедели DATE = DATEADD(DAY, 6, @НачалоНедели);
    
    SELECT 
        g.Название AS Группа,
        d.Название AS Дисциплина,
        COUNT(DISTINCT z.Занятие_ID) AS КоличествоЗанятий,
        COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентовВГруппе,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS ВсегоПрисутствий,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS ВсегоОтсутствий,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(DISTINCT s.Студент_ID) * COUNT(DISTINCT z.Занятие_ID), 0) AS DECIMAL(5,2)) AS СреднийПроцентПосещаемости
    FROM Занятие z
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    LEFT JOIN Студент s ON r.Группа_ID = s.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE z.Дата_Занятия BETWEEN @НачалоНедели AND @КонецНедели
    GROUP BY 
        g.Группа_ID, g.Название, 
        d.Дисциплина_ID, d.Название
    ORDER BY g.Название, d.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоПреподавателю]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 44. СформироватьОтчетПоПреподавателю
CREATE PROCEDURE [dbo].[СформироватьОтчетПоПреподавателю]
    @Преподаватель_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(MONTH, -1, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    SELECT 
        d.Название AS Дисциплина,
        g.Название AS Группа,
        z.Дата_Занятия,
        COUNT(DISTINCT s.Студент_ID) AS ВсегоСтудентовВГруппе,
        COUNT(DISTINCT пос.Студент_ID) AS ОтмеченоСтудентов,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(DISTINCT s.Студент_ID), 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
    FROM Преподаватель prep
    INNER JOIN Дисциплина d ON prep.Преподаватель_ID = d.Преподаватель_ID
    INNER JOIN Расписание r ON d.Дисциплина_ID = r.Дисциплина_ID
    INNER JOIN Учебная_Группа g ON r.Группа_ID = g.Группа_ID
    INNER JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID 
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN Студент s ON r.Группа_ID = s.Группа_ID
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE prep.Преподаватель_ID = @Преподаватель_ID
    GROUP BY 
        d.Дисциплина_ID, d.Название, 
        g.Группа_ID, g.Название, 
        z.Дата_Занятия
    ORDER BY z.Дата_Занятия DESC, d.Название, g.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьОтчетПоСтуденту]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 43. СформироватьОтчетПоСтуденту
CREATE PROCEDURE [dbo].[СформироватьОтчетПоСтуденту]
    @Студент_ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @НачалоПериода IS NULL
        SET @НачалоПериода = DATEADD(MONTH, -3, GETDATE());
    
    IF @КонецПериода IS NULL
        SET @КонецПериода = GETDATE();
    
    -- Общая сводка
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
    FROM Студент s
    INNER JOIN Учебная_Группа g ON s.Группа_ID = g.Группа_ID
    LEFT JOIN Расписание r ON s.Группа_ID = r.Группа_ID
    LEFT JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID 
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID = @Студент_ID
    GROUP BY s.Студент_ID, s.ФИО, g.Название;
    
    -- Детализация по дисциплинам
    SELECT 
        d.Название AS Дисциплина,
        d.[краткое наименование] AS Код_Дисциплины,
        d.[краткое наименование],
        p.ФИО AS Преподаватель,
        p.Кафедра,
        COUNT(z.Занятие_ID) AS ВсегоЗанятий,
        SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
        SUM(CASE WHEN пос.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
        SUM(CASE WHEN пос.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
        SUM(CASE WHEN пос.Статус = N'Уважительная причина' THEN 1 ELSE 0 END) AS УважительнаяПричина,
        CAST(SUM(CASE WHEN пос.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(z.Занятие_ID), 0) AS DECIMAL(5,2)) AS ПроцентПосещаемости
    FROM Студент s
    INNER JOIN Расписание r ON s.Группа_ID = r.Группа_ID
    INNER JOIN Дисциплина d ON r.Дисциплина_ID = d.Дисциплина_ID
    INNER JOIN Преподаватель p ON d.Преподаватель_ID = p.Преподаватель_ID
    LEFT JOIN Занятие z ON r.Расписание_ID = z.Расписание_ID 
        AND z.Дата_Занятия BETWEEN @НачалоПериода AND @КонецПериода
    LEFT JOIN Посещаемость пос ON z.Занятие_ID = пос.Занятие_ID AND пос.Студент_ID = s.Студент_ID
    WHERE s.Студент_ID = @Студент_ID
    GROUP BY 
        d.Дисциплина_ID, d.Название, d.[краткое наименование],
        p.Преподаватель_ID, p.ФИО, p.Кафедра
    ORDER BY d.Название;
END;
GO
/****** Object:  StoredProcedure [dbo].[СформироватьПроизвольныйОтчет]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[СформироватьПроизвольныйОтчет]
    @Группа_ID          INT = NULL,
    @Дисциплина_ID      INT = NULL,
    @Преподаватель_ID   INT = NULL,
    @Студент_ID         INT = NULL,
    @ДатаНачала         DATE = NULL,
    @ДатаКонца          DATE = NULL,
    @СтатусПосещения    NVARCHAR(30) = NULL,
    @Лимит              INT = 1000
AS
BEGIN
    SET NOCOUNT ON;

    -- بناء الاستعلام الأساسي
    DECLARE @sql NVARCHAR(MAX) = N'
        SELECT TOP (@Лимит)
            г.Название                 AS [Группа],
            д.Название                 AS [Дисциплина],
            преп.ФИО                   AS [Преподаватель],
            с.ФИО                      AS [Студент],
            з.Дата_Занятия             AS [Дата],
            р.Время_Начала              AS [Начало],
            р.Время_Окончания           AS [Конец],
            пос.Статус                  AS [Статус посещения],
            пос.Тип_Отметки              AS [Тип отметки],
            пос.Дата_Отметки             AS [Дата отметки],
            CASE 
                WHEN об.Обоснование_ID IS NOT NULL 
                THEN об.Статус 
                ELSE NULL 
            END                         AS [Статус обоснования],
            об.Причина                   AS [Причина обоснования]
        FROM Посещаемость пос
        INNER JOIN Занятие з ON пос.Занятие_ID = з.Занятие_ID
        INNER JOIN Расписание р ON з.Расписание_ID = р.Расписание_ID
        INNER JOIN Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
        INNER JOIN Преподаватель преп ON д.Преподаватель_ID = преп.Преподаватель_ID
        INNER JOIN Учебная_Группа г ON р.Группа_ID = г.Группа_ID
        INNER JOIN Студент с ON пос.Студент_ID = с.Студент_ID
        LEFT JOIN Обоснования_Отсутствия об 
            ON пос.Занятие_ID = об.Занятие_ID 
            AND пос.Студент_ID = об.Студент_ID
        WHERE 1=1 ';

    -- قائمة المعاملات المطلوبة لـ sp_executesql
    DECLARE @paramList NVARCHAR(500) = N'
        @Группа_ID INT,
        @Дисциплина_ID INT,
        @Преподаватель_ID INT,
        @Студент_ID INT,
        @ДатаНачала DATE,
        @ДатаКонца DATE,
        @СтатусПосещения NVARCHAR(30),
        @Лимит INT';

    -- إضافة الشروط ديناميكياً
    IF @Группа_ID IS NOT NULL
        SET @sql += N' AND г.Группа_ID = @Группа_ID ';

    IF @Дисциплина_ID IS NOT NULL
        SET @sql += N' AND д.Дисциплина_ID = @Дисциплина_ID ';

    IF @Преподаватель_ID IS NOT NULL
        SET @sql += N' AND преп.Преподаватель_ID = @Преподаватель_ID ';

    IF @Студент_ID IS NOT NULL
        SET @sql += N' AND с.Студент_ID = @Студент_ID ';

    IF @ДатаНачала IS NOT NULL
        SET @sql += N' AND з.Дата_Занятия >= @ДатаНачала ';

    IF @ДатаКонца IS NOT NULL
        SET @sql += N' AND з.Дата_Занятия <= @ДатаКонца ';

    IF @СтатусПосещения IS NOT NULL
        SET @sql += N' AND пос.Статус = @СтатусПосещения ';

    -- الترتيب النهائي
    SET @sql += N' ORDER BY з.Дата_Занятия DESC, г.Название, с.ФИО;';

    -- تنفيذ الاستعلام الديناميكي
    EXEC sp_executesql @sql, @paramList,
        @Группа_ID,
        @Дисциплина_ID,
        @Преподаватель_ID,
        @Студент_ID,
        @ДатаНачала,
        @ДатаКонца,
        @СтатусПосещения,
        @Лимит;
END;
GO
/****** Object:  StoredProcedure [dbo].[УдалитьРоль]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 15. УдалитьРоль
CREATE PROCEDURE [dbo].[УдалитьРоль]
    @Роль_ID INT,
    @КтоУдалил INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @НазваниеРоли NVARCHAR(50);
        DECLARE @МожноУдалять BIT;
        
        SELECT 
            @НазваниеРоли = Название,
            @МожноУдалять = Можно_Удалять
        FROM Роль 
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
        
        IF EXISTS (SELECT 1 FROM Пользователь WHERE Роль_ID = @Роль_ID)
        BEGIN
            RAISERROR(N'Нельзя удалить роль, к которой привязаны пользователи', 16, 1);
            RETURN;
        END
        
        DELETE FROM Разрешения_Ролей WHERE Роль_ID = @Роль_ID;
        DELETE FROM Роль WHERE Роль_ID = @Роль_ID;
        
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус)
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
/****** Object:  StoredProcedure [dbo].[УдалитьСпециальность]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4.3 ОбновитьСпециальность (аналогично, пропускаем для краткости, но он будет в полном файле)
-- ...

-- 4.4 УдалитьСпециальность (с проверкой наличия групп)
CREATE   PROCEDURE [dbo].[УдалитьСпециальность]
    @Специальность_ID INT,
    @КтоУдалил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF EXISTS (SELECT 1 FROM Учебная_Группа WHERE Специальность_ID = @Специальность_ID)
        BEGIN
            RAISERROR(N'Невозможно удалить специальность, к которой привязаны учебные группы', 16, 1);
            RETURN;
        END
        DELETE FROM Специальность WHERE Специальность_ID = @Специальность_ID;
        IF @@ROWCOUNT = 0 RAISERROR(N'Специальность не найдена', 16, 1);
        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
        VALUES (@КтоУдалил, N'Удаление специальности', N'Специальность', @Специальность_ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);
        SELECT 1 AS Удалено, N'Специальность удалена' AS Сообщение;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[УдалитьФакультет]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[УдалитьФакультет]
    @Факультет_ID INT,
    @КтоУдалил INT,
    @IP_Адрес NVARCHAR(45) = NULL,
    @Устройство NVARCHAR(100) = NULL,
    @Браузер NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Проверка прав (Admin)
        DECLARE @РольПользователя NVARCHAR(50);
        SELECT @РольПользователя = r.Название
        FROM Пользователь u
        INNER JOIN Роль r ON u.Роль_ID = r.Роль_ID
        WHERE u.Пользователь_ID = @КтоУдалил AND u.Активен = 1;
        IF @РольПользователя NOT IN (N'Admin')
        BEGIN
            RAISERROR(N'Недостаточно прав для удаления факультета', 16, 1);
            RETURN;
        END

        -- Проверка, есть ли специальности
        IF EXISTS (SELECT 1 FROM Специальность WHERE Факультет_ID = @Факультет_ID)
        BEGIN
            RAISERROR(N'Невозможно удалить факультет, к которому привязаны специальности', 16, 1);
            RETURN;
        END

        DELETE FROM Факультет WHERE Факультет_ID = @Факультет_ID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Факультет не найден', 16, 1);
            RETURN;
        END

        INSERT INTO Лог_Действий (Пользователь_ID, Действие, Таблица, Запись_ID, Статус, IP_Адрес, Устройство, Браузер)
        VALUES (@КтоУдалил, N'Удаление факультета', N'Факультет', @Факультет_ID, N'Успешно', @IP_Адрес, @Устройство, @Браузер);

        SELECT 1 AS Удалено, N'Факультет удалён' AS Сообщение;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[ЭкспортОтчетаВCSV]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 48. ЭкспортОтчетаВCSV (упрощённая версия – возвращает данные для экспорта)
CREATE PROCEDURE [dbo].[ЭкспортОтчетаВCSV]
    @ТипОтчета NVARCHAR(50),
    @ID INT,
    @НачалоПериода DATE = NULL,
    @КонецПериода DATE = NULL,
    @Параметры NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- В реальной реализации здесь вызывается соответствующий отчёт и возвращается результат
    -- Для примера просто возвращаем сообщение
    SELECT 
        N'Экспорт отчёта "' + @ТипОтчета + N'" для ID=' + CAST(@ID AS NVARCHAR) AS Заголовок,
        GETDATE() AS ДатаЭкспорта;
END;
GO
/****** Object:  StoredProcedure [dbo].[ЭкспортПосещаемостиВCSV]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ЭкспортПосещаемостиВCSV]
    @ДатаНачала DATE,
    @ДатаКонца DATE,
    @CSV_Содержимое NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Header NVARCHAR(MAX) = N'Дата;Студент;Группа;Дисциплина;Статус;Преподаватель;ДатаОтметки;ТипОтметки' + CHAR(13) + CHAR(10);
    DECLARE @Rows NVARCHAR(MAX) = N'';
    
    SELECT @Rows = @Rows + 
        CONVERT(NVARCHAR(10), з.Дата_Занятия, 104) + N';' +
        с.ФИО + N';' +
        г.Название + N';' +
        д.Название + N';' +
        п.Статус + N';' +
        преп.ФИО + N';' +
        ISNULL(CONVERT(NVARCHAR(19), п.Дата_Отметки, 120), N'') + N';' +
        п.Тип_Отметки + CHAR(13) + CHAR(10)
    FROM Посещаемость п
    INNER JOIN Занятие з ON п.Занятие_ID = з.Занятие_ID
    INNER JOIN Расписание р ON з.Расписание_ID = р.Расписание_ID
    INNER JOIN Дисциплина д ON р.Дисциплина_ID = д.Дисциплина_ID
    INNER JOIN Преподаватель преп ON д.Преподаватель_ID = преп.Преподаватель_ID
    INNER JOIN Студент с ON п.Студент_ID = с.Студент_ID
    INNER JOIN Учебная_Группа г ON с.Группа_ID = г.Группа_ID
    WHERE з.Дата_Занятия BETWEEN @ДатаНачала AND @ДатаКонца
    ORDER BY з.Дата_Занятия, с.ФИО;
    
    SET @CSV_Содержимое = @Header + @Rows;
END;
GO
/****** Object:  Trigger [dbo].[TRG_УправлениеQRСессиями]    Script Date: 22-Apr-26 1:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Управление статусами QR-сессий
CREATE TRIGGER [dbo].[TRG_УправлениеQRСессиями]
ON [dbo].[QR_Сессия]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE qr
    SET Статус = CASE 
        WHEN GETDATE() > qr.Время_Действия_Конец THEN N'Завершен'
        WHEN GETDATE() < qr.Время_Действия_Начало THEN N'Ожидание'
        ELSE N'Активен'
    END
    FROM QR_Сессия qr
    INNER JOIN inserted i ON qr.QR_Сессия_ID = i.QR_Сессия_ID;
    
    -- Автоматическое закрытие истёкших сессий (с запасом 5 минут)
    UPDATE QR_Сессия 
    SET Статус = N'Завершен',
        Примечание = CONCAT(Примечание, N' | Автозакрытие: ', GETDATE())
    WHERE Статус = N'Активен'
    AND Время_Действия_Конец < DATEADD(MINUTE, -5, GETDATE());
END;
GO
ALTER TABLE [dbo].[QR_Сессия] ENABLE TRIGGER [TRG_УправлениеQRСессиями]
GO
/****** Object:  Trigger [dbo].[TRG_ЗакрытиеQRПоСтатусуЗанятия]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Закрытие QR-сессий при изменении статуса занятия
CREATE TRIGGER [dbo].[TRG_ЗакрытиеQRПоСтатусуЗанятия]
ON [dbo].[Занятие]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(Статус)
    BEGIN
        UPDATE qr
        SET 
            Статус = N'Завершен',
            Примечание = CONCAT(
                ISNULL(qr.Примечание, N''), 
                N' | Закрыто автоматически при изменении статуса занятия на: ', 
                i.Статус
            )
        FROM QR_Сессия qr
        INNER JOIN inserted i ON qr.Занятие_ID = i.Занятие_ID
        INNER JOIN deleted d ON i.Занятие_ID = d.Занятие_ID
        WHERE qr.Статус = N'Активен'
        AND i.Статус IN (N'Проведено', N'Отменено', N'Перенесено')
        AND d.Статус <> i.Статус;
    END
END;
GO
ALTER TABLE [dbo].[Занятие] ENABLE TRIGGER [TRG_ЗакрытиеQRПоСтатусуЗанятия]
GO
/****** Object:  Trigger [dbo].[TRG_ОбновлениеСтатусаЗанятия]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Автоматическое обновление статуса занятия по времени
CREATE TRIGGER [dbo].[TRG_ОбновлениеСтатусаЗанятия]
ON [dbo].[Занятие]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Сейчас DATETIME = GETDATE();
    
    UPDATE z
    SET Статус = CASE 
        WHEN z.Дата_Занятия < CAST(@Сейчас AS DATE) THEN N'Проведено'
        WHEN z.Дата_Занятия > CAST(@Сейчас AS DATE) THEN N'Запланировано'
        ELSE -- Тот же день
            CASE 
                WHEN CAST(@Сейчас AS TIME) < DATEADD(MINUTE, -30, r.Время_Начала) THEN N'Запланировано'
                WHEN CAST(@Сейчас AS TIME) > DATEADD(MINUTE, 30, r.Время_Окончания) THEN N'Проведено'
                ELSE N'В процессе'
            END
    END
    FROM Занятие z
    INNER JOIN inserted i ON z.Занятие_ID = i.Занятие_ID
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
    WHERE z.Статус NOT IN (N'Отменено', N'Перенесено');
    
    -- Заполнение фактического времени, если статус стал "Проведено"
    UPDATE z
    SET 
        Время_Начала_Факт = CASE 
            WHEN i.Статус = N'Проведено' AND z.Время_Начала_Факт IS NULL 
            THEN CAST(z.Дата_Занятия AS DATETIME) + CAST(r.Время_Начала AS DATETIME)
            ELSE z.Время_Начала_Факт
        END,
        Время_Окончания_Факт = CASE 
            WHEN i.Статус = N'Проведено' AND z.Время_Окончания_Факт IS NULL 
            THEN CAST(z.Дата_Занятия AS DATETIME) + CAST(r.Время_Окончания AS DATETIME)
            ELSE z.Время_Окончания_Факт
        END
    FROM Занятие z
    INNER JOIN inserted i ON z.Занятие_ID = i.Занятие_ID
    INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID;
END;
GO
ALTER TABLE [dbo].[Занятие] ENABLE TRIGGER [TRG_ОбновлениеСтатусаЗанятия]
GO
/****** Object:  Trigger [dbo].[TRG_ЛогированиеДействий]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRG_ЛогированиеДействий]
ON [dbo].[Лог_Действий]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ДатаСегодня DATE = CAST(GETDATE() AS DATE);
    
    -- Удаляем старые агрегированные данные за сегодня для типа 'Активность'
    -- Общая статистика (Подтип_Статистики IS NULL)
    DELETE FROM Статистика_Системы
    WHERE Дата_Статистики = @ДатаСегодня
      AND Тип_Статистики = N'Активность'
      AND Подтип_Статистики IS NULL;
    
    -- Удаляем статистику по уровням логов (Подтип_Статистики начинается с 'Уровень: ')
    DELETE FROM Статистика_Системы
    WHERE Дата_Статистики = @ДатаСегодня
      AND Тип_Статистики = N'Активность'
      AND Подтип_Статистики LIKE N'Уровень: %';
    
    -- Удаляем статистику по статусам (Подтип_Статистики начинается с 'Статус: ')
    DELETE FROM Статистика_Системы
    WHERE Дата_Статистики = @ДатаСегодня
      AND Тип_Статистики = N'Активность'
      AND Подтип_Статистики LIKE N'Статус: %';
    
    -- Теперь вставляем новые данные
    
    -- Общая статистика по логам
    INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Текст_Значение)
    SELECT 
        @ДатаСегодня,
        N'Активность',
        COUNT(*) AS КоличествоЛогов,
        CONCAT(N'Добавлено логов: ', COUNT(*), N', Разных пользователей: ', COUNT(DISTINCT Пользователь_ID))
    FROM inserted;
    
    -- По уровням логов
    INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Подтип_Статистики, Значение_1)
    SELECT 
        @ДатаСегодня,
        N'Активность',
        CONCAT(N'Уровень: ', Уровень_Лога),
        COUNT(*)
    FROM inserted
    GROUP BY Уровень_Лога;
    
    -- По статусам
    INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Подтип_Статистики, Значение_1)
    SELECT 
        @ДатаСегодня,
        N'Активность',
        CONCAT(N'Статус: ', Статус),
        COUNT(*)
    FROM inserted
    GROUP BY Статус;
END;
GO
ALTER TABLE [dbo].[Лог_Действий] ENABLE TRIGGER [TRG_ЛогированиеДействий]
GO
/****** Object:  Trigger [dbo].[TRG_МониторингТриггеров]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 16. Мониторинг работы триггеров (пример)
CREATE TRIGGER [dbo].[TRG_МониторингТриггеров]
ON [dbo].[Лог_Действий]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE Действие LIKE N'%триггер%' OR Действие LIKE N'%Trigger%')
    BEGIN
        INSERT INTO Мониторинг_Триггеров (Триггер_Имя, Таблица, Тип_Операции, КоличествоЗаписей)
        SELECT 
            N'TRG_ЛогированиеДействий',
            N'Лог_Действий',
            N'INSERT',
            COUNT(*)
        FROM inserted;
    END
END;
GO
ALTER TABLE [dbo].[Лог_Действий] ENABLE TRIGGER [TRG_МониторингТриггеров]
GO
/****** Object:  Trigger [dbo].[TRG_ЗапретУдаленияКритическихДанных]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. Запрет удаления критических данных (INSTEAD OF DELETE)
CREATE TRIGGER [dbo].[TRG_ЗапретУдаленияКритическихДанных]
ON [dbo].[Пользователь]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        INNER JOIN Роль r ON d.Роль_ID = r.Роль_ID
        WHERE r.Название = N'Admin' OR d.Логин = N'admin'
    )
    BEGIN
        RAISERROR(N'Нельзя удалять администраторов системы или пользователя admin', 16, 1);
        RETURN;
    END
    
    -- Вместо удаления – деактивация
    UPDATE u
    SET 
        Активен = 0,
        Примечание = CONCAT(
            ISNULL(u.Примечание, ''), 
            N' | Деактивирован вместо удаления: ', 
            GETDATE()
        )
    FROM Пользователь u
    INNER JOIN deleted d ON u.Пользователь_ID = d.Пользователь_ID;
    
    INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
    SELECT 
        N'Попытка удаления пользователя – выполнена деактивация',
        N'Пользователь',
        N'Предупреждение',
        N'Пользователь_ID: ' + CAST(d.Пользователь_ID AS NVARCHAR) + 
        N', Логин: ' + d.Логин
    FROM deleted d;
END;
GO
ALTER TABLE [dbo].[Пользователь] ENABLE TRIGGER [TRG_ЗапретУдаленияКритическихДанных]
GO
/****** Object:  Trigger [dbo].[TRG_АвтоОбновлениеСтатистикиПосещаемости]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 15. Автоматическое обновление статистики студента при изменении посещаемости
CREATE TRIGGER [dbo].[TRG_АвтоОбновлениеСтатистикиПосещаемости]
ON [dbo].[Посещаемость]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Студенты TABLE (Студент_ID INT PRIMARY KEY);
    
    INSERT INTO @Студенты (Студент_ID)
    SELECT Студент_ID FROM inserted
    UNION
    SELECT Студент_ID FROM deleted;
    
    IF EXISTS (SELECT 1 FROM @Студенты)
    BEGIN
        DECLARE @Статистика TABLE (
            Студент_ID INT PRIMARY KEY,
            ВсегоЗанятий INT,
            Присутствовал INT,
            Отсутствовал INT,
            Опоздал INT,
            Процент DECIMAL(5,2)
        );
        
        INSERT INTO @Статистика (Студент_ID, ВсегоЗанятий, Присутствовал, Отсутствовал, Опоздал, Процент)
        SELECT 
            s.Студент_ID,
            COUNT(p.Посещаемость_ID) AS ВсегоЗанятий,
            SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовал,
            SUM(CASE WHEN p.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовал,
            SUM(CASE WHEN p.Статус = N'Опоздал' THEN 1 ELSE 0 END) AS Опоздал,
            CAST(SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) * 100.0 / 
                 NULLIF(COUNT(p.Посещаемость_ID), 0) AS DECIMAL(5,2)) AS Процент
        FROM Студент s
        LEFT JOIN Посещаемость p ON s.Студент_ID = p.Студент_ID
        LEFT JOIN Занятие z ON p.Занятие_ID = z.Занятие_ID
        WHERE s.Студент_ID IN (SELECT Студент_ID FROM @Студенты)
        AND z.Дата_Занятия >= DATEADD(MONTH, -3, GETDATE())
        GROUP BY s.Студент_ID;
        
        -- Обновление примечания студента статистикой
        UPDATE s
        SET Примечание = CONCAT(
            CASE 
                WHEN CHARINDEX(N'| Статистика обновлена:', ISNULL(s.Примечание, N'')) > 0 
                THEN LEFT(s.Примечание, CHARINDEX(N'| Статистика обновлена:', s.Примечание) - 1)
                ELSE ISNULL(s.Примечание, N'')
            END,
            N' | Статистика обновлена: ',
            FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm'),
            N' | Посещаемость: ',
            CAST(st.Процент AS NVARCHAR),
            N'% (',
            st.Присутствовал, N'/', st.ВсегоЗанятий,
            N')'
        )
        FROM Студент s
        INNER JOIN @Статистика st ON s.Студент_ID = st.Студент_ID;
    END
END;
GO
ALTER TABLE [dbo].[Посещаемость] ENABLE TRIGGER [TRG_АвтоОбновлениеСтатистикиПосещаемости]
GO
/****** Object:  Trigger [dbo].[TRG_АвтосборСтатистики]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 9. Автосбор статистики при изменении посещаемости
CREATE TRIGGER [dbo].[TRG_АвтосборСтатистики]
ON [dbo].[Посещаемость]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ДатаСегодня DATE = CAST(GETDATE() AS DATE);
    
    -- Если статистики за сегодня ещё нет – создаём
    IF NOT EXISTS (
        SELECT 1 FROM Статистика_Системы 
        WHERE Дата_Статистики = @ДатаСегодня AND Тип_Статистики = N'Посещаемость'
    )
    BEGIN
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3)
        SELECT 
            @ДатаСегодня,
            N'Посещаемость',
            COUNT(DISTINCT i.Студент_ID) AS УникальныхСтудентов,
            SUM(CASE WHEN i.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало,
            SUM(CASE WHEN i.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовало
        FROM inserted i;
    END
    ELSE
    BEGIN
        -- Обновляем существующую статистику (удаляем и вставляем заново)
        DELETE FROM Статистика_Системы 
        WHERE Дата_Статистики = @ДатаСегодня AND Тип_Статистики = N'Посещаемость';
        
        INSERT INTO Статистика_Системы (Дата_Статистики, Тип_Статистики, Значение_1, Значение_2, Значение_3)
        SELECT 
            @ДатаСегодня,
            N'Посещаемость',
            COUNT(DISTINCT p.Студент_ID) AS УникальныхСтудентов,
            SUM(CASE WHEN p.Статус = N'Присутствовал' THEN 1 ELSE 0 END) AS Присутствовало,
            SUM(CASE WHEN p.Статус = N'Отсутствовал' THEN 1 ELSE 0 END) AS Отсутствовало
        FROM Посещаемость p
        INNER JOIN Занятие z ON p.Занятие_ID = z.Занятие_ID
        WHERE z.Дата_Занятия = @ДатаСегодня;
    END
END;
GO
ALTER TABLE [dbo].[Посещаемость] ENABLE TRIGGER [TRG_АвтосборСтатистики]
GO
/****** Object:  Trigger [dbo].[TRG_ЗапретДублированияПосещаемости]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 1. Запрет дублирования записей посещаемости
CREATE TRIGGER [dbo].[TRG_ЗапретДублированияПосещаемости]
ON [dbo].[Посещаемость]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE EXISTS (
            SELECT 1 
            FROM Посещаемость p 
            WHERE p.Занятие_ID = i.Занятие_ID 
            AND p.Студент_ID = i.Студент_ID
        )
    )
    BEGIN
        RAISERROR(N'Нельзя создать дублирующую запись посещаемости для одного студента на одном занятии', 16, 1);
        RETURN;
    END
    
    INSERT INTO Посещаемость (
        Занятие_ID, Студент_ID, Статус, Тип_Отметки, Примечание, Кто_Отметил, Дата_Отметки
    )
    SELECT 
        Занятие_ID, Студент_ID, Статус, Тип_Отметки, Примечание, Кто_Отметил, ISNULL(Дата_Отметки, GETDATE())
    FROM inserted;
END;
GO
ALTER TABLE [dbo].[Посещаемость] ENABLE TRIGGER [TRG_ЗапретДублированияПосещаемости]
GO
/****** Object:  Trigger [dbo].[TRG_УведомленияОПропусках]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 10. Уведомления о частых пропусках
CREATE TRIGGER [dbo].[TRG_УведомленияОПропусках]
ON [dbo].[Посещаемость]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ПорогПропусков INT = 3;
    DECLARE @ПериодДней INT = 7;
    
    WITH ПропускиСтудента AS (
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
        WHERE ув.Пользователь_ID = p.Преподаватель_ID
        AND ув.Заголовок LIKE N'%Студент с частыми пропусками%'
        AND ув.Время_Создания > DATEADD(DAY, -1, GETDATE())
    );
    
    -- Уведомления для самого студента
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
ALTER TABLE [dbo].[Посещаемость] ENABLE TRIGGER [TRG_УведомленияОПропусках]
GO
/****** Object:  Trigger [dbo].[TRG_АвтоСозданиеЗанятий]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 14. Автоматическое создание занятий по расписанию
CREATE TRIGGER [dbo].[TRG_АвтоСозданиеЗанятий]
ON [dbo].[Расписание]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @НедельВперед INT = 4;
    DECLARE @ДатаНачала DATE = CAST(GETDATE() AS DATE);
    DECLARE @ДатаКонца DATE = DATEADD(WEEK, @НедельВперед, @ДатаНачала);
    
    -- Генерируем все даты в диапазоне
    ;WITH Даты AS (
        SELECT @ДатаНачала AS Дата
        UNION ALL
        SELECT DATEADD(DAY, 1, Дата)
        FROM Даты
        WHERE Дата < @ДатаКонца
    )
    INSERT INTO Занятие (Расписание_ID, Дата_Занятия, Статус)
    SELECT 
        r.Расписание_ID,
        d.Дата,
        N'Запланировано'
    FROM inserted r
    CROSS JOIN Даты d
    WHERE DATEPART(WEEKDAY, d.Дата) = r.День_Недели
    AND d.Дата BETWEEN @ДатаНачала AND @ДатаКонца
    AND NOT EXISTS (
        SELECT 1 
        FROM Занятие z 
        WHERE z.Расписание_ID = r.Расписание_ID 
        AND z.Дата_Занятия = d.Дата
    )
    OPTION (MAXRECURSION 365);
    
    INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
    SELECT 
        N'Автоматическое создание занятий по расписанию',
        N'Расписание',
        N'Успешно',
        CONCAT(
            'Расписание_ID: ', CAST(r.Расписание_ID AS NVARCHAR),
            ', Создано занятий: ', CAST(@@ROWCOUNT AS NVARCHAR)
        )
    FROM inserted r;
END;
GO
ALTER TABLE [dbo].[Расписание] ENABLE TRIGGER [TRG_АвтоСозданиеЗанятий]
GO
/****** Object:  Trigger [dbo].[TRG_Уведомление_ПриИзмененииРасписания]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    CREATE TRIGGER [dbo].[TRG_Уведомление_ПриИзмененииРасписания]
    ON [dbo].[Расписание]
    AFTER UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;
        
        IF UPDATE(Время_Начала) OR UPDATE(Время_Окончания) OR UPDATE(Кабинет) OR UPDATE(Аудитория_ID)
        BEGIN
            DECLARE @Изменения NVARCHAR(MAX);
            DECLARE @Группа_ID INT, @Дисциплина_ID INT, @День_Недели TINYINT;
            
            SELECT 
                @Группа_ID = i.Группа_ID,
                @Дисциплина_ID = i.Дисциплина_ID,
                @День_Недели = i.День_Недели,
                @Изменения = 
                    CASE WHEN i.Время_Начала <> d.Время_Начала 
                         THEN N'Время начала изменено с ' + CONVERT(NVARCHAR(5), d.Время_Начала) + N' на ' + CONVERT(NVARCHAR(5), i.Время_Начала) + N'; ' ELSE N'' END +
                    CASE WHEN i.Время_Окончания <> d.Время_Окончания 
                         THEN N'Время окончания изменено с ' + CONVERT(NVARCHAR(5), d.Время_Окончания) + N' на ' + CONVERT(NVARCHAR(5), i.Время_Окончания) + N'; ' ELSE N'' END +
                    CASE WHEN i.Кабинет <> d.Кабинет 
                         THEN N'Аудитория изменена с ' + ISNULL(d.Кабинет, N'не указана') + N' на ' + ISNULL(i.Кабинет, N'не указана') + N'; ' ELSE N'' END
            FROM inserted i
            INNER JOIN deleted d ON i.Расписание_ID = d.Расписание_ID
            WHERE i.Расписание_ID IS NOT NULL;
            
            IF LEN(@Изменения) > 0
            BEGIN
                -- Уведомляем всех студентов группы
                INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение)
                SELECT 
                    u.Пользователь_ID,
                    N'Важное',
                    N'Изменение в расписании',
                    CONCAT(N'В расписании вашей группы произошли изменения: ', @Изменения, N'Обратитесь к расписанию для подробностей.')
                FROM Учебная_Группа г
                INNER JOIN Студент s ON г.Группа_ID = s.Группа_ID
                INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
                WHERE г.Группа_ID = @Группа_ID;
            END
        END
    END
GO
ALTER TABLE [dbo].[Расписание] ENABLE TRIGGER [TRG_Уведомление_ПриИзмененииРасписания]
GO
/****** Object:  Trigger [dbo].[TRG_ОбновлениеПоследнегоВхода]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 12. Обновление времени последнего входа при создании сессии
CREATE TRIGGER [dbo].[TRG_ОбновлениеПоследнегоВхода]
ON [dbo].[Сессия_Пользователя]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE u
    SET Последний_Вход = GETDATE()
    FROM Пользователь u
    INNER JOIN inserted i ON u.Пользователь_ID = i.Пользователь_ID
    WHERE i.Активна = 1;
END;
GO
ALTER TABLE [dbo].[Сессия_Пользователя] ENABLE TRIGGER [TRG_ОбновлениеПоследнегоВхода]
GO
/****** Object:  Trigger [dbo].[TRG_МониторингСрокаДействияКарт]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 13. Мониторинг срока действия карт (уведомления)
CREATE TRIGGER [dbo].[TRG_МониторингСрокаДействияКарт]
ON [dbo].[СКУД_Карта]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(Дата_Истечения) OR (SELECT COUNT(*) FROM inserted) > 0
    BEGIN
        INSERT INTO Уведомления (Пользователь_ID, Тип, Заголовок, Сообщение, Срок_Действия)
        SELECT 
            u.Пользователь_ID,
            N'Информация',
            N'Срок действия карты истекает',
            CONCAT(
                N'Срок действия вашей карты СКУД (№', sk.Номер_Карты, 
                N') истекает ', FORMAT(sk.Дата_Истечения, N'dd.MM.yyyy'),
                N'. Обратитесь для продления.'
            ),
            sk.Дата_Истечения
        FROM СКУД_Карта sk
        INNER JOIN inserted i ON sk.Карта_ID = i.Карта_ID
        INNER JOIN Студент s ON sk.Студент_ID = s.Студент_ID
        INNER JOIN Пользователь u ON s.Пользователь_ID = u.Пользователь_ID
        WHERE sk.Дата_Истечения BETWEEN DATEADD(MONTH, 1, GETDATE()) AND DATEADD(MONTH, 2, GETDATE())
        AND sk.Статус = N'Активна'
        AND NOT EXISTS (
            SELECT 1 
            FROM Уведомления ув 
            WHERE ув.Пользователь_ID = u.Пользователь_ID
            AND ув.Заголовок LIKE N'%Срок действия карты истекает%'
            AND ув.Время_Создания > DATEADD(DAY, -7, GETDATE())
        );
    END
END;
GO
ALTER TABLE [dbo].[СКУД_Карта] ENABLE TRIGGER [TRG_МониторингСрокаДействияКарт]
GO
/****** Object:  Trigger [dbo].[TRG_СинхронизацияСКУДКарт]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 11. Синхронизация карт СКУД
CREATE TRIGGER [dbo].[TRG_СинхронизацияСКУДКарт]
ON [dbo].[СКУД_Карта]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Проверка уникальности номера карты
    IF UPDATE(Номер_Карты)
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM СКУД_Карта sk
            INNER JOIN inserted i ON sk.Номер_Карты = i.Номер_Карты
            WHERE sk.Карта_ID <> i.Карта_ID
        )
        BEGIN
            RAISERROR(N'Карта с таким номером уже зарегистрирована', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    
    -- Установка даты истечения, если не указана
    UPDATE sk
    SET Дата_Истечения = DATEADD(YEAR, 1, sk.Дата_Выдачи)
    FROM СКУД_Карта sk
    INNER JOIN inserted i ON sk.Карта_ID = i.Карта_ID
    WHERE sk.Дата_Истечения IS NULL;
    
    -- Автоматическое обновление статуса по дате истечения
    UPDATE sk
    SET Статус = CASE 
        WHEN sk.Дата_Истечения < GETDATE() THEN N'Истекла'
        WHEN sk.Статус = N'Активна' AND sk.Дата_Истечения < DATEADD(MONTH, 1, GETDATE()) THEN N'Скоро истекает'
        ELSE sk.Статус
    END
    FROM СКУД_Карта sk
    INNER JOIN inserted i ON sk.Карта_ID = i.Карта_ID;
END;
GO
ALTER TABLE [dbo].[СКУД_Карта] ENABLE TRIGGER [TRG_СинхронизацияСКУДКарт]
GO
/****** Object:  Trigger [dbo].[TRG_КонсистентностьДанныхСтудента]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 7. Консистентность данных студента
CREATE TRIGGER [dbo].[TRG_КонсистентностьДанныхСтудента]
ON [dbo].[Студент]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Проверка при смене группы
    IF UPDATE(Группа_ID)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Посещаемость p
            INNER JOIN Занятие z ON p.Занятие_ID = z.Занятие_ID
            INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
            INNER JOIN inserted i ON p.Студент_ID = i.Студент_ID
            WHERE r.Группа_ID <> i.Группа_ID
        )
        BEGIN
            INSERT INTO Лог_Действий (Действие, Таблица, Статус, Параметры)
            SELECT 
                N'Обнаружены записи посещаемости для студента в старой группе',
                N'Студент',
                N'Предупреждение',
                N'Студент_ID: ' + CAST(i.Студент_ID AS NVARCHAR) + 
                N', Новая группа: ' + CAST(i.Группа_ID AS NVARCHAR)
            FROM inserted i;
        END
    END
    
    -- Проверка при смене пользователя
    IF UPDATE(Пользователь_ID)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Студент s
            INNER JOIN inserted i ON s.Пользователь_ID = i.Пользователь_ID
            WHERE s.Студент_ID <> i.Студент_ID
        )
        BEGIN
            RAISERROR(N'Этот пользователь уже привязан к другому студенту', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO
ALTER TABLE [dbo].[Студент] ENABLE TRIGGER [TRG_КонсистентностьДанныхСтудента]
GO
/****** Object:  Trigger [dbo].[TRG_ЗащитаСтруктурыДанных]    Script Date: 22-Apr-26 1:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 8. Защита структуры данных при изменении статуса группы
CREATE TRIGGER [dbo].[TRG_ЗащитаСтруктурыДанных]
ON [dbo].[Учебная_Группа]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(Статус)
    BEGIN
        DECLARE @Группа_ID INT, @НовыйСтатус NVARCHAR(20), @СтарыйСтатус NVARCHAR(20);
        
        SELECT 
            @Группа_ID = i.Группа_ID,
            @НовыйСтатус = i.Статус,
            @СтарыйСтатус = d.Статус
        FROM inserted i
        INNER JOIN deleted d ON i.Группа_ID = d.Группа_ID;
        
        IF @НовыйСтатус IN (N'Выпущена', N'Расформирована') 
           AND @СтарыйСтатус NOT IN (N'Выпущена', N'Расформирована')
        BEGIN
            UPDATE z
            SET Статус = N'Отменено',
                Примечание = CONCAT(
                    ISNULL(z.Примечание, ''),
                    N' | Отменено автоматически при закрытии группы: ',
                    GETDATE()
                )
            FROM Занятие z
            INNER JOIN Расписание r ON z.Расписание_ID = r.Расписание_ID
            WHERE r.Группа_ID = @Группа_ID
            AND z.Дата_Занятия > CAST(GETDATE() AS DATE)
            AND z.Статус = N'Запланировано';
        END
    END
END;
GO
ALTER TABLE [dbo].[Учебная_Группа] ENABLE TRIGGER [TRG_ЗащитаСтруктурыДанных]
GO
USE [master]
GO
ALTER DATABASE [Улучшенная] SET  READ_WRITE 
GO

