CREATE OR REPLACE FUNCTION dms_sample.selltickets(IN par_p_person_id INTEGER, IN par_p_event_id INTEGER, IN par_p_quantity INTEGER)
RETURNS VOID
AS
$BODY$
DECLARE
    var_v_ticket_id BIGINT;
    var_v_seat_level VARCHAR(50);
    var_v_seat_section VARCHAR(15);
    var_v_seat_row VARCHAR(10);
    var_v_tickets_sold INTEGER DEFAULT 0;
    var_v_time_of_sale TIMESTAMP WITHOUT TIME ZONE;
    var_all_done VARCHAR(50) DEFAULT FALSE;
    t_cur CURSOR FOR
    SELECT
        id, seat_level, seat_section, seat_row
        FROM dms_sample.sporting_event_ticket
        WHERE sporting_event_id = par_p_event_id
        ORDER BY seat_level NULLS FIRST, LOWER(seat_section) NULLS FIRST, LOWER(seat_row) NULLS FIRST;
BEGIN
    var_v_time_of_sale := (clock_timestamp()::TIMESTAMP)::TIMESTAMP WITHOUT TIME ZONE;
    OPEN t_cur;

    <<tik_loop>>
    LOOP
        FETCH t_cur INTO var_v_ticket_id, var_v_seat_level, var_v_seat_section, var_v_seat_row;
        UPDATE dms_sample.sporting_event_ticket
        SET ticketholder_id = par_p_person_id
            WHERE id = var_v_ticket_id;
        INSERT INTO dms_sample.ticket_purchase_hist (sporting_event_ticket_id, purchased_by_id, transaction_date_time, purchase_price)
        SELECT
            id, ticketholder_id, var_v_time_of_sale, ticket_price
            FROM dms_sample.sporting_event_ticket
            WHERE id = var_v_ticket_id;
        var_v_tickets_sold := (var_v_tickets_sold::NUMERIC + 1::NUMERIC)::SMALLINT;

        IF var_v_tickets_sold = par_p_quantity THEN
            CLOSE t_cur;
            
            EXIT tik_loop;
        END IF;
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
