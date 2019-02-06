-- 1a--Display the first and last names of all actors from the table actor.

SELECT * FROM actor;
SELECT first_name,last_name FROM actor;

-- 1b-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name," ",last_name)as Actor_Name FROM actor;

-- 2a--you need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
--  What is one query would you use to obtain this information?

SELECT actor_id,first_name,last_name FROM actor
WHERE first_name = "Joe";

-- 2b--Find all actors whose last name contain the letters GEN:

SELECT  * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c--Find all actors whose last names contain the letters LI. This time, 
-- order the rows by last name and first name, in that order:

SELECT  * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name,first_name;

-- 2d--Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT * FROM country;
SELECT * FROM country WHERE country IN ("Afghanistan","Bangladesh","China") ;

-- 3a--You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 

ALTER TABLE actor
ADD COLUMN description LONGBLOB NULL AFTER last_name;

-- 3b--Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a--List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
COUNT(*) FROM actor
GROUP BY (last_name);

-- 4b--List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name,
COUNT(*) 
FROM actor 
GROUP BY last_name
HAVING COUNT(last_name) >= 2; 

-- 4c--The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
--  Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d--Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a--You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE TABLE address(
        address_id  =  smallint(5) unsigned NOT NULL AUTO_INCREMENT 
        address     =  varchar(50) NOT NULL,
        address2    =  varchar(50) DEFAULT NULL,
        district    =  varchar(20) NOT NULL,
        city_id     =  smallint(5) unsigned NOT NULL,
        postal_code =  varchar(10) DEFAULT NULL,
        phone       =  varchar(20) NOT NULL,
        location    =  geometry NOT NULL,
        last_update =  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
		PRIMARY KEY (address_id)
  );      
        
-- 6a--Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT * FROM address;
SELECT * FROM staff;
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;

-- 6b--Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT CONCAT(staff.first_name," ",staff.last_name) AS employee_name,SUM(payment.amount),
CONCAT(month(payment.payment_date),"/",year(payment.payment_date)) 
FROM staff
INNER JOIN payment ON
staff.staff_id=payment.staff_id
WHERE month(payment_date) = 8 and year(payment_date) =2005
GROUP BY CONCAT(staff.first_name," ",staff.last_name),CONCAT(month(payment.payment_date),"/",year(payment.payment_date));

-- 6c--List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;
SELECT COUNT(film_actor.actor_id)AS total_actor,film.title
FROM film_actor
INNER JOIN film ON
film_actor.film_id=film.film_id
GROUP BY film.title;

-- 6d--How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM inventory;
SELECT COUNT(inventory.film_id)as total, film.title
FROM film
INNER JOIN inventory ON
film.film_id=inventory.film_id
WHERE film.title = 'Hunchback Impossible'
GROUP BY film.title;

-- 6e--Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name: 

SELECT * FROM customer;
SELECT * FROM payment;
SELECT customer.first_name,customer.last_name,SUM(payment.amount)
FROM customer
INNER JOIN payment ON
customer.customer_id=payment.customer_id
GROUP BY customer.first_name,customer.last_name 
ORDER BY customer.last_name ASC;

-- *7a--The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

		SElECT title 
             FROM film
	         WHERE title LIKE "Q%" OR title LIKE "K%"
		and language_id = (SELECT language_id FROM language
	         WHERE language.name = 'English')
        ;
    
-- 7b--Use subqueries to display all actors who appear in the film Alone Trip.  
          
SELECT * FROM actor
 WHERE actor_id IN
 (
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
   (
     SELECT film_id
     FROM film
     WHERE title = 'Alone Trip'
    )
   );
   
-- 7c--You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

-- SOLUTION 1
SELECT cus.first_name,cus.last_name,cus.email
FROM 	customer cus
JOIN 	address a   ON cus.address_id = a.address_id
JOIN	city c	    ON a.city_id = c.city_id
JOIN    country cnt ON  c.country_id = cnt.country_id
WHERE cnt.country = 'Canada';  

-- SOLUTION 2
SELECT first_name,last_name,email FROM customer
 WHERE address_id IN
  (
   SELECT address_id
   FROM address
   WHERE city_id IN
   (
     SELECT city_id
     FROM city
     WHERE country_id IN
     (
      SELECT country_id
      FROM country
      WHERE country = "Canada"
      )
    )
   );

-- 7d--Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM film_category;
SELECT title
from film
WHERE film_id IN
 ( 
   SELECT film_id
   FROM film_category
   WHERE category_id IN
    ( 
      SELECT category_id
      FROM category
      WHERE name = 'Family'
	)
  );
  
-- 7e--Display the most frequently rented movies in descending order.

SELECT * FROM inventory;
SELECT f.title, COUNT(*) as Rentals
FROM 	rental r
JOIN	inventory i ON r.inventory_id = i.inventory_id
JOIN	film f 		ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(*) DESC,f.title ASC
;
-- 7f-- Write a query to display how much business, in dollars, each store brought in. 

SELECT s.store_id,SUM(p.amount) AS Total_$_amount
FROM store s
JOIN staff st  ON s.store_id = st.store_id
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY p.staff_id ;



-- 7g--Write a query to display for each store its store ID, city, and country.

SELECT s.store_id,c.city,cnt.country
FROM store s
JOIN address ad   ON s.address_id = ad.address_id
JOIN city c     ON ad.city_id = c.city_id
JOIN country cnt ON c.country_id = cnt.country_id;


-- 7h--List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT SUM(p.amount),ctg.name 
FROM payment p
JOIN rental r  ON p.rental_id = r.rental_id
JOIN inventory i  ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category ctg  ON fc.category_id = ctg.category_id
GROUP BY ctg.name 
ORDER BY SUM(p.amount)DESC LIMIT 5;

-- 8a--In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Gross_Revenue AS
SELECT SUM(p.amount),ctg.name 
FROM payment p
JOIN rental r  ON p.rental_id = r.rental_id
JOIN inventory i  ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category ctg  ON fc.category_id = ctg.category_id
GROUP BY ctg.name 
ORDER BY SUM(p.amount)DESC LIMIT 5;


-- 8b--How would you display the view that you created in 8a?

SELECT * FROM Gross_Revenue;
SELECT * FROM revenue;

-- 8c-- You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW revenue;









