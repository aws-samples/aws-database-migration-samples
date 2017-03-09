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


grant SELECT ANY TRANSACTION to dms_sample;
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_OBJECTS','DMS_SAMPLE'); 
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLES','DMS_SAMPLE'); 
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('OBJ$','DMS_SAMPLE');
grant SELECT on ALL_INDEXES to dms_sample;
grant SELECT on ALL_OBJECTS to dms_sample;
grant SELECT on ALL_TABLES to dms_sample;
grant SELECT on ALL_USERS to dms_sample;
grant SELECT on ALL_CATALOG to dms_sample;
grant SELECT on ALL_CONSTRAINTS to dms_sample;
grant SELECT on ALL_CONS_COLUMNS to dms_sample;
grant SELECT on ALL_TAB_COLS to dms_sample;
grant SELECT on ALL_IND_COLUMNS to dms_sample;
grant SELECT on ALL_LOG_GROUPS to dms_sample;

exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLESPACES','DMS_SAMPLE');
grant SELECT on ALL_TAB_PARTITIONS to dms_sample;
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS','DMS_SAMPLE');
grant SELECT on ALL_VIEWS  to dms_sample;

exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS','DMS_SAMPLE');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','DMS_SAMPLE');
grant logmining to dms_sample;





