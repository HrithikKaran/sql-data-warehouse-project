/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL bronze.load_all_tables();
===============================================================================
*/



CREATE OR REPLACE PROCEDURE bronze.load_all_tables()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time        TIMESTAMP;
    v_end_time          TIMESTAMP;
    v_batch_start       TIMESTAMP;
    v_batch_end         TIMESTAMP;
    v_duration          INTERVAL;

    -- Error handling variables
    v_error_message     TEXT;
    v_error_detail      TEXT;
    v_error_hint        TEXT;
    v_error_context     TEXT;

BEGIN

    -- =========================
    -- Batch Start
    -- =========================
    v_batch_start := clock_timestamp();
    RAISE NOTICE 'Loading Bronze Layer Started at: %', v_batch_start;

    -- =========================
    -- MAIN PROCESS BLOCK (TRY)
    -- =========================
    BEGIN

        -- =========================
        -- CRM TABLES LOADING
        -- =========================
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading CRM Tables Started at: %', v_start_time;

        TRUNCATE TABLE bronze.crm_cust_info;
        COPY bronze.crm_cust_info
        FROM '/tmp/cust_info.csv'
        DELIMITER ','
        CSV HEADER;

        TRUNCATE TABLE bronze.crm_prd_info;
        COPY bronze.crm_prd_info
        FROM '/tmp/prd_info.csv'
        DELIMITER ','
        CSV HEADER;

        TRUNCATE TABLE bronze.crm_sales_details;
        COPY bronze.crm_sales_details
        FROM '/tmp/sales_details.csv'
        DELIMITER ','
        CSV HEADER;

        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;

        RAISE NOTICE 'Loading CRM Tables Completed at: %', v_end_time;
        RAISE NOTICE 'CRM Load Duration: %', v_duration;

        -- =========================
        -- ERP TABLES LOADING
        -- =========================
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading ERP Tables Started at: %', v_start_time;

        TRUNCATE TABLE bronze.erp_cust_az12;
        COPY bronze.erp_cust_az12
        FROM '/tmp/CUST_AZ12.csv'
        DELIMITER ','
        CSV HEADER;

        TRUNCATE TABLE bronze.erp_loc_a101;
        COPY bronze.erp_loc_a101
        FROM '/tmp/LOC_A101.csv'
        DELIMITER ','
        CSV HEADER;

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        COPY bronze.erp_px_cat_g1v2
        FROM '/tmp/PX_CAT_G1V2.csv'
        DELIMITER ','
        CSV HEADER;

        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;

        RAISE NOTICE 'Loading ERP Tables Completed at: %', v_end_time;
        RAISE NOTICE 'ERP Load Duration: %', v_duration;

    -- =========================
    -- EXCEPTION BLOCK (CATCH)
    -- =========================
    EXCEPTION
        WHEN OTHERS THEN
            -- Capture detailed error info
            GET STACKED DIAGNOSTICS
                v_error_message = MESSAGE_TEXT,
                v_error_detail  = PG_EXCEPTION_DETAIL,
                v_error_hint    = PG_EXCEPTION_HINT,
                v_error_context = PG_EXCEPTION_CONTEXT;

            RAISE NOTICE '❌ ERROR OCCURRED!';
            RAISE NOTICE 'Message: %', v_error_message;
            RAISE NOTICE 'Detail: %', v_error_detail;
            RAISE NOTICE 'Hint: %', v_error_hint;
            RAISE NOTICE 'Context: %', v_error_context;

            -- Optional: rethrow error if you want the procedure to fail
            -- RAISE;

    END;

    -- =========================
    -- Batch End
    -- =========================
    v_batch_end := clock_timestamp();
    v_duration := v_batch_end - v_batch_start;

    RAISE NOTICE 'Loading Bronze Layer Completed at: %', v_batch_end;
    RAISE NOTICE 'Total Batch Load Duration: %', v_duration;

END;
$$;
