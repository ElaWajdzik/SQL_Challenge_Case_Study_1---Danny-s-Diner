# <p align="center">  Case Study #1: 🍜 Danny's Diner 
 
## <p align="center"> A. Case Study Questions



### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT
	s.customer_id,
    COUNT(s.customer_id) AS number_orders, 	--is not necessary to count how many orders do each customer
	SUM(m.price) AS total_amount
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

#### Steps:
- Merge the ```sales``` and ```menu``` tables using **JOIN**, where ```customer_id``` comes from the ```sales``` table and ```price``` comes from the ```menu``` table.
- Find out the ```total_amount``` for each customer using **SUM** and **GROUP BY**.
- Find out the ```number_orders``` for each customer using **COUNT** and **GROUP BY**.

#### Result:
| customer_id | number_orders | total_amount |
| ----------- | ------------- | ------------ |
| A           | 6             | 76           |
| B           | 6             | 74           |
| C           | 3             | 36           |


- Customer **A** ordered 6 products and spent $76.
- Customer **B** ordered 6 products and spent $74.
- Customer **C** ordered 3 products and spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS number_of_days
FROM sales
GROUP BY customer_id;
````

#### Steps:
- Use **COUNT(DISTINCT ```order_date```)** to count the number of distinct days of visits. 

#### Result:
| customer_id | number_of_days   |
| ----------- | -----------------|
| A           | 4                |
| B           | 6                |
| C           | 2                |

- Customer **A** visited Danny's Diner on 4 different days.
- Customer **B** visited Danny's Diner on 6 different days.
- Customer **C** visited Danny's Diner on 2 different days.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

If I work with PostgreSQL, I will make use of the construct called **SELECT DISTINCT ON ()** and **ORDER BY order_date ASC**. 

#### Steps:
- Create a common table expression (CTE) to calculate the ranking of orders using the **WITH** clause.
- Calculate the ranking of orders using the **DENSE_RANK** function. 

#### Result:
| customer_id | product_name |
| ----------- | -------------|
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

- Customer **A** bought two dishes, sushi and curry, on their first purchase.
- Customer **B** first purchased curry.
- Customer **C** first purchased ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT 
	m.product_name,
	COUNT(*) AS number_of_orders  --counts every order from every client
FROM sales s
LEFT JOIN menu m
	ON m.product_id = s.product_id
GROUP BY m.product_name;
````

#### Steps:
- Use **COUNT** to calculate the number of orders for each dish.
- Order the results in descending order using **ORDER BY** with the **DESC** parameter to determine which item was purchased most frequently.

#### Result:
| product_name | number_of_orders |
|--------------|------------------|
| ramen        | 8                |
| curry        | 4                |
| sushi        | 3                |

- The most frequently purchased item was ramen. The customers at Danny's Diner bought it 8 times, which is twice as many as curry.

***

### 5. Which item was the most popular for each customer?

````sql
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
````

#### Steps:
- Create a temporary table (using **WITH**) to generate a ranking of popularity (using **DENSE_RANK**).
- Select only the rows from the temporary table **WHERE** the ranking of popularity is equal to 1.

#### Result:
| customer_id | product_name | number_of_orders |
|-------------|--------------|------------------|
| A           | ramen        | 3                |
| B           | curry        | 2                |
| B           | ramen        | 2                |
| B           | sushi        | 2                |
| C           | ramen        | 3                |

- The most popular item for each customer was ramen.
- Additionally, customer **B** liked every item (ramen, sushi, and curry).

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````

#### Steps:
- As in question 5, create a temporary table (using **WITH**) to generate a ranking of orders (using **DENSE_RANK**).
- Select the first order for each member after joining, using the ranking of orders, and filter to include only the top-ranked value (using the **WHERE** clause).


#### Result:
| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| B           | sushi        |

- After customer **A** became a member, they first purchased curry.
- After customer **B** became a member, they first  purchased sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
````

#### Steps:
- Use a similar function as in question 6. The main change is to use **DENSE_RANK** in descending order.

#### Result:
| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

- Customer **A** in the order placed before becoming a member, bought two types of items - sushi and curry.
- Customer **B** in the order placed before becoming a member, bought sushi.

According to the results from questions 6 and 7, customers **A** and **B** bought the same product just before and just after becoming members.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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
````

#### Steps:
- Use aggregate functions **COUNT** and **SUM**.
- Join all three tables to create the result.

#### Result:
| customer_id | number_of_item | spent_amount |
|-------------|----------------|--------------|
| A           | 2              | 25           |
| B           | 3              | 40           |

- Customer **A**, before becoming a member, spent $25 at Danny's Diner and bought 2 items.
- Customer **B**, before becoming a member, spent $40 at Danny's Diner and bought 3 items (2 different type of items).

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
SELECT 
	s.customer_id,
	SUM(CASE s.product_id
			WHEN 1 THEN mn.price * 2 * 10	--double points for sushi orders
			ELSE mn.price * 10			--calculate the points 1$ = 10 points
		END) AS number_of_points
FROM sales s
INNER JOIN members m
	ON s.customer_id = m.customer_id
INNER JOIN menu mn
	ON mn.product_id = s.product_id

WHERE s.order_date >= m.join_date
GROUP BY s.customer_id;
````

#### Steps:
- In this problem, I assume that points can only be collected by members, and only for orders placed after joining.
- Use the function **CASE** to check if ordered items if the ordered item was ```sushi``` (```product_id = 1```) and then multiplied by 2 number of points. The number of points is calculated like ```price``` * 10.

#### Result:
| customer_id | number_of_points |
|-------------|------------------|
| A           | 510              |
| B           | 440              |


- Customer **A** collected 510 points, and customer **B** collected 440 points.

It is interesting to see what they can get with these points.


***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
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
````

#### Steps:
- It is important not to increase the multiplier for sushi to 4 during the first week of membership.
- Use the **SUM** and **CASE** functions to calculate the number of points earned in the first 7 days after becoming a member, and after that. In the first week, $1 is equal to 20 points; after that, $1 is equal to 10 points.
- Limit the data to orders placed by the end of January.


#### Result:

| customer_id | points |
|-------------|--------|
| A           | 1020   |
| B           | 320    |

- Customer **A** collected 1020 points.
- Customer **B** collected 320 points.