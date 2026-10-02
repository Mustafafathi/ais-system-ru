# Быстрый запуск AIS V2 RU

## Пути поставки

- Приложение: C:\xampp\htdocs\ais-system-ru
- Документация: C:\xampp\htdocs\ais-system-ru-docs
- URL приложения: http://localhost/ais-system-ru/

## Перед запуском

Проверьте, что запущены службы:

- Apache в XAMPP Control Panel
- SQL Server (MSSQLSERVER)

SQL Server должен принимать TCP-подключения на порту 15432, как указано в config.php.

## Если SQL Server остановлен

Откройте PowerShell или Services от имени администратора и выполните:

`powershell
Start-Service -Name MSSQLSERVER
`

Для плановых отчётов дополнительно:

`powershell
Start-Service -Name SQLSERVERAGENT
`

## Проверка приложения

1. Откройте http://localhost/ais-system-ru/.
2. Выполните вход под тестовой или рабочей учётной записью.
3. Проверьте роль администратора, преподавателя, студента, куратора и методиста.
4. При ошибке подключения к БД проверьте:
   - службу MSSQLSERVER;
   - порт 15432;
   - базу Улучшенная;
   - пользователя php_user;
   - расширение PHP sqlsrv.

## Состав документации

Полный индекс документации находится в README.md и README_RU.md этого каталога.
