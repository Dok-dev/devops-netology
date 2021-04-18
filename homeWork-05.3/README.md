# Домашнее задание «5.3. Контейнеризация на примере Docker»

## Задание 1 

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;    
**Ответ:**    
Да, отлично подойдет. Будет отличная производительность, масштабирование и изоляция. Простота развертывания.

- Go-микросервис для генерации отчетов;    
**Ответ:**    
Да. Вполне приемлимый вариант. Будет просто переносить и разворачивать заново.

- Nodejs веб-приложение;    
**Ответ:**    
Да. Позволит оптимизировать процесс разработки и вывода в продакшн Node.js-проектов.

- Мобильное приложение c версиями для Android и iOS;    
**Ответ:**    
Не совсем понятно о чем идет речь, о приложении на телефоне или на бэкэнде этих приложений.
Если на телефоне, но нет. Если речь идет о среде для сборлки или бэкэнде то вполне. В готовой настроенно среде можно быстро собрать проект. Бэкэнд тоже может запускаться в контейнере и легко масштабироваться.

- База данных postgresql используемая, как кэш;    
**Ответ:**    
В случае если данные этого кэша не имеют особой ценности можно использовать запуск в контейненре.

- Шина данных на базе Apache Kafka;    
**Ответ:**    
Да. Apache Kafka изночально предусматривает кластеризацию и взрывное масштабирование, контеризация подходящая для этого технология позволяющая бысто разворачивать новые ноды.

- Очередь для Logstash на базе Redis;    
**Ответ:**    
Можно, но лучше с хранением данных вне контейнера.

- Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;    
**Ответ:**    
Да. Есть готовые решения с конетейнерами для стека ELK.

- Мониторинг-стек на базе prometheus и grafana;    
**Ответ:**    
Да. Хотя с сохранением данных мониторинга могут быть проблемы.

- Mongodb, как основное хранилище данных для java-приложения;    
**Ответ:**    
В данном случае лучше подойдет виртуальная или физическая машина с RAID для предотвращения потери данных приложений.

- Jenkins-сервер.    
**Ответ:**    
Да. Изоляция, переносимость, готовая среда для сборки.

---

## Задание 2

Сценарий выполения задачи:

- создайте свой репозиторий на докерхаб; 
- выберете любой образ, который содержит апачи веб-сервер;
- создайте свой форк образа;
- реализуйте функциональность: 
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже: 
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m kinda DevOps now</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.    

**Ответ:**    
https://hub.docker.com/r/0dok0/httpd-nettology

код:
```bash
docker pull httpd

echo FROM httpd > appache2_nettology2
echo COPY /home/vagrant/index.html /usr/local/htdocs/index.html >> appache2_nettology2

docker build -t 0dok0/httpd-nettology:latest -f appache2_nettology

docker run docker run -d --name httpd-nettology 0dok0/httpd-nettology

docker login

docker push 0dok0/httpd-nettology:latest
```

---

## Задание 3 

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /share/info контейнера;
- Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /info контейнера;
- Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info;
- Добавьте еще один файл в папку info на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.

**Ответ:**    
```
root@vagrant:/home/vagrant/docker# docker exec -ti debian bash
root@c03f90ffc194:/# ls -lha /share/info/
total 12K
drwxr-xr-x 2 root root 4.0K Apr 14 17:48 .
drwxr-xr-x 3 root root 4.0K Apr 14 17:51 ..
-rw-r--r-- 1 root root    3 Apr 14 17:40 test1
-rw-r--r-- 1 root root    0 Apr 14 17:48 test2
```

код:
```bash
docker run -v /home/vagrant/info:/share/info -d -it --name centos centos bash
docker run -v /home/vagrant/info:/share/info -d -it --name debian debian bash

docker exec -ti centos bash
touch /share/info/test2
^D

touch /home/vagrant/info/test1

docker exec -ti debian bash
ls -lha /share/info/
```