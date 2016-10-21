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

