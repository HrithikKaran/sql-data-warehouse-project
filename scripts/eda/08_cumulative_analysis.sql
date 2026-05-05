/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

--calculate the total sales per month and running total of sales over time
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales
FROM(
SELECT 
	DATE_TRUNC('month', order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date)
)t


--partition the data by year
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date ASC) AS running_total_sales
FROM(
SELECT 
	DATE_TRUNC('month', order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date)
)t

--calculate the total sales per month and running total of sales over time
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date ASC) AS moving_avg
FROM(
SELECT 
	DATE_TRUNC('year', order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('year', order_date)
)t
