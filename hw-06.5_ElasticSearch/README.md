# Домашнее задание «6.5. Elasticsearch»

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elasticsearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

**Ответ:**    
```
FROM centos:7
LABEL maintainer="Timofey Biryukov"
LABEL version="1.0"

RUN yum update -y && \
    yum install -y perl-Digest-SHA && \
    yum install -y java-1.8.0-openjdk.x86_64

ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.1-linux-x86_64.tar.gz /
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.1-linux-x86_64.tar.gz.sha512 /

RUN shasum -a 512 -c elasticsearch-7.12.1-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.12.1-linux-x86_64.tar.gz && \
    rm -rf elasticsearch-7.12.1-linux-x86_64.tar.gz elasticsearch-7.12.1-linux-x86_64.tar.gz.sha512

RUN sed -i 's/#cluster.name: my-application/cluster.name: netology_test/g' /elasticsearch-7.12.1/config/elasticsearch.yml && \
    sed -i 's/#path.data: \/path\/to\/data/path.data: \/var\/lib\/elasticsearch\/data/g' /elasticsearch-7.12.1/config/elasticsearch.yml && \
#   sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /elasticsearch-7.12.1/config/elasticsearch.yml
    echo network.host: 127.0.0.1 >> /elasticsearch-7.12.1/config/elasticsearch.yml && \
    echo http.host: 0.0.0.0 >> /elasticsearch-7.12.1/config/elasticsearch.yml


RUN useradd elastic  && \
    mkdir -p /var/lib/elasticsearch/data && \
    chown -R elastic /elasticsearch-7.12.1 /var/lib/elasticsearch/data

VOLUME /var/lib/elasticsearch/data

EXPOSE 9200/tcp
EXPOSE 9300/tcp

USER elastic

#CMD ["-Enode.name=netology_test"]
ENTRYPOINT ["/elasticsearch-7.12.1/bin/elasticsearch"]
```
- ссылку на образ в репозитории dockerhub

**Ответ:**    
комманды при выполнении:    
```
sudo docker build -t 0dok0/elasticsearch -f elasticsearch .
sudo docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 0dok0/elasticsearch
sudo docker login
sudo docker push 0dok0/elasticsearch
```
https://hub.docker.com/r/0dok0/elasticsearch


- ответ `elasticsearch` на запрос пути `/` в json виде

**Ответ:**    
```json
vagrant@vagrant:/$ curl -X GET 'http://localhost:9200/'
{
  "name" : "280fc4231b1f",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "e_pcps10RlyExWVp2FytzQ",
  "version" : {
    "number" : "7.12.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3186837139b9c6b6d23c3200870651f10d3343b7",
    "build_date" : "2021-04-20T20:56:39.040728659Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

---

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

**Выполнение:**    
```json
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/ind-1?pretty ' -H 'Content-Type: application/json' -d'
 {
   "settings": {
     "index": {
       "number_of_shards": 1,
       "number_of_replicas": 0
     }
   }
 }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/ind-2?pretty ' -H 'Content-Type: application/json' -d'
 {
   "settings": {
     "index": {
       "number_of_shards": 2,
       "number_of_replicas": 1
     }
   }
 }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/ind-3?pretty ' -H 'Content-Type: application/json' -d'
 {
   "settings": {
     "index": {
       "number_of_shards": 4,
       "number_of_replicas": 2
     }
   }
 }'

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.    
**Ответ:**    
```json
vagrant@vagrant:/$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 h_hEWWhYQc-mj_AkuntSAg   1   0          0            0       208b           208b
yellow open   ind-3 gX597_0TRTuQb7MGrgZ7xw   4   2          0            0       832b           832b
yellow open   ind-2 y7La3r00QumIw0D3A19k-g   2   1          0            0       416b           416b
```

Получите состояние кластера `elasticsearch`, используя API.    
**Ответ:**    
```json
vagrant@vagrant:/$ curl 'localhost:9200/_cluster/health?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 7,
  "active_shards" : 7,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 41.17647058823529
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?     
**Ответ:**    
*Потому, что в ind-2 и ind-3 имеются неназначенные реплики:*
```
vagrant@vagrant:/$ curl 'localhost:9200/_cat/shards?v&pretty'
index shard prirep state      docs store ip        node
ind-3 1     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-3 1     r      UNASSIGNED
ind-3 1     r      UNASSIGNED
ind-3 2     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-3 2     r      UNASSIGNED
ind-3 2     r      UNASSIGNED
ind-3 3     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-3 3     r      UNASSIGNED
ind-3 3     r      UNASSIGNED
ind-3 0     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-3 0     r      UNASSIGNED
ind-3 0     r      UNASSIGNED
ind-2 1     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-2 1     r      UNASSIGNED
ind-2 0     p      STARTED       0  208b 127.0.0.1 280fc4231b1f
ind-2 0     r      UNASSIGNED
ind-1 0     p      STARTED       0  208b 127.0.0.1 280fc4231b1f 
```

Удалите все индексы.    
**Выполнение:**    
```
vagrant@vagrant:/$ curl -X DELETE 'http://localhost:9200/ind-*?pretty'
{
  "acknowledged" : true
}

