#
#  Copyright 2017 Amazon.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


############################
#
# The following scripts create the sample db and 
# generate data used by the sampe db
#
############################

use dms_sample

select 'Dropping objects...';

drop table if exists ticket_purchase_hist;

drop table if exists sporting_event_ticket;

drop table if exists sporting_event;

drop table if exists seat;

drop table if exists person;

drop table if exists player;

drop table if exists sport_team;

drop table if exists sport_location;

drop table if exists sport_division;
drop table if exists sport_league;
drop table if exists seat_type;
drop table if exists sport_type;


select 'Creating objects and base data...';

select 'Creating seat_type table...';
source ./schema/seat_type.tab;

select 'Creating sport_type table...';
source ./schema/sport_type.tab;

select 'Creating sporting_league table...';
source ./schema/sport_league.tab;

select 'Creating sporting location table...';
source ./schema/sport_location.tab;

select 'Creating sporting_division table...';
source ./schema/sport_division.tab;

select 'Creating sporting_team table...';
source ./schema/sport_team.tab;

select 'Creating seat table...';
source ./schema/seat.tab;

select 'Creating player table...';
source ./schema/player.tab

select 'Creating person table...';
source ./schema/person.tab


select 'Creating sporting_event table...';
source ./schema/sporting_event.tab


select 'Loading baseball teams...';
source ./schema/set_mlb_team_home_field.sql

select 'Loading NFL teams...';
source ./schema/set_nfl_team_home_field.sql
call setNFLTeamHomeField;

select 'Creating location seats...';
call generateSeats;

select 'Loading baseball players...';
call loadMLBPlayers;

select 'Loading NFL players...';
call loadNFLPlayers;

select 'Loading sporting events...'
union
select 'Generating baseball season...';
delete from sporting_event where sport_type_name = 'baseball';
source ./schema/generate_mlb_season.sql;
call generateMLBSeason;

select 'Generating NFL season...';
delete from sporting_event where sport_type_name = 'football';
source ./schema/generate_nfl_season.sql;
call generateNFLSeason;

select 'Creating ticket table...';
source ./schema/sporting_event_ticket.tab

select 'Creating table ticket_purchase_hist...';
source ./schema/ticket_purchase_hist.tab

select 'installing procedures generateTickets and generateSportTickets...';
source ./schema/generate_tickets.sql
source ./schema/generate_sport_tickets.sql

/*  generate mlb tickets */
select 'Generating football tickets...';
call generateSportTickets('baseball');

/* generate NFL tickets */
select 'Generating football tickets...';
call generateSportTickets('football');


select 'Creating proceduer sellTickets...';
source  ./schema/sell_tickets.sql

select 'Creating procedure transferTicket...';
source ./schema/transfer_tickets.sql

select 'Creating procedure generateTicketActivity...';
source ./schema/generate_ticket_activity.sql

select 'Creating procedure generateTransferActivity...';
source ./schema/generate_transfer_activity.sql

/* create a couple of views... */
source ./schema/sporting_event_info.vw
source ./schema/sporting_event_ticket_info.vw

