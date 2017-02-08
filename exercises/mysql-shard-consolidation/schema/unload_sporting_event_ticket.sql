
SELECT * FROM sporting_event_ticket INTO OUTFILE '/tmp/sporting_event_ticket.csv' 
  FIELDS TERMINATED BY ',' 
  OPTIONALLY ENCLOSED BY '"' 
  ESCAPED BY '\\\\' 
  LINES TERMINATED BY '\\n' ;

