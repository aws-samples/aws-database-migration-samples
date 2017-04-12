-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.player
ADD CONSTRAINT sport_team_fk_741577680 FOREIGN KEY (sport_team_id) 
REFERENCES dms_sample.sport_team (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.seat
ADD CONSTRAINT seat_type_fk_677577452 FOREIGN KEY (seat_type) 
REFERENCES dms_sample.seat_type (name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_league_fk_517576882 FOREIGN KEY (sport_league_short_name) 
REFERENCES dms_sample.sport_league (short_name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_type_fk_501576825 FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;


ALTER TABLE dms_sample.sport_league
ADD CONSTRAINT sl_sport_type_fk_421576540 FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;


ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT home_field_fk_565577053 FOREIGN KEY (home_field_id) 
REFERENCES dms_sample.sport_location (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;


ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT st_sport_type_fk_581577110 FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_away_team_id_fk_885578193 FOREIGN KEY (away_team_id) 
REFERENCES dms_sample.sport_team (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_home_team_id_fk_869578136 FOREIGN KEY (home_team_id) 
REFERENCES dms_sample.sport_team (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_location_id_fk_901578250 FOREIGN KEY (location_id) 
REFERENCES dms_sample.sport_location (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_sport_type_fk_853578079 FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_person_id_997578592 FOREIGN KEY (ticketholder_id) 
REFERENCES dms_sample.person (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;


ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_sport_event_tic_id_1061578820 FOREIGN KEY (sporting_event_ticket_id) 
REFERENCES dms_sample.sporting_event_ticket (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_ticketholder_id_1077578877 FOREIGN KEY (purchased_by_id) 
REFERENCES dms_sample.person (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_transfer_from_id_1093578934 FOREIGN KEY (transferred_from_id) 
REFERENCES dms_sample.person (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION NOT VALID;
