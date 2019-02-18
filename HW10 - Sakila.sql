Use sakila; 
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name 
from actor; 
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
select upper(concat(first_name, ' ', last_name)) as "Actor Name" from actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select first_name, last_name 
from actor
where first_name like "Joe"; 

-- 2b.  Find all actors whose last name contain the letters `GEN`
select actor_id, first_name, last_name
from actor 
where last_name like '%GEN%';  	

-- 2c. Find all actors whose last names contain the letters `LI`. 
--     This time, order the rows by last name and first name, in that order:
select last_name, first_name
from actor
where last_name like "%LI%"; 

-- 2d. Using `IN`, display the `country_id` and `country` columns of 
-- the following countries: Afghanistan, Bangladesh, and China

select country_id, country 
from country 
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table
 -- actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor add column description BLOB; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) countof from actor group by last_name having count(*)>=1; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select last_name, count(*) countof from actor group by last_name having count(*)>1; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = 'HARPO'
where first_name = "Groucho" AND last_name = "Williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = "Groucho" 
where first_name = "Harpo" and last_name = "Williams"; 

--  5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address; 
-- or
describe sakila.address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address
from staff s
join address a on s.address_id=a.address_id; 

-- 6b. Use JOIN to the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and add `payments` 
select first_name, last_name, sum(payment.amount)from staff 
join payment on payment.staff_id = staff.staff_id
where payment_date like "2005-08%" group by first_name, last_name;  

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film, use Inner Join. 
select title, count(actor_id) from film
inner join film_actor on film.film_id = film_actor.film_id group by title; 

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, (
select count(*) from inventory
where film.film_id = inventory.film_id
) as 'We have this many copies in stock'
from film 
where title = "Hunchback Impossible"; 

-- 6e Using the tables paymnet 
select c.first_name, c.last_name, sum(p.amount) as `Amount Paid`
from customer c
join payment p
on c.customer_id=p.customer_id
group by c.customer_id order by c.last_name asc; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with 
-- the letters K and Q whose language is English.

select title from film 
where title like 'K%' or title like 'Q%' 
and title in
(select title from film where language_id =1);

-- 7b.Use subqueries to display all actors who appear in the film Alone Trip. 
select first_name, last_name from actor
where actor_id in 
	(select actor_id from film_actor
		where film_id in 
		(select film_id from film
	where title = "Alone Trip")); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names andemail addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select cust.first_name, cust.last_name, cust.email
from customer cust
join address a
on(cust.address_id=a.address_id)
join city cy
on(cy.city_id=a.city_id)
join country co
on(co.country_id=cy.country_id)
where co.country="Canada"; 
 
 -- 7d. Sales have been lagging amoung young families, and you wish to target all family movies for a promotion. 
 --  Identify all movies categorized as family films.
 select title from film
 where film_id in 
 (
 select film_id from film_category
 where category_id in
 (
 select category_id from category 
 where name ="Family"
 )); 


-- 7e. Display the most frequently rented movies in descending order
select f.title, count(rental_id) as 'times rented'
from rental r
join inventory i
on (r.inventory_id = i.inventory_id)
join film f
on (i.film_id = f.film_id)
group by f.title
order by `times rented` desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) 
from store s
join staff st
on s.store_id=st.staff_id
join payment p
on p.staff_id=st.staff_id
group by s.store_id order by sum(amount); 

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, city, country 
from store s
join customer cust
on s.store_id=cust.store_id
join staff st
on s.store_id=st.store_id
join address a on cust.address_id=a.address_id
join city cy
on a.city_id=cy.city_id
join country co on cy.country_id=co.country_id; 

-- 7h. List the top five genres in gross revenue in descending order. 
-- use the following tables: category, film_category, inventory, payment, and rental
select ca.name as `Genres`, sum(p.amount) as `Gross Revenues`
from category ca
join film_category fc
on(ca.category_id=fc.category_id)
join inventory i
on(fc.film_id=i.film_id)
join rental r
on(i.inventory_id=r.inventory_id)
join payment p
on(r.rental_id=p.rental_id)
group by ca.name order by sum(p.amount) desc limit 5 ;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, 
-- you can substitute another query to create a view.
create view best_genres as
select ca.name as `Genres`, sum(p.amount) as `Gross Revenues`
from category ca
join film_category fc
on(ca.category_id=fc.category_id)
join inventory i
on(fc.film_id=i.film_id)
join rental r
on(i.inventory_id=r.inventory_id)
join payment p
on(r.rental_id=p.rental_id)
group by ca.name order by sum(p.amount) desc limit 5 ;

-- 8b. How would you display the view that you created in 8a?
select * from best_genres; 

-- 8c. You find that you no longer need the view `top_five_genres`. 
-- Write query to delete it. 
drop view best_genres 

