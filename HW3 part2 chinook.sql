--319-chinook
--Q4a
SELECT DISTINCT t.name AS track_name
FROM Track t, InvoiceLine il, Invoice i
WHERE t.TrackId = il.TrackId
AND il.InvoiceId = i.InvoiceId
AND i.Total BETWEEN 20 AND 30
ORDER BY t.name;

--14 rows

--Q4b
SELECT DISTINCT t.name AS track_name
FROM Track t, InvoiceLine il, Invoice i
WHERE t.TrackId = il.TrackId
AND il.InvoiceId = i.InvoiceId
AND i.total = (SELECT MAX(Total) FROM Invoice)
ORDER BY t.name;

--14 rows
/*
The queries are fundamentally different because 4a uses
direct filtering on a fixed range, while 4b uses a dynamic
filter which includes an aggregate function MAX, for 4a,
the range condition is applied during the iteration, but for
4b, the subquery is evaluated first before being applied on the
outer query
*/

--Q5a
SELECT a.name AS artist_name, SUM(t.Milliseconds)/(1000*60*60) AS cumulative_time
FROM Artist a, Album alb, Track t
WHERE
	a.artistid = alb.artistid
	AND alb.albumid = t.albumid
GROUP BY a.name
HAVING SUM(t.Milliseconds)/(1000*60*60) >= 10
ORDER BY a.name;
--8 rows
/*
Join the artist table with the Track table where
the time in milliseconds is located. Convert into hours
and filter for hours>= 10 using the HAVING clause. Sort
by name.
*/

--Q5b
SELECT SUM(t.Milliseconds) / (1000 * 60 * 60) AS cumulative_time
FROM Track t
WHERE t.TrackId IN (
    SELECT DISTINCT il.TrackId
    FROM InvoiceLine il
)
--1 row
/*
Now we apply a subquery to check if the track ID is in the
invoiceline table and therefore being purchased. Sum up the 
column.
*/

--Q5c
SELECT SUM(t.Milliseconds) / (1000 * 60 * 60) AS cumulative_time
FROM Track t
WHERE t.TrackId NOT IN (
    SELECT DISTINCT il.TrackId
    FROM InvoiceLine il
)
--1 row
/*
Changed the query of the previous question from IN to NOT IN.
*/

--Q5d
SELECT SUM(t.Milliseconds) / (1000 * 60 * 60) AS cumulative_time
FROM Track t
WHERE NOT EXISTS (
    SELECT 1
    FROM InvoiceLine il
	WHERE il.trackid = t.trackid
)

--1 row
/*
Select all the milliseconds rows if the trackID is not in the invoiceline
table.
*/

--Q5e
SELECT SUM(t.Milliseconds) / (1000 * 60 * 60) AS cumulative_time
FROM Track t
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
WHERE il.TrackId IS NULL;

--1 row
/*
Left Join the invoiceline table with the track table,
make the TrackId NULL during the join.
*/

--Q6
SELECT DISTINCT a.Name AS artist_name
FROM Artist AS a, Album AS alb, Track AS t, InvoiceLine AS il, Invoice AS i
WHERE a.ArtistId = alb.ArtistId
AND alb.AlbumId = t.AlbumId
AND t.TrackId = il.TrackId
AND il.InvoiceId = i.InvoiceId
AND i.InvoiceDate <= '2009-05-01'
AND NOT EXISTS (
    SELECT 1
    FROM Invoice AS i2, InvoiceLine AS il2, Track AS t2, Album AS alb2
    WHERE i2.InvoiceId = il2.InvoiceId
    AND il2.TrackId = t2.TrackId
    AND t2.AlbumId = alb2.AlbumId
    AND alb2.ArtistId = a.ArtistId
    AND i2.InvoiceDate >= '2013-02-01'
)
ORDER BY a.Name;

--28 rows
/*
We need to filter the artists according to two dates which
could not be done in the same WHERE clause, since no row
could both before 2009 and after 2013 at the same time.
So I created a subquery using NOT EXISTS to exclude the dates
after 2013.
*/

--Q7a

SELECT t.TrackId, t.Name AS track_name, COALESCE(SUM(il.Quantity), 0) AS purchase_count
FROM Track t
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY purchase_count DESC;

--3503 rows
/*
Join the track table and invoiceline table to get purchase
data, Coalesce replaces NULL with 0
*/

--Q7b
SELECT purchase_count, COUNT(*) AS num_occurrences
FROM (
    SELECT t.TrackId, COALESCE(SUM(il.Quantity), 0) AS purchase_count
    FROM Track t
    LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY t.TrackId
) AS track_purchases
GROUP BY purchase_count
ORDER BY purchase_count DESC;

--3 rows
/*
Grouping the result from the previous query based on the purchase count.
*/









