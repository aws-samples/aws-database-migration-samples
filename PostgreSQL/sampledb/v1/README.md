#Amazon DMS Sample Database for PostgreSQL: version 1.0

Scripts in this repository can be used to generate a PostgreSQL database suitable for testing and exercising
the AWS Database Migration Service (DMS) and the AWS Schema Conversion Tool (SCT)

The scripts will generate schema objects and procedures which represent a mock sports  ticketing application.
The scripts will also load approximately 7 GB of data into the source tables.

The sampledb is not meant as an example of how one might ideally build a sports ticketing system rather,
it's designed to allow the user to get a feel for how to use the AWS Database Migration Service and Schema Converstion Tool.

**Requirements:**
* Any version of PostgreSQL compatible with DMS
* Approximately 10GB of disk space
* You will need a privileged (DBA) account to execute the scripts

**Steps to install sample DB:**
* Clone this git repository
* Navigate to the /PostgreSQL/sampledb/v1 directory
* Login as master user in RDS PostgreSQL or a privileged user on other PostgreSQL installations to the required PostgreSQL database
* Execute this from the postgres prompt- 
\i install-postgresql.sql 

**Note:**
* Allow 45 minutes for installation (depending on the size of the host)
* The scripts create users: dms_user/dms_user
* Objects are created in the schema: dms_sample (You can choose a database of your choice)


------------------------------------------------------------------------------------------------------------------------
<b>Below find the following:</b>
 * structure of the PostgreSQL sampledb git repository
 * plans for future versions of the sampledb
 * instructions on how to use the sampledb with DMS or SCT
 * instructions on how to generate transactions for the sampledb
 * description of most of the objects included in the sampledb

## Repo Structure
There are three directories below this main directory. they are:
* data: files containing base data used by the system. These are here for reference only.
* user: files for creating and adding privileges to the dms_user user accounts
* schema: files used for creating schema objects (including procedures and functions etc.) also included are some scripts used in generating data

## Future Versions
Future versions of the sampledb will include objects usefull for demonstrating or practicing tricky, complicated or advanced migration/conversion techniques. Examples may include:
* working with large objects (BLOBS, CLOBS, etc.)
* working with filtering
* working with transformations
* working with partitioned tables - fan out, fan in, etc.
* more sports/more data (currently only football and baseball are represented.)
* etc.

## Using the sampledb With DMS or SCT
The user dms_user is created as part of the installation of the sampledb. When you connect to the database using DMS or the SCT you should connect using this accont. The password for dms_user is set to dms_user by default, it is recommended you change this.

## Generating Transactions 
Most people who use DMS will want to exercise change capture and apply (CDC.) The sampledb includes some procedures designed to generate transactions on your source system. The procedures are called - generatticketactivity and generatetransferactivity. To generate transactions you can log into the database using a psql client or PGAdmin III and do the following:

```
postgres=# select generateticketactivity(1000);
```

This will "sell" 1000 tickets in successive purchases. Tickets are sold in random groups of 1-6 to random people for a random price. A record of each transaction is recorded in the ticket_purchase_hist table.

 Once you've sold some tickets you can run the generateTransferActivity procedure:

```
postgres=# select generatetransferactivity(100);
````

This will generate 100 "transfer" transactions. Tickets are transfered as a group 80% of the time 20% of the time singlets are transfered. A record of each transaction is recorded in ticket_purchase_hist.

##Entity Relationship Diagram of the System
![alt tag](/images/sampledb.jpg)

##Object Descriptions
### PROCEDURES
* **generateSeats:** Randomly generates seats for each stadium in a "realistic" fashion
* **loadmlbplayers:** Loads the Major League Baseball players from the base data
* **loadmlbteams:** Loads the Major League Baseball team data from the base data
* **loadnflplayers:** Loads the NFL players from the base data
* **loadnflteams:** Loads the NFL teams from the base data
* **transferticket:** Transfers ticket(s) from one person to another
* **generateticketactivity:** Repeatedly sells a random number of tickets (1-6) to a random person
* **generatetransferactivity:** Repeatedly transfers tickets from one person to another. 80% are transferred as a group, 20% as singlets (calls transferTicket)

### TABLES
* **mlb_data:** Holds Major League Baseball base data. This is used to generate player, team and stadium data.
* **name_data:** Holds name data used to randomly generate a large number of PEOPLE who can buy tickets etc.
* **nfl_data:** Holds NFL base data. This is used to generate player and team data.
* **nfl_stadium_data:** Holds information about NFL stadiums. Used to generate stadium data etc.
* **person:** Randomly generated people who can buy tickets.
* **player:** A player of a sport - currently either baseball or football.
* **seat:** A specific seat in a specific stadium for which a person can buy a ticket.
* **seat_type:** The type of seat: standard, premium, obstructed, etc.
* **sport_division:** Football has divisions like: AFC WEST, NFC EAST. It allows them to organize their battles and create rivalries.
* **sport_league:** An organized group of teams of the same sport: NFL - National Football League; MLB - Major League Baseball.
* **sport_location:** A battlefield where teams meet and attempt to destroy each other. Century Link Field (home of the Hawks) is particularly intimidating.
* **sport_team:** An organized group of people who play the same sport. The Seattle Seahawks, (an NFL team), are particularly menacing.
* **sport_type:** Baseball or Football - what's your pleasure?
* **sporting_event:** A specific meeting between two teams at a specific time and place where they will do battle.
* **sporting_event_ticket:** A ticket which, for a price, allows a person to sit their butt in a seat and watch a sporting event.
* **ticket_purchase_hist:** A recording of every ticket purchase (including transfers) ever made in this system. (Even scalping is recorded here.)

###VIEWS
* **sporting_event_info:** An aggregated view of everything important about a specific sporting event.
* **sporting_event_ticket_info:** A consolidated view of all information pertinent to a ticket.
