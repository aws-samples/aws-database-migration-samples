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
-- The following creates a user dms_user to which 
-- we will grant all privileges necessary to use DMS to migrate
-- tables and data from the dms_sample schema
--
---------------------------------------------------------

create user dms_user identified by dms_user;

grant CREATE SESSION to dms_user;
grant connect to dms_user;
