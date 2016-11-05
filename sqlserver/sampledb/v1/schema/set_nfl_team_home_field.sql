
BEGIN
  DECLARE @nsd_cur CURSOR;
  SET @nsd_cur = CURSOR FOR SELECT sport_location_id, team, location FROM nfl_stadium_data;
  DECLARE @sport_location_id INT;
  DECLARE @team VARCHAR(40);
  DECLARE @loc VARCHAR(40);

  OPEN @nsd_cur;
  FETCH NEXT FROM @nsd_cur INTO @sport_location_id, @team, @loc;

  WHILE @@FETCH_STATUS = 0 
  BEGIN
    UPDATE s
	SET s.home_field_id = @sport_location_id
	FROM sport_team s
	WHERE s.name = @team
	AND   s.sport_league_short_name = 'NFL'
	AND   s.sport_type_name = 'football';

	FETCH NEXT FROM @nsd_cur INTO @sport_location_id, @team, @loc;
  END;
  CLOSE @nsd_cur;
  DEALLOCATE @nsd_cur;
END;
