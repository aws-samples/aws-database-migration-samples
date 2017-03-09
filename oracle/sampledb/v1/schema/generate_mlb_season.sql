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

delete from sporting_event where sport_type_name = 'baseball';

DECLARE
  sport_type_name sport_type.name%TYPE;
  event_date DATE;
 
  date_offset NUMBER := 0; 

  CURSOR team1 IS
  SELECT id, home_field_id from sport_team
  WHERE sport_league_short_name = 'MLB'
  AND   sport_type_name = 'baseball'
  order by id;

  CURSOR team2(IN_ID IN NUMBER) IS
  SELECT id, home_field_id from sport_team
  WHERE ID > IN_ID
  AND   sport_league_short_name = 'MLB'
  AND   sport_type_name = 'baseball'
  ORDER BY ID;

  CURSOR team3(IN_ID IN NUMBER) IS
  SELECT id, home_field_id from sport_team
  WHERE ID < IN_ID
  AND   sport_league_short_name = 'MLB'
  AND   sport_type_name = 'baseball'
  ORDER BY ID;

BEGIN
  select name into sport_type_name from sport_type where LOWER(name) = 'baseball';

  --- every team plays every other team twice, each has home field advantage once

  FOR hrec IN team1 LOOP
    event_date := NEXT_DAY(TO_DATE('31-MAR-' || TO_CHAR(SYSDATE,'YYYY'),'DD-MON-YYYY'),'saturday') + 7*date_offset;
    FOR arec IN team2(hrec.id) LOOP
      event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
      INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
      VALUES(sport_type_name, hrec.id, arec.id, hrec.home_field_id, event_date);

      event_date := TRUNC(event_date) +7;
    END LOOP;

    event_date := TRUNC(NEXT_DAY(EVENT_DATE,'wednesday'));

    FOR h2_rec in team3(hrec.id) LOOP
      event_date := (event_date - 7) + TRUNC(dbms_random.value(12,19))/24;
      INSERT INTO sporting_event(sport_Type_name, home_team_id, away_team_id, location_id, start_date_time)
      VALUES(sport_type_name, hrec.id, h2_rec.id, hrec.home_field_id, event_date);
    END LOOP;

    date_offset := date_offset +1;
  END LOOP;
END;
/

