# AIS V2 RU - поставочный комплект

## Назначение

Этот каталог содержит полный рабочий комплект системы AIS V2 RU для запуска через Apache/XAMPP.

## URL запуска

```text
http://localhost/ais-system-ru/
```

## Состав проекта

- `api.php` - единая точка API.
- `config.php` - конфигурация подключения и runtime-параметры.
- `index.php` - входная точка и маршрутизация по ролям.
- `login/` - вход, выход, установка сессии.
- `admin/`, `student/`, `teacher/`, `curator/`, `methodist/` - рабочие места ролей.
- `includes/` - общие компоненты интерфейса и проверки доступа.
- `assets/` - CSS, JavaScript, изображения и локальные QR-библиотеки.
- `integration/` - SKUD, CSV/1C, health endpoint и общие интеграционные функции.
- `Database/` - SQL Server scripts, хранимые процедуры и триггеры.
- `runtime/` - runtime-папки для сессий, idempotency и временных файлов.
- `uploads/` - каталог пользовательских вложений.
- `docs/final-delivery/ru/` - полный комплект русской документации и QA-отчёт.

## Быстрый старт

1. Запустить Apache в XAMPP.
2. Запустить SQL Server `MSSQLSERVER`.
3. Проверить, что SQL Server доступен на `localhost,15432`.
4. Открыть `http://localhost/ais-system-ru/`.
5. Читать `docs/final-delivery/ru/START_HERE_RU.md`.

## Документация

Основной индекс документации:

```text
docs/final-delivery/ru/README.md
```

Отчёт проверки пакета:

```text
docs/final-delivery/ru/PACKAGE_QA_REPORT_RU.md
```