```
**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.


---

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.    
**Выполнение:**    
```
vagrant@vagrant:/$ docker exec -ti elasticsearch bash
[elastic@280fc4231b1f /]$ mkdir /elasticsearch-7.12.1/snapshots
[elastic@280fc4231b1f /]$ echo path.repo: /elasticsearch-7.12.1/snapshots >> /elasticsearch-7.12.1/config/elasticsearch.yml
[elastic@280fc4231b1f /]$ mkdir /elasticsearch-7.12.1/snapshots/netology_backup
^D
vagrant@vagrant:/$ sudo docker restart elasticsearch
```

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.     
**Ответ:**    
```json
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/_snapshot/netology_backup?pretty ' -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "netology_backup"
  }
}'
{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.    
**Выполнение и ответ:**    
```json
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/test?pretty ' -H 'Content-Type: application/json' -d'
 {
   "settings": {
     "index": {
       "number_of_shards": 1,
       "number_of_replicas": 0
     }
   }
 }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

vagrant@vagrant:/$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  Vrh8U5DrQFuWIQJq96j8fw   1   0          0            0       208b           208b
```
[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.    
**Выполнение и ответ:**    
```json
vagrant@vagrant:/$ curl -X PUT 'localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty'
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "R7ZfV3t3Syqgp02JuPRELQ",
    "version_id" : 7120199,
    "version" : "7.12.1",
    "indices" : [
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-05-18T13:07:22.859Z",
    "start_time_in_millis" : 1621343242859,
    "end_time" : "2021-05-18T13:07:23.060Z",
    "end_time_in_millis" : 1621343243060,
    "duration_in_millis" : 201,
    "failures" : [ ],
    "shards" : {
      "total" : 1,
      "failed" : 0,
      "successful" : 1
    },
    "feature_states" : [ ]
  }
}

vagrant@vagrant:/$ docker exec -ti elasticsearch bash

[elastic@280fc4231b1f /]$ ls -lha /elasticsearch-7.12.1/snapshots/netology_backup
total 52K
drwxrwxr-x 3 elastic elastic 4.0K May 18 13:07 .
drwxrwxr-x 3 elastic elastic 4.0K May 18 12:34 ..
-rw-r--r-- 1 elastic elastic  505 May 18 13:07 index-0
-rw-r--r-- 1 elastic elastic    8 May 18 13:07 index.latest
drwxr-xr-x 3 elastic elastic 4.0K May 18 13:07 indices
-rw-r--r-- 1 elastic elastic  26K May 18 13:07 meta-R7ZfV3t3Syqgp02JuPRELQ.dat
-rw-r--r-- 1 elastic elastic  283 May 18 13:07 snap-R7ZfV3t3Syqgp02JuPRELQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.    
**Выполнение и ответ:**    
```json
vagrant@vagrant:/$ curl -X DELETE 'http://localhost:9200/test?pretty'
{
  "acknowledged" : true
}
vagrant@vagrant:/$ curl -X PUT 'http://localhost:9200/test-2?pretty ' -H 'Content-Type: application/json' -d'
>  {
>    "settings": {
>      "index": {
>        "number_of_shards": 1,
       "number_of_replicas": 0
>        "number_of_replicas": 0
>      }
>    }
>  }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

vagrant@vagrant:/$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 MN3054O0TGiuwILGiVBNSg   1   0          0            0       208b           208b

```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.    
**Выполнение и ответ:**    
```json
vagrant@vagrant:/$ curl -X POST 'localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty'
{
  "accepted" : true
}

vagrant@vagrant:/$ curl 'localhost:9200/_cat/indices?v&pretty'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 MN3054O0TGiuwILGiVBNSg   1   0          0            0       208b           208b
green  open   test   DbDlIWULT-iqM5dUjif9pA   1   0          0            0       208b           208b

```


Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

Николай Хащанов (преподаватель)
22 мая 2021 11:10

Добрый день, Тимофей.
Спасибо за выполненную работу.

Вы хорошо справились со всеми заданиями.

Успехов в дальнейшем обучении!
