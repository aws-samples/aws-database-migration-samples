/*
 Copyright 2017 Amazon.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

--------------------------------------------------------
--
-- The following scripts create the sample db and 
-- generate data used by the sampe db
--
--------------------------------------------------------
set timing on
prompt 'Dropping objects...'

drop table ticket_purchase_hist;

drop sequence sporting_event_ticket_seq;
drop table sporting_event_ticket;

drop sequence sporting_event_seq;
drop trigger sporting_event_id_trg;
drop table sporting_event;

drop table seat;

drop sequence person_seq;
drop trigger person_id_trg;
drop table person;

drop trigger player_id_trg;
drop sequence player_seq;
drop table player;

drop trigger sport_team_id_trg;
drop sequence sport_team_seq;
drop table sport_team;

drop sequence sport_location_seq;
drop table sport_location;

drop table sport_division;
drop table sport_league;
drop table seat_type;
drop table sport_type;


prompt 'Creating objects and base data...'

prompt 'Creating seat_type table...'
@schema/seat_type.tab;
prompt 'Creating sport_type table...'
@schema/sport_type.tab;
prompt 'Creating sporting_league table...'
@schema/sport_league.tab;
prompt 'Creating sporting location table...'
@schema/sport_location.tab;
prompt 'Creating sporting_division table...'
@schema/sport_division.tab;
prompt 'Creating sporting_team table...'
@schema/sport_team.tab;
prompt 'Creating seat table...'
@schema/seat.tab;
prompt 'Creating player table...'
@schema/player.tab
prompt 'Creating person table...'
@schema/person.tab


prompt 'Creating sporting_event table...'
@schema/sporting_event.tab;


prompt 'Loading baseball teams...'
exec loadMLBTeams;
@schema/set_mlb_team_home_field;

prompt 'Loading NFL teams...'
exec loadNFLTeams;
@schema/set_nfl_team_home_field;

prompt 'Creating location seats...'
exec generateSeats;

prompt 'Loading baseball players...'
exec loadMLBPlayers;
commit;

prompt 'Loading NFL players...'
exec loadNFLPlayers;
commit;

prompt 'Loading sporting events...'
prompt 'Generating baseball season...'
@schema/generate_mlb_season;

prompt 'Generating NFL season...'
@schema/generate_nfl_season;

prompt 'Creating ticket table...'
@schema/sporting_event_ticket.tab

prompt 'Creating table ticket_purchase_hist...'
@schema/ticket_purchase_hist.tab

prompt 'installing procedure generate_tickets...'

@schema/generate_tickets.pls

-- generate mlb tickets
prompt 'Generating baseball tickets...'
BEGIN
  FOR event_rec IN (select id from sporting_event where sport_type_name = 'baseball') LOOP
    generate_tickets(event_rec.id);
    COMMIT;
  END LOOP;
END;
/

-- generate NFL tickets
prompt 'Generating football tickets...'
BEGIN
  FOR event_rec IN (select id from sporting_event where sport_type_name = 'football') LOOP
    generate_tickets(event_rec.id);
    COMMIT;
  END LOOP;
END;
/


Prompt 'installing the ticket management package...'
@schema/ticket_management.pkg

Prompt 'gathering statistics...'
exec dbms_stats.gather_schema_stats('DMS_SAMPLE');

@schema/public_synonyms.sql

@schema/sporting_event_info.vw
@schema/ticket_info.vw


---------------------------------------------------
-- grant privileges on tables to dms_user
--------------------------------------------------
DECLARE
  CURSOR tabcur IS
  SELECT table_name
  FROM   dba_tables
  WHERE  owner = 'DMS_SAMPLE';

  stmt VARCHAR2(200);
BEGIN
  FOR trec IN tabcur LOOP
    stmt := 'grant select, insert, update, delete, alter on dms_sample.' || trec.table_name || ' to dms_user';
    dbms_output.put_line('Granting privileges to dms_user on: ' || trec.table_name );
    EXECUTE IMMEDIATE stmt;
  END LOOP;
END;
/

---------------------------------------------------
-- grant privileges on package to dms_user
--------------------------------------------------
--create public synonym ticket_management for dms_sample.ticket_management;
--grant execute on ticketManagement.generateTicketActivity to dms_user;
--grant execute on ticketManagement.generateTransferActivity to dms_user;
--

create or replace  public synonym ticket_management for dms_sample.ticketManagement;
grant execute on ticket_management to dms_user;


---------------------------------------------------
-- add table level supplemental logging
--------------------------------------------------

DECLARE
  CURSOR tabcur IS
  SELECT table_name
  FROM   dba_tables
  WHERE  owner = 'DMS_SAMPLE';

  stmt VARCHAR2(200);
BEGIN
  FOR trec IN tabcur LOOP
    stmt :=  'alter table dms_sample.' || trec.table_name || ' add supplemental log data (primary key) columns';
    dbms_output.put_line('Adding supplemental logging for: ' || trec.table_name );
    EXECUTE IMMEDIATE stmt;
  END LOOP;
END;
/

