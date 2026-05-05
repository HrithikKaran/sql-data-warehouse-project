/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/


CREATE OR REPLACE VIEW gold.report_products
 AS
 WITH base_query AS (
         SELECT f.order_number,
            f.customer_key,
            f.order_date,
            f.sales_amount,
            f.quantity,
            p.product_key,
            p.product_name,
            p.category,
            p.subcategory,
            p.cost
           FROM gold.fact_sales f
             LEFT JOIN gold.dim_products p ON p.product_key = f.customer_key
          WHERE f.order_date IS NOT NULL
        ), product_aggregation AS (
         SELECT base_query.product_key,
            base_query.product_name,
            base_query.category,
            base_query.subcategory,
            base_query.cost,
            count(DISTINCT base_query.order_number) AS total_order,
            count(DISTINCT base_query.customer_key) AS total_customers,
            sum(base_query.sales_amount) AS total_sales,
            sum(base_query.quantity) AS total_quantity,
            max(base_query.order_date) AS last_sale_date,
            EXTRACT(year FROM age(max(base_query.order_date)::timestamp with time zone, min(base_query.order_date)::timestamp with time zone)) * 12::numeric + EXTRACT(month FROM age(max(base_query.order_date)::timestamp with time zone, min(base_query.order_date)::timestamp with time zone)) AS lifespan,
            round(avg(base_query.sales_amount::numeric / NULLIF(base_query.quantity, 0)::numeric), 2) AS avg_selling_price
           FROM base_query
          GROUP BY base_query.product_key, base_query.product_name, base_query.category, base_query.subcategory, base_query.cost
        )
 SELECT product_aggregation.product_key,
    product_aggregation.product_name,
    product_aggregation.category,
    product_aggregation.subcategory,
    product_aggregation.cost,
    product_aggregation.last_sale_date,
    EXTRACT(year FROM CURRENT_DATE) * 12::numeric + EXTRACT(month FROM CURRENT_DATE) - (EXTRACT(year FROM product_aggregation.last_sale_date) * 12::numeric + EXTRACT(month FROM product_aggregation.last_sale_date)) AS recency_months,
        CASE
            WHEN product_aggregation.total_sales > 50000 THEN 'High Performer'::text
            WHEN product_aggregation.total_sales >= 10000 THEN 'Mid Range'::text
            ELSE 'Low Performer'::text
        END AS product_segment,
    product_aggregation.lifespan,
    product_aggregation.total_order,
    product_aggregation.total_sales,
    product_aggregation.total_quantity,
    product_aggregation.total_customers,
    product_aggregation.avg_selling_price,
    NULLIF(product_aggregation.total_sales, 0) / product_aggregation.total_order AS avg_order_value,
    NULLIF(product_aggregation.total_sales, 0)::numeric / NULLIF(product_aggregation.lifespan, 0::numeric) AS avg_monthly_revenue
   FROM product_aggregation;
