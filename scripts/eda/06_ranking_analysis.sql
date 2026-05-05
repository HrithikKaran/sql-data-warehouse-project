/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

--which 5 products generate the highest revenue?
--Using GROUP BY
--which 5 products generate the highest revenue?
SELECT 
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5

--using window function
SELECT product_name, total_revenue
FROM(
	SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rn
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
)t
WHERE rn <= 5

--what are the 5 worst-performing products in terms of sales
--using group by
SELECT 
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5


--using window function
SELECT product_name, total_revenue
FROM(
	SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) ASC) AS rn
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
)t
WHERE rn <= 5


--find the top 10 customers who have generated the highest revenue
--using group by
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue_by_customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue_by_customer DESC
LIMIT 10


--using window function
SELECT customer_key, first_name, last_name, total_revenue_by_customer
FROM
(
	SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		SUM(f.sales_amount) AS total_revenue_by_customer,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC ) as rn
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
	GROUP BY c.customer_key,
		c.first_name,
		c.last_name
)t
WHERE rn <= 10

--the 3 customers with fewest orders placed
--using group by

SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT order_number) AS total_orders
		--ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT order_number) ASC ) as rn
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
	GROUP BY c.customer_key,
		c.first_name,
		c.last_name
	ORDER BY total_orders
	LIMIT 3

--using window function
WITH customer_orders AS(
	SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT f.order_number) AS total_orders
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
		ON c.customer_key = f.customer_key
	GROUP BY 
		c.customer_key,
		c.first_name,
		c.last_name
)
SELECT * 
FROM (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY total_orders ASC) AS rn
	FROM customer_orders
)t
WHERE rn <= 3
