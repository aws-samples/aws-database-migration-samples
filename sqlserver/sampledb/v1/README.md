#Amazon DMS Sample Database for SQL Server: version 1.0

Scripts in this repository can be used to generate a SQL Server database suitable for testing and exercising
the AWS Database Migration Service (DMS) and the AWS Schema Conversion Tool (SCT)

The scripts will generate schema objects, procedures, functions etc. which represent a mock sports
ticketing application. The scripts will also load approximately 8.5 GB of data into the source tables.

The sampledb is not meant as an example of how one might ideally build a sports ticketing system rather,
it's designed to allow the user to get a feel for how to use the AWS Database Migration Service and Schema Converstion Tool.

The installation process creates the database, loads the data, and sets the database up for replication using DMS.

**Requirements:**
* Any version of SQL Server compatible with DMS **NOTE: SQL Server 2016 is not yet supported for CDC**
* Approximately 50GB of disk space
* You will need a privileged Administrative account to execute the scripts

**Note:**
* Allow 45 minutes for installation (depending on the size of the host)
* The scripts create the database: dms_sample and the login and user: dms_user/dms_user 
* Objects are created in the schema: dbo

##Installation Instructions
* Download the source
* Open a PowerShell session
* Change your directory to the location of the install script **...sqlserver\sampledb\v1**
* Run the install script using the sqlcmd utility. If your on the database server:
```sql
sqlcmd -i .\install-onprem.sql
```
...it takes 30-40 minutes to install depending on the host.

**Ensure your authentication is set to: "SQL Server and Windows Authentication mode." To set this:**
* Log into SQL Server Management Studio (SSMS)
* Right click on the Server (WIN-< xxxxxxxx >)
* Open "properties"
* Choose "security"
* On the right under Server Authentication choose "SQL Server and Windows Authentication mode."
* Restart SQL Server (You can use SQL Server Configuration Manager to do this)

------------------------------------------------------------------------------------------------------------------------
<b>Below find the following:</b>
 * structure of the SQL Server sampledb git repository
 * plans for future versions of the sampledb
 * instructions on how to use the sampledb with DMS or SCT
 * instructions on how to generate transactions for the sampledb
 * description of most of the objects included in the sampledb

## Repo Structure
There are five directories below this main directory. they are:
* **data:** files containing base data used by the system. These are here for reference only.
* **user:** scripts for creating and adding loging capability to the dms_user
* **schema:** scripts used for creating schema objects (including procedures and functions etc.) also included are some scripts used in generating data
* **system:** scripts used to enable replication and create the initial backup of the database

## Future Versions
Future versions of the sampledb will include objects usefull for demonstrating or practicing tricky, complicated or advanced migration/conversion techniques. Examples may include:
* working with large objects (BLOBS, CLOBS, etc.)
* working with filtering
* working with transformations
* working er account dms_user is created when the sampledb is installed in SQL Server. This account should be used when connecting to the sampledb from the Schema Conversion Tool or the Database Migratoin Service.

## Generating Transactions
Most people who use DMS will want to exercise change capture and apply (CDC.) The sampledb includes some procedures designed to generate transactions on your source system. The procedures are called: generateTicketActivity and generateTransferActivity. 

The following will generate 1000 ticket sales in batches of 1-6 tickets to randomly selected people for a random price (within a range.) A record of each transaction is recorded in the ticket_purchase_hist table:
```sql
use dms_sample;
exec generateTicketActivity 1000 
```

Once you've sold some tickets you can run the generateTransferActivity procedure. The following will transfer tickets from the owner to another person. The whole "batch" of tickets purchased is transferred 80% of the time and 20% of the time an individual ticket is transferred.
```sql
use dms_sample
exec generateTransferActivity 100
````
##Entity Relationship Diagram of the System
![alt tag](/images/sampledb.jpg)

##Object Descriptions
### PROCEDURES
* **generateSeats:** Randomly generates seats for each stadium in a "realistic" fashion
* **generate_tickets:** Generates a ticket for each seat for each event.
* **loadMLBPlayers:** Loads the Major League Baseball players from the base data
* **loadMLBTeams:** Loads the Major League Baseball team data from the base data
* **loadNFLPlayers:** Loads the NFL players from the base data
* **loadNFLTeams:** Loads the NFL teams from the base data
* **sellTickets:** Sells ticket(s) to a person
* **transferTicket:** Transfers ticket(s) from one person to another
* **generateTicketActivity:** Repeatedly sells a random number of tickets (1-6) to a random person (calls sellTickets)
* **generateTransferActivity:** Repeatedly transfers tickets from one person to another. 80% are transferred as a group, 20% as singlets (calls transferTicket)

### FUNCTIONS
* **rand_int:** Generates a random integer between a max and min values

### TABLES
* **mlb_data:** Holds Major League Baseball base data. This is used to generate player, team and stadium data.
* **name_data:** Holds name data used to randomly generate a large number of PEOPLE who can buy tickets etc.
* **nfl_data:** Hods NFL base data. This is used to generate player and team data.
* **nfl_stadium_data:** Holds information about NFL stadiums. Used to generate stadium data etc.
* **person:** Randomly generated people who can buy tickets.
* **player:** A player of a sport - currently either baseball or football.
* **seat:** A specific seat in a specific stadium for which a person can buy a ticket.
* **seat_type:** The type of seat: standard, premium, obstructed, etc.
* **sporting_event:** A specific meeting between two teams at a specific time and place where they will do battle.
* **sporting_event_ticket:** A ticket which, for a price, allows a person to sit their butt in a seat and watch a sporting event.
* **sport_division:** Football has divisions like: AFC WEST, NFC EAST. It allows them to organize their battles and create rivalries.
* **sport_league:** On organized group of teams of the same sport: NFL - National Football League; MLB - Major League Baseball
* **sport_location:** A battlefield where teams meet and attempt to destroy each other. Century Link Field (home of the Hawks) is particularly intimidating.
* **sport_team:** An organized group of people who play the same sport. The Seattle Seahawks, (an NFL team), are particularly menacing.
* **sport_type:** Baseball or Football - what's your pleasure?
* **ticket_purchase_hist:** A recording of every ticket purchas (including transfers) ever made in this system. (Even scalping is recorded here.)

### VIEWS
* **sporting_event_info:** An aggregated view of everything important about a specific sporting event.
* **sporting_event_ticket_info:** An consolidated view of all information pertinent to a ticket.

