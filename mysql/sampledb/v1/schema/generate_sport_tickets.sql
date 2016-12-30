-----------------------------------------------
-- create procedure to generate MLB tickets
-----------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS generateSportTickets $$

create procedure generateSportTickets(IN p_sport VARCHAR(15) ) 
BEGIN
  DECLARE v_event_id BIGINT;
  DECLARE all_done INT DEFAULT FALSE;

  DECLARE event_cur CURSOR FOR
  SELECT id 
  FROM sporting_event 
  WHERE sport_type_name = p_sport;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET all_done = TRUE;

select p_sport;

  OPEN event_cur;
  event_loop: LOOP
    FETCH event_cur INTO v_event_id;

    IF all_done THEN
      CLOSE event_cur;
      LEAVE event_loop;
    END IF;

    CALL generateTickets(v_event_id);
  END LOOP;

END;
$$
DELIMITER ;

