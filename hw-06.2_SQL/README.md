# Домашнее задание «6.2. SQL»

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.    
**Ответ:**    
Согласно документации официальный образ postgres:12 уже содержит один volume 'VOLUME /var/lib/postgresql/data' для БД, но мы можем его перезаписать:
```bash
docker pull postgres:12
docker volume create sqlbackup
docker run -d --name postgres --restart unless-stopped -e POSTGRES_PASSWORD=netology -p 5432:5432 -v sqlbackup:/backups postgres:12

vagrant@vagrant:~$ sudo docker volume ls
DRIVER    VOLUME NAME
local     469d5c547f4e4d87a691c73f1eacc428edec23183dcec3d9ecb584a3ac54ec8a
local     sqlbackup
```
В случае замена volume:
```bash
docker volume create sqlbackup
docker volume create posgres_db
docker run -d --name postgres --restart unless-stopped -e POSTGRES_PASSWORD=netology -p 5432:5432 -v sqlbackup:/backups -v posgres_db:/var/lib/postgresql/data  postgres:12

vagrant@vagrant:~$ sudo docker volume ls
DRIVER    VOLUME NAME
local     posgres_db
local     sqlbackup
```
```
vagrant@vagrant:~$ sudo docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS                                       NAMES
c53286af4999   postgres:12   "docker-entrypoint.s…"   6 minutes ago   Up 4 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres
```
---

## Задача 2

В БД из задачи 1:    
- создайте пользователя test-admin-user и БД test_db
```
vagrant@vagrant:~$ sudo docker exec -ti postgres bash

root@c53286af4999:/# su postgres

postgres@c53286af4999:/$ psql
psql (12.6 (Debian 12.6-1.pgdg100+1))
Type "help" for help.

postgres=#
```
```sql
CREATE DATABASE test_db;

\c test_db

CREATE USER "test-admin-user" WITH ENCRYPTED PASSWORD '123456';
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)    

Таблица orders:    
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:    
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)
```sql
CREATE TABLE test_db.public.orders (
id SERIAL PRIMARY KEY,
name varchar(150) NOT NULL,
price numeric (8, 2)
);

CREATE TABLE test_db.public.clients (
id SERIAL PRIMARY KEY,
fio varchar(250) NOT NULL,
country varchar(150) NOT NULL,
order_id INT,
FOREIGN KEY (order_id) REFERENCES orders (id)
);
```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```sql
GRANT SELECT ON test_db IN SCHEMA public TO "test-admin-user";
GRANT ALL PRIVILEGES ON DATABASE test_db TO "test-admin-user";
\c test_db;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
```

- создайте пользователя test-simple-user    
```sql
CREATE USER "test-simple-user" WITH ENCRYPTED PASSWORD '1234';
```
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```sql
\c test_db;
GRANT SELECT ON test_db IN SCHEMA public TO "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON test_db IN SCHEMA public TO "test-simple-user";
```

Приведите:    
- итоговый список БД после выполнения пунктов выше,    
**Ответ:**    
```
test_db=# \list
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```

- описание таблиц (describe)    
**Ответ:**    
```
test_db=# \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(150) |           | not null |
 price  | numeric(8,2)           |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

test_db=# \d clients
                                        Table "public.clients"
  Column  |          Type          | Collation | Nullable |                  Default
