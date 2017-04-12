-- ------------ Write DROP-TRIGGER-stage scripts -----------


DROP TRIGGER IF EXISTS player_id_trg
ON dms_sample.player;



DROP TRIGGER IF EXISTS sporting_event_id_trg
ON dms_sample.sporting_event;



DROP TRIGGER IF EXISTS sport_team_id_trg
ON dms_sample.sport_team;

-- ------------ Write DROP-TABLE-stage scripts -----------

DROP TABLE IF EXISTS dms_sample.mlb_data;



DROP TABLE IF EXISTS dms_sample.name_data;



DROP TABLE IF EXISTS dms_sample.nfl_data;



DROP TABLE IF EXISTS dms_sample.nfl_stadium_data;



DROP TABLE IF EXISTS dms_sample.person;



DROP TABLE IF EXISTS dms_sample.player;



DROP TABLE IF EXISTS dms_sample.seat;



DROP TABLE IF EXISTS dms_sample.seat_type;



DROP TABLE IF EXISTS dms_sample.sporting_event;



DROP TABLE IF EXISTS dms_sample.sporting_event_ticket;



DROP TABLE IF EXISTS dms_sample.sport_division;



DROP TABLE IF EXISTS dms_sample.sport_league;



DROP TABLE IF EXISTS dms_sample.sport_location;



DROP TABLE IF EXISTS dms_sample.sport_team;



DROP TABLE IF EXISTS dms_sample.sport_type;



DROP TABLE IF EXISTS dms_sample.ticket_purchase_hist;



-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS dms_sample;


-- ------------ Write DROP-SEQUENCE-stage scripts -----------

DROP SEQUENCE IF EXISTS dms_sample.player_seq;



DROP SEQUENCE IF EXISTS dms_sample.sporting_event_seq;



DROP SEQUENCE IF EXISTS dms_sample.sporting_event_ticket_seq;



DROP SEQUENCE IF EXISTS dms_sample.sport_location_seq;



DROP SEQUENCE IF EXISTS dms_sample.sport_team_seq;

-- ------------ Write CREATE-SEQUENCE-stage scripts -----------

CREATE SEQUENCE dms_sample.player_seq
INCREMENT BY 10
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE dms_sample.sporting_event_seq
INCREMENT BY 10
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE dms_sample.sporting_event_ticket_seq
INCREMENT BY 10
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE dms_sample.sport_location_seq
INCREMENT BY 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE dms_sample.sport_team_seq
INCREMENT BY 10
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;


