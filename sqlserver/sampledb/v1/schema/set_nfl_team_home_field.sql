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
