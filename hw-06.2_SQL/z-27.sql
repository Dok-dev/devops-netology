select * from customer

select first_name, last_name from customer

create database название_базы

create schema b

set search_path to b

create table author (author_id serial primary key)

drop table author

create table books (
	id serial primary key,
	book_name varchar(150) not null,
	book_year int2 not null check(book_year between 1800 and 2100),
	author_id int2 ,
	create_date timestamp default now(),
	deleted int2 default 0
)

alter table books add constraint books_author_fkey foreign key (author_id) references author(author_id)

alter table books add column b_test int[]

alter table books drop column deleted

select * from books

select * from payment

drop view aaa

create view aaa as 
	select customer_id, payment_date, round(amount * 0.8 * 1.3, 2)
	from payment 

explain analyze
select * from aaa

create materialized view bbb as 
	select customer_id, payment_date, round(amount * 0.8 * 1.3, 2)
	from payment 
with data

explain analyze
select * from bbb

create function 

drop table

drop database

select payment_id, customer_id, payment_date, amount
from payment 

select customer_id, date_trunc('month', payment_date), sum(amount)
from payment 
group by customer_id, date_trunc('month', payment_date)

select customer_id, date_trunc('month', payment_date), sum(amount) as sum_per_month
from payment 
where customer_id < 50
group by customer_id, date_trunc('month', payment_date)
having sum(amount) > 50
order by sum_per_month desc

select distinct amount
from payment 

select * from books

insert into author
values (1), (2), (3)

insert into books (book_name, book_year, author_id)
values ('¬ойна и мир', 1863, 1)

insert into books (book_name, book_year, author_id)
values ('ћир без война', 2022, 3)

insert into author
select customer_id
from "dvd-rental".customer
where customer_id > 3

select * from books

update books
set book_name = 'ѕреступление и наказание'
where id = 5

update books
set book_name = 'ѕреступление и наказание'

delete from author
where author_id = 1

delete from books 
where author_id = 1

cascade 

select * from pg_user

create user test_user password '123'

select user

grant all privileges on all tables in schema "dvd-rental" to test_user

grant all privileges on schema "dvd-rental" to test_user

select * from books

set search_path to b

select table_catalog, table_schema, table_name, privilege_type
from information_schema.table_privileges 
where grantee = 'test_user'

revoke all privileges on all tables in schema "dvd-rental" from test_user

revoke all privileges on schema "dvd-rental" from test_user

drop user test_user

select count(fa.actor_id), title, description, release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by f.film_id

select count(film_actor.actor_id), title, description, release_year
from film 
join film_actor on film_actor.film_id = film.film_id
group by film.film_id

select 1::int as x, 1::int as y
union 
select 1::text as x, 1::int as y

select 1 as x, 1 as y
union all
select 1 as x, 1 as y

select 1 as x, 1 as y
except
select 1 as x, 1 as y

select 1 as x, 1 as y
except
select 1 as x, 2 as y

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.29 / 0.47

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.47

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and 
	fc.category_id in (select category_id
	from category 
	where "name" like 'C%')
join category c on c.category_id = fc.category_id --175 / 47.11 / 0.45

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 46.96 / 0.43

explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.43
	
select * from table_one 

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select concat(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2 

select t1.name_one, t2.name_two
from table_one t1, table_two t2 

select t1.name_one, t2.name_two
from table_one t1, table_two t2 
where t1.name_one = t2.name_two

delete from table_one

delete from table_two

insert into table_one (name_one)
select unnest(array[1,1,2])

insert into table_two (name_two)
select unnest(array[1,1,3])

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

1a 1A 1x
1b 1B 2y
2c 3C 3z

1a = 1A, 1a = 1B, 1b = 1A, 1b = 1B

1a-1x + 1A-1x

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

cross join -> inner join -> left / join / full

explain analyze --302.20 --332 / 16.49 / 9.29
select c.last_name, p.amount
from customer c
join payment p using(customer_id)
where c.customer_id < 30

alter table customer add constraint customer_pkey primary key (customer_id)

ALTER TABLE "dvd-rental".customer DROP CONSTRAINT customer_pkey cascade;

select * from test

explain analyze -- 8 146 723.67
select
	gs::date as change_date,
	fields.field as field_name,
	case 
		when (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event = gs::date) is not null 
			then (
				select new_value 
				from test t 
				where t.field = fields.field and t.date_event = gs::date)
		else (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event < gs::date 
			order by date_event desc 
			limit 1) 
	end as field_value
from 
	generate_series((select min(date(date_event)) from test), (select max(date(date_event)) from test), interval '1 day') as gs, 
	(select distinct field from test) as fields
order by 
	field_name, change_date

explain analyze -- 92 709.22
select
	distinct field, gs, first_value(new_value) over (partition by value_partition)
from
	(select
		t2.*,
		t3.new_value,
		sum(case when t3.new_value is null then 0 else 1 end) over (order by t2.field, t2.gs) as value_partition
	from
		(select
			field,
			generate_series((select min(date_event)::date from test), (select max(date_event)::date from test), interval '1 day')::date as gs
		from test) as t2
	left join test t3 on t2.field = t3.field and t2.gs = t3.date_event::date) t4
order by 
	field, gs
	
explain analyze -- 2 616.70
with recursive r(a, b, c) as (
    select temp_t.i, temp_t.field, t.new_value
    from 
	    (select min(date(t.date_event)) as i, f.field
	    from test t, (select distinct field from test) as f
	    group by f.field) as temp_t
    left join test t on temp_t.i = t.date_event and temp_t.field = t.field
    union all
    select a + 1, b, 
    	case 
    		when t.new_value is null then c
    		else t.new_value
		end
    from r  
    left join test t on t.date_event = a + 1 and b = t.field
    where a < (select max(date(date_event)) from test)
)    
SELECT *
FROM r
order by b, a

explain  (format json, analyze) -- 476.66
with recursive r as (
 	--стартова€ часть рекурсии
 	 	select
 	     	min(t.date_event) as c_date
		   ,max(t.date_event) as max_date
	from test t
	union
	-- рекурсивна€ часть
	select
	     r.c_date+ INTERVAL '1 day' as c_date
	    ,r.max_date
	from r
	where r.c_date < r.max_date
 ),
t as (select t.field
		, t.new_value
		, t.date_event
		, case when lead(t.date_event) over (partition by t.field order by t.date_event) is null
			   then max(t.date_event) over ()
			   else lead(t.date_event) over (partition by t.field order by t.date_event)- INTERVAL '1 day'
		  end	  
			   as next_date
		, min (t.date_event) over () as min_date
		, max(t.date_event) over () as max_date	  
from (
select t1.date_event
		,t1.field
		,t1.new_value
		,t1.old_value
from test t1
union all
select distinct min (t2.date_event) over () as date_event --первые стартовые даты
		,t2.field
		,null as new_value
		,null as old_value
from test t2) t
)
select r.c_date, t.field , t.new_value
from r
join t on r.c_date between t.date_event and t.next_date
order by t.field,r.c_date

—сылка на сервис по анализу плана запроса 

https://explain.depesz.com/

https://tatiyants.com/pev/

https://habr.com/ru/post/203320/