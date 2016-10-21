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

