
--Q1
CREATE TABLE ACTOR (
    id INT,
    fname VARCHAR(50),
    lname VARCHAR(50),
    gender VARCHAR(1),
	PRIMARY KEY (id)
);

CREATE TABLE MOVIE (
    id INT,
    name VARCHAR(170),
    year INT,
	PRIMARY KEY (id)
);


CREATE TABLE DIRECTOR (
    id INT,
    fname VARCHAR(50),
    lname VARCHAR(50),
	PRIMARY KEY (id)
);

CREATE TABLE PLAY (
    aid INT,
    mid INT,
    role VARCHAR(100),
    FOREIGN KEY (aid) REFERENCES ACTOR(id),
    FOREIGN KEY (mid) REFERENCES MOVIE(id)
);

CREATE TABLE MOVIE_DIRECTOR (
    did INT,
    mid INT,
    FOREIGN KEY (did) REFERENCES DIRECTOR(id),
    FOREIGN KEY (mid) REFERENCES MOVIE(id)
);

CREATE TABLE GENRE (
    mid INT,
    genre VARCHAR(50)
);	

--SELECT * FROM GENRE LIMIT 10;

/*
Imported the IMDB datasets
Created tables according to the datasests,
all the id are classed as integers, set string length
limit using varchar()
Foreign keys (linking attributes across different tables) 
and primary keys are specified according to
the instructions
*/


--Q2
SELECT 
    MOVIE.name AS movie_name,
    MOVIE.year AS movie_year,
    PLAY.role AS role_name
FROM 
	MOVIE, PLAY, ACTOR
WHERE 
    MOVIE.id = PLAY.mid
    AND PLAY.aid = ACTOR.id
    AND ACTOR.fname = 'Chris'
    AND ACTOR.lname = 'Pratt'
ORDER BY 
    MOVIE.year ASC, 
    MOVIE.name ASC, 
    PLAY.role ASC;

--146 rows
/*
Link movie id to the role,
link role to the actor id,
filter actor names by the
specified first name and last name

Order: (by priority)
1.Year (from earliest to most recent)
2.Movie name in alphabetical order
3.Role name in alphabetical order

*/

--Q3
SELECT 
    MOVIE.name AS movie_name, 
    MOVIE.year AS movie_year
FROM 
    MOVIE, PLAY, ACTOR, MOVIE_DIRECTOR, DIRECTOR
WHERE 
    MOVIE.id = PLAY.mid
    AND PLAY.aid = ACTOR.id
    AND MOVIE.id = MOVIE_DIRECTOR.mid
    AND MOVIE_DIRECTOR.did = DIRECTOR.id
    AND ACTOR.fname = 'Jackie' 
    AND ACTOR.lname = 'Chan'
    AND DIRECTOR.fname = 'Jackie' 
    AND DIRECTOR.lname = 'Chan'
ORDER BY 
    MOVIE.year ASC;

--17 rows

/*
Link movie and actor using play (role)
table, link movie and director using
movie director table, filter through
both actor and director rows using 
Jakie Chan's first & last name.
Finally sort the table by year.
*/


--Q4

SELECT
	MOVIE.name AS movie_name, 
    MOVIE.year AS movie_year

FROM
	GENRE, MOVIE, DIRECTOR, ACTOR, ACTOR AS A1, ACTOR AS A2, PLAY AS P1, PLAY AS P2, MOVIE_DIRECTOR
WHERE
	GENRE.genre = 'Comedy'
	AND GENRE.mid = MOVIE.id
	AND MOVIE_DIRECTOR.mid = MOVIE.id
	AND MOVIE_DIRECTOR.did = DIRECTOR.id
	AND P1.mid = MOVIE.id
	AND P2.mid = MOVIE.id
	AND P1.aid = A1.id
	AND P2.aid = A2.id
	AND DIRECTOR.fname = A1.fname
	AND DIRECTOR.lname = A2.lname
	AND A1.id != A2.id
ORDER BY
	MOVIE.year ASC,
	MOVIE.name ASC;

