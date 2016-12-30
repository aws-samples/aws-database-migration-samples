--------------------------------------------------------
--
-- The dms_sample database contains the objects and data
-- for the sample database.
--
---------------------------------------------------------

source ./schema/create_dms_sample.sql

---------------------------------------------------------
--
-- The dms_user script creates the user dms_user with 
-- the password dms_user. It is recommended you change
-- the password for dms_user.
-- 
-- dms_user should have all the privileges required to
-- use the Database Migration Service and Schema Conversion
-- Tool against the dms_sample database.
--
---------------------------------------------------------

source ./user/create_dms_user.sql
source ./user/dms_user_privileges.sql


---------------------------------------------------------
-- RDS Specific commands
---------------------------------------------------------
call mysql.rds_set_configuration('binlog retention hours',8);


--------------------------------------------------------
--
-- install the objects in the dms_sample database
--
---------------------------------------------------------
use dms_sample;
source ./schema/load_base_data.sql
source ./schema//install_dms_sample_data.sql

