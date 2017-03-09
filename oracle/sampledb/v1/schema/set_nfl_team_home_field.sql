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

--- Must be run after teams are created and after sporting locations are created

---------------------------------
-- Football Teams
---------------------------------
DECLARE
  CURSOR nsd_cur IS
  SELECT sport_location_id, team 
  FROM   nfl_stadium_data;
BEGIN
  FOR nrec IN nsd_cur LOOP
    UPDATE sport_team s
    SET s.home_field_id = nrec.sport_location_id
    WHERE s.name = nrec.team
    AND   s.sport_league_short_name = 'NFL'
    AND   s.sport_type_name = 'football';
  END LOOP;
END;
/

