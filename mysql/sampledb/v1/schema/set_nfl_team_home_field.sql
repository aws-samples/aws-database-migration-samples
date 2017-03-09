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
# create procedure to set nfl team home field
#######################
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

