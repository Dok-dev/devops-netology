# Домашнее задание «6.3. MySQL»

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.
  
**Ответ:**    
```
vagrant@vagrant:~$ sudo docker run -d --name mysql -e MYSQL_ROOT_PASSWORD='123456' -p 3306:3306 -v sqlbackup:/sqlbuckup mysql:8

vagrant@vagrant:~$ sudo wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql /var/lib/docker/volumes/sqlbackup/_data

vagrant@vagrant:~$ sudo docker exec -ti mysql bash 

root@82788d8c4b50:/#  mysql -u root -p

mysql> \h

mysql> create database test_db;
mysql> exit

root@82788d8c4b50:/# mysql -u root -p test_db < /sqlbuckup/test_dump.sql

root@82788d8c4b50:/# mysql -u root -p
```
```sql
use test_db;
SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.01 sec)
```


---

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"   
     
**Ответ:**    
```
mysql -u root -p --default-auth=mysql_native_password
```
```sql
CREATE USER 'test'@'%'
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_QUERIES_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3
    ATTRIBUTE '{"Name": "James", "lname":"Pretty"}';
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.    

**Ответ:**    
```sql
GRANT SELECT ON test_db.* TO 'test'@'%';
FLUSH PRIVILEGES;
```
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

**Ответ:**    
```sql
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
+------+------+--------------------------------------+
| USER | HOST | ATTRIBUTE                            |
+------+------+--------------------------------------+
| test | %    | {"Name": "James", "lname": "Pretty"} |
+------+------+--------------------------------------+
```

---

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

**Ответ:**    
```sql
set profiling=1;

mysql> SELECT * FROM test_db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+------------------------------+
| Query_ID | Duration   | Query                        |
+----------+------------+------------------------------+
|        1 | 0.00028175 | SELECT DATABASE()            |
|        2 | 0.00043300 | SELECT DATABASE()            |
|        3 | 0.00212300 | show databases               |
|        4 | 0.00246700 | show tables                  |
|        5 | 0.00047675 | SELECT * FROM test_db.orders |
+----------+------------+------------------------------+
5 rows in set, 1 warning (0.00 sec)
```

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

**Ответ:**    
```sql
SELECT engine, table_name FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db';
+--------+------------+
| ENGINE | TABLE_NAME |
+--------+------------+
| InnoDB | orders     |
+--------+------------+
1 row in set (0.01 sec)
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

**Ответ:**    
```sql
# ALTER TABLE orders ENGINE = MyISAM;  Опасный способ (блокируется таблица, теряются внешние ключи и грузит диск).

CREATE TABLE orders2 LIKE orders;
ALTER TABLE orders2 ENGINE=MyISAM;
INSERT INTO orders2 SELECT * FROM orders;
DROP TABLE orders;
RENAME TABLE orders2 TO orders;
# Для больших таблиц тоже негодится из за высокой нагрузки на диск и большого журнала отмены. В таком случае копировать данные нужно порционно.

SELECT engine, table_name FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db';
+--------+------------+
| ENGINE | TABLE_NAME |
+--------+------------+
| MyISAM | orders     |
+--------+------------+
1 row in set (0.00 sec)


SELECT * FROM test_db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.01 sec)

mysql> SHOW PROFILES;
+----------+------------+---------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                 |
+----------+------------+---------------------------------------------------------------------------------------+
|        5 | 0.00047675 | SELECT * FROM test_db.orders                                                          |
|       12 | 0.06643100 | CREATE TABLE orders2 LIKE orders                                                      |
|       13 | 0.08881025 | ALTER TABLE orders2 ENGINE=MyISAM                                                     |
|       14 | 0.00598700 | INSERT INTO orders2 SELECT * FROM orders                                              |
|       15 | 0.03229625 | DROP TABLE orders                                                                     |
|       16 | 0.01533500 | RENAME TABLE orders2 TO orders                                                        |
|       17 | 0.00236600 | SELECT engine, table_name FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db' |
|       18 | 0.00179650 | SELECT * FROM test_db.orders                                                          |
+----------+------------+---------------------------------------------------------------------------------------+
15 rows in set, 1 warning (0.00 sec)
# скорость выполнения упала на порядок

```

---

## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

**Ответ:**    
```
# The MySQL  Server configuration file.
[mysqld]

# - Скорость IO важнее сохранности данных
# Быстраа но менне бережная многопоточная логика сброса данных на диск
innodb_flush_metod = O_DSYNK
# Поведение механизма сброса операций в лог файл на диск, при скорости IO важнее чем сохранность данных
innodb_flush_log_at_trx_commit = 2

# - Нужна компрессия таблиц для экономии места на диске
# Хранение таблиц по разным файлам. Таблицы, созданные с параметром innodb_file_per_table могут использовать innodb_file_format=Barracuda, 
# а этот формат в свою очередь дает возможность работать с ROW_FORMAT=COMPRESSED и ROW_FORMAT=DYNAMIC. 
# Можно выполнять операцию OPTIMIZE TABLE tbl_name. Операция TRUNCATE [TABLE] tbl_name выполняется гораздо быстрее.
innodb_file_per_table = 1

# - Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1M

# - Буффер кеширования 30% от ОЗУ
# Не совсем понятно от чего отталкиваться, но т. к. контейнеру выделено 1Gb (cat /proc/meminfo)
innodb_buffer_pool_size = 300M

# - Размер файла логов операций 100 Мб
innodb_log_file_size = 100M

pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/
```

