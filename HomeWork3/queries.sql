--1. вывести количество фильмов в каждой категории, отсортировать по убыванию.
select
       fc.category_id,
       c.name as category_name,
       count(fc.film_id) as num
from
    film_category fc
    left join category c on fc.category_id = c.category_id
group by
    fc.category_id,
    c.name
order by 1 desc

--2. вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select
    a.first_name,
    a.last_name,
    count(r.rental_id) as num
from
    rental r
    left join inventory i on r.inventory_id = i.inventory_id
    left join film f on i.film_id = f.film_id
    left join film_actor fa on f.film_id = fa.film_id
    left join actor a on fa.actor_id = a.actor_id
group by
    a.first_name,
    a.last_name
order by
    3 desc
limit 10

--3. вывести категорию фильмов, на которую потратили больше всего денег.
select
    c.name,
    sum(p.amount) as payment_total
from
    payment p
    left join rental r on p.customer_id = r.customer_id
    left join inventory i on r.inventory_id = i.inventory_id
    left join film f on i.film_id = f.film_id
    left join film_category fc on f.film_id = fc.film_id
    left join category c on fc.category_id = c.category_id
group by
    c.name
order by
    2 desc
limit 1

--4. вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
select
    f.title
from
    film f
    left join inventory i on f.film_id = i.film_id
where
    i.inventory_id is null

--5. вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех..
select
    t.first_name,
    t.last_name
from
(
    select
        a.first_name,
        a.last_name,
        dense_rank() over (order by count(f.film_id) desc) as drank
    from
        category c
        left join film_category fc on c.category_id = fc.category_id
        left join film f on fc.film_id = f.film_id
        left join film_actor fa on f.film_id = fa.film_id
        left join actor a on fa.actor_id = a.actor_id
    where
        c.name = 'Children'
    group by
        a.first_name,
        a.last_name
)t
where
    t.drank < 4

--6. вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select
    t.city,
    sum(t.is_active) as active,
    count(t.customer_id) - sum(t.is_active) as inactive,
    count(t.customer_id) as total
from
(
     select
        c.city,
        cus.customer_id,
        coalesce(cus.active, 0) as is_active
    from
        city c
        left join address a on c.city_id = a.city_id
        left join customer cus on a.address_id = cus.address_id
)t
group by
    t.city
order by
    3 desc

--7. --вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”.
-- То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
select
    *
from
(
select
    c.name,
    sum(f.rental_duration)
from
    category c
    left join film_category fc on c.category_id = fc.category_id
    left join film f on fc.film_id = f.film_id
    left join inventory i on f.film_id = i.film_id
    left join rental r on i.inventory_id = r.inventory_id
    left join customer cus on r.customer_id = cus.customer_id
    left join address a on cus.address_id = a.address_id
    left join city ct on a.city_id = ct.city_id
where
    lower(ct.city) like 'a%'
group by
    c.name
order by
    2 desc
limit 1
)t1
union
(
select
    c.name,
    sum(f.rental_duration)
from
    category c
    left join film_category fc on c.category_id = fc.category_id
    left join film f on fc.film_id = f.film_id
    left join inventory i on f.film_id = i.film_id
    left join rental r on i.inventory_id = r.inventory_id
    left join customer cus on r.customer_id = cus.customer_id
    left join address a on cus.address_id = a.address_id
    left join city ct on a.city_id = ct.city_id
where
    ct.city like '%-%'
group by
    c.name
order by
    2 desc
limit 1
)


