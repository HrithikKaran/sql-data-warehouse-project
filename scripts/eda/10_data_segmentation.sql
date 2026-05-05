/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

--segment products into cost ranges and count how many products fall into each segement

WITH product_segements AS(
SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
FROM gold.dim_products
)
SELECT 
cost_range,
COUNT(product_name) AS total_products
FROM product_segements
GROUP BY cost_range
ORDER BY total_products DESC


--group customers into three segments based on their spending behavior.
-- VIP – Customers with at least 12 months of history and spending more than $5000
-- Regular – customers with at least 12 months of history but spending $5000 or less.
-- New – Customers with a lifespan less than 12 months
-- And find the total number of customers by each group

WITH customer_lifecycle AS (
    SELECT
        c.customer_key,
		SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
    		EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    GROUP BY c.customer_key
),
customer_segment AS
(SELECT
    customer_key,
	total_spending,
    lifespan,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <=5000 THEN 'regular'
		ELSE 'New'
	END segment
FROM customer_lifecycle)
SELECT 
	segment,
	COUNT(*) AS total_customers
FROM customer_segment
GROUP BY segment
ORDER BY segment
