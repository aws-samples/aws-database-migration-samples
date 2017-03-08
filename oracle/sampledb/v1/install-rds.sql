/*
 Copyright 2017 Amazon.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

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
-- RDS Specific commands
---------------------------------------------------------
exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD');
exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD','PRIMARY KEY');
exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',8);


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
@user/dms_user_privileges.sql

--------------------------------------------------------
--
-- If you want the dms_user to use the Schema Conversion 
-- Tool (SCT) you will need to give them the following privileges
--
--------------------------------------------------------
@user/dms_user_sct_privileges.sql



--------------------------------------------------------
--
-- install the objects in the dms_sample schema
--
---------------------------------------------------------
alter session set current_schema = dms_sample;
@schema/load_base_data.sql
@schema/install_dms_sample_data.sql



-- stop spooling output

spool off
