

-----------------------------------------------
-- create procedure to set nfl team home field
-----------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS setNFLTeamHomeField $$

CREATE PROCEDURE setNFLTeamHomeField()
BEGIN
  DECLARE v_sport_location_id INT;
  DECLARE v_team VARCHAR(40);
  DECLARE v_loc VARCHAR(40);

  DECLARE done INT DEFAULT FALSE;

  DECLARE nsd_cur CURSOR FOR SELECT sport_location_id, team, location FROM nfl_stadium_data;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN nsd_cur;
  read_loop: LOOP
    FETCH NEXT FROM nsd_cur INTO v_sport_location_id, v_team, v_loc;
    IF done THEN
      LEAVE read_loop;
    END IF;

    UPDATE sport_team s
    SET s.home_field_id = v_sport_location_id
    WHERE s.name = v_team
    AND   s.sport_league_short_name = 'NFL'
    AND   s.sport_type_name = 'football';

  END LOOP;

  CLOSE nsd_cur;
END;
$$

DELIMITER ;