----------+------------------------+-----------+----------+-------------------------------------------
 id       | integer                |           | not null | nextval('clients_id_seq'::regclass)
 fio      | character varying(250) |           | not null |
 country  | character varying(150) |           | not null |
 order_id | integer                |           | not null | nextval('clients_order_id_seq'::regclass)
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db    
**Ответ:**    
```sql
SELECT *
FROM information_schema.table_privileges
WHERE table_name = 'clients' OR table_name = 'orders';
```
- список пользователей с правами над таблицами test_db        
**Ответ:**    
```
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | postgres         | test_db       | public       | orders     | INSERT         | YES          | NO
 postgres | postgres         | test_db       | public       | orders     | SELECT         | YES          | YES
 postgres | postgres         | test_db       | public       | orders     | UPDATE         | YES          | NO
 postgres | postgres         | test_db       | public       | orders     | DELETE         | YES          | NO
 postgres | postgres         | test_db       | public       | orders     | TRUNCATE       | YES          | NO
 postgres | postgres         | test_db       | public       | orders     | REFERENCES     | YES          | NO
 postgres | postgres         | test_db       | public       | orders     | TRIGGER        | YES          | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | postgres         | test_db       | public       | clients    | INSERT         | YES          | NO
 postgres | postgres         | test_db       | public       | clients    | SELECT         | YES          | YES
 postgres | postgres         | test_db       | public       | clients    | UPDATE         | YES          | NO
 postgres | postgres         | test_db       | public       | clients    | DELETE         | YES          | NO
 postgres | postgres         | test_db       | public       | clients    | TRUNCATE       | YES          | NO
 postgres | postgres         | test_db       | public       | clients    | REFERENCES     | YES          | NO
 postgres | postgres         | test_db       | public       | clients    | TRIGGER        | YES          | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
(36 rows)

test_db=# \dp orders
                                      Access privileges
 Schema |  Name  | Type  |         Access privileges          | Column privileges | Policies
--------+--------+-------+------------------------------------+-------------------+----------
 public | orders | table | postgres=arwdDxt/postgres         +|                   |
        |        |       | "test-admin-user"=arwdDxt/postgres+|                   |
        |        |       | "test-simple-user"=arwd/postgres   |                   |
(1 row)

test_db=# \dp clients
                                      Access privileges
 Schema |  Name   | Type  |         Access privileges          | Column privileges | Policies
--------+---------+-------+------------------------------------+-------------------+----------
 public | clients | table | postgres=arwdDxt/postgres         +|                   |
        |         |       | "test-admin-user"=arwdDxt/postgres+|                   |
        |         |       | "test-simple-user"=arwd/postgres   |                   |
(1 row)
```

---

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

**Ответ:**    
```sql
test_db=# INSERT INTO orders VALUES 
(1, 'Шоколад', 10), 
(2, 'Принтер', 3000), 
(3, 'Книга', 500), 
(4, 'Монитор', 7000), 
(5, 'Гитара', 4000);
INSERT 0 5

# Правильно, отработки счетчика:
INSERT INTO orders (name, price) VALUES 
('Шоколад', 10), 
('Принтер', 3000), 
('Книга', 500), 
('Монитор', 7000), 
('Гитара', 4000);

test_db=# SELECT * from orders;
 id |  name   |  price
----+---------+---------
  1 | Шоколад |   10.00
  2 | Принтер | 3000.00
  3 | Книга   |  500.00
  4 | Монитор | 7000.00
  5 | Гитара  | 4000.00
(5 rows)
```

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

**Ответ:**    
```sql
test_db=# INSERT INTO clients VALUES 
(1, 'Иванов Иван Иванович', 'USA', 6), 
(2, 'Петров Петр Петрович', 'Canada', 6), 
(3, 'Иоганн Себастьян Бах', 'Japan', 6), 
(4, 'Ронни Джеймс Дио', 'Russia', 6), 
(5, 'Ritchie Blackmore', 'Russia', 6);
INSERT 0 5
test_db=# INSERT INTO orders VALUES (6, 'нет заказов', 0);

INSERT 0 5
test_db=# INSERT INTO orders VALUES (6, 'нет заказов', 0);

# Правильно, отработки счетчика:
test_db=# INSERT INTO clients (fio, country, order_id) VALUES 
('Иванов Иван Иванович', 'USA', NULL), 
('Петров Петр Петрович', 'Canada', NULL), 
('Иоганн Себастьян Бах', 'Japan', NULL), 
('Ронни Джеймс Дио', 'Russia', NULL), 
('Ritchie Blackmore', 'Russia', NULL);
```

Т.к. у нас имеется внешний ключ с номером заказа необходимо добавить еще один пустой заказ к таблие orders:
```sql
test_db=# INSERT INTO orders VALUES (6, 'нет заказов', 0);
```

test_db=# SELECT * from clients;
 id |         fio          | country | order_id
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        6
  2 | Петров Петр Петрович | Canada  |        6
  3 | Иоганн Себастьян Бах | Japan   |        6
  4 | Ронни Джеймс Дио     | Russia  |        6
  5 | Ritchie Blackmore    | Russia  |        6
