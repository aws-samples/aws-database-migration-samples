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
BEGIN
  DECLARE @date_offset INT;
  SET @date_offset = 0;

  DECLARE @team1 CURSOR;
  DECLARE @t1_id INT;
  DECLARE @t1_home_id INT;

  SET @team1 = CURSOR FOR
  SELECT id, home_field_id from sport_team
  WHERE sport_league_short_name = 'MLB'
  AND   sport_type_name = 'baseball'
  order by id;

  BEGIN
   --- every team plays every other team twice, each has home field advantage once
   OPEN @team1;
   FETCH NEXT 
   FROM @team1 INTO @t1_id, @t1_home_id;

   WHILE @@FETCH_STATUS = 0
   BEGIN
	 DECLARE @team2 CURSOR;
	 DECLARE @t2_id INT;
     DECLARE @t2_home_id INT;

	 SET @team2 = CURSOR FOR
	 SELECT id, home_field_id from sport_team
     WHERE ID > @t1_id
     AND   sport_league_short_name = 'MLB'
     AND   sport_type_name = 'baseball'
     ORDER BY ID;

     --- start on the closest saturday to mar 31 of the current year
     DECLARE @event_date DATETIME;
     DECLARE @day_increment INT;
     SET @day_increment = 6 - DATEPART(WEEKDAY,CAST(CONCAT('31-MAR',YEAR(GETDATE())) AS DATETIME));
     SET @event_date =  CAST(CONCAT('31-MAR',YEAR(GETDATE())) AS DATETIME) + @day_increment + 7*@date_offset;

	 OPEN @team2;
	 FETCH NEXT
	 FROM @team2 INTO @t2_id, @t2_home_id;

	 WHILE @@FETCH_STATUS = 0
	 BEGIN
      INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
      VALUES('baseball', @t1_id, @t2_id, @t1_home_id,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date) );
	  
	   SET @event_date = @event_date + 7;

	   FETCH NEXT
	   FROM @team2 INTO @t2_id, @t2_home_id;
	 END;
	 CLOSE @team2;
	 DEALLOCATE @team2;

  	 DECLARE @team3 CURSOR;
	 DECLARE @t3_id INT;
     DECLARE @t3_home_id INT;

	 SET @team3 = CURSOR FOR
     SELECT id, home_field_id from sport_team
     WHERE ID < @t1_id
     AND   sport_league_short_name = 'MLB'
     AND   sport_type_name = 'baseball'
     ORDER BY ID;

	 OPEN @team3;
	 FETCH NEXT
	 FROM @team3 INTO @t3_id, @t3_home_id;

	 WHILE @@FETCH_STATUS = 0
	 BEGIN
       SET @event_date =  @event_date - 7;
       INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
       VALUES('baseball', @t1_id, @t3_id, @t1_home_id,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date) );

	   FETCH NEXT
	   FROM @team3 INTO @t3_id, @t3_home_id;
	 END;
	 CLOSE @team3;
	 DEALLOCATE @team3;


     FETCH NEXT 
     FROM @team1 INTO @t1_id, @t1_home_id;
	 SET @date_offset = @date_offset +1;
   END;

   CLOSE @team1;
   DEALLOCATE @team1;

  END;
END;

