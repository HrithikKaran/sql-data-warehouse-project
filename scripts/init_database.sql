-- Create Database and schemas
-- Script purpose:
--   This script create a new database named 'DataWarehouse' using the linux terminal.
--   Additionally, the script sets up three schemas within the database: bronze, silver and gold

--Create new database using linux terminal:

-- lenovo@lenovo-ThinkPad-P50:~$ sudo -i -u postgres
-- [sudo] password for lenovo: 
-- postgres@lenovo-ThinkPad-P50:~$ psql
-- psql (14.20 (Ubuntu 14.20-0ubuntu0.22.04.1))
-- Type "help" for help.

-- postgres=# CREATE DATABASE DataWarehouse;
-- CREATE DATABASE
-- postgres=# CREATE USER dwhuser WITH PASSWORD 'dwhadmin';
-- CREATE ROLE
-- postgres=# GRANT ALL PRIVILEGES ON DATABASE DataWarehouse TO dwhuser;
-- GRANT
-- postgres=# \q
-- postgres@lenovo-ThinkPad-P50:~$ exit
-- logout
-- lenovo@lenovo-ThinkPad-P50:~$ 

--Create schemas:

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
