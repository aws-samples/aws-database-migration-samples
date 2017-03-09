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

delete from sporting_event where sport_type_name = 'football';

DECLARE
  sport_type_name sport_type.name%TYPE;
  event_date DATE;
 
  date_offset NUMBER := 0; 

  CURSOR div_cur IS 
  SELECT distinct sport_division_short_name 
  FROM   sport_team
  WHERE  sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL';

  CURSOR team1(p_division IN VARCHAR2) IS
  SELECT id, home_field_id from sport_team
  WHERE  sport_division_short_name = p_division
  AND    sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL'
  order by id;

  CURSOR team2(p_division IN VARCHAR2, IN_ID IN NUMBER) IS
  SELECT id, home_field_id from sport_team
  where  ID > IN_ID
  AND    sport_division_short_name = p_division
  AND    sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL'
  order by id;

  CURSOR team3(p_division IN VARCHAR2, IN_ID IN NUMBER) IS
  SELECT id, home_field_id from sport_team
  WHERE ID < IN_ID
  AND    sport_division_short_name = p_division
  AND    sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL'
  order by id;

  TYPE divTab IS table of VARCHAR2(15) INDEX BY BINARY_INTEGER;
  afc_tab divTab;
  nfc_tab divTab;

  TYPE dateTab IS table of DATE INDEX BY BINARY_INTEGER;
  date_tab dateTab;

  CURSOR cross_div_cur(p_t2 IN VARCHAR2, p_t1 IN VARCHAR2) IS 
  select rownum as cur_row, DECODE(mod(rownum,2),0,a.id,1,b.id) as home_id
        , a.id as t2_id, a.home_field_id as t2_field_id
        , b.id as t1_id, b.home_field_id as t1_field_id
  from sport_team a, sport_team b
  where a.sport_division_short_name = p_t2
  and b.sport_division_short_name = p_t1
  order by a.name,b.name;

 
BEGIN
  select name into sport_type_name from sport_type where LOWER(name) = 'football';

  -- Each team plays each team in their own division twice
  FOR drec IN div_cur LOOP
    date_offset := 0;
    FOR hrec IN team1(drec.sport_division_short_name) LOOP
      event_date := NEXT_DAY(TO_DATE('01-SEP-' || TO_CHAR(sysdate,'YYYY'),'DD-MON-YYYY'),'sunday') + 7*date_offset;
      FOR arec IN team2(drec.sport_division_short_name,hrec.id) LOOP
        event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, hrec.id, arec.id, hrec.home_field_id, event_date);

        event_date := TRUNC(event_date) +7;
      END LOOP;

      event_date := TRUNC(NEXT_DAY(EVENT_DATE,'sunday'));

      FOR h2_rec in team3(drec.sport_division_short_name,hrec.id) LOOP
        event_date := (event_date - 7) + TRUNC(dbms_random.value(12,19))/24;
        INSERT INTO sporting_event(sport_Type_name, home_team_id, away_team_id, location_id, start_date_time)
        VALUES(sport_type_name, hrec.id, h2_rec.id, hrec.home_field_id, event_date);
      END LOOP;

      date_offset := date_offset +1;
    END LOOP;
  END LOOP;

  -- Each team plays each team in another division once 

  -- load division tables, note there are 4 teams per division so use the counter for indexing
  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(1) := event_date;
  date_tab(6) := event_date;
  date_tab(11) := event_date;
  date_tab(16) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(2) := event_date;
  date_tab(7) := event_date;
  date_tab(12) := event_date;
  date_tab(13) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(3) := event_date;
  date_tab(8) := event_date;
  date_tab(9) := event_date;
  date_tab(14) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(4) := event_date;
  date_tab(5) := event_date;
  date_tab(10) := event_date;
  date_tab(15) := event_date;

  nfc_tab(1) := 'NFC North';
  nfc_tab(2) := 'NFC East';
  nfc_tab(3) := 'NFC South';
  nfc_tab(4) := 'NFC West';
  afc_tab(1) := 'AFC North';
  afc_tab(2) := 'AFC East';
  afc_tab(3) := 'AFC South';
  afc_tab(4) := 'AFC West';
  FOR i IN 1..4 LOOP
    FOR trec IN cross_div_cur(nfc_tab(i),afc_tab(i)) LOOP
      IF trec.home_id = trec.t2_id THEN 
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t2_id, trec.t1_id, trec.t2_field_id, date_tab(trec.cur_row));
      ELSE
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t1_id, trec.t2_id, trec.t1_field_id, date_tab(trec.cur_row));
      END IF;
    END LOOP;
  END LOOP;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(1) := event_date;
  date_tab(6) := event_date;
  date_tab(11) := event_date;
  date_tab(16) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(2) := event_date;
  date_tab(7) := event_date;
  date_tab(12) := event_date;
  date_tab(13) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(3) := event_date;
  date_tab(8) := event_date;
  date_tab(9) := event_date;
  date_tab(14) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(4) := event_date;
  date_tab(5) := event_date;
  date_tab(10) := event_date;
  date_tab(15) := event_date;

  nfc_tab(1) := 'NFC North';
  nfc_tab(2) := 'NFC East';
  nfc_tab(3) := 'NFC South';
  nfc_tab(4) := 'NFC West';
  afc_tab(1) := 'AFC West';
  afc_tab(2) := 'AFC North';
  afc_tab(3) := 'AFC East';
  afc_tab(4) := 'AFC South';
  FOR i IN 1..4 LOOP
    FOR trec IN cross_div_cur(nfc_tab(i),afc_tab(i)) LOOP
      IF trec.home_id = trec.t2_id THEN 
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t2_id, trec.t1_id, trec.t2_field_id, date_tab(trec.cur_row));
      ELSE
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t1_id, trec.t2_id, trec.t1_field_id, date_tab(trec.cur_row));
      END IF;
    END LOOP;
  END LOOP;

-- Play three more random games
  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(1) := event_date;
  date_tab(6) := event_date;
  date_tab(11) := event_date;
  date_tab(16) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(2) := event_date;
  date_tab(7) := event_date;
  date_tab(12) := event_date;
  date_tab(13) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(3) := event_date;
  date_tab(8) := event_date;
  date_tab(9) := event_date;
  date_tab(14) := event_date;

  event_date := TRUNC(EVENT_DATE)+7;
  event_date := event_date + TRUNC(dbms_random.value(12,19))/24;
  date_tab(4) := event_date;
  date_tab(5) := event_date;
  date_tab(10) := event_date;
  date_tab(15) := event_date;

  nfc_tab(1) := 'NFC North';
  nfc_tab(2) := 'NFC East';
  nfc_tab(3) := 'NFC South';
  nfc_tab(4) := 'NFC West';
  afc_tab(1) := 'AFC South';
  afc_tab(2) := 'AFC West';
  afc_tab(3) := 'AFC North';
  afc_tab(4) := 'AFC East';
  FOR i IN 1..3 LOOP
    FOR trec IN cross_div_cur(nfc_tab(i),afc_tab(i)) LOOP
      IF trec.home_id = trec.t2_id THEN 
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t2_id, trec.t1_id, trec.t2_field_id, date_tab(trec.cur_row));
      ELSE
        INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES(sport_type_name, trec.t1_id, trec.t2_id, trec.t1_field_id, date_tab(trec.cur_row));
      END IF;
    END LOOP;
  END LOOP;
END;
/

