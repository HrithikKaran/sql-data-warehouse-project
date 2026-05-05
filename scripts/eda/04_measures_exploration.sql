/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

--find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales

--find how many items are sold.
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

--find the average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales

--find the total number of orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales

SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

--find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products

--find the total number of customer
SELECT COUNT(customer_number) FROM gold.dim_customers

--find the total number of customers that has placed an order.
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales

--generate a report that shows all key metrics of the business
--using CTE
WITH sales_metrics AS (
	SELECT 
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		AVG(price) AS avg_price,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers_with_orders
	FROM gold.fact_sales
),
product_metrics AS (
	SELECT 
		COUNT(product_name) AS total_products
	FROM gold.dim_products
),
customer_metrics AS (
	SELECT
		COUNT(customer_number) AS total_customers
	FROM gold.dim_customers
)

SELECT
	s.total_sales,
	s.total_quantity,
	s.avg_price,
	s.total_orders,
	s.total_customers_with_orders,
	p.total_products,
	c.total_customers
FROM sales_metrics s
CROSS JOIN product_metrics p
CROSS JOIN  customer_metrics c;

--using UNION ALL
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Avg Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers with Orders' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales
