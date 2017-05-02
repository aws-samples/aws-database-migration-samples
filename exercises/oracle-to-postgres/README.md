# Migrating from Oracle Source to Postgres Target

1. **Setting up the Oracle Source:**

Set up an Oracle instance using either AMI ami-c0b429a8 or ami- 68f6707e in us-east-1 or search for Oracle-AMI-for-Training in other regions.

If you choose to use (ami-c0b429a8) - You need to create your own database. You will need to set up listeners and archive logs and run the script to set up the tables and load data in them.

If you choose to use ami-68f6707e. - Database orcl is already created and the tables have been set up.

   - Launch EC2 instance using one of the above AMIs. ( I used a c3.xlarge host). Save the key pair file to your desktop.

   - Change permissions of the keypair file to 600.

   chmod 600  ~/.ssh/&lt;.pem file&gt;

   - Login to the host using the key

   ssh -i ~/.ssh/&lt;Your .pem file&gt; ec2-user@&lt;your ec2 host name&gt;

**Change the listener and tnsnames file:**

Change listener.ora file:

- vi /u01/app/oracle/product/11.2.0/db1/network/admin/listener.ora. Change the host name to your ec2 host name and restart the listener.
- lsnrctl stop l\_orcl\_001
- lsnrctl start l\_orcl\_001
- alter system set LOCAL\_LISTENER=&quot;(address\_list=(address=(protocol=tcp)(host= hostname)(port=1521)))&quot;;
- alter system register;
- Change the hostname in  vi /u01/app/oracle/product/11.2.0/db1/network/admin/tnsnames.ora

Note:

In case you are using the ami-c0b429a8:

Turn off archiving.

Run the below commands to turn off archiving before running the install-onprem script. Otherwise a ton of archive logs will be generated and you will need to manually delete the applied ones to free up space on the host.

- Sqlplus / as sysdba
- Shutdown immediate;
- Startup mount;
- Alter database noarchivelog;
- Alter database open;
- Archive log list ( To check if database log mode is &quot;No Archive Mode&quot;)



2.**Download scripts from git**

Download database scripts to create users and load tables from the git repository. ( Do this step only if you are building the database from scratch using ami-c0b429a8)

How to download git:

- sudo yum install -y git

download the code from repository (awslabs/aws-database-migration-samples) to the linux machine

- git clone [https://github.com/awslabs/aws-database-migration-samples.git](https://github.com/awslabs/aws-database-migration-samples.git)

Note: Tables have already been created in ami-68f6707e. Skip to step 4.


3. **Connect to the source database**

Login to the host :

- ssh -i ~/.ssh/&lt;Your .pem file&gt; ec2-user@&lt;your ec2 host name&gt;

Go to the scripts directory:

- cd aws-database-migration-samples/oracle/sampledb/v1

Login as Oracle:

- Sudo su – oracle

Login to the database:

- Sqlplus / as sysdba

- Run install-onprem.sql script to set up tables and data.

oracle@ip-172-31-0-211 ~/aws-database-migration-samples/oracle/sampledb/v1&gt; sqlplus  / as sysdba

SQL&gt; @install-onprem.sql

The script takes about 45-60 mins to complete depending on the instance size.

4. **Create a Target Postgres instance:**

While the tables are being created and loaded, go ahead and spin up an RDS Postgres instance.

Login to your AWS console. Go to RDS -&gt; Instances and click on Launch Instance. Select PostgresSQL for Production and specify the DB details.

For the purpose of this exercise I used a db.m3.xlarge host. Provide the Database Instance Identifier/ User name and password and proceed to the next step.

Select the appropriate VPC and security groups and Make the instance publicly accessible. Provide the database name and fill in the Database Options/Monitoring/Backup and Maintenance fields (Leave all the other options to default)

Launch your instance.

5. **Download the Schema Conversion Tool(SCT)**

Once your source and target are created and tables are loaded, Download the Schema conversion Tool - http://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP\_SchemaConversionTool.Installing.html .

Download required drivers from links in the &quot;Installing the Required Database Drivers&quot; section from the above link. You will need to download Oracle and PostgreSQL drivers for this exercise.

6. **Create a new project in SCT.**

After installing SCT, Click on File -&gt; New Project.

Provide a name for your project. Enter the source database engine as Oracle and Target as Amazon RDS for Postgres.

7. **Connect to your source database.**

Enter the following details:

- EC2 host name - Name of your host
- Port - 1521
- SID - orcl
- Username - dms\_sample
- Password - dms\_sample

8. **Connect to your target database.**

- Server name - Get the endpoint of your RDS Postgres database from the AWS console.
- Port - 5432
- Database - Enter the database name you provided while creating the instance.
- Username/Password - Enter your username and password

9. **The Migration:**

Once you are connected to both the source and target, click on the source schema you would like to migrate. In this case, it is DMS\_SAMPLE.

Right click on DMS\_SAMPLE on the source side and click on &quot;Create Report&quot;. This will generate a report of the conversion actions for the migration. You need to check and take the necessary action based on the recommendations provided. In our case, you can safely ignore the warnings as they are for the procedures created on the source database to generate data for the tables. We are only focused on migrating the data to Postgres in this exercise.

Right click on DMS\_SAMPLE on the source side and click on &quot;Convert Schema&quot;. The schema will be converted and shown on the PostgreSQL instance (it has not been applied yet).

Check the tables on the target side and right click on the schema dms\_sample and click on &quot;Apply to Database&quot;.

10. **Create Replication Instance:**

Next, go to the AWS console and click on DMS. Click on &quot;Replication Instances&quot; -&gt; &quot;Create Replication Instance&quot; .

Create a replication instance in the same VPC as your source and target databases.

For this exercise, I chose dms.t2.medium instance class. You can choose any host that works for you. Mark the instance as publicly accessible. Select all the security groups you chose while created your source and target databases previously.

- Name: &lt;name&gt;
- Description: &lt;description&gt;
- Instance Class: t2.medium
- VPC: select any
- Multi-AZ: NO
- Publicly Accessible: YES (check this box)

11. **Creating Endpoints:**

Next, Click on &quot;Endpoints&quot; -&gt; &quot;Create Endpoint&quot; and proceed to create endpoints for both the source and the target.

Select &quot;Source&quot; and enter the below details.

- Endpoint Identifier - ex: oracle-source
- Source Engine - Oracle
- Server name -  This is your hostname - for ex: ec2-52-87-218-19.compute-1.amazonaws.com
- Port - 1521
- SSL mode - None
- Username/Password - dms\_user/dms\_user
- SID - orcl

You can run a connection test by selecting your vpc and the replication instance you just created in step 12.

Once the test is successful, go ahead and click on Create Endpoint. In case the test is unsuccessful, you can still create the end point. Fix the issues with the test and then run it again later.

Similarly for target endpoint, Select &quot;Target&quot;  and enter the below details.

- Endpoint Identifier - ex: postgres-target
- Source Engine - Postgres
- Server name -  This is your hostname - for ex:
- Port - 1521
- SSL mode - None
- Username/Password - dms\_user/dms\_user
- SID - orcl

12. **Creating the Migration Task :**

Next , Click on &quot;Tasks&quot; -&gt; &quot;Create Task&quot;.

Enter the details in the form.

- Task Name - ex: orcl-pg-migration
- Replication Instance - Choose the instance you created in step 12.
- Source Endpoint - Choose the source endpoint you created in step 13.
- Target Endpoint - Choose the target endpoint you created in step 13.
- Migration Type - Migrate existing data.
- Select start task on Create
- Target table preparation mode - Do Nothing
- Include LOB columns in replication\* - Default
- Select &quot;Enable Logging&quot;

**In Table mappings:**

- Schema name is - DMS\_SAMPLE
- Table name is - %
- Action - Include

**In Transformation Rule:**

- Schema name - DMS\_SAMPLE
- Transformation Rule - Make Lowercase
- Click on **Create Task.**

The task takes about 10 minutes to complete. If the task fails check if the foreign keys are enabled on the postgres database. If yes, drop them and restart the job.


**Script to drop FK constraints:**

alter table SPORT\_LEAGUE                  drop constraint     SL\_SPORT\_TYPE\_FK;

alter table SPORT\_TEAM                      drop constraint HOME\_FIELD\_FK;

alter table SPORT\_TEAM                      drop constraint ST\_SPORT\_TYPE\_FK;

alter table SEAT                              drop constraint S\_SPORT\_LOCATION\_FK;

alter table SEAT                              drop constraint SEAT\_TYPE\_FK;

alter table SPORTING\_EVENT                  drop constraint     SE\_SPORT\_TYPE\_FK;

alter table SPORTING\_EVENT                  drop constraint     SE\_HOME\_TEAM\_ID\_FK;

alter table SPORTING\_EVENT                  drop constraint     SE\_AWAY\_TEAM\_ID\_FK;

alter table SPORTING\_EVENT                  drop constraint     SE\_LOCATION\_ID\_FK;

alter table SPORTING\_EVENT\_TICKET        drop  constraint      SET\_SPORTING\_EVENT\_FK;

alter table SPORTING\_EVENT\_TICKET        drop  constraint        SET\_PERSON\_ID;

alter table SPORTING\_EVENT\_TICKET        drop  constraint        SET\_SEAT\_FK;

alter table TICKET\_PURCHASE\_HIST        drop  constraint      TPH\_SPORT\_EVENT\_TIC\_ID;

alter table TICKET\_PURCHASE\_HIST        drop  constraint        TPH\_TICKETHOLDER\_ID;

alter table TICKET\_PURCHASE\_HIST        drop  constraint        TPH\_TRANSFER\_FROM\_ID;


13. **Validation:**

Login to the RDS postgres database to run the validation and make sure the table counts are same in both the source and the target. ( You can use pgadmin tool to login to the postgres database. Download the tool using this link - https://www.pgadmin.org/download/ )

**Script to check all the table counts:**

select count(\*) from DMS\_SAMPLE.&quot;MLB\_DATA&quot;;

select count(\*) from DMS\_SAMPLE.&quot;NAME\_DATA&quot;;

select count(\*) from DMS\_SAMPLE.&quot;NFL\_DATA&quot;;

select count(\*) from DMS\_SAMPLE.&quot;NFL\_STADIUM\_DATA&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SEAT\_TYPE&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORT\_TYPE&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORT\_LEAGUE&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORT\_LOCATION&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORT\_DIVISION&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORT\_TEAM&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SEAT&quot;;

select count(\*) from DMS\_SAMPLE.&quot;PLAYER&quot;;

select count(\*) from DMS\_SAMPLE.&quot;PERSON&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORTING\_EVENT&quot;;

select count(\*) from DMS\_SAMPLE.&quot;SPORTING\_EVENT\_TICKET&quot;;

select count(\*) from DMS\_SAMPLE.&quot;TICKET\_PURCHASE\_HIST&quot;;

#**Running task with CDC:**

1. **Supplemental Logging:**

Add supplemental logging on the Oracle source. For tables with no primary key you need to add supplemental logging to all columns.

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA; 

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;

Tables that do not have a PK:

alter table DMS\_SAMPLE.MLB\_DATA add supplemental log data (ALL) columns;

alter table DMS\_SAMPLE.NFL\_DATA add supplemental log data (ALL) columns;

alter table DMS\_SAMPLE.NFL\_STADIUM\_DATA add supplemental log data (ALL) columns;

2. **Change Migration Type while creating the Task:**

Do Step (12) from above but change

**migration type**  – Migrate Existing data and replicate ongoing changes.

**Stop task after full load completes -** Stop After Applying Cached Changes

This allows us to add foreign keys after applying the cached changes and then continue with the task.

3. **Add Foreign Key constraints:**

Once the full load is completed, add the foreign key constraints.

alter table dms\_sample.PLAYER add constraint SPORT\_TEAM\_FK foreign key (SPORT\_TEAM\_ID) references SPORT\_TEAM(ID);

alter table dms\_sample.SPORTING\_EVENT add constraint SE\_AWAY\_TEAM\_ID\_FK foreign key (AWAY\_TEAM\_ID) references SPORT\_TEAM(ID);

alter table SPORTING\_EVENT add constraint SE\_HOME\_TEAM\_ID\_FK foreign key (HOME\_TEAM\_ID) references SPORT\_TEAM(ID);

alter table SPORT\_DIVISION add constraint SD\_SPORT\_LEAGUE\_FK foreign key (SPORT\_LEAGUE\_SHORT\_NAME) references SPORT\_LEAGUE(SHORT\_NAME);
alter table TICKET\_PURCHASE\_HIST add constraint TPH\_SPORT\_EVENT\_TIC\_ID foreign key (SPORTING\_EVENT\_TICKET\_ID) references SPORTING\_EVENT\_TICKET(ID);

alter table SPORTING\_EVENT\_TICKET add constraint SET\_SEAT\_FK foreign key (SPORT\_LOCATION\_ID, SEAT\_LEVEL, SEAT\_SECTION, SEAT\_ROW, SEAT) references SEAT(SPORT\_LOCATION\_ID, SEAT\_LEVEL, SEAT\_SECTION, SEAT\_ROW, SEAT);

4. **Run Insert/Update procedures:**

Login to the Oracle database and run the below procedures.

SQL&gt; SQL&gt; exec ticketManagement.generateTicketActivity(0.01,1000);

PL/SQL procedure successfully completed.

SQL&gt; exec ticketManagement.generateTransferActivity(0.1,1000);

PL/SQL procedure successfully completed.

These procedures will insert 4899 rows to TICKET\_PURCHASE\_HIST and update

5. **Start the task now**

After inserting/updating new rows and adding FK constraints, start the task and verify if he changes are applied on the target.

Go to the task and click on &quot;Table Statistics&quot; . You should see 4899 inserts on TICKET\_PURCHASE\_HIST table and 4899 rows updated on SPORTING\_EVENT\_TICKET
