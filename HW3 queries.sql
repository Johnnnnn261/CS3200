--300-smallIMDB

--Q1

SELECT DISTINCT d.fname AS first_name, d.lname AS last_name
FROM Director d, Movie_director md, Movie m, Genre g
WHERE d.id = md.did
AND md.mid = m.id
AND m.id = g.mid
AND g.genre IN ('Comedy', 'Thriller')
AND d.id NOT IN (
    SELECT d2.id
    FROM Director d2, Movie_director md2, Movie m2, Genre g2
    WHERE d2.id = md2.did
    AND md2.mid = m2.id
    AND m2.id = g2.mid
    AND g2.genre IN ('Drama', 'Action')
)
ORDER BY d.lname, d.fname;

--13 rows
/*
The goal is to find the directors worked in Comedy or Thriller,
but never worked in Drama or Action. We connect the director table
with the genre table first, filter for the two genres we need using IN.
then use the director ID to exclude the other two genres by creating an
identical subquery inside the NOT IN but selecing the director ID.
*/ 

--Q2

SELECT DISTINCT d.fname AS first_name, d.lname AS last_name
FROM Director d
WHERE EXISTS (
    SELECT 1
    FROM Movie_director md, Movie m, Genre g
    WHERE md.did = d.id
    AND md.mid = m.id
    AND m.id = g.mid
    AND (g.genre = 'Comedy' OR g.genre = 'Thriller')
)
AND NOT EXISTS (
    SELECT 1
    FROM Movie_director md, Movie m, Genre g
    WHERE md.did = d.id
    AND md.mid = m.id
    AND m.id = g.mid
    AND (g.genre = 'Drama' OR g.genre = 'Action')
)
ORDER BY d.lname, d.fname;


--13 rows
/*
The structure of the query is mostly the same as the above,
but the subquery using EXISTS could result in duplicate rows
everytime it returns TRUE, so I added DISTINCT in the SELECT
clause, and avoid referring the director table again. 
Check for EXISTS in Comedy and Thriller movies, check for 
NOT EXISTS in Drama and Action movies.
*/

--Q3
WITH directors_in_comedy_thriller AS (
    SELECT d.id AS did, d.fname, d.lname
    FROM Director d, Movie_director md, Movie m, Genre g
    WHERE d.id = md.did
    AND md.mid = m.id
    AND m.id = g.mid
    AND (g.genre = 'Comedy' OR g.genre = 'Thriller')
),
directors_in_drama_action AS (
    SELECT d.id AS did
    FROM Director d, Movie_director md, Movie m, Genre g
    WHERE d.id = md.did
    AND md.mid = m.id
    AND m.id = g.mid
    AND (g.genre = 'Drama' OR g.genre = 'Action')
)

SELECT DISTINCT c.fname, c.lname
FROM directors_in_comedy_thriller c
FULL OUTER JOIN directors_in_drama_action da ON c.did = da.did
WHERE da.did IS NULL
ORDER BY c.lname, c.fname;

--13 rows
/*
Create two temporary table relations using WITH:
Comedy/thriller directors, drama/action directors,
I then use the full outer join between the two,
da.did IS NULL filters the drama and action directors
*/



