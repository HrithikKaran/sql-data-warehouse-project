/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/


SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE table_type ='VIEW'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'dim_customers'
