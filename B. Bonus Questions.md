# <p align="center">  Case Study #1: 🍜 Danny's Diner 
 
## <p align="center"> B. Bonus Questions



### Join All The Things

Recreate the following table output using the available data

| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | curry	      | 15	  | N      |


````sql
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
````

#### Steps:
- Join all three tables to create the expected table. From the ``sales`` table, I need date about ``customer_id`` and ``order_date``. From the ``menu`` table I need date about  ``product_name`` and ``price``. The date from the ``members`` table I need to calculate the value of ``member`` column.

#### Result:

<img src="https://github.com/user-attachments/assets/e171832d-c92a-450c-a41c-c33a2a48e863" height="450">


<br/>

***

### Rank All The Things
Create a table like before in **Join All The Things** but add the ``ranking``. The ``ranking`` of customer products is only for member purchases, and the ``ranking`` value is **null** when customers are not yet part of the loyalty program.


````sql
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
````

#### Steps:
- Create the table as before, but using a Common Table Expresion (CTE) with **WITH**.
- In the second step, add the ``ranking`` column, with ranking applied only to data involving the member purchases.

#### Result:


<img src="https://github.com/user-attachments/assets/8a40df2c-521c-442b-aa89-96698c4382bd" height="450">
