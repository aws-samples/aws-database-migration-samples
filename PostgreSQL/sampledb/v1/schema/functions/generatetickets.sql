CREATE OR REPLACE FUNCTION dms_sample.generatetickets(IN par_p_event_id BIGINT)
RETURNS void
AS
$BODY$
DECLARE
    var_v_e_id BIGINT;
    var_v_loc_id INTEGER;
    var_v_standard_price NUMERIC(6, 2);
    var_all_done VARCHAR(10) DEFAULT FALSE;
    event_cur CURSOR FOR
    SELECT
        id, location_id
        FROM dms_sample.sporting_event
        WHERE id = par_p_event_id;
BEGIN
    var_v_standard_price := ROUND(((RANDOM() * (50::NUMERIC - 30::NUMERIC)) + 30::NUMERIC)::NUMERIC, (2)::INT)::NUMERIC(6, 2);
    OPEN event_cur;

    <<ticket_loop>>
    LOOP
        FETCH event_cur INTO var_v_e_id, var_v_loc_id;

        IF NOT FOUND THEN
            CLOSE event_cur;
            EXIT ticket_loop;
        END IF;
        INSERT INTO dms_sample.sporting_event_ticket (sporting_event_id, sport_location_id, seat_level, seat_section, seat_row, seat, ticket_price)
        SELECT
            sporting_event.id, seat.sport_location_id, seat.seat_level, seat.seat_section, seat.seat_row, seat.seat, (CASE
                WHEN LOWER(seat.seat_type) = LOWER('luxury'::VARCHAR(15)) THEN 3::NUMERIC * var_v_standard_price::NUMERIC
                WHEN LOWER(seat.seat_type) = LOWER('premium'::VARCHAR(15)) THEN 2::NUMERIC * var_v_standard_price::NUMERIC
                WHEN LOWER(seat.seat_type) = LOWER('standard'::VARCHAR(15)) THEN var_v_standard_price
                WHEN LOWER(seat.seat_type) = LOWER('sub-standard'::VARCHAR(15)) THEN 0.8::NUMERIC * var_v_standard_price::NUMERIC
                WHEN LOWER(seat.seat_type) = LOWER('obstructed'::VARCHAR(15)) THEN 0.5::NUMERIC * var_v_standard_price::NUMERIC
                WHEN LOWER(seat.seat_type) = LOWER('standing'::VARCHAR(15)) THEN 0.5::NUMERIC * var_v_standard_price::NUMERIC
            END) AS ticket_price
            FROM dms_sample.sporting_event, dms_sample.seat
            WHERE sporting_event.location_id = seat.sport_location_id AND sporting_event.id = var_v_e_id;
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
