#
#  Copyright 2017 Amazon.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


#######################
# create procedure to generate the MLB season
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS generateMLBSeason $$

CREATE PROCEDURE generateMLBSeason()
BEGIN
  DECLARE v_date_offset INT DEFAULT 0;

  DECLARE v_t1_id INT;
  DECLARE v_t1_home_id INT;
  DECLARE v_event_date DATETIME;
  DECLARE v_day_increment INT;

  DECLARE t1_done INT DEFAULT FALSE;


  DECLARE team1  CURSOR FOR
  SELECT id, home_field_id from sport_team
  WHERE sport_league_short_name = 'MLB'
  AND   sport_type_name = 'baseball'
  order by id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET t1_done = TRUE;

   /* every team plays every other team twice, each has home field advantage once */

   OPEN team1;
   team1_loop: LOOP
     FETCH NEXT  FROM team1 INTO v_t1_id, v_t1_home_id;

     IF t1_done THEN
       CLOSE team1;
       LEAVE team1_loop;
     END IF;

     /* start on the closest saturday to mar 31 of the current year */
     SET v_day_increment = 7 - DAYOFWEEK(STR_TO_DATE(concat('31,3,',DATE_FORMAT(NOW(),'%Y')),'%d,%m,%Y'));
     SET v_event_date = DATE_ADD(STR_TO_DATE(concat('31,3,',DATE_FORMAT(NOW(),'%Y')),'%d,%m,%Y'), INTERVAL v_day_increment + 7*v_date_offset DAY);

     BLOCK2: BEGIN
       DECLARE v_t2_id INT;
       DECLARE v_t2_home_id INT;
       DECLARE t2_done INT DEFAULT FALSE;


       DECLARE team2 CURSOR FOR
       SELECT id, home_field_id from sport_team
       WHERE ID > v_t1_id
       AND   sport_league_short_name = 'MLB'
       AND   sport_type_name = 'baseball'
       ORDER BY ID;
       DECLARE CONTINUE HANDLER FOR NOT FOUND SET t2_done = TRUE;

       OPEN team2;
       team2_loop: LOOP
         FETCH NEXT  FROM team2 INTO v_t2_id, v_t2_home_id;

         IF t2_done THEN
           CLOSE team2;
           LEAVE team2_loop;
         END IF;

         INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date, start_date_time)
         VALUES('baseball', v_t1_id, v_t2_id, v_t1_home_id,v_event_date, DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR) );
	  
         SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
       END LOOP;
     END BLOCK2;

     BLOCK3: BEGIN
       DECLARE v_t3_id INT;
       DECLARE v_t3_home_id INT;
       DECLARE t3_done INT DEFAULT FALSE;

       DECLARE team3 CURSOR FOR
       SELECT id, home_field_id from sport_team
       WHERE ID < v_t1_id
       AND   sport_league_short_name = 'MLB'
       AND   sport_type_name = 'baseball'
       ORDER BY ID;
       DECLARE CONTINUE HANDLER FOR NOT FOUND SET t3_done = TRUE;

       OPEN team3;
       team3_loop: LOOP
         FETCH NEXT  FROM team3 INTO v_t3_id, v_t3_home_id;

         IF t3_done THEN
           CLOSE team3;
           LEAVE team3_loop;
         END IF;

         SET v_event_date =  DATE_ADD(v_event_date, INTERVAL 7 DAY);

         INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id, start_date, start_date_time)
         VALUES('baseball', v_t1_id, v_t3_id, v_t1_home_id, v_event_date, DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR) );
       END LOOP;
     END BLOCK3;

  END LOOP;
END;

$$

DELIMITER ;
