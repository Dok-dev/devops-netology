# Домашнее задание к занятию "10.3 Grafana"

## Обязательные задания

### Задание 1
Используя директорию [help](./help) внутри данного домашнего задания - запустите связку prometheus-grafana.

Зайдите в веб-интерфейс графана, используя авторизационные данные, указанные в манифесте docker-compose.

Подключите поднятый вами prometheus как источник данных.

Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.

> **Ответ:**    
> ![1](1.png)  


## Задание 2
Изучите самостоятельно ресурсы:
- [promql-for-humans](https://timber.io/blog/promql-for-humans/#cpu-usage-by-instance)
- [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)

Создайте Dashboard и в ней создайте следующие Panels:
- Утилизация CPU для nodeexporter (в процентах, 100-idle)
> **Ответ:**    
> (1 - avg by(instance)(irate(node_cpu_seconds_total{instance="nodeexporter:9100", job="nodeexporter", mode="idle"}[5m]))) * 100

- CPULA 1/5/15
> **Ответ:**    
> Что бы корректно отрисовывать шкалу — нам потребуется получить значение LA, поделить его на кол-во ядер и умножить на 100 — получим % от «максимального» значения(в кавычках, потому что LA может быть и выше 1):
> avg(node_load1{instance="nodeexporter:9100", job="nodeexporter"}) / count(count(node_cpu_seconds_total{instance="nodeexporter:9100", job="nodeexporter"}) by (cpu)) * 100
> avg(node_load5{instance="nodeexporter:9100", job="nodeexporter"}) / count(count(node_cpu_seconds_total{instance="nodeexporter:9100", job="nodeexporter"}) by (cpu)) * 100
> avg(node_load15{instance="nodeexporter:9100", job="nodeexporter"}) / count(count(node_cpu_seconds_total{instance="nodeexporter:9100", job="nodeexporter"}) by (cpu)) * 100

- Количество свободной оперативной памяти
> **Ответ:**    
> В мегабайтах:
> node_memory_MemFree_bytes{instance="nodeexporter:9100", job="nodeexporter"}/1024^2
> Если в процентах:
> node_memory_MemFree_bytes{instance="nodeexporter:9100", job="nodeexporter"} / (node_memory_MemTotal_bytes{instance="nodeexporter:9100", job="nodeexporter"} / 100)

- Количество места на файловой системе
> **Ответ:**    
> 
> node_filesystem_avail_bytes{instance="nodeexporter:9100", job="nodeexporter", mountpoint="/",fstype!="tmpfs"}/1024^3

Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.


## Задание 3
Создайте для каждой Dashboard подходящее правило alert (можно обратиться к первой лекции в блоке "Мониторинг").

Для решения ДЗ - приведите скриншот вашей итоговой Dashboard.
> **Ответ:**    
> ![3](3.png)    
> ![3.1](3.1.png)   

## Задание 4
Сохраните ваш Dashboard.

Для этого перейдите в настройки Dashboard, выберите в боковом меню "JSON MODEL".

Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.

В решении задания - приведите листинг этого файла.
> **Ответ:**    
> https://github.com/Dok-dev/devops-netology/blob/main/hw-10.3_Monitoring-Grafana/dashboard_Netology.json

---

## Задание повышенной сложности

**В части задания 1** не используйте директорию [help](./help) для сборки проекта, самостоятельно разверните grafana, где в 
роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
- grafana
- prometheus-server
- prometheus node-exporter

За дополнительными материалами, вы можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы 
использовали в процессе решения задания.
> **Ответ:**    
> https://github.com/Dok-dev/devops-netology/blob/main/hw-10.3_Monitoring-Grafana/stack

**В части задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например Telegram или Email
и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.
> **Ответ:**    
> ![star2](star2.png)    
> ![star0](Screenshot_2021-08-18-16-50-12-682_org.telegram.messenger.png)    
> ![star](star.png)    
> ![star1](star1.png)  

