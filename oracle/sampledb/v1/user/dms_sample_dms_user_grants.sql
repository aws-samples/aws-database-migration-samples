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


DECLARE
  CURSOR tabcur IS
  SELECT  table_name
  FROM   user_tables;
BEGIN
  FOR trec IN tabcur LOOP
   EXECUTE IMMEDIATE 'grant select on dms_sample.' || trec.table_name || ' to DMS_USER';
   EXECUTE IMMEDIATE 'grant alter on dms_sample.'  || trec.table_name || ' to DMS_USER';

  END LOOP;
END;
/



/*grant execute on ticketManagement to dms_user;
create or replace public synonym ticketmanagement for dms_sample.ticketmanagement;
*/

create or replace  public synonym ticket_management for dms_sample.ticketManagement;
grant execute on ticket_management to dms_user;

