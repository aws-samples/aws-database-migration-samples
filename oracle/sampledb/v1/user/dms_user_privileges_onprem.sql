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


---------------------------------------------------------
--
-- The following grants all privileges necessary for
-- the user dms_user to use DMS to migrate
-- tables and data from the dms_sample schema
--
---------------------------------------------------------
grant SELECT ANY TRANSACTION to dms_user;
grant select on sys.V_$ARCHIVED_LOG to dms_user;
grant select on sys.V_$LOG to dms_user;
grant select on sys.V_$LOGFILE to dms_user;
grant select on sys.V_$DATABASE to dms_user;
grant select on sys.V_$THREAD to dms_user;
grant select on sys.V_$PARAMETER to dms_user;
grant select on sys.V_$NLS_PARAMETERS to dms_user;
grant select on sys.V_$TIMEZONE_NAMES to dms_user;
grant select on sys.V_$TRANSACTION to dms_user;
grant select on sys.DBA_OBJECTS to dms_user;
grant select on sys.DBA_REGISTRY to dms_user;
grant select on sys.OBJ$ to dms_user;
grant select on sys.DBA_TABLESPACES to dms_user;
grant select on sys.ALL_ENCRYPTED_COLUMNS to dms_user;
grant select on sys.DBMS_LOGMNR to dms_user;
grant select on sys.V_$LOGMNR_LOGS to dms_user;
grant execute on sys.DBMS_LOGMNR to dms_user;

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

grant SELECT on ALL_TAB_PARTITIONS to dms_user;
grant SELECT on ALL_VIEWS  to dms_user;

grant logmining to dms_user;

-- for use with SCT
grant SELECT ANY DICTIONARY to dms_user


