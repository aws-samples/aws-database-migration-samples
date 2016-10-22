---------------------------------------------------------
--
-- The following grants all privileges necessary for
-- the user dms_user to use DMS to migrate
-- tables and data from the dms_sample schema
--
---------------------------------------------------------
grant SELECT ANY TRANSACTION to dms_user;
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_OBJECTS','DMS_USER'); 
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('OBJ$','DMS_USER');
grant SELECT on ALL_INDEXES to dms_user;
grant SELECT on ALL_OBJECTS to dms_user;
grant SELECT on ALL_TABLES to dms_user;
grant SELECT on ALL_USERS to dms_user;
grant SELECT on ALL_CATALOG to dms_user;
grant SELECT on ALL_CONSTRAINTS to dms_user;
grant SELECT on ALL_CONS_COLUMNS to dms_user;
grant SELECT on ALL_TAB_COLS to dms_user;
grant SELECT on ALL_IND_COLUMNS to dms_user;
grant SELECT on ALL_LOG_GROUPS to dms_user;

exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLESPACES','DMS_USER');
grant SELECT on ALL_TAB_PARTITIONS to dms_user;
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS','DMS_USER');
grant SELECT on ALL_VIEWS  to dms_user;

exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS','DMS_USER');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','DMS_USER');
grant logmining to dms_user;


