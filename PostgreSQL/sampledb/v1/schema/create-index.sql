CREATE INDEX seat_sport_location_idx
ON dms_sample.seat
USING BTREE (sport_location_id ASC);



CREATE INDEX se_start_date_fcn
ON dms_sample.sporting_event
USING BTREE (DATE(start_date_time) ASC);



CREATE INDEX set_ev_id_tkholder_id_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sporting_event_id ASC, ticketholder_id ASC);



CREATE INDEX set_seat_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sport_location_id ASC, seat_level ASC, seat_section ASC, seat_row ASC, seat ASC);



CREATE INDEX set_sporting_event_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sporting_event_id ASC);



CREATE INDEX set_ticketholder_idx
ON dms_sample.sporting_event_ticket
USING BTREE (ticketholder_id ASC);



CREATE UNIQUE INDEX sport_team_u
ON dms_sample.sport_team
USING BTREE (sport_type_name ASC, sport_league_short_name ASC, name ASC);



CREATE INDEX tph_purch_by_id
ON dms_sample.ticket_purchase_hist
USING BTREE (purchased_by_id ASC);



CREATE INDEX tph_trans_from_id
ON dms_sample.ticket_purchase_hist
USING BTREE (transferred_from_id ASC);



-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.name_data
ADD CONSTRAINT name_data_pk PRIMARY KEY (name_type, name);



ALTER TABLE dms_sample.person
ADD CONSTRAINT person_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.player
ADD CONSTRAINT player_pk PRIMARY KEY (id);



--ALTER TABLE dms_sample.seat
--ADD CONSTRAINT seat_pk PRIMARY KEY (sport_location_id, seat_level, seat_section, seat_row, seat);



ALTER TABLE dms_sample.seat_type
ADD CONSTRAINT st_seat_type_pk PRIMARY KEY (name);



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT chk_sold_out CHECK (sold_out IN (0, 1));



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT sporting_event_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT sporting_event_ticket_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sport_division_pk PRIMARY KEY (sport_type_name, sport_league_short_name, short_name);



ALTER TABLE dms_sample.sport_league
ADD CONSTRAINT sport_league_pk PRIMARY KEY (short_name);



ALTER TABLE dms_sample.sport_location
ADD CONSTRAINT sport_location_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT sport_team_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sport_type
ADD CONSTRAINT sport_type_pk PRIMARY KEY (name);



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT ticket_purchase_hist_pk PRIMARY KEY (sporting_event_ticket_id, purchased_by_id, transaction_date_time);

