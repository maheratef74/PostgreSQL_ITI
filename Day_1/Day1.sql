-- 1. Select the title, description, and length of all films that are longer than 120
-- minutes. Sort them from the longest to the shortest

select title , description , length 
from film 
where length > 120
order by length DESC;


-- 2. Find all films that have a rental_rate of 0.99 or 2.99, but their
--    replacement_cost is greater than 20.00

select * from film 
where (rental_rate = 0.99 or rental_rate = 2.99) and replacement_Cost > 20;


-- 3. Count the total number of films available in each rating (G, PG, R, etc.)

select count(film_id) , rating from film 
group by (rating) ;


-- 4. List the customer_ids who have made more than 30 separate payments in the payment table.

select customer_id , count(payment_id) from payment 
group by (customer_id)
having count(payment_id) > 30;




-- 5. Get all "Cities" in the database and the "Country" they belong to, but only
--    for cities located in 'Egypt'

select * from city
where country_id = (
	select country_id from country where country = 'Egypt'
);


-- 6. Display a list of all films and the names of the actors who starred in them.
--   (show film id, title and actor name

select f.film_id, f.title, concat(a.first_name, ' ', a.last_name)
from film f
join film_actor fa on f.film_id = fa.film_id
join actor a on fa.actor_id = a.actor_id
order by f.film_id;



-- 7. Find all customers who have rented a movie but haven't returned it yet
select distinct c.customer_id, concat( c.first_name, ' ' , c.last_name) as full_name
from rental r
inner join customer c on r.customer_id = c.customer_id
where r.return_date is null;

--8. List the titles of all films whose length is greater than the average length of
--   all films in the database.

select title , length from film 
where length > (
	select avg(length) from film
);


-- 9. Write a query to find the first_name, last_name, and email of customers who
--    have zero rental records

select first_name, last_name, email
from customer
where customer_id not in (select customer_id from rental);


--10.Create a view named customer_spending_summary. This view should
--   display each customer's name, their total number of rentals, and the total
--   amount of money they have paid.

create view customer_spendeing_summary as
select  c.first_name, c.last_name,  count(r.rental_id) as total_rentals, 
         sum(p.amount) as total_paid
from customer c
join rental r on c.customer_id = r.customer_id
join payment p on r.rental_id = p.rental_id
group by c.customer_id;


-- 11.Use the previous view to find only customers who spent more than $100

select * from customer_spendeing_summary
where total_paid > 100;

-- Bonus:
--1. We want to reward our most loyal actors. Find the names of the actors who have
--appeared in 'Action' films more than 10 times.
-- Step 1: Use a CTE to find all actors and their counts in the 'Action'
--category.
-- Step 2: Filter that CTE in your main SELECT.

with action_actor_counts as (
    select  a.first_name,  a.last_name, count(fa.film_id) as action_film_count
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film_category fc on fa.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where c.name = 'Action'
    group by a.actor_id, a.first_name, a.last_name
)
SELECT first_name, last_name, action_film_count
from action_actor_counts
where action_film_count > 10;

