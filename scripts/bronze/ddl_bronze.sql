/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE	
);


DROP TABLE IF EXISTS bronze.crm_prod_info;
CREATE TABLE bronze.crm_prod_info(
	prd_id INT,
	prd_key TEXT,
	prd_nm TEXT,
	prd_cost TEXT,
	prd_line TEXT,
	prd_start_dt TEXT,
	prd_end_dt TEXT
);


DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num TEXT,
	sls_prd_key TEXT,
	sls_cust_id TEXT,
	sls_order_dt TEXT,
	sls_ship_dt TEXT,
	sls_due_dt TEXT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);


DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid TEXT,
	bdate DATE,
	gen TEXT
);


DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid VARCHAR(50),
	cntry VARCHAR(50)
);


DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

