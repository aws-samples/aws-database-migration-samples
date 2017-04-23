CREATE OR REPLACE FUNCTION dms_sample.generatesporttickets(IN par_p_sport VARCHAR, OUT p_refcur refcursor)
AS
$BODY$
DECLARE
    var_v_event_id BIGINT;
    var_all_done varchar(10) DEFAULT FALSE;
    event_cur2 CURSOR FOR
    SELECT
        id
        FROM dms_sample.sporting_event
        WHERE LOWER(sport_type_name) = LOWER(par_p_sport);
BEGIN
    OPEN p_refcur FOR
    SELECT
        par_p_sport;
    OPEN event_cur2;

    <<event_loop>>
    LOOP
        FETCH event_cur2 INTO var_v_event_id;

        IF NOT FOUND THEN
            CLOSE event_cur2;
            EXIT event_loop;
        END IF;
        
      WITH event_list AS (
        SELECT
          id AS var_v_e_id,
          location_id AS var_v_loc_id
        FROM dms_sample.sporting_event
        WHERE id = var_v_event_id
      ),
      constants AS (
        SELECT 
          ROUND(((RANDOM() * (50::NUMERIC - 30::NUMERIC)) + 30::NUMERIC)::NUMERIC, (2)::INT)::NUMERIC(6, 2)
            AS var_v_standard_price
      )
        INSERT INTO dms_sample.sporting_event_ticket (
          sporting_event_id, 
          sport_location_id, 
          seat_level, 
          seat_section, 
          seat_row, 
          seat, 
          ticket_price
        )
        SELECT
          sporting_event.id, 
          seat.sport_location_id, 
          seat.seat_level, 
          seat.seat_section, 
          seat.seat_row, 
          seat.seat, 
          (CASE
            WHEN LOWER(seat.seat_type) = LOWER('luxury'::VARCHAR(15))
              THEN 3::NUMERIC * var_v_standard_price::NUMERIC
            WHEN LOWER(seat.seat_type) = LOWER('premium'::VARCHAR(15))
              THEN 2::NUMERIC * var_v_standard_price::NUMERIC
            WHEN LOWER(seat.seat_type) = LOWER('standard'::VARCHAR(15))
              THEN var_v_standard_price
            WHEN LOWER(seat.seat_type) = LOWER('sub-standard'::VARCHAR(15))
              THEN 0.8::NUMERIC * var_v_standard_price::NUMERIC
            WHEN LOWER(seat.seat_type) = LOWER('obstructed'::VARCHAR(15))
              THEN 0.5::NUMERIC * var_v_standard_price::NUMERIC
            WHEN LOWER(seat.seat_type) = LOWER('standing'::VARCHAR(15))
              THEN 0.5::NUMERIC * var_v_standard_price::NUMERIC
        END) AS ticket_price
        FROM constants, event_list, dms_sample.sporting_event, dms_sample.seat
        WHERE sporting_event.location_id = seat.sport_location_id
          AND sporting_event.id = var_v_e_id;
              
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
