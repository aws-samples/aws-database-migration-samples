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

DROP PROCEDURE IF EXISTS generateNFLSeason $$

CREATE PROCEDURE generateNFLSeason()
BEGIN
 /* Each team plays each team in their own division twice */

 DECLARE v_date_offset INT DEFAULT 0;
 DECLARE v_event_date DATETIME;
 DECLARE v_sport_division_short_name VARCHAR(10);
 DECLARE v_day_increment INT;
 DECLARE div_done INT DEFAULT FALSE;



 DECLARE div_cur CURSOR FOR
  SELECT distinct sport_division_short_name
  FROM   sport_team
  WHERE  sport_type_name = 'football'
  AND    sport_league_short_name = 'NFL';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET div_done = TRUE;

  OPEN div_cur;
  div_loop: LOOP
    FETCH NEXT FROM div_cur INTO v_sport_division_short_name;

    IF div_done THEN
      CLOSE div_cur;
      LEAVE div_loop;
    END IF;

    SET v_date_offset = 0;

    BLOCK1: BEGIN
      DECLARE v_team1_id INT;
      DECLARE v_team1_home_field_id INT;
      DECLARE team1_done INT DEFAULT FALSE;

      DECLARE team1 CURSOR FOR
      SELECT id, home_field_id FROM sport_team
      WHERE sport_division_short_name = v_sport_division_short_name
      AND   sport_type_name = 'football'
      AND   sport_league_short_name = 'NFL'
      order by id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET team1_done = TRUE;

      OPEN team1;
      team1_loop: LOOP
        FETCH NEXT FROM team1 INTO v_team1_id, v_team1_home_field_id;

        IF team1_done THEN
          CLOSE team1;
          LEAVE team1_loop;
        END IF;

        /* start on the closest sunday to sept 1 of the current year */
        SET v_day_increment = 1 - DAYOFWEEK(STR_TO_DATE(concat('01,9,',DATE_FORMAT(NOW(),'%Y')),'%d,%m,%Y'));
        SET v_event_date = DATE_ADD(STR_TO_DATE(concat('01,9,',DATE_FORMAT(NOW(),'%Y')),'%d,%m,%Y'), INTERVAL v_day_increment + 7*v_date_offset DAY);


        BLOCK2: BEGIN
          DECLARE v_team2_id INT;
          DECLARE v_team2_home_field_id INT;
          DECLARE team2_done INT DEFAULT FALSE;

          DECLARE team2 CURSOR FOR
          SELECT id, home_field_id FROM sport_team
          WHERE ID > v_team1_id
          AND sport_division_short_name = v_sport_division_short_name
          AND sport_type_name = 'football'
          AND sport_league_short_name = 'NFL'
          ORDER BY id;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET team2_done = TRUE;
 
          open team2;
          team2_loop: LOOP
            FETCH NEXT FROM team2 INTO v_team2_id, v_team2_home_field_id;

            IF team2_done THEN
              CLOSE team2;
              LEAVE team2_loop;
            END IF;

            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_team1_id, v_team2_id, v_team1_home_field_id, DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR),v_event_date );

            SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);

          END LOOP;
        END BLOCK2;

        BLOCK3: BEGIN
          DECLARE v_team3_id INT;
          DECLARE v_team3_home_field_id INT;
          DECLARE team3_done INT DEFAULT FALSE;

          DECLARE team3 CURSOR FOR
          SELECT id, home_field_id FROM sport_team
          WHERE id < v_team1_id
          AND sport_division_short_name = v_sport_division_short_name
          AND sport_Type_name = 'football'
          AND sport_league_short_name = 'NFL'
          ORDER BY id;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET team3_done = TRUE;

          OPEN team3;
          team3_loop: LOOP
            FETCH NEXT FROM team3 INTO v_team3_id, v_team3_home_field_id;

            IF team3_done THEN
              CLOSE team3;
              LEAVE team3_loop;
            END IF;

            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time, start_date)
            VALUES('football', v_team1_id, v_team3_id, v_team1_home_field_id,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR),v_event_date );

            SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);

          END LOOP;
        END BLOCK3;
        set v_date_offset = v_date_offset + 1; 
      END LOOP;
    END BLOCK1;
  END LOOP;

  /* Each team plays each team in another division once */

  /* load division tables, note there are 4 teams per division so use the counter for indexing */

  drop table if exists v_date_tab;
  create temporary table v_date_tab(id INT PRIMARY KEY, dt DATETIME);

  SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);

  insert into v_date_tab values(1,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(6,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(11,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(16,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

  SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
  insert into v_date_tab values(2,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(7,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(12,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(13,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

  SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
  insert into v_date_tab values(3,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(8,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(9,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(14,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

  SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
  insert into v_date_tab values(4,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(5,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(10,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
  insert into v_date_tab values(15,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

  drop table if exists v_nfc_tab;
  create temporary table v_nfc_tab(id INT, conf VARCHAR(10));
  INSERT INTO v_nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

  drop table if exists v_afc_tab;
  create temporary table v_afc_tab(id INT, conf VARCHAR(10));
  INSERT INTO v_afc_tab VALUES (1,'AFC North'), (2,'AFC East'), (3,'AFC South'), (4,'AFC West');

  CROSS_CONF_BLOCK: BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nfc_conf VARCHAR(10);
    DECLARE v_afc_conf VARCHAR(10);

    WHILE i <= 4 DO
      SELECT conf INTO v_nfc_conf FROM v_nfc_tab WHERE id = i;
      SELECT conf INTO v_afc_conf FROM v_afc_tab WHERE id = 1;

      CC_BLOCK1: BEGIN
        DECLARE v_rownum INT DEFAULT 1;
        DECLARE v_t2_id INT;
        DECLARE v_t2_field_id INT;
        DECLARE v_t1_id INT;
        DECLARE v_t1_field_id INT;
        DECLARE v_dt DATETIME;
        DECLARE cross_div_done INT DEFAULT FALSE;

        DECLARE cross_div_cur CURSOR FOR
        SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
        FROM sport_team a, sport_team b
        WHERE a.sport_division_short_name = v_afc_conf
        AND   b.sport_division_short_name = v_nfc_conf
        ORDER BY a.name, b.name;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET cross_div_done = TRUE;

        OPEN cross_div_cur;
        cross_div_cur_loop: LOOP
          FETCH NEXT FROM cross_div_cur INTO v_t2_id, v_t2_field_id, v_t1_id, v_t1_field_id;

          IF cross_div_done THEN
            CLOSE cross_div_cur;
            LEAVE cross_div_cur_loop;
          END IF;

          SELECT dt INTO v_dt FROM v_date_tab WHERE id = v_rownum;

          IF (v_rownum % 2) = 0 THEN
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t2_id, v_t1_id, v_t2_field_id, v_dt,v_dt);
          ELSE
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t1_id, v_t2_id, v_t1_field_id, v_dt,v_dt);
          END IF;
        END LOOP;
      END CC_BLOCK1;

      SET i = i + 1;
    END WHILE;

    DELETE FROM v_date_tab;

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(1,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(6,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(11,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(16,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(2,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(7,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(12,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(13,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(3,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(8,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(9,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(14,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(4,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(5,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(10,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(15,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    DELETE FROM v_nfc_tab;
    INSERT INTO v_nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

    DELETE FROM v_afc_tab;
    INSERT INTO v_afc_tab VALUES (1,'AFC West'), (2,'AFC North'), (3,'AFC East'), (4,'AFC South');

    SET i = 1;
    WHILE i <= 4 DO
      SELECT conf INTO v_nfc_conf FROM v_nfc_tab WHERE id = i;
      SELECT conf INTO v_afc_conf FROM v_afc_tab WHERE id = 1;

      CC_BLOCK2: BEGIN
        DECLARE v_rownum INT DEFAULT 1;
        DECLARE v_t2_id INT;
        DECLARE v_t2_field_id INT;
        DECLARE v_t1_id INT;
        DECLARE v_t1_field_id INT;
        DECLARE v_dt DATETIME;
        DECLARE cross_div_done INT DEFAULT FALSE;

        DECLARE cross_div_cur CURSOR FOR
        SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
        FROM sport_team a, sport_team b
        WHERE a.sport_division_short_name = v_afc_conf
        AND   b.sport_division_short_name = v_nfc_conf
        ORDER BY a.name, b.name;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET cross_div_done = TRUE;

        OPEN cross_div_cur;
        cross_div_cur_loop: LOOP
          FETCH NEXT FROM cross_div_cur INTO v_t2_id, v_t2_field_id, v_t1_id, v_t1_field_id;

          IF cross_div_done THEN
            CLOSE cross_div_cur;
            LEAVE cross_div_cur_loop;
          END IF;

          SELECT dt INTO v_dt FROM v_date_tab WHERE id = v_rownum;

          IF (v_rownum % 2) = 0 THEN
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t2_id, v_t1_id, v_t2_field_id, v_dt,v_dt);
          ELSE
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t1_id, v_t2_id, v_t1_field_id, v_dt,v_dt);
          END IF;
        END LOOP;
      END CC_BLOCK2;

      SET i = i + 1;
    END WHILE;

    DELETE FROM v_date_tab;
    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(1,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(6,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(11,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(16,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(2,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(7,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(12,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(13,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(3,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(8,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(9,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(14,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    SET v_event_date = DATE_ADD(v_event_date, INTERVAL 7 DAY);
    insert into v_date_tab values(4,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(5,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(10,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));
    insert into v_date_tab values(15,DATE_ADD(v_event_date, INTERVAL FLOOR(rand()*(19 - 12 +1)) + 12 HOUR));

    DELETE FROM v_nfc_tab;
    INSERT INTO v_nfc_tab VALUES (1,'NFC North'), (2,'NFC East'), (3,'NFC South'), (4,'NFC West');

    DELETE FROM v_afc_tab;
    INSERT INTO v_afc_tab VALUES (1,'AFC South'), (2,'AFC West'), (3,'AFC North'), (4,'AFC East');

    SET i = 1;
    WHILE i <= 4 DO
      SELECT conf INTO v_nfc_conf FROM v_nfc_tab WHERE id = i;
      SELECT conf INTO v_afc_conf FROM v_afc_tab WHERE id = 1;

      CC_BLOCK3: BEGIN
        DECLARE v_rownum INT DEFAULT 1;
        DECLARE v_t2_id INT;
        DECLARE v_t2_field_id INT;
        DECLARE v_t1_id INT;
        DECLARE v_t1_field_id INT;
        DECLARE v_dt DATETIME;
        DECLARE cross_div_done INT DEFAULT FALSE;

        DECLARE cross_div_cur CURSOR FOR
        SELECT a.id as t2_id, a.home_field_id as t2_field_id, b.id as t1_id, b.home_field_id as t1_field_id
        FROM sport_team a, sport_team b
        WHERE a.sport_division_short_name = v_afc_conf
        AND   b.sport_division_short_name = v_nfc_conf
        ORDER BY a.name, b.name;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET cross_div_done = TRUE;

        OPEN cross_div_cur;
        cross_div_cur_loop: LOOP
          FETCH NEXT FROM cross_div_cur INTO v_t2_id, v_t2_field_id, v_t1_id, v_t1_field_id;

          IF cross_div_done THEN
            CLOSE cross_div_cur;
            LEAVE cross_div_cur_loop;
          END IF;

          SELECT dt INTO v_dt FROM v_date_tab WHERE id = v_rownum;
          IF (v_rownum % 2) = 0 THEN
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t2_id, v_t1_id, v_t2_field_id, v_dt,v_dt);
          ELSE
            INSERT INTO sporting_event(sport_type_name, home_team_id, away_team_id, location_id,start_date_time,start_date)
            VALUES('football', v_t1_id, v_t2_id, v_t1_field_id, v_dt,v_dt);
          END IF;
        END LOOP;
      END CC_BLOCK3;

      SET i = i + 1;
    END WHILE;


  END CROSS_CONF_BLOCK;
END;
$$
DELIMITER ;

