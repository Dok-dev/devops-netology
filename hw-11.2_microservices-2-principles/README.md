# Домашнее задание к занятию "11.2 Микросервисы: принципы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.

> **Ответ:**    
>
> | Gateway API | Маршрутизация запросов | Аутентификация | Терминация HTTPS | Бесплатное решение |
> |:---:|:---:|:---:|:---:|:---:|
> | APISIX                 | да  | да  | да  | да  |
> | Apigee                 | да  | да  | да  | нет |
> | Kong                   | да  | да  | да  | да  |
> | Ambassador             | да  | да  | да  | нет |
> | Gloo                   | да  | да  | да  | нет |
> | MuleSoft               | да  | да  | да  | нет |
> | Axway                  | да  | да  | да  | нет | 
> | Istio                  | да  | да  | да  | да  |
> | Young App              | да  | да  | да  | нет |
> | SnapLogic              | да  | да  | да  | нет |
> | Akana API Platform     | да  | да  | да  | нет |
> | Oracle API Platform    | да  | да  | да  | нет |
> | TIBCO Cloud-Mashery    | да  | да  | да  | нет |
> | 3scale                 | да  | да  | да  | нет |
> | Google API Platform    | да  | да  | да  | нет |
> | SberCloud API Gateway  | да  | да  | да  | нет |
> | Amazon API Gateway     | да  | да  | да  | нет |
> | Aliyun                 | да  | да  | да  | нет |
> | Yandex API Gateway     | да  | да  | да  | нет |
> | Azure API Management   | да  | да  | да  | нет |
> 
> Поскольку применение платных решений необходимо обосновать, а для применения некоторых условно-платных нужно знать количество запросов, предпочтительнее будет рассмотреть бесплатные решения:    
>
> |           | APISIX|  Kong | Istio |
> |:---:|:---:|:---:|:---:|
> | Колличество доступных плагинов   | ** | *** | * |
> | Размер комьюнити                 | *  | *** | ** |
> | Технологии реализации            | Appache+Lua | Nginx+Lua | Nginx, Spring, ASP NET, Flask |
> | Частное развертывание            | да  | да  | да  |
> | Поддержка внешних IDP            | да  | да  | нет |
> | Поддержка YML                    | да  | да  | да  |
> | Качество документации            | **  | *** | *** |
>
> Учитывая приведенный выше анализ я бы наверное предложил Kong Gateway как хорошо развитый программный продукт с хорошей масштабируемостью и большим набором инструментов. Хотя наиболее функциональная версия "Enterprise edition" версия тоже является платной, функционал бесплатной версии удовлетворяет нашему заданию.


## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Простота эксплуатации

Обоснуйте свой выбор.

> **Ответ:**    
> Т.к. необходимость использования пропиетарных решений от Google, Azure, Amazon, Yandex т.д. неочевидна, то рассмотрим бесплатные open source решения:
> 
> |	                    | NATS | Apache Qpid | ActiveMQ Artemis | Apache Kafka | RabitMQ | Apache Pulsar |
> |:---:|:---:|:---:|:---:|:---:|:---:|:---:|
> |Поддержка кластеризации	                   |да | да | да | да | да | да |
> |Хранение сообщений на диске                 | нет | да |	да | да | да | да |
> |Разные форматы сообщений	                   | да | да | да | да | да | да |
> |Разделение прав доступа к потокам сообщений | да | да | да | да | да | да |
> |Простота эксплуатации	                   | *** | *** | *** | ** | ** | *** |
> |Качество документации                       | *** | *** | *** | *** | *** | *** |
> |Скорость работы	                           | ***** | ** | ** | **** | *** | **** |
> |Порядок доставки сообщений	               | нет | да | да | да | нет | да |
> |Возможности масштабироания	               | *** | ** | ** | *** | ** | *** |
> |Бесплатное opensource решение	           | да | да | да | да | да | да |
> 
> Наиболее производительными решениями с хранением сообщений на диске являются Apache Kafka и Apache Pulsar. Pulsar лучше приспособлен под геораспределенную структуру и лучше Kafka справляется с ростом числа топиков, я бы остановил свой выбор на нем.


## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**
- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**
- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизаци
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)

> **Ответ:**    
> Доработанный стек с результатами работы: https://github.com/Dok-dev/devops-netology/tree/main/hw-11.2_microservices-2-principles/stack/
> 
>#### Проверка
> получаем токен:
> ```console
> $ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
> eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
> ```
> запрос без токена:
> ```console
> $ curl -X POST -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
> Warning: Couldn't read data from file "1.jpg", this makes an empty POST.
> <html>
> <head><title>401 Authorization Required</title></head>
> <body>
> <center><h1>401 Authorization Required</h1></center>
> <hr><center>nginx/1.21.3</center>
> </body>
> </html>
> ```
> запрос с токеном:
> ```console
> $ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
> {"filename":"b3c5c420-27a7-404f-a85b-4ec3bb694c01.jpg"}
> ```
> загружаем картинку назад:
> ```console
> $ curl http://localhost/images/b3c5c420-27a7-404f-a85b-4ec3bb694c01.jpg > 2.jpg
>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
>                                  Dload  Upload   Total   Spent    Left  Speed
> 100 12117  100 12117    0     0   591k      0 --:--:-- --:--:-- --:--:--  622k
> $ ls -lha *.jpg
> -rw-rw-r-- 1 vagrant vagrant 12K Feb  3  2020 1.jpg
> -rw-rw-r-- 1 vagrant vagrant 12K Sep 26 14:03 2.jpg
> ```

---

Андрей Копылов (преподаватель)
27 сентября 2021 20:34

Добрый день!

Спасибо за отлично выполненное задание. Отмечу как идеально выполненное задание.