(5 rows)
```

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы    

**Ответ:**    
```sql
test_db=# SELECT COUNT(*) from clients;
 count
-------
     5
(1 row)

test_db=# SELECT COUNT(*) from orders;
 count
-------
     6
(1 row)
```
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

---

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.    

**Ответ:**    
```sql
UPDATE clients SET order_id = 3 WHERE fio = 'Иванов Иван Иванович'; 
UPDATE clients SET order_id = 4 WHERE fio = 'Петров Петр Петрович'; 
UPDATE clients SET order_id = 5 WHERE fio = 'Иоганн Себастьян Бах'; 
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.    
**Ответ:**    
```sql
SELECT * FROM clients WHERE order_id != 6;

 id |         fio          | country | order_id
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)
```
 ---

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

**Ответ:**    
```sql
test_db=# EXPLAIN SELECT * from clients;
                                  QUERY PLAN
          -----------------------------------------------------------
           Seq Scan on clients  (cost=0.00..10.90 rows=90 width=842)
          (1 row)
```
Seq Scan — последовательное, блок за блоком, чтение данных таблицы.    
0.00 - стоимость (абстратная временная единица) обработки до начала вывода первой строки.    
10.90 - стоимость по времени до вывода последней строки.    
rows - ожидаемое количество возвращаемых строк при выполнении операции, по мению планировщика.    
width - средняя, ожидаемая прланировщиком, длина строки.    

После пересчета и обновления статистики:
```sql
test_db=# ANALYZE clients;
ANALYZE
test_db=# EXPLAIN VERBOSE SELECT * from clients;
                          QUERY PLAN
---------------------------------------------------------------
 Seq Scan on public.clients  (cost=0.00..1.05 rows=5 width=47)
   Output: id, fio, country, order_id

# или EXPLAIN (ANALYZE) SELECT * from clients;
```
---

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).   

код для ответа:
```
root@c53286af4999:/# pg_dump -U postgres test_db > backups/test_db.sql
exit
```
Остановите контейнер с PostgreSQL (но не удаляйте volumes).

код для ответа:
```bash
sudo docker stop postgres
```
Поднимите новый пустой контейнер с PostgreSQL.

код для ответа:
```bash
docker run -d --name postgres2 -e POSTGRES_PASSWORD=netology -p 5432:5432 -v sqlbackup:/backups postgres:12
```

Восстановите БД test_db в новом контейнере.

код для ответа:
```
vagrant@vagrant:~$ sudo docker exec -ti postgres2 bash

root@4fcbbbca9855:/# psql -U postgres -c "CREATE DATABASE test_db;"
CREATE DATABASE

root@4fcbbbca9855:/# psql -U postgres test_db < backups/test_db.sql
# так же можно использовать утилиту pg_restore

psql -U postgres
```
```sql
\c test_db
CREATE USER "test-admin-user" WITH ENCRYPTED PASSWORD '123456';
GRANT ALL PRIVILEGES ON DATABASE test_db TO "test-admin-user";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
CREATE USER "test-simple-user" WITH ENCRYPTED PASSWORD '1234';
GRANT SELECT ON test_db IN SCHEMA public TO "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления.    

---

Николай Хащанов (преподаватель)
5 мая 2021 15:48

Добрый день, Тимофей.
Спасибо за выполненную работу.

В таблице clients у атрибута order_id не может быть типа данных serial, так как значения в этом столбце должны вноситься вручную, а не автоинкрементом, должен быть тип integer.

В задании 3 при внесении данных в таблицы лучше указать в какие столбцы будете вносить данные и руками не заполнять идентификаторы, которые имеют тип serial, потому что при ручном внесении не отрабатывает счетчик автоинкремента и в дальнейшем будут ошибки при внесении данных.
Так же нет необходимости добавлять пустой заказ, так как у столбца order_id нет ограничения not null и можно просто внести null в случает отсутствия заказа.

По остальным заданиям и моментам все верно - в результате очень хорошая работа!

Будут вопросы - пишите в слаке.

Успехов в дальнейшем обучении!
