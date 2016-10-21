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
@seat_type.tab;
prompt 'Creating sport_type table...'
@sport_type.tab;
prompt 'Creating sporting_league table...'
@sport_league.tab;
prompt 'Creating sporting location table...'
@sport_location.tab;
prompt 'Creating sporting_division table...'
@sport_division.tab;
prompt 'Creating sporting_team table...'
@sport_team.tab;
prompt 'Creating seat table...'
@seat.tab;
prompt 'Creating player table...'
@player.tab
prompt 'Creating person table...'
@person.tab


prompt 'Creating sporting_event table...'
@sporting_event.tab;


prompt 'Loading baseball teams...'
exec loadMLBTeams;
@set_mlb_team_home_field;

prompt 'Loading NFL teams...'
exec loadNFLTeams;
@set_nfl_team_home_field;

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
@generate_mlb_season;

prompt 'Generating NFL season...'
@generate_nfl_season;

prompt 'Creating ticket table...'
@sporting_event_ticket.tab

prompt 'Creating table ticket_purchase_hist...'
@ticket_purchase_hist.tab

prompt 'installing procedure generate_tickets...'

@generate_tickets.pls

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
@ticket_management.pkg

Prompt 'gathering statistics...'
exec dbms_stats.gather_schema_stats('DMS_SAMPLE');

@public_synonyms.sql

@sporting_event_info.vw
@ticket_info.vw
