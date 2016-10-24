------------------------------
-- File in this directory are used to create and manage user accounts
------------------------------

-- The following files create the user dms_user and grant the privileges
-- necessary to access the data from DMS or the SCT

create_dms_user.sql
dms_user_privileges.sql
dms_user_sct_privileges.sql

-- The following files create the user dms_sample and grant the privileges
-- necessary to create the objects that make up this sample database.
-- Additionally dms_sample_dms_user_grants.sql grants privileges 
-- necessary to access these objects to the user dms_user
 
create_dms_sample.sql
dms_sample_dms_user_grants.sql
dms_sample_privileges.sql
