#Amazon DMS Sample Database for Oracle: version 1.0

Scripts in this repository can be used to generate an Oracle database suitable for testing and exercising
the AWS Database Migration Service (DMS) and the AWS Schema Conversion Tool (SCT)

The scripts will generate schema objects, procedures, functions etc. which represent a mock sports 
ticketing application. The scripts will also load approximately 8.5 GB of data into the source tables. 

The sampledb is not meant as an example of how one might ideally build a sports ticketing system rather,
it's designed to allow the user to get a feel for how to use the AWS Database Migration Service and Schema Converstion Tool.

**Requirements:**
* Any version of Oracle compatible with DMS
* Approximately 10GB of disk space
* You will need a privileged (DBA) account to execute the scripts

**Note:**
* Allow 45 minutes for installation (depending on the size of the host) 
* The scripts create users: dms_sample/dms_sample, dms_user/dms_user
* Objects are created in the schema: dms_sample

IF you are installing the sampledb into an RDS database run the following script from an account that has DBA  privileges (The master account):

`install-rds.sql`


IF you are installing the sampledb into a NON RDS database run the following script from an account that has DBA  privileges:

`install-onprem.sql`


------------------------------------------------------------------------------------------------------------------------
<b>Below find the following:</b>
 * structure of the Oracle sampledb git repository
 * plans for future versions of the sampledb
 * instructions on how to use the sampledb with DMS or SCT
 * instructions on how to generate transactions for the sampledb
 * description of most of the objects included in the sampledb

## Repo Structure
There are three directories below this main directory. they are:
* data: files containing base data used by the system. These are here for reference only.
* user: files for creating and adding privileges to the dms_sample and dms_user user accounts
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
Two users are created with the sampledb: dms_sample and dms_user. Dms_sample is the owner of the objects. Dms_user is a user with more limited privileges - only those privileges necessary to use DMS or SCT. This is intended to mimick a real-life situation and the best practice of least privilege: The accounts used to connect to your databases from DMS or SCT should have the minimal privileges required to do their job. 

Therefore, when you connect to the sampldb from DMS or SCT, you should connect as the user *DMS_USER* (not DMS_SAMPLE.)

## Generating Transactions 
Most people who use DMS will want to exercise change capture and apply (CDC.) The sampledb includes some packaged designed to generate transactions on your source system. The package is called - dms_sample.ticketManagement. To generate transactions you can log into the database as dms_sample (using SQL Plus or SQL Developer) and do the following:

```
SQL> exec ticketManagement.generateTicketActivity(0.01,1000);
```

This will "sell" 1000 tickets in successive purchases each delayed by 0.01 seconds. Tickets are sold in random groups of 1-6 to random people for a random price. A record of each transaction is recorded in the ticket_purchase_hist table.

 Once you've sold some tickets you can run the generateTransferActivity procedure:

```
SQL> exec ticketManagement.generateTransferActivity(0.1,1000);
````

This will generate 1000 "transfer" transactions each delayed by 0.1 seconds. Tickets are transfered as a group 80% of the time 20% of the time singlets are transfered. A record of each transaction is recorded in ticket_purchase_hist.

##Entity Relationsip Diagram of the System
![alt tag](/images/sampledb.jpg)

##Object Descriptions
###PACKAGES           
* **TICKETMANAGEMENT:** Details above under "generating transactions"

### PROCEDURES
* **GENERATESEATS:** Randomly generates seats for each stadium in a "realistic" fashion.
* **GENERATE_TICKETS:** Generates a ticket for each seat for each event.
* **LOADMLBPLAYERS:** Loads the Major League Baseball players from the base data
* **LOADMLBTEAMS:** Loads the Major League Baseball team data from the base data
* **LOADNFLPLAYERS:** Loads the NFL players from the base data
* **LOADNFLTEAMS:** Loads the NFL teams from the base data

### SEQUENCES
* **PLAYER_SEQ:** Used to generate surrogate key for players
* **SPORTING_EVENT_SEQ:** Used to generate surrogate key for sporting events
* **SPORTING_EVENT_TICKET_SEQ:** used to generate surrogate key for tickets
* **SPORT_LOCATION_SEQ:** used to generate surrogate key for sport locations (stadiums etc.)
* **SPORT_TEAM_SEQ:** used to generate surrogate key for sports teams

### TABLES
* **MLB_DATA:** Holds Major League Baseball base data. This is used to generate player, team and stadium data.
* **NAME_DATA:** Holds name data used to randomly generate a large number of PEOPLE who can buy tickets etc.
* **NFL_DATA:** Hods NFL base data. This is used to generate player and team data.
* **NFL_STADIUM_DATA:** Holds information about NFL stadiums. Used to generate stadium data etc.
* **PERSON:** Randomly generated people who can buy tickets.
* **PLAYER:** A player of a sport - currently either baseball or football. 
* **SEAT:** A specific seat in a specific stadium for which a person can buy a ticket.
* **SEAT_TYPE:** The type of seat: standard, premium, obstructed, etc.
* **SPORTING_EVENT:** A specific meeting between two teams at a specific time and place where they will do battle.
* **SPORTING_EVENT_TICKET:** A ticket which, for a price, allows a person to sit their butt in a seat and watch a sporting event.
* **SPORT_DIVISION:** Football has divisions like: AFC WEST, NFC EAST. It allows them to organize their battles and create rivalries.
* **SPORT_LEAGUE** On organized group of teams of the same sport: NFL - National Football League; MLB - Major League Baseball
* **SPORT_LOCATION:** A battlefield where teams meet and attempt to destroy each other. Century Link Field (home of the Hawks) is particularly intimidating.
* **SPORT_TEAM:** An organized group of people who play the same sport. The Seattle Seahawks, (an NFL team), are particularly menacing.
* **SPORT_TYPE:** Baseball or Football - what's your pleasure?
* **TICKET_PURCHASE_HIST:** A recording of every ticket purchas (including transfers) ever made in this system. (Even scalping is recorded here.)

### VIEWS
* **SPORTING_EVENT_INFO:** An aggregated view of everything important about a specific sporting event.
* **SPORTING_EVENT_TICKET_INFO:** An consolidated view of all information pertinent to a ticket.
