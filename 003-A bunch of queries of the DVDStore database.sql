/***************************************************************************************************
FILENAME: 003-A bunch of queries of the DVDStore database
***************************************************************************************************/

/***************************************************************************************************
NOTES: A bunch of queries of the DVDStore database
***************************************************************************************************/


USE DVDStore;
--Find out how much data is in the database

EXEC sp_MSforeachtable 
     @precommand = 'CREATE TABLE ##spaceused 
		(TableName varchar(128) NOT NULL, 
		Rows int,
		SpaceReservedUsed varchar(200),
		DataSpaceUsed varchar(200),
		IndexSpaceUsed varchar(200),
		UnusedSpace varchar(200))'
   , @command1 = "INSERT INTO ##spaceused (TableName, Rows, SpaceReservedUsed, DataSpaceUsed, IndexSpaceUsed, UnusedSpace) EXEC sp_spaceused '?'"
   , @postcommand = 'SELECT *
			FROM ##spaceused
			ORDER BY Rows DESC;
		DROP TABLE ##spaceused';
-- Display the first and last names of all actors from the table actor.

SELECT first_name
     , last_name
FROM   actor;
GO
-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, ' ', last_name))
       AS Actor_Name
FROM   actor;
GO
-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 'Joe.' 

SELECT actor_id
     , first_name
     , last_name
FROM   actor
WHERE  first_name = 'Joe';
GO
-- Find all actors whose last name contain the letters GEN:

SELECT *
FROM   actor
WHERE  last_name LIKE '%GEN%';
GO
-- Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:

SELECT last_name
     , first_name
FROM   actor
WHERE  last_name LIKE '%LI%';
GO
-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id
     , country
FROM   country
WHERE  country IN
                 (
                  'Afghanistan'
                , 'Bangladesh'
                , 'China'
                 );
GO
-- List the last names of actors, as well as how many actors have that last name.

SELECT last_name
     , COUNT(last_name)
       AS 'Number_of_Actors'
FROM   actor
GROUP BY last_name;
GO
-- List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name
     , COUNT(last_name)
       AS Number_of_Actors
FROM   actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;
GO
-- Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
--UPDATE actor
--SET first_name = 'HARPO'
--WHERE actor_id = 172;
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
--UPDATE actor
--SET first_name = 'GROUCHO'
--WHERE actor_id = 172;
-- Explore all the tables and their columns with data typeinformation in the database

SELECT @@servername
       AS SERVER
     , DB_NAME()
       AS dbname
     , isc.table_name
       AS tablename
     , isc.table_schema
       AS schemaname
     , ordinal_position
       AS ord
     , column_name
     , data_type
     , numeric_precision
       AS prec
     , numeric_scale
       AS scale
     , character_maximum_length
       AS len -- -1 means max like varchar(max)   
     , is_nullable
     , column_default
     , table_type
FROM   INFORMATION_SCHEMA.COLUMNS
     AS isc
       INNER JOIN INFORMATION_SCHEMA.TABLES
     AS ist ON isc.table_name = ist.table_name
--      where table_type = 'base table' -- 'base table' or 'view' 
ORDER BY dbname
       , tablename
       , schemaname
       , ordinal_position;
GO
-- Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT s.first_name
     , s.last_name
     , a.address
FROM   staff
     AS s
       JOIN address
     AS a ON s.address_id = a.address_id;
GO
-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment

SELECT s.staff_id
     , SUM(p.amount)
       AS 'August_2005_amount'
FROM   staff
     AS s
       INNER JOIN payment
     AS p ON s.staff_id = p.staff_id
WHERE  CONVERT(DATE, p.payment_date) LIKE '2005-08%'
GROUP BY s.staff_id;
GO
-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT fa.film_id
     , COUNT(fa.actor_id)
       AS 'Number_of_Actors'
FROM   film_actor
     AS fa
       INNER JOIN film
     AS f ON fa.film_id = f.film_id
GROUP BY fa.film_id;
GO
-- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film_id
     , COUNT(inventory_id)
       AS 'Number_of_Copies'
FROM   inventory
WHERE  film_id =
      (
        SELECT film_id
        FROM   film
        WHERE  title = 'HUNCHBACK IMPOSSIBLE'
      )
GROUP BY film_id;
GO
-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT customer.first_name
     , customer.last_name
     , SUM(payment.amount)
       AS 'Total Amount Paid'
FROM   payment
       JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY last_name
       , first_name
ORDER BY last_name ASC;
GO
-- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT actor.first_name
     , actor.last_name
FROM   actor
WHERE  actor_id IN
                   (
                     SELECT actor_id
                     FROM   film_actor
                     WHERE  film_id =
                           (
                             SELECT film_id
                             FROM   film
                             WHERE  title = 'ALONE TRIP'
                           )
                   );
GO
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.

SELECT customer.first_name
     , customer.last_name
     , customer.email
FROM   country
       INNER JOIN city ON country.country_id = city.country_id
       INNER JOIN address ON address.city_id = city.city_id
       INNER JOIN customer ON customer.address_id = address.address_id
WHERE  city.country_id = 20;
GO
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

SELECT film.title
FROM   category
       INNER JOIN film_category ON category.category_id = film_category.category_id
       INNER JOIN film ON film.film_id = film_category.film_id
WHERE  category.NAME = 'Family';
GO
-- Display the most frequently rented movies in descending order.

SELECT film.title
     , COUNT(film.title)
       AS 'Number_of_Rentals'
FROM   rental
       INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
       INNER JOIN film ON film.film_id = inventory.film_id
GROUP BY title
ORDER BY Number_of_Rentals DESC;
GO
-- Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id
     , FORMAT(SUM(amount), 'C', 'en-US')
       AS 'Revenue'
FROM   store
       INNER JOIN staff ON store.store_id = staff.store_id
       INNER JOIN rental ON rental.staff_id = staff.staff_id
       INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY store.store_id;
GO
-- Write a query to display for each store its store ID, city, and country.

SELECT store.store_id
     , city.city
     , country.country
FROM   store
       INNER JOIN address ON store.address_id = address.address_id
       INNER JOIN city ON city.city_id = address.city_id
       INNER JOIN country ON country.country_id = city.country_id;
GO
-- List the top five genres in gross revenue in descending order. 

SELECT TOP 5 category.NAME
           , SUM(payment.amount)
       AS 'Gross_Revenue'
FROM         category
             INNER JOIN film_category ON category.category_id = film_category.category_id
             INNER JOIN inventory ON inventory.film_id = film_category.film_id
             INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
             INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.NAME
ORDER BY Gross_Revenue DESC;
GO
-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW dbo.top_five_genres
AS
     SELECT TOP 5 category.NAME
                , SUM(payment.amount)
            AS 'Gross_Revenue'
     FROM         category
                  INNER JOIN film_category ON category.category_id = film_category.category_id
                  INNER JOIN inventory ON inventory.film_id = film_category.film_id
                  INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
                  INNER JOIN payment ON payment.rental_id = rental.rental_id
     GROUP BY category.NAME;
GO
-- How would you display the view that you created in 8a?

SELECT *
FROM   top_five_genres;
GO
-- You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;
GO