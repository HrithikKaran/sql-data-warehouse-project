/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
--option 1: exact difference in years
SELECT 
	MIN (order_date) AS first_order,
	MAX(order_date) AS last_order,
	AGE(MAX(order_date), MIN (order_date)) AS sales_year
FROM gold.fact_sales

--Option 2: Number of years (integer)
  SELECT 
	MIN (order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATE_PART('year', AGE(MAX(order_date), MIN (order_date))) AS sales_year
FROM gold.fact_sales

--Option 3: Count distinct calendar years (often what people actually want)
  SELECT 
	MIN (order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATE_PART('year', AGE(MAX(order_date), MIN (order_date))) AS sales_year,
	COUNT(DISTINCT(DATE_PART('year', order_date))) AS total_years,
	AGE(MAX(order_date), MIN(order_date)) AS sales_duration
FROM gold.fact_sales
  

-- Find the youngest and oldest customer based on birthdate
SELECT
	MIN(birthdate) AS oldest_customer,
	DATE_PART('year',AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_age,
	MAX(birthdate) AS youngest_customer,
	DATE_PART('year',AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_age
FROM gold.dim_customers
