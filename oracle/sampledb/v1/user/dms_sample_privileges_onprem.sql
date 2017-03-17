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
grant select on sys.V_$ARCHIVED_LOG to dms_sample;
grant select on sys.V_$LOG to dms_sample;
grant select on sys.V_$LOGFILE to dms_sample;
grant select on sys.V_$DATABASE to dms_sample;
grant select on sys.V_$THREAD to dms_sample;
grant select on sys.V_$PARAMETER to dms_sample;
grant select on sys.V_$NLS_PARAMETERS to dms_sample;
grant select on sys.V_$TIMEZONE_NAMES to dms_sample;
grant select on sys.V_$TRANSACTION to dms_sample;
grant select on sys.DBA_OBJECTS to dms_sample;
grant select on sys.DBA_REGISTRY to dms_sample;
grant select on sys.OBJ$ to dms_sample;
grant select on sys.DBA_TABLESPACES to dms_sample;
grant select on sys.ALL_ENCRYPTED_COLUMNS to dms_sample;
grant select on sys.DBMS_LOGMNR to dms_sample;
grant select on sys.V_$LOGMNR_LOGS to dms_sample;
grant execute on sys.DBMS_LOGMNR to dms_sample;
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

grant SELECT on ALL_TAB_PARTITIONS to dms_sample;
grant SELECT on ALL_VIEWS  to dms_sample;

grant logmining to dms_sample;





