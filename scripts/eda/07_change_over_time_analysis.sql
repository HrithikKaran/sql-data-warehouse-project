/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

--analyze sales performance over time
SELECT 
	DATE_PART('year', order_date) AS order_year,
  DATE_PART('month', order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
  COUNT(DISTINCT customer_key) AS total_customers,
  SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('year', order_date)
ORDER BY DATE_PART('year', order_date)

--analyze sales performance over time
SELECT 
	DATE_PART('year', order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customes,
	SUM(quantity) AS total_quanity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('year', order_date)
ORDER BY DATE_PART('year', order_date)



--analyze sales performance over time
SELECT 
	DATE_PART('year', order_date) AS order_year,
	DATE_PART('month', order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customes,
	SUM(quantity) AS total_quanity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('year', order_date), DATE_PART('month', order_date)
ORDER BY DATE_PART('year', order_date), DATE_PART('month', order_date)



--analyze sales performance over time
SELECT 
	DATE_TRUNC('month', order_date) AS oder_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customes,
	SUM(quantity) AS total_quanity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date)

