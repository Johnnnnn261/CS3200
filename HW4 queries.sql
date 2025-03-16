--Q4
WITH customer_spending as (
    SELECT c.cust_name, SUM(oi.item_price * oi.quantity) as total_spent
    FROM Customers as c, Orders as o, OrderItems as oi
    WHERE c.cust_id = o.cust_id
    AND o.order_num = oi.order_num
    GROUP BY c.cust_name
)
SELECT cust_name, total_spent as amount
FROM customer_spending
WHERE total_spent = (
	SELECT max(total_spent)
	FROM customer_spending)

--1 row

--Q5
SELECT c.cust_id, c.cust_name, COUNT(DISTINCT(oi.prod_id)) AS product_count
FROM Customers as c, Orders as o, OrderItems as oi
WHERE c.cust_id = o.cust_id
	AND o.order_num = oi.order_num
GROUP BY c.cust_id
ORDER BY product_count DESC, c.cust_name ASC;
--4 rows

--Q6
SELECT DISTINCT c.cust_id, c.cust_name
FROM Customers as c
WHERE EXISTS (
    SELECT 1 
	FROM Orders as o, OrderItems as oi
    WHERE o.cust_id = c.cust_id
    AND o.order_num = oi.order_num
    AND oi.item_price < 4
)
AND EXISTS (
    SELECT 1 
	FROM Orders as o, OrderItems as oi
    WHERE o.cust_id = c.cust_id
    AND o.order_num = oi.order_num
    AND oi.item_price > 10
);
--3 rows

--Q7
SELECT v.vend_id
FROM Vendors as v, Customers as c, Orders as o, OrderItems as oi, Products as p
WHERE c.cust_id = o.cust_id
	AND o.order_num = oi.order_num
	AND oi.prod_id = p.prod_id
	AND p.vend_id = v.vend_id
GROUP BY v.vend_id
HAVING COUNT(DISTINCT(cust_state)) = 4

--0 row

--Q8
SELECT v.uid, p.pagerank
FROM Visits as v, Pages as p
WHERE v.url IN (
    SELECT url 
    FROM Pages
    WHERE pagerank > (SELECT AVG(pagerank) 
						FROM Pages)
);

--15 rows

--Q9
SELECT v.uid, AVG(p.pagerank) AS avg_pagerank
FROM Visits v, Pages p
WHERE v.url = p.url
GROUP BY v.uid
HAVING AVG(p.pagerank) > (SELECT AVG(pagerank) 
							FROM Pages);

--2 rows





