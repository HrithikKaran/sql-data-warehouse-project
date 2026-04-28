/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL silver.load_silver_layer();
===============================================================================
*/




CREATE OR REPLACE PROCEDURE silver.load_silver_layer()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '===== STARTING SILVER LAYER ETL =====';

    ------------------------------------------------------------------
    -- 1. CRM CUSTOMER INFO
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 1: Loading silver.crm_cust_info...';

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
             WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
             ELSE 'n/a'
        END,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
             WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
             ELSE 'n/a'
        END,
        cs_create_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cs_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
    ) t
    WHERE flag_last = 1 AND cst_id IS NOT NULL;

    RAISE NOTICE 'Completed: silver.crm_cust_info';


    ------------------------------------------------------------------
    -- 2. CRM PRODUCT INFO
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 2: Loading silver.crm_prd_info...';

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_'),
        SUBSTRING(TRIM(prd_key), 7, LENGTH(prd_key)),
        TRIM(prd_nm),
        COALESCE(
            CASE 
                WHEN prd_cost ~ '^[0-9]+$' THEN prd_cost::INT
                ELSE NULL
            END, 0
        ),
        CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
             WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
             WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
             WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
             ELSE 'n/a'
        END,
        prd_start_dt::DATE,
        LEAD(prd_start_dt::DATE) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day'
    FROM bronze.crm_prd_info;

    RAISE NOTICE 'Completed: silver.crm_prd_info';


    ------------------------------------------------------------------
    -- 3. CRM SALES DETAILS
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 3: Loading silver.crm_sales_details...';

    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt ~ '^\d{8}$' 
             AND TO_CHAR(TO_DATE(sls_order_dt, 'YYYYMMDD'), 'YYYYMMDD') = sls_order_dt
            THEN TO_DATE(sls_order_dt, 'YYYYMMDD')
            ELSE NULL
        END,
        CASE 
            WHEN sls_ship_dt ~ '^\d{8}$' 
             AND TO_CHAR(TO_DATE(sls_ship_dt, 'YYYYMMDD'), 'YYYYMMDD') = sls_ship_dt
            THEN TO_DATE(sls_ship_dt, 'YYYYMMDD')
            ELSE NULL
        END,
        CASE 
            WHEN sls_due_dt ~ '^\d{8}$' 
             AND TO_CHAR(TO_DATE(sls_due_dt, 'YYYYMMDD'), 'YYYYMMDD') = sls_due_dt
            THEN TO_DATE(sls_due_dt, 'YYYYMMDD')
            ELSE NULL
        END,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE
            WHEN sls_price < 0 THEN ABS(sls_price)
            WHEN sls_price = 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze.crm_sales_details;

    RAISE NOTICE 'Completed: silver.crm_sales_details';


    ------------------------------------------------------------------
    -- 4. ERP CUSTOMER
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 4: Loading silver.erp_cust_az12...';

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT 
        CASE
            WHEN UPPER(TRIM(cid)) LIKE 'NAS%' 
            THEN SUBSTRING(UPPER(TRIM(cid)) FROM 4)
            ELSE UPPER(TRIM(cid))
        END,
        CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END,
        CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
             WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
             ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;

    RAISE NOTICE 'Completed: silver.erp_cust_az12';


    ------------------------------------------------------------------
    -- 5. ERP LOCATION
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 5: Loading silver.erp_loc_a101...';

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101(
        cid,
        cntry
    )
    SELECT
        REPLACE(TRIM(cid), '-', ''),
        CASE
            WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
            WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a101;

    RAISE NOTICE 'Completed: silver.erp_loc_a101';


    ------------------------------------------------------------------
    -- 6. ERP PRODUCT CATEGORY
    ------------------------------------------------------------------
    RAISE NOTICE 'Step 6: Loading silver.erp_px_cat_g1v2...';

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT 
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    RAISE NOTICE 'Completed: silver.erp_px_cat_g1v2';


    ------------------------------------------------------------------
    RAISE NOTICE '===== SILVER LAYER ETL COMPLETED SUCCESSFULLY =====';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR OCCURRED: %', SQLERRM;
        RAISE;
END;
$$;
