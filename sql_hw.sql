-- quit safe mode to update rows --
SET SQL_SAFE_UPDATES = 0;

-- activate the Sakila database --
USE sakila;

-- display first and last names of all actors from the table actor --
SELECT first_name, last_name FROM actor;

-- display the first and last name of each actor in a single column in --
-- upper case letters in the column Actor Name --
ALTER TABLE actor
ADD actor_name VARCHAR (100) AFTER last_name;
UPDATE actor SET actor_name = CONCAT (first_name,' ', last_name);
SELECT * FROM actor;

-- find first name Joe --
SELECT * FROM actor WHERE first_name = 'Joe';

-- find all actors whose last name contain the letters GEN --
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- find all actors whose last name contain LI order by last name and first name --
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

-- display country_id and country of Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country WHERE country IN ('Afghanistan','Bangladesh','China');

-- create a column of actor description --
ALTER TABLE actor
ADD description BLOB AFTER last_name;

-- drop description column --
ALTER TABLE actor
DROP description;

-- list last names of actors and count
SELECT COUNT(actor_id), last_name from actor GROUP BY last_name ORDER BY COUNT(actor_id) DESC;

-- list last names of actors and count >2--
SELECT COUNT(actor_id), last_name from actor GROUP BY last_name 
HAVING COUNT(actor_id)>2 ORDER BY COUNT(actor_id) DESC;

-- fix record GROUCHO WILLIAMS to make it HARPO WILLIAMS --
UPDATE actor SET first_name = 'HARPO' WHERE actor_name = 'GROUCHO WILLIAMS';

-- change the name back -- 
UPDATE actor SET first_name = 
(CASE
WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS ' THEN 'GROUCHO'
ELSE (first_name)
END);

-- recreate schema --
SHOW CREATE TABLE address;

-- join staff and address table to display address --
SELECT staff.first_name, staff.last_name, address.address 
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- display the total amount rung up by each staff member in August of 2005 --
SELECT staff.first_name, staff.last_name, SUM(payment.amount)  
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

-- List each film and the number of actors who are listed for that film.  --

SELECT film.title, count(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id
ORDER BY count(film_actor.actor_id) DESC;

-- no. of copies of Hunchback Impossible --
SELECT film.title, count(inventory.film_id)
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id AND film.title = 'Hunchback Impossible'
GROUP BY film.film_id;

-- list the total paid by each customer --
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- display the titles of movies starting with the letters K and Q whose language is English. --

SELECT title
FROM film
WHERE language_id =
(SELECT language_id
FROM language
WHERE name = 'English')
AND (title LIKE 'K%' OR title LIKE 'Q%')
ORDER BY title;


-- display all actors who appear in the film Alone Trip --
SELECT actor_name
FROM actor
WHERE actor_id in
(SELECT actor_id
FROM film_actor
WHERE film_id = 
(SELECT film_id 
FROM film
WHERE title = 'Alone Trip'));


-- names and email addresses of all Canadian customers --
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
LEFT JOIN address ON customer.address_id = address.address_id
LEFT JOIN city on address.address_id = city.city_id
LEFT JOIN country ON country.country_id = city.country_id
WHERE country.country='Canada';


-- Identify all movies categorized as family films --
SELECT title FROM film
WHERE film_id IN (
SELECT film_id FROM film_category 
WHERE category_id = (
SELECT category_id FROM category
WHERE name = 'family'))
ORDER BY title;

-- Display the most frequently rented movies in descending order --
SELECT film.title, COUNT(film.film_id)
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
LEFT JOIN rental on inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY COUNT(film.film_id) DESC;


-- Write a query to display how much business, in dollars, each store brought in --
SELECT staff.store_id, SUM(payment.amount)
FROM payment
LEFT JOIN rental ON payment.rental_id = rental.rental_id
LEFT JOIN staff ON rental.staff_id = staff.staff_id
GROUP BY staff.store_id;

-- Write a query to display for each store its store ID, city, and country. --
SELECT store_id, city.city, country.country
FROM store
LEFT JOIN address ON store.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id;

-- List the top five genres in gross revenue in descending order, and create a view --
CREATE VIEW top5 AS
SELECT category.name AS 'Category Name', sum(payment.amount) AS 'Gross Revenue ($)'
FROM payment
LEFT JOIN rental ON payment.rental_id = rental.rental_id
LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film_category ON inventory.film_id = film_category.film_id
LEFT JOIN category ON film_category.category_id = category.category_id
GROUP BY category.category_id 
ORDER BY sum(payment.amount) DESC
LIMIT 5;

SELECT * FROM top5;


-- drop the top five view --
DROP VIEW top5;
