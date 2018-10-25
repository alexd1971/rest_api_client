# REST API Client

Library of tools to create REST resource clients (web- и mobile-clients are supported)

## Структура

В основе библиотеки лежит класс `RestResource`, который для общения с API-сервером использует `RestClient`. Объекты, с которыми работает `RestResource` должны реализовывать интерфейс `JsonEncodable`

`RestResource` изначально поддерживает стандартные методы (CRUD) работы с REST-ресурсами:
* `create` - создание объекта
* `read` - получение объекта/списка объектов
* `update` - частичное обновление данных объекта
* `replace` - полная замена данных объекта
* `delete` - удаление объекта

При наследовании ресурсы можно дополнять другими необходимыми методами.

## Примеры использования

Конкретные варианты использования можно посмотреть в [примерах](https://github.com/alexd1971/rest_resource/blob/master/example/rest_resource_example.dart), а также кое что можно почерпнуть из тестов.

## Тестирование

`pub run test -p vm,chrome`