-- rows 3138

/*
Create two separate copies for both actor
and play table, link the genre table with 
movie table after filter the comedy movie
in the genre table. Link the movie table
with director table using movie director
table. Then link the movie table with the
two play (role) table.
Filter for the directors and actors sharing
same first name & last name respectively 
with the condition of two actors must be different.


*/


--Q5

SELECT
	DIRECTOR.fname AS first_name,
	DIRECTOR.lname AS last_name
FROM 
    DIRECTOR, MOVIE, MOVIE_DIRECTOR
WHERE 
    MOVIE_DIRECTOR.did = DIRECTOR.id
    AND MOVIE_DIRECTOR.mid = MOVIE.id
    AND MOVIE.year = 2001
GROUP BY 
    DIRECTOR.id
HAVING 
    COUNT(MOVIE.id) >= 4;

--1417 rows

/*
Link the movie table and the director table
with the movie director table. Then filter
for movies in the year of 2001.
Add the HAVING condition that there should
be at least 4 movies directed.

*/


--Q6

SELECT
	ACTOR.id AS actor_id,
	ACTOR.fname AS first_name,
	ACTOR.lname AS last_name,
	MOVIE.id AS movie_id,
	Genre.genre
FROM
	GENRE, MOVIE, PLAY, ACTOR
WHERE
	GENRE.mid = MOVIE.id
	AND ACTOR.id = Play.aid
	AND PLAY.mid = MOVIE.id

--8022941 rows

/*
Link the actor table and movie table
using play table. Also link the genre table
with the movie table to display all the genres
associated.

*/


--Q7

SELECT 
	ACTOR.id AS actor_id,
	ACTOR.fname AS first_name,
	ACTOR.lname AS last_name,
	Genre.genre AS genre,
	COUNT(*) AS countassociations

FROM
	GENRE, ACTOR, PLAY, MOVIE
WHERE
	GENRE.genre IN ('Comedy', 'Drama', 'Thriller', 'Family', 'Horror')
	AND GENRE.mid = MOVIE.id
	AND ACTOR.id = PLAY.aid
	AND PLAY.mid = MOVIE.id
GROUP BY
	ACTOR.id, ACTOR.fname, ACTOR.lname, GENRE.genre
HAVING COUNT(*) >= 4
ORDER BY 
	ACTOR.lname ASC;

--201475 rows

/*
Filter for the five specific genres,
link genre table with play table using 
movie table, merge the actors using names and
ID, genre name
Finally, filter for actors associated at least 4 times

*/



--Q8

SELECT actor.id, actor.fname, actor.lname
FROM ACTOR AS actor, (
	SELECT actor.id, genre.genre, COUNT(*) AS genre_count
	FROM ACTOR AS actor, PLAY AS play, MOVIE AS movie, GENRE AS genre
	WHERE genre.genre IN ('Comedy', 'Drama', 'Thriller', 'Family', 'Horror')
	AND actor.id = play.aid
	AND play.mid = movie.id
	AND movie.id = genre.mid
	GROUP BY actor.id, genre.genre
	HAVING COUNT (*) >= 4
) AS X

WHERE actor.id = X.id
GROUP BY actor.id
HAVING COUNT(DISTINCT X.genre) >= 3 
ORDER BY actor.lname ASC

--19306 rows
	
/*
- Subquery
FROM: we need the actor, play, movie, genre table
WHERE: select the 5 specific genres, connect actors to their roles,
connect roles to the movies, connect movies to their genres
GROUP BY: Merge the group by actor ID and genre so that count(*) is
able to operate accurately on the filtered rows
HAVING: Only actor-genre pairs associated with at least 4 movies are included

- After Subquery
WHERE: Connects the query with subquery's result, the actors selected are
associated at least 4 times
GROUP BY: Consolidate the actor-genre pairs according to actor ID
HAVING: Only actors associated with at least 3 distinct genres are included
ORDER BY: Sort last name in alphabetical order

*/





