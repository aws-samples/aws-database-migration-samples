-- Adding the constraint to check the table sporting event

ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT chk_sold_out CHECK (sold_out IN (0, 1));

-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_person_id FOREIGN KEY (ticketholder_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_ticketholder_id FOREIGN KEY (purchased_by_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_transfer_from_id FOREIGN KEY (transferred_from_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.player
ADD CONSTRAINT sport_team_fk FOREIGN KEY (sport_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_seat_fk FOREIGN KEY (sport_location_id, seat_level, seat_section, seat_row, seat) 
REFERENCES dms_sample.seat (sport_location_id, seat_level, seat_section, seat_row, seat)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.seat
ADD CONSTRAINT seat_type_fk FOREIGN KEY (seat_type) 
REFERENCES dms_sample.seat_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.seat
ADD CONSTRAINT s_sport_location_fk FOREIGN KEY (sport_location_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_away_team_id_fk FOREIGN KEY (away_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_home_team_id_fk FOREIGN KEY (home_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_location_id_fk FOREIGN KEY (location_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_sporting_event_fk FOREIGN KEY (sporting_event_id) 
REFERENCES dms_sample.sporting_event (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_sport_event_tic_id FOREIGN KEY (sporting_event_ticket_id) 
REFERENCES dms_sample.sporting_event_ticket (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_league_fk FOREIGN KEY (sport_league_short_name) 
REFERENCES dms_sample.sport_league (short_name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_league
ADD CONSTRAINT sl_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT home_field_fk FOREIGN KEY (home_field_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT st_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



-- ------------ Write CREATE-TRIGGER-stage scripts -----------

CREATE TRIGGER player_id_trg
BEFORE INSERT
ON dms_sample.player
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.player_id_trg$player();



CREATE TRIGGER sporting_event_id_trg
BEFORE INSERT
ON dms_sample.sporting_event
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.sporting_event_id_trg$sporting_event();



CREATE TRIGGER sport_team_id_trg
BEFORE INSERT
ON dms_sample.sport_team
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.sport_team_id_trg$sport_team();




