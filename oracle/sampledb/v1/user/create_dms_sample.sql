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


--------------------------------------------------------
--
-- Create the user dms_sample 
--
--------------------------------------------------------
create user dms_sample identified by dms_sample;
grant CREATE SESSION to dms_sample;
grant resource to dms_sample;
grant create table to dms_sample;
grant create sequence to dms_sample;
grant create procedure to dms_sample;
grant create trigger to dms_sample;
grant create view to dms_sample;
grant create synonym to dms_sample;
grant create public synonym to dms_sample;
grant drop public synonym to dms_sample;
grant execute on dbms_lock to dms_sample;

alter user dms_sample default tablespace users;
alter user dms_sample quota unlimited on users;

alter user dms_sample temporary tablespace temp;

--------------------------------------------------------
--
-- required for the schema conversion tool
--
--------------------------------------------------------
grant select_catalog_role to dms_sample;
grant select any dictionary to dms_sample;
