
LOAD DATA INFILE '/tmp/sporting_event_ticket.csv' INTO TABLE sporting_event_ticket
  FIELDS TERMINATED BY ',' 
  OPTIONALLY ENCLOSED BY '"' 
  ESCAPED BY '\\\\' 
  LINES TERMINATED BY '\\n' ;
