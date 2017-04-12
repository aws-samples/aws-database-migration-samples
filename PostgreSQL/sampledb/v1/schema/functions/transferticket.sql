CREATE OR REPLACE FUNCTION dms_sample.transferticket(IN par_ticket_id NUMERIC, IN par_new_ticketholder_id NUMERIC, IN par_transfer_all NUMERIC DEFAULT 0, IN par_price NUMERIC DEFAULT NULL)
RETURNS void
AS
$BODY$
DECLARE
    var_last_txn_date TIMESTAMP WITHOUT TIME ZONE;
    var_old_ticketholder_id NUMERIC(10, 0);
    var_sporting_event_ticket_id NUMERIC(20, 0);
    var_purchase_price NUMERIC(10, 4);
    var_xfer_cur refcursor;
BEGIN
    SELECT
        MAX(h.transaction_date_time), t.ticketholder_id
        INTO var_last_txn_date, var_old_ticketholder_id
        FROM dms_sample.ticket_purchase_hist AS h, dms_sample.sporting_event_ticket AS t
        WHERE t.id = par_ticket_id AND h.purchased_by_id = t.ticketholder_id AND ((h.sporting_event_ticket_id = par_ticket_id) OR (par_transfer_all = 1))
        GROUP BY t.ticketholder_id;
    OPEN var_xfer_cur FOR
    SELECT
        sporting_event_ticket_id, purchase_price
        FROM dms_sample.ticket_purchase_hist
        WHERE purchased_by_id = var_old_ticketholder_id AND transaction_date_time = var_last_txn_date;
    FETCH var_xfer_cur INTO var_sporting_event_ticket_id, var_purchase_price;

    WHILE (CASE FOUND::INT
        WHEN 0 THEN - 1
        ELSE 0
    END) = 0 LOOP
        /* update the sporting event ticket with the new owner */
        UPDATE dms_sample.sporting_event_ticket
        SET ticketholder_id = par_new_ticketholder_id
            WHERE id = var_sporting_event_ticket_id
        /* record the transaction */;
        INSERT INTO dms_sample.ticket_purchase_hist (sporting_event_ticket_id, purchased_by_id, transferred_from_id, transaction_date_time, purchase_price)
        VALUES (var_sporting_event_ticket_id, par_new_ticketholder_id, var_old_ticketholder_id, CURRENT_TIMESTAMP(3), COALESCE(par_price, var_purchase_price));
        FETCH var_xfer_cur INTO var_sporting_event_ticket_id, var_purchase_price;
    END LOOP;
    CLOSE var_xfer_cur
    ;
END;
$BODY$
LANGUAGE  plpgsql;
