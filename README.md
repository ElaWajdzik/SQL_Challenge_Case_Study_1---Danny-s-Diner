I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# <p align="center"> Case Study #1: 🍜 Danny's Diner 
<p align="center"> <img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image Danny's Diner - the taste of success" height="400">

***

## Table of Contents

- [Business Case](#business-case)
- [Relationship Diagram](#relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-questions)


## Business Case
Danny seriously loves Japanese food so at the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but has no idea how to use their data to help them run the business.

## Relationship Diagram

<img src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/f8120a7a-13d9-49e9-92f4-2077ec3041a9" width="500">

Additionally, in the code, I created constraints related to primary and foreign keys. The information about the constraints comes from the relationship diagram.

````sql
ALTER TABLE members
ALTER COLUMN customer_id VARCHAR(1) NOT NULL;

ALTER TABLE members
ADD CONSTRAINT members_customer_id_pk PRIMARY KEY (customer_id);

ALTER TABLE menu
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE menu
ADD CONSTRAINT menu_product_id_pk PRIMARY KEY (product_id);

ALTER TABLE sales
ADD CONSTRAINT sales_product_id_fk 
FOREIGN KEY(product_id) REFERENCES menu(product_id);

--I can't create a foreign key constraint between members.customer_id and sales.customer_id because not every customer is also a member
````

## Available Data

<details><summary>
    All datasets exist in database schema.
  </summary> 

#### ``Table 1: sales``

customer_id | order_date | product_id
-- | -- | --
A | 2021-01-01 | 1
A | 2021-01-01 | 2
A | 2021-01-07 | 2
A | 2021-01-10 | 3
A | 2021-01-11 | 3
A | 2021-01-11 | 3
B | 2021-01-01 | 2
B | 2021-01-02 | 2
B | 2021-01-04 | 1
B | 2021-01-11 | 1
B | 2021-01-16 | 3
B | 2021-02-01 | 3
C | 2021-01-01 | 3
C | 2021-01-01 | 3
C | 2021-01-07 | 3


#### ``Table 2: menu``

product_id | product_name | price
-- | -- | --
1 | sushi | 10
2 | curry | 15
3 | ramen | 12

#### ``Table 3: members``

customer_id | join_date
-- | --
A | 2021-01-07
B | 2021-01-09


  </details>



## Case Study Questions

- [A. Case Study Questions](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_1---Danny-s-Diner/blob/main/A.%20Case%20Study%20Questions.md)

- [B. Bonus Questions](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_1---Danny-s-Diner/blob/main/B.%20Bonus%20Questions.md)

<br/>

*** 

 # <p align="center"> Thank you for your attention! 🫶️

**Thank you for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

***
