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


BEGIN
-- Each team plays each team in their own division twice

 DECLARE @date_offset INT;
 SET @date_offset = 0;
 DECLARE @event_date DATETIME;
 DECLARE @sport_division_short_name VARCHAR(10);
 DECLARE @day_increment INT;

 DECLARE @div_cur CURSOR;
 SET @div_cur = CURSOR FOR 
  SELECT distinct sport_division_short_name 
  FROM   sport_team
  WHERE  sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL';

  OPEN @div_cur;
  FETCH NEXT 
  FROM @div_cur INTO @sport_division_short_name;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @date_offset = 0;

	DECLARE @team1 CURSOR;
	DECLARE @team1_id INT;
	DECLARE @team1_home_field_id INT;

	SET @team1 = CURSOR FAST_FORWARD FOR
	SELECT id, home_field_id FROM sport_team
	WHERE sport_division_short_name = @sport_division_short_name
	AND   sport_type_name = 'football'
	AND   sport_league_short_name = 'NFL'
	order by id;

	OPEN @team1;
	FETCH NEXT FROM @team1 INTO @team1_id, @team1_home_field_id;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  DECLARE @team2 CURSOR;
      DECLARE @team2_id INT;
	  DECLARE @team2_home_field_id INT;
	  
	  SET @team2 = CURSOR FAST_FORWARD FOR
	  SELECT id, home_field_id FROM sport_team
	  WHERE ID > @team1_id
	  AND sport_division_short_name = @sport_division_short_name
	  AND sport_type_name = 'football'
	  AND sport_league_short_name = 'NFL'
	  ORDER BY id;

	  DECLARE @team3 CURSOR;
	  DECLARE @team3_id INT;
	  DECLARE @team3_home_field_id INT;

	  SET @team3 = CURSOR FAST_FORWARD FOR
	  SELECT id, home_field_id FROM sport_team
	  WHERE id < @team1_id
	  AND sport_division_short_name = @sport_division_short_name
	  AND sport_Type_name = 'football'
	  AND sport_league_short_name = 'NFL'
	  ORDER BY id;

	  SET @day_increment = DATEPART(WEEKDAY,CAST(CONCAT('01-SEP',YEAR(GETDATE())) AS DATETIME))-1;
	  SET @event_date = CAST(CONCAT('01-SEP',YEAR(GETDATE())) AS DATETIME) - @day_increment + 7*@date_offset;

	  OPEN @team2;
      FETCH NEXT FROM @team2 INTO @team2_id, @team2_home_field_id;

	  WHILE @@FETCH_STATUS = 0
	  BEGIN
	    INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES('football', @team1_id, @team2_id, @team1_home_field_id,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date) );

	    -- PRINT CONCAT(DATEPART(WEEKDAY,@event_date), ' ', @event_date, ' ',@sport_division_short_name,' ',@date_offset,' t1: ', @team1_id, ' t1h: ', @team1_home_field_id,' t2: ', @team2_id, ' t2h: ', @team2_home_field_id);
	    FETCH NEXT FROM @team2 INTO @team2_id, @team2_home_field_id;
		set @event_date = @event_date +7;
	  END;
	  CLOSE @team2;

	  OPEN @team3;
	  FETCH NEXT FROM @team3 INTO @team3_id, @team3_home_field_id;
	  set @event_date = @event_date +7;

	  WHILE @@FETCH_STATUS = 0
	  BEGIN
	    INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES('football', @team1_id, @team3_id, @team1_home_field_id,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date) );

	    -- PRINT CONCAT(DATEPART(WEEKDAY,@event_date), ' ', @event_date, ' ',@sport_division_short_name,' ',@date_offset,' t1: ', @team1_id, ' t1h: ', @team1_home_field_id,' t3: ', @team3_id, ' t3h: ', @team3_home_field_id);
	    FETCH NEXT FROM @team3 INTO @team3_id, @team3_home_field_id;
	    set @event_date = @event_date +7;
	  END;
	  CLOSE @team3;
	  FETCH NEXT FROM @team1 INTO @team1_id, @team1_home_field_id;

      SET @date_offset = @date_offset +1;
	END;
	CLOSE @team1;

	FETCH NEXT
	FROM @div_cur INTO @sport_division_short_name;
  END;
  CLOSE @div_cur;

  -- Each team plays each team in another division once 

  -- load division tables, note there are 4 teams per division so use the counter for indexing
  DECLARE @date_tab TABLE( id INT NOT NULL PRIMARY KEY CLUSTERED, dt datetime);

  SET @event_date = @event_date + 7;
  insert into @date_tab values(1,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(6,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(11,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(16,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(2,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(7,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(12,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(13,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(3,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(8,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(9,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(14,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(4,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(5,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(10,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(15,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  DECLARE @nfc_tab TABLE(id INT, conf VARCHAR(10));
  INSERT INTO @nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

  DECLARE @afc_tab TABLE(id INT, conf VARCHAR(10));
  INSERT INTO @afc_tab VALUES (1,'AFC North'), (2,'AFC East'), (3,'AFC South'), (4,'AFC West');

  DECLARE @i INT = 1;
  DECLARE @nfc_conf VARCHAR(10);
  DECLARE @afc_conf VARCHAR(10);

   WHILE @i <= 4 
   BEGIN
     SELECT @nfc_conf = conf FROM @nfc_tab WHERE id = @i;
	 SELECT @afc_conf = conf FROM @afc_tab WHERE id = @i; 

     DECLARE @rownum INT = 1;
     DECLARE @t2_id INT;
	 DECLARE @t2_field_id INT;
	 DECLARE @t1_id INT;
	 DECLARE @t1_field_id INT;
	 DECLARE @dt DATETIME;

     DECLARE @cross_div_cur CURSOR;
	 SET @cross_div_cur = CURSOR FOR 
	     SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
		 FROM sport_team a, sport_team b
		 WHERE a.sport_division_short_name = @afc_conf
		 AND   b.sport_division_short_name = @nfc_conf
		 ORDER BY a.name, b.name;

	 OPEN @cross_div_cur;
	 FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;

	 WHILE @@FETCH_STATUS = 0
	 BEGIN
	   SELECT @dt = dt FROM @date_tab WHERE id = @rownum;
	   IF (@rownum % 2) = 0 
         INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
         VALUES('football', @t2_id, @t1_id, @t2_field_id, @dt);
	   ELSE
		INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES('football', @t1_id, @t2_id, @t1_field_id, @dt);

	   FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;
	   SET @rownum = @rownum+1;
	 END;

     SET @i = @i +1;
   END;

   CLOSE @cross_div_cur;

  DELETE FROM @date_tab;

  SET @event_date = @event_date + 7;
  insert into @date_tab values(1,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(6,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(11,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(16,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(2,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(7,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(12,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(13,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(3,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(8,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(9,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(14,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(4,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(5,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(10,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(15,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  DELETE FROM @nfc_tab;
  INSERT INTO @nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

  DELETE FROM @afc_tab;
  INSERT INTO @afc_tab VALUES (1,'AFC West'), (2,'AFC North'), (3,'AFC East'), (4,'AFC South');

  SET @i = 1;

   WHILE @i <= 4 
   BEGIN
     SELECT @nfc_conf = conf FROM @nfc_tab WHERE id = @i;
	 SELECT @afc_conf = conf FROM @afc_tab WHERE id = @i; 

     SET @rownum = 1;

	 SET @cross_div_cur = CURSOR FOR 
	     SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
		 FROM sport_team a, sport_team b
		 WHERE a.sport_division_short_name = @afc_conf
		 AND   b.sport_division_short_name = @nfc_conf
		 ORDER BY a.name, b.name;

	 OPEN @cross_div_cur;
	 FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;

	 WHILE @@FETCH_STATUS = 0
	 BEGIN
	   SELECT @dt = dt FROM @date_tab WHERE id = @rownum;
	   IF (@rownum % 2) = 0 
         INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
         VALUES('football', @t2_id, @t1_id, @t2_field_id, @dt);
	   ELSE
		INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES('football', @t1_id, @t2_id, @t1_field_id, @dt);

	   FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;
	   SET @rownum = @rownum+1;
	 END;

     SET @i = @i +1;
   END;

  CLOSE @cross_div_cur;

  DELETE FROM @date_tab;

  SET @event_date = @event_date + 7;
  insert into @date_tab values(1,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(6,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(11,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(16,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(2,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(7,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(12,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(13,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(3,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(8,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(9,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(14,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  SET @event_date = @event_date + 7;
  insert into @date_tab values(4,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(5,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(10,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));
  insert into @date_tab values(15,DATEADD(hh,FLOOR(rand()*(19 - 12 +1)) + 12,@event_date));

  DELETE FROM @nfc_tab;
  INSERT INTO @nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

  DELETE FROM @afc_tab;
  INSERT INTO @afc_tab VALUES (1,'AFC South'), (2,'AFC West'), (3,'AFC North'), (4,'AFC East');

  SET @i = 1;

   WHILE @i <= 4 
   BEGIN
     SELECT @nfc_conf = conf FROM @nfc_tab WHERE id = @i;
	 SELECT @afc_conf = conf FROM @afc_tab WHERE id = @i; 

     SET @rownum = 1;

	 SET @cross_div_cur = CURSOR FOR 
	     SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
		 FROM sport_team a, sport_team b
		 WHERE a.sport_division_short_name = @afc_conf
		 AND   b.sport_division_short_name = @nfc_conf
		 ORDER BY a.name, b.name;

	 OPEN @cross_div_cur;
	 FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;

	 WHILE @@FETCH_STATUS = 0
	 BEGIN
	   SELECT @dt = dt FROM @date_tab WHERE id = @rownum;
	   IF (@rownum % 2) = 0 
         INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
         VALUES('football', @t2_id, @t1_id, @t2_field_id, @dt);
	   ELSE
		INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time)
        VALUES('football', @t1_id, @t2_id, @t1_field_id, @dt);

	   FETCH NEXT FROM @cross_div_cur INTO @t2_id, @t2_field_id, @t1_id, @t1_field_id;
	   SET @rownum = @rownum+1;
	 END;

     SET @i = @i +1;
   END;

END;
