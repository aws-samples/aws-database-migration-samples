---------------------------------------------------------
--
-- The following creates a user dms_user to which 
-- we will grant all privileges necessary to use DMS to migrate
-- tables and data from the dms_sample schema
--
---------------------------------------------------------

create user dms_user identified by dms_user;

grant CREATE SESSION to dms_user;
grant connect to dms_user;
