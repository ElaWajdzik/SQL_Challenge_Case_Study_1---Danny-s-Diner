---------------------------
--A. Case Study Questions--
---------------------------

--Author: Ela Wajdzik
--Date: 9.09.2024  (update 12.09.2024)
--Tool used: Microsoft SQL Server

--1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
  COUNT(s.customer_id) AS number_orders, 	--is not necessary to count how many orders do each customer
	SUM(m.price) AS total_amount
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;

--2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS number_of_days
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH sales_with_ranking AS (
	SELECT
		s.*,
		m.product_name,									--add the name of the product
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking	--product ranking order
	FROM sales s
	LEFT JOIN menu m
	ON m.product_id = s.product_id)

SELECT
	customer_id,
	product_name
FROM sales_with_ranking
WHERE ranking = 1			--select only the first order
GROUP BY customer_id, product_name;	--group by the same products

--If I work with PostgreSQL, I will make use of the construct called SELECT DISTINCT ON () and ORDER BY order_date ASC.

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	m.product_name,
	COUNT(*) AS number_of_orders  --counts every order from every client
FROM sales s
LEFT JOIN menu m
	ON m.product_id = s.product_id
GROUP BY m.product_name;

--5. Which item was the most popular for each customer?

WITH sales_with_popularity_by_client AS (
	SELECT 
		s.customer_id,
		m.product_name,
		COUNT(*) AS number_of_orders,								--counts every product bought by every client
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS ranking	--the most popular product ranking by each client
	FROM sales s
	LEFT JOIN menu m
		ON m.product_id=s.product_id
	GROUP BY s.customer_id, m.product_name)

SELECT
	customer_id,
	product_name,
	number_of_orders		--this information is not necessary
FROM sales_with_popularity_by_client
WHERE ranking = 1;


--6. Which item was purchased first by the customer after they became a member?

WITH members_sales_with_ranking AS (
	SELECT 
		s.customer_id,
		s.order_date,
		s.product_id,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS ranking		--order of the first products bought by members 
	FROM sales s
	INNER JOIN members m
	ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date)

SELECT
	s.customer_id,
	m.product_name
FROM members_sales_with_ranking s
LEFT JOIN menu m
	ON m.product_id = s.product_id
WHERE s.ranking = 1		--select only the first order placed after becoming a member

--7. Which item was purchased just before the customer became a member?

WITH sales_before_membership_with_ranking AS (
	SELECT 
		s.customer_id,
		s.order_date,
		s.product_id,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS ranking		--order of the last products bought after becoming a member 
	FROM sales s
	INNER JOIN members m
		ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date)

SELECT 
	s.customer_id,
	m.product_name
FROM sales_before_membership_with_ranking s
LEFT JOIN menu m
	ON m.product_id = s.product_id
WHERE s.ranking = 1;

--8. What is the total items and amount spent for each member before they became a member?

SELECT 
	s.customer_id,
	COUNT(*) AS number_of_item,		--count the number of items
	SUM(mn.price) AS spent_amount		--sum of the prices
FROM sales s
INNER JOIN members m
	ON s.customer_id = m.customer_id
INNER JOIN menu mn
	ON mn.product_id = s.product_id

WHERE s.order_date < m.join_date		--filter the orders bought before becoming a member
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--I assume that points can only be collected by members, and only for orders placed after joining

SELECT 
	s.customer_id,
	SUM(CASE s.product_id
			WHEN 1 THEN mn.price * 2 * 10		--double points for sushi orders
			ELSE mn.price * 10			--calculate the points 1$ = 10 points
		END) AS number_of_points
FROM sales s
INNER JOIN members m
	ON s.customer_id = m.customer_id
INNER JOIN menu mn
	ON mn.product_id = s.product_id

WHERE s.order_date >= m.join_date
GROUP BY s.customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	s.customer_id,
	SUM(CASE
			WHEN DATEDIFF(DAY, m.join_date, s.order_date) < 7 THEN mn.price * 2		--double points for all items purchased after joining the program
			ELSE mn.price
		END) * 10 AS number_of_points
FROM sales s
INNER JOIN members m
	ON s.customer_id = m.customer_id
INNER JOIN menu mn
	ON mn.product_id = s.product_id

WHERE s.order_date >= m.join_date	--filter the orders placed after becoming a member
AND s.order_date < '2021-02-01'		--filter the orders at the end of January
GROUP BY s.customer_id;

