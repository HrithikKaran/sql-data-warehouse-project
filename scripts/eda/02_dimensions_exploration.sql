
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/
--explore all countries our customers come from.
SELECT DISTINCT
	country
FROM gold.dim_customers

--retrieve all from gold.dim_customers
SELECT *
FROM gold.dim_customers

--explore all the product categories “The major Divisions”

SELECT DISTINCT
	category
FROM gold.dim_products

SELECT DISTINCT
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 1,2,3
