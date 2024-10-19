----------------------
--B. Bonus Questions--
----------------------

--Author: Ela Wajdzik
--Date: 9.09.2024  (update 12.09.2024)
--Tool used: Microsoft SQL Server



--1. Join All The Things
--Recreate the following table output using the available data

--customer_id   order_date  product_name	price	member
--A             2021-01-01  curry	        15	    N

SELECT
	s.customer_id,
	s.order_date,
	mn.product_name,
	mn.price,
	CASE	
		WHEN m.join_date <= s.order_date THEN 'Y'	--an additional column with the value 'Y' if the order comes from a customer who is a member, and 'N' if not
		ELSE 'N'
	END AS member
FROM sales s
INNER JOIN menu mn
	ON mn.product_id = s.product_id
LEFT JOIN members m
	ON m.customer_id = s.customer_id;


--2. Rank All The Things

--customer_id	order_date	product_name	price	member	ranking
--A	            2021-01-01	curry	        15	    N	    null

WITH full_table AS (
	SELECT
		s.customer_id,
		s.order_date,
		mn.product_name,
		mn.price,
		CASE 
			WHEN m.join_date <= s.order_date THEN 'Y'
			ELSE 'N'
		END AS member
	FROM sales s
	INNER JOIN menu mn
		ON mn.product_id = s.product_id
	LEFT JOIN members m
		ON m.customer_id = s.customer_id)

SELECT 
	*,
	CASE 
		WHEN member = 'N' THEN null
		ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date ASC)		--an additional column with the ranking of orders, but only for orders made by a member
	END AS ranking
FROM full_table;
