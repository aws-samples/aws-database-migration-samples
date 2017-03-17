--
--  Allow 45 minutes for installation (depending on the size of the host)
-- 

--------------------------------------------------------
-- 
-- !!! log in as a user with DBA privilege (master user in RDS)
--
--------------------------------------------------------

-- Spool to output
spool install-rds.out


--------------------------------------------------------
--
-- The dms_sample user/schema contains the objects and data
-- for this database. 
--
-- The following script creates the user dms_sample/dms_sample
-- it is recommended that you change the password
-- after creating the account.
--
---------------------------------------------------------

@user/create_dms_sample.sql


---------------------------------------------------------
-- In order to capture changes supplemental logging is required
-- The following commands turn on supplemental logging and increase 
-- archive retention (RDS)
---------------------------------------------------------

---------------------------------------------------------
-- If your source is NOT on RDS:
---------------------------------------------------------
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;



--------------------------------------------------------
-- 
-- In general, it's a good idea to create and use an 
-- account other than the account that owns the schema 
-- objects for the migration. The following creates the 
-- user dms_user/dms_user which can be used to migrate
-- the objects contained in the dms_sample account.
-- It is recommended that you change the password
-- after creating the account.
---------------------------------------------------------
@user/create_dms_user.sql
@user/dms_user_privileges_onprem.sql

--------------------------------------------------------
--
-- If you want the dms_user to use the Schema Conversion 
-- Tool (SCT) you will need to give them the following privileges
--
--------------------------------------------------------
@user/dms_user_sct_privileges.sql



--------------------------------------------------------
--
-- !!! log in as the user DMS_SAMPLE
--
---------------------------------------------------------
-- run the following scripts:
alter session set current_schema = dms_sample;
@schema/load_base_data.sql
@schema/install_dms_sample_data.sql


-- stop spooling
spool off

