#Amazon DMS Sample Database for MySQL: version 1.0

Scripts in this repository can be used to generate a MySQL database suitable for testing and exercising
the AWS Database Migration Service (DMS) and the AWS Schema Conversion Tool (SCT)

The scripts will generate schema objects and procedures which represent a mock sports  ticketing application. 
The scripts will also load approximately 8.5 GB of data into the source tables. 

The sampledb is not meant as an example of how one might ideally build a sports ticketing system rather,
it's designed to allow the user to get a feel for how to use the AWS Database Migration Service and Schema Converstion Tool.

**Requirements:**
* Any version of MySQL compatible with DMS
* Approximately 10GB of disk space
* You will need a privileged (DBA) account to execute the scripts

**Note:**
* Allow 45 minutes for installation (depending on the size of the host) 
* The scripts create users: dms_sample/dms_sample, dms_user/dms_user
* Objects are created in the schema: dms_sample

NOTE: currently the mysql sampledb has only been tested on RDS however it should work on-prem as well
IF you are installing the sampledb into an RDS database run the following script from an account that has DBA  privileges (The master account):

`install-rds.sql`



------------------------------------------------------------------------------------------------------------------------
<b>Below find the following:</b>
 * structure of the mysql sampledb git repository
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
The user dms_user is created as part of the installation of the sampledb. When you connect to the database using DMS or the SCT you should connect using this accont. The password for dms_user is set to dms_user by default, it is recommended you change this.

## Generating Transactions 
Most people who use DMS will want to exercise change capture and apply (CDC.) The sampledb includes some procedures designed to generate transactions on your source system. The procedures are called - generatTicketActivity and generateTransferActivity. To generate transactions you can log into the database using a mysql client or MySQL Workbench and do the following:

```
MySQL> call generateTicketActivity(1000,0.01);
```

This will "sell" 1000 tickets in successive purchases each delayed by 0.01 seconds. Tickets are sold in random groups of 1-6 to random people for a random price. A record of each transaction is recorded in the ticket_purchase_hist table.

 Once you've sold some tickets you can run the generateTransferActivity procedure:

```
MySQL> call generateTransferActivity(100,0.1);
````

This will generate 100 "transfer" transactions each delayed by 0.1 seconds. Tickets are transfered as a group 80% of the time 20% of the time singlets are transfered. A record of each transaction is recorded in ticket_purchase_hist.

##Entity Relationship Diagram of the System
![alt tag](/images/sampledb.jpg)

##Object Descriptions
### PROCEDURES
* **generateTicketActivity(p_max_transactions,p_delay_in_seconds):** Calls the procedure "sellTickets" <p_max_transactions> times with a delay of <p_delay_in_seconds> seconds, (fractions of seconds are allowed). The default is to generate 1000 transactions with a delay of 0.25 seconds. To execute the procedure using the defaults use: call generateTicketActivity(NULL,NULL);
* **generateTransferActivity(p_max_transactions,p_delay_in_seconds):** Calls the procedure "transferTicket" <p_max_transactions> times with a delay of <p_delay_in_seconds> seconds, (fractions of seconds are allowed). The default is to generate 10 transfers with a delay of 0.25 seconds. To execute the procedure using the defaults use: call generateTransferActivity(NULL,NULL);
* **sellTickets:** Procedure to "sell/purchase" tickets.
* **transferTicket:** Procedure to "transfer" tickets.
* **generateSportTickets:** Generates a ticket for each seat for each event for a given sport type (baseball or football).
* **generateMLBSeason:** Generates the Major League Baseball season.
* **generateNFLSeason:** Generates the NFL season.
* **generateSeats:** Generates seats for each stadium.
* **generateTickets:** Generates a ticket for each seat for each event.
* **loadMLBPlayers:** Loads the Major League Baseball players from the base data.
* **loadNFLPlayers:** Loads the NFL players from the base data.
* **setNFLTeamHomeField:** Sets the home field for each NFL team.

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

