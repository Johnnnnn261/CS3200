--Q1

SELECT DISTINCT art.Name AS artist_name, c.Country AS customer_country
FROM Artist AS art, Customer AS c
WHERE EXISTS (
    SELECT 1
    FROM Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
    WHERE art.ArtistId = alb.ArtistId
      AND alb.AlbumId = t.AlbumId
      AND t.TrackId = il.TrackId
      AND il.InvoiceId = i.InvoiceId
      AND i.CustomerId = c.CustomerId
)
ORDER BY art.Name ASC

--704 rows

/*
We would need to establish a chain to connect the artist table
all the way to the customer table to find out the country. The ]
subquery with EXIST allows partial matches by focusing only on what
exists at each level of the chain. (I did not get the right number of
rows at first without using the subquery as lots of rows that do not have 
perfect match were dropped.)

*/

--Q2
SELECT art.Name AS artist_name, COUNT(DISTINCT(c.country)) AS number_of_countries
FROM Artist AS art, Customer AS c
WHERE EXISTS (
    SELECT 1
    FROM Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
    WHERE art.ArtistId = alb.ArtistId
      AND alb.AlbumId = t.AlbumId
      AND t.TrackId = il.TrackId
      AND il.InvoiceId = i.InvoiceId
      AND i.CustomerId = c.CustomerId
)
GROUP BY art.ArtistId
HAVING COUNT(DISTINCT(c.country)) >= 10
ORDER BY COUNT(DISTINCT(c.country)) DESC;

--9 rows
/*
The inner subquery is the same as Q1, connecting the artist table with
customer table to obtain the country info. Added the condition that grouping
artists by their IDs as some might share the same name but different artists,
also make the count of distinct countries at least 10. Finally sort the country
column by descending numeric order.
*/

--Q3
SELECT MAX(num_countries) AS max_num_of_countries
FROM(
	SELECT art.ArtistId, COUNT(DISTINCT c.Country) AS num_countries
	FROM Artist AS art, Customer AS c
    WHERE EXISTS (
    SELECT 1
    FROM Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
    WHERE art.ArtistId = alb.ArtistId
      AND alb.AlbumId = t.AlbumId
      AND t.TrackId = il.TrackId
      AND il.InvoiceId = i.InvoiceId
      AND i.CustomerId = c.CustomerId
)
	GROUP BY art.ArtistId

)
AS X

--1 row
/*
As aggregate functions cannot be nested again, in order to find the
maximum number of distinct countries, I have to create another nested
subquery as the FROM, so that I'll be able to search for the maximum inside it.
*/


--Q4

SELECT art.Name AS artist_name, COUNT(DISTINCT c.Country) AS num_countries
FROM Artist AS art, Customer AS c
WHERE EXISTS (
    SELECT 1
    FROM Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
    WHERE art.ArtistId = alb.ArtistId
      AND alb.AlbumId = t.AlbumId
      AND t.TrackId = il.TrackId
      AND il.InvoiceId = i.InvoiceId
      AND i.CustomerId = c.CustomerId
)
GROUP BY art.ArtistId
HAVING COUNT(DISTINCT c.Country) = (
    SELECT MAX(num_countries)
    FROM (
        SELECT COUNT(DISTINCT c.Country) AS num_countries
        FROM Artist AS art, Customer AS c
        WHERE EXISTS (
            SELECT 1
            FROM Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
            WHERE art.ArtistId = alb.ArtistId
              AND alb.AlbumId = t.AlbumId
              AND t.TrackId = il.TrackId
              AND il.InvoiceId = i.InvoiceId
              AND i.CustomerId = c.CustomerId
        )
        GROUP BY art.ArtistId
    ) AS max_num
)

--2 rows

/*
Based on Q3, we need the artist names of the corresponding maximum
number of countries, so an extra subquery is added in the HAVING
clause to display only the artist with highest count. Here I am 
comparing the each artist's country count with the overall maximum.

*/


--Q5
SELECT COUNT(*) AS numtuples
FROM Genre AS g
WHERE NOT EXISTS (
    SELECT m.id
    FROM Movie AS m
    WHERE g.genreid = m.id
);

--1 row
/*
I need to identify how many entries in the genre table 
does not match the movie in the movie table by comparing
the genre ID and the movie ID. Using the NOT EXIST
nested query. The row(s) that does not match will be appended
to the result.

*/

--Q6

SELECT m.name AS movie_name, COUNT(DISTINCT p.aid) AS castsize
FROM Movie AS m, Play AS p
WHERE m.id = p.mid
GROUP BY m.id, m.name
HAVING COUNT(DISTINCT p.aid) = (
    SELECT MAX(cast_count)
    FROM (
        SELECT COUNT(DISTINCT p.aid) AS cast_count
        FROM Movie AS m, Play AS p
        WHERE m.id = p.mid
        GROUP BY m.id
    ) AS max_cast
);

--1 row
/*
We want to find filter for the cast size (the number of distinct actors) 
of each movie and then find the maximum cast size.
The outter main query counts the number of unique actors for each movie,
the subquery finds the maximum cast size among each movie's distinct actors group,
the HAVING clause filters the result to only include cast sizes equals to the maximum value.

*/

--Q7
SELECT a.fname AS actor_fname, a.lname AS actor_lname, m.name AS movie_name, COUNT(p.role) AS numroles
FROM Actor AS a, Movie AS m, Play AS p
WHERE a.id = p.aid AND m.id = p.mid
GROUP BY a.id, a.fname, a.lname, m.id, m.name
HAVING COUNT(p.role) = (
    SELECT MAX(role_count)
    FROM (
        SELECT COUNT(p.role) AS role_count
        FROM Actor AS a, Movie AS m, Play AS p
        WHERE a.id = p.aid AND m.id = p.mid
        GROUP BY a.id, m.id
    ) AS max_roles
)

--2 rows

/*
The main query joins the actor, movie and play table using ID,
then group by actor and movie, and count the number of roles 
for each actor. HAVING clause filters for the actors who only
played maximum number of roles. The subquery is finding the 
maximum number of roles in a single movie.
*/


--Q8
SELECT COUNT(DISTINCT p1.aid) AS countactors
FROM Play AS p1, Play AS p2, Actor AS a
WHERE p1.mid = p2.mid
	AND p2.aid = a.id
	AND a.fname = 'Kevin'
	AND a.lname = 'Bacon'
	AND p1.aid <> p2.aid;

--1 row 
/*
The goal is to find out how many actors acted in the same
film as Kevin Bacon. We then first filter for the films he
acted and place it as the first player table, then use the
second table to compare the films we filtered in order to 
search for the actors that acted those movies. Finally making
sure that the actors IDs are different to exclude Kevin Bacon
himself
*/