-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE IF NOT EXISTS dms_sample.mlb_data(
mlb_id DOUBLE PRECISION,
mlb_name CHARACTER VARYING(30),
mlb_pos CHARACTER VARYING(30),
mlb_team CHARACTER VARYING(30),
mlb_team_long CHARACTER VARYING(30),
bats CHARACTER VARYING(30),
throws CHARACTER VARYING(30),
birth_year CHARACTER VARYING(30),
bp_id DOUBLE PRECISION,
bref_id CHARACTER VARYING(30),
bref_name CHARACTER VARYING(30),
cbs_id CHARACTER VARYING(30),
cbs_name CHARACTER VARYING(30),
cbs_pos CHARACTER VARYING(30),
espn_id DOUBLE PRECISION,
espn_name CHARACTER VARYING(30),
espn_pos CHARACTER VARYING(30),
fg_id CHARACTER VARYING(30),
fg_name CHARACTER VARYING(30),
lahman_id CHARACTER VARYING(30),
nfbc_id DOUBLE PRECISION,
nfbc_name CHARACTER VARYING(30),
nfbc_pos CHARACTER VARYING(30),
retro_id CHARACTER VARYING(30),
retro_name CHARACTER VARYING(30),
debut CHARACTER VARYING(30),
yahoo_id DOUBLE PRECISION,
yahoo_name CHARACTER VARYING(30),
yahoo_pos CHARACTER VARYING(30),
mlb_depth CHARACTER VARYING(30)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.name_data(
name_type CHARACTER VARYING(15) NOT NULL,
name CHARACTER VARYING(45) NOT NULL
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.nfl_data(
position CHARACTER VARYING(5),
player_number NUMERIC(3,0),
name CHARACTER VARYING(40),
status CHARACTER VARYING(10),
stat1 CHARACTER VARYING(10),
stat1_val CHARACTER VARYING(10),
stat2 CHARACTER VARYING(10),
stat2_val CHARACTER VARYING(10),
stat3 CHARACTER VARYING(10),
stat3_val CHARACTER VARYING(10),
stat4 CHARACTER VARYING(10),
stat4_val CHARACTER VARYING(10),
team CHARACTER VARYING(10)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.nfl_stadium_data(
stadium CHARACTER VARYING(60),
seating_capacity DOUBLE PRECISION,
location CHARACTER VARYING(40),
surface CHARACTER VARYING(80),
roof CHARACTER VARYING(30),
team CHARACTER VARYING(40),
opened CHARACTER VARYING(10),
sport_location_id DOUBLE PRECISION
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.person(
id DOUBLE PRECISION NOT NULL,
full_name CHARACTER VARYING(60) NOT NULL,
last_name CHARACTER VARYING(30),
first_name CHARACTER VARYING(30)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.player(
id DOUBLE PRECISION DEFAULT NEXTVAL('dms_sample.player_seq'),
sport_team_id DOUBLE PRECISION NOT NULL,
last_name CHARACTER VARYING(30),
first_name CHARACTER VARYING(30),
full_name CHARACTER VARYING(30)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.seat(
sport_location_id DOUBLE PRECISION NOT NULL,
seat_level NUMERIC(1,0) NOT NULL,
seat_section CHARACTER VARYING(15) NOT NULL,
seat_row CHARACTER VARYING(10) NOT NULL,
seat CHARACTER VARYING(10) NOT NULL,
seat_type CHARACTER VARYING(15)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.seat_type(
name CHARACTER VARYING(15) NOT NULL,
description CHARACTER VARYING(120),
relative_quality NUMERIC(2,0)
)
WITH (
OIDS=FALSE
);


CREATE TABLE IF NOT EXISTS dms_sample.sporting_event(
id BIGINT NOT NULL DEFAULT nextval('dms_sample.sporting_event_seq'),
sport_type_name VARCHAR(15) NOT NULL,
home_team_id INTEGER NOT NULL,
away_team_id INTEGER NOT NULL,
location_id SMALLINT NOT NULL,
start_date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
start_date DATE NOT NULL,
sold_out SMALLINT NOT NULL DEFAULT 0
)
WITH (
OIDS=FALSE
);


CREATE TABLE IF NOT EXISTS dms_sample.sporting_event_ticket(
id DOUBLE PRECISION DEFAULT NEXTVAL('dms_sample.sporting_event_ticket_seq'),
sporting_event_id DOUBLE PRECISION NOT NULL,
sport_location_id DOUBLE PRECISION NOT NULL,
seat_level NUMERIC(1,0) NOT NULL,
seat_section CHARACTER VARYING(15) NOT NULL,
seat_row CHARACTER VARYING(10) NOT NULL,
seat CHARACTER VARYING(10) NOT NULL,
ticketholder_id DOUBLE PRECISION,
ticket_price NUMERIC(8,2) NOT NULL
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.sport_division(
sport_type_name CHARACTER VARYING(15) NOT NULL,
sport_league_short_name CHARACTER VARYING(10) NOT NULL,
short_name CHARACTER VARYING(10) NOT NULL,
long_name CHARACTER VARYING(60),
description CHARACTER VARYING(120)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.sport_league(
sport_type_name CHARACTER VARYING(15) NOT NULL,
short_name CHARACTER VARYING(10) NOT NULL,
long_name CHARACTER VARYING(60) NOT NULL,
description CHARACTER VARYING(120)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.sport_location(
id NUMERIC(3,0) DEFAULT NEXTVAL('dms_sample.sport_location_seq'),
name CHARACTER VARYING(60) NOT NULL,
city CHARACTER VARYING(60) NOT NULL,
seating_capacity NUMERIC(7,0),
levels NUMERIC(1,0),
sections NUMERIC(4,0)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.sport_team(
id DOUBLE PRECISION DEFAULT NEXTVAL('dms_sample.sport_team_seq'),
name CHARACTER VARYING(30) NOT NULL,
abbreviated_name CHARACTER VARYING(10),
home_field_id NUMERIC(3,0),
sport_type_name CHARACTER VARYING(15) NOT NULL,
sport_league_short_name CHARACTER VARYING(10) NOT NULL,
sport_division_short_name CHARACTER VARYING(10)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.sport_type(
name CHARACTER VARYING(15) NOT NULL,
description CHARACTER VARYING(120)
)
WITH (
OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS dms_sample.ticket_purchase_hist(
sporting_event_ticket_id DOUBLE PRECISION NOT NULL,
purchased_by_id DOUBLE PRECISION,
transaction_date_time TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
transferred_from_id DOUBLE PRECISION,
purchase_price NUMERIC(8,2) NOT NULL
)
WITH (
OIDS=FALSE
);




