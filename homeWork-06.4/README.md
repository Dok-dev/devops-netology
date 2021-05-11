# Домашнее задание «6.4. PostgreSQL»

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql
  
**Ответ:**    
```
docker volume create postgre_db
docker run -d --name postgres --restart unless-stopped -e POSTGRES_PASSWORD=netology -p 5432:5432 -v postgre_db:/var/lib/postgresql/data postgres:13
docker exec -ti postgres bash

root@8241e96f3086:/# psql -U postgres
```
```
# вывод списка БД:
\l
# подключения к БД:
\c
# вывода списка таблиц в текущей схеме
\dt
# вывода описания содержимого таблиц
\d таблицы
# выхода из psql
\q

```

---

## Задача 2

Используя `psql` создайте БД `test_database`.
```
root@8241e96f3086:/# psql -U postgres -c "CREATE DATABASE test_database;"
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.
```
vagrant@vagrant:~$ sudo wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql
vagrant@vagrant:~$ sudo docker cp test_dump.sql postgres:/root
vagrant@vagrant:~$ sudo docker exec -ti postgres bash
root@8241e96f3086:/# psql -U postgres test_database < root/test_dump.sql
# Еще можно использовать утилиту pg_restore если дамп не текстового формата, как в данном случае.
root@8241e96f3086:/# psql -U postgres
```

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```sql
\c test_database;
ANALYZE orders;
```
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
     
**Ответ:**    
```sql
SELECT attname FROM pg_stats WHERE avg_width = (SELECT MAX(avg_width) FROM pg_stats WHERE tablename = 'orders');
 attname
---------
 title
(1 row)

```

---

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

**Ответ:**     
Невозможно превратить обычную таблицу в партиционированную или наоборот. Тем не менее, можно добавить обычную или партиционированную таблицу, 
содержащую данные, как партицию в партиционированную таблицу (ATTACH PARTITION и DETACH PARTITION). Также можно удалить партицию из патиционированной 
таблицы, превратив её в обычную таблицу.
Но в нашем случае понадобится полная переливка данных в новую таблицу.
```sql
BEGIN;

CREATE TABLE orders_new (LIKE orders INCLUDING DEFAULTS) PARTITION BY RANGE (price);
--- В PostgreSQL > 9 триггеры вставки по партициям формируются автоматически, а счетчик переносится с базовой таблици автоматическим запросом
--- типа ALTER TABLE orders_new ADD id int4 NOT NULL DEFAULT nextval('orders_id_seq'::regclass);
--- Поэтому нам остается только создать необходимые партиции.
--- Т.к. при создании диапазонной секции нижняя граница, задаваемая во FROM, включается в диапазон, а верхняя граница, задаваемая в TO — исключается:
CREATE TABLE orders_1 PARTITION OF orders_new FOR VALUES FROM (MINVALUE) TO (499);
CREATE TABLE orders_2 PARTITION OF orders_new FOR VALUES FROM (499) TO (MAXVALUE);

--- Во время копирования могут не попасть новые данные, их надо будет догнать позже.
INSERT INTO orders_new SELECT * FROM orders;

--- Если таблица очень большая то возможно будет намного быстрее сделать так:
---COPY orders TO '/tmp/table.csv' DELIMITER ',';
---COPY orders_new FROM '/tmp/table.csv' DELIMITER ',';

--- Максимальное время выполнения оператора установим в 1 сек, что бы предотвратить всех каскадную блокировку других транзакций. А партиционирование можно повторить еще раз.
SET statement_timeout TO '1s';

--- Важно не забыть про права, но у нас в исходной таблице оригинальных прав нет.
--- Собственно пореименуем таблицы.
ALTER TABLE orders RENAME TO orders_old;
ALTER TABLE orders_new RENAME TO orders;

COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**Ответ:**    
Конечно! Таблицу лучше было сразу создавать партиционированной, что бы избежать последующего копирования данных, т.к. непартицонированную таблицу партиционировать нельзя.


---

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

**Ответ:**    
Бэкап:
```
root@8241e96f3086:/# pg_dump -U postgres test_database > root/test_database2.sql
```
Делаем резервную копию (с расширением .bak) и добавляем в файле бэкапа ключь уникальности для всех столбцов title:
```
root@8241e96f3086:/# sed -i.bak 's/title character varying(80)/title character varying(80) UNIQUE/g' /root/test_database2.sql
```

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
