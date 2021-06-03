# Домашнее задание «6.1. Типы и структура СУБД»

## 1 - задание.    
Архитектор ПО решил проконсультироваться у вас, какой тип БД 
лучше выбрать для хранения определенных данных.
Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор. 

Он вам предоставил следующие типы сущностей, которые нужно будет хранить в БД:

- Электронные чеки в json виде    
**Ответ:**    
Если не требуются сложные аналитические запросы то подойдут NoSQL документо-ориентированные NoSQL БД (типа MongoDB), т.к. прекрасно подходят для хранения данных формата json. 

- Склады и автомобильные дороги для логистической компании    
**Ответ:**    
Т.к. будет много связанных объектов с необходимостью быстрого поиска связей подойдет NoSQL БД графового типа. Информацию же по данным на складах уже лучше хранить в реляционной БД, поскольку потребуются структурирование и согласованность данных.

- Генеалогические деревья    
**Ответ:**    
Т.к. будут древовидные структуры хранения данных с большим количеством связей и возможных пересечений связей по объектам я бы рекомендовал графовую NoSQL БД для хранения связей + NoSQL документо-ориентированная для хранения метаданных по объектам.

- Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации    
**Ответ:**    
Подойдет Memcached т.к. является быстродействующим (хранится в ОЗУ) простым и не ресурсоёмким NoSQL инструментом типа ключ-значение, а так же поддерживает Time-To-Live для данных.

- Отношения клиент-покупка для интернет-магазина    
**Ответ:**    
Поскольку связь единичная и несложно реализовать выборку удобнее будет использовать реляционную SQL базу данных, т.к. наверняка понадобятся дополнительные возможности по другим запросам в рамках интернет магазина. Хотя если требуется отдельно хранить только заказы в соответствии с клиентами, то можно использовать и NoSQL документо-ориентированные БД.  

---

## 2 - задание.    
Вы создали распределенное высоконагруженное приложение и хотите классифицировать его согласно 
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система, если 
(каждый пункт - это отдельная реализация вашей системы и для каждого пункта надо привести классификацию):

А согласно PACELC-теореме, как бы вы классифицировали данные реализации?    

- Данные записываются на все узлы с задержкой до часа (асинхронная запись)    
**Ответ:**    
CAP: AP    
PACELC: PA/EL

- При сетевых сбоях, система может разделиться на 2 раздельных кластера    
**Ответ:**    
CAP: CA    
PACELC: PA/EC

- Система может не прислать корректный ответ или сбросить соединение    
**Ответ:**    
CAP: CP    
PACELC: PC/EC

---

## 3 - задание.    
Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?

**Ответ:**    
Одновременно не могут. ACID изначально предусматривает точную фиксацию и согласованность всех данных, BASE же разрешает частичную деградацию и временную несогласованность в угоду доступности.

---

## 4 - задание.    
Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни
- реакция на истечение таймаута

Вы слышали о key-value хранилище, которое имеет механизм [Pub/Sub](https://habr.com/ru/post/278237/). 
Что это за система? Какие минусы выбора данной системы?

**Ответ:**    
Под данное описание подпадает СУБД Redis.
Это система с высоким быстродейсвием, хранящая данные в оперативной памяти по принципу "ключ-значение".
Которая так же поддерживает механизм подписки на публикации (pub/sub).

Существует множество потенциальных преимуществ и потенциальных недостатков использования Redis 
вместо классической реляционной СУБД. Они действительно очень разные по сути и назначению. 
Но вот некоторые из недостатков по сравнению с РСУБД:    
- размер БД ограничен доступной оперативной памятью;    
- нет возможности разделения доступа по пользователям и группам, доступ осуществляется по общему паролю;   
- отсутствие очередей сообщений;   
- это сервер структуры данных, нет языка запросов (только команды);
- при подходе pub/sub издетель не контролирует получение сообщений подписчиками;    
- уникальный экземпляр Redis не масштабируется, он работает только на одном ядре процессора в однопоточном режиме. (Чтобы получить масштабируемость, несколько экземпляров Redis должны быть развернуты и запущены.);
- без "Redis Sentinel" не имеет механизма консенсуса (при отказе ведущей реплики необходимо вручную выбрать новую ведущую реплику).