#MySQL Shard Consolidation Exercise

Following is an exercise in using the Database Migration Service, (DMS) to consolidate a sharded MySQL system into Amazon Aurora using the DMS sample database. Our sample database is based on a mock sports ticketing system. The gist of the system is to sell tickets to sporting events. An entity relationship of the system looks as follows:

![alt tag](/images/sampledb.jpg)

In our system the sporting_event_ticket and ticket_purchase_history tables are the “active” tables. All of the other tables are relatively static. Therefore, we’ve decided to shard just those two tables and consider other data as reference data. We’ve divided the system into a master node and two shards.  Data was distributed to each shard based on the sporting_event_id. So, tickets for any given sporting event will reside in a single shard, (can anyone see the problem with this?) In any case, while perhaps not ideal, it’s good enough for illustrative purposes. Our sharded system now looks like this:


![alt tag](/images/shardedERD.jpg)

In short – we have three databases we need to move to Aurora. Let’s get started!
You can find RDS snapshots here (To find them in the RDS console go to RDS -> snapshots -> Filter: All Public Snapshots. Make sure you are in the us-west-2 region):
* <b>Master:</b> arn:aws:rds:us-west-2:900514285683:snapshot:mysql-sampledb-master-shard
* <b>Shard1:</b> arn:aws:rds:us-west-2:900514285683:snapshot:mysql-sampledb-shard1
* <b>Shard2:</b> arn:aws:rds:us-west-2:900514285683:snapshot:mysql-sampledb-shard2

We mentioned earlier there were several ways for migrating a MySQL instance into Aurora. One such way is to use snapshot conversion. We’re going to use this option to convert our master node. Note: this method does require an outage long enough to create and convert the snapshot. Many applications can afford such an outage, if yours can’t, one of the other methods mentioned can probably work for you. For our example, we’ll use snapshot conversion for illustrative purposes.
Locate the snapshot mysql-sampledb-master-shard in the RDS console and click the “migrate snapshot” button at the top of the page.  You’ll want to choose the following:
* <b>Instance Class:</b> the smallest you can get - db.t2.medium
* <b>VPC:</b> Just keep in mind you’ll want to put everything in the same VPC
* <b>Everything Else:</b> the default values should be fine

While we’re waiting for the snapshot to migrate, let’s create our shards from the snapshots. Locate the shard1 and shard2 snapshots and for each click the “restore snapshot” button at the top of the page. Choose the following:
* <b>Instance Class:</b> db.t2.small (or micro if you like.)
* <b>Multi-AZ:</b> NO
* <b>Instance ID:</b> mysql-sampledb-shard<n>
* <b>Publicly Accessible:</b> Yes
* <b>VPC:</b> Just keep in mind you’ll want to put everything in the same VPC
* <b>Everything Else:</b> The default values should be fine

We’ll be using the Database Migration Service (DMS) to migrate our shards to Aurora. We’ll also be configuring our DMS tasks to use Change Data Capture (CDC) during the migration. To allow this, we’ll need to configure our shards appropriately. For this, we’ll need to create a parameter group. To do so log into the RDS console, click Parameter Groups (on the left), select “create parameter group”.  Select the mysql parameter family that corresponds to the version of mysql your shards are running on (in my case it mysql5.6).  Give your parameter group a name, something like: MYSQL-DMS-CDC, add a description and click “create.” Now, select the parameter group you just created and click “Edit Parameters.” Change the following parameters and save your changes:
* <b>Binlog_checksum:</b> NONE 
* <b>Binlog_format:</b> ROW

Once the creation of your shards is complete you will need to modify them to: add your newly created parameter group and, change the master password. For each shard, from the RDS console click “Instance Actions” -> “Modify”.  Change the master password, and under “DB Parameter Group” select the parameter group you just created, make sure your instances are being backed up and have the changes applied immediately. Once you’ve added the parameter group to your instance you’ll need to reboot it so it picks up the change. Got to the AWS RDS console, locate your instance, select “reboot” from the Instance Actions menu.
Okay – there’s one more thing we need to do to prepare our shards for DMS change capture and apply. It turns out RDS is super efficient when it comes to binlog management. This is great! Except for the fact that we need the binlogs to remain on the host long enough for DMS to mine transactions. To tell RDS to keep those binlogs around we can call a procedure. So… log into each instance using your favorite MySQL client (I prefer the basic client but Workbench works just as well).  Once logged in issue the following procedure call to direct RDS to retain binlogs for 24 hours:

```
MySQL> call mysql.rds_set_configuration('binlog retention hours', 24);
Query OK, 0 rows affected (0.00 sec)
```

Excellent! The two shards should be ready to roll!

By now the migration of your master snapshot should be close to completion. When it is complete, restore the snapshot. Select a small instance (t2.medium is fine), and make sure you put it in the correct VPC. Once the instance has been created, modify it and change the master password.
Excellent! You should now have a system that looks something like this:

![alt tag](/images/unconsolidatedShards.png)

We’ve used the snapshot migration process to copy our master shard into Aurora thereby establishing our beach head. Our two shards are still running on MySQL and need to be migrated to Aurora. Note that the data in each of the shards is housed in the database called dms_sample. We’re now ready to use DMS to migrate the data from shard1 into our Aurora instance.  To do so we’ll need to do the following:
* Launch a replication instance in our VPC
* Create endpoints to both our source and target databases ( shard 1 and the master shard respectively)
* Create a task to migrate the data from shard1 into our Aurora instance

To launch a replication instance go the AWS console and select DMS. located under “Migration”, (make sure you’re in the correct region: us-west-2.) On the left hand side select Replication instances and click the “Create replication instance” located in the upper left. Supply a name (auroraMigration), description, choose an instance class (t2.small or medium is fine), and make sure you select the same VPC that contains your database instances. While the instance is being created go to the RDS console and make not of the endpoints for your Aurora instance and your shard1 instance, you’ll need them to create endpoints.
To create your source endpoint, go to the AWS DMS console, select endpoints, then click “Create endpoint.”  Choose the following inputs:
* <b>Endpoint type:</b> source
* <b>Identifier:</b> shard1
* <b>Engine:</b> mysql
* <b>Server name:</b> <enter the endpoint for the RDS instance that contains shard1. (don’t include the port.)>
* <b>SSL mode:</b> none
* <b>Username:</b> dbmaster  (we’ll use the master account for simplicity)
* <b>Password:</b> <the password>  (this will be the new password you supplied when modifying the instance)
* <b>VPC:</b> select the appropriate vpc
* <b>Replication instance:</b> select the replication instance you just created
* <b>--></b> Now click “run test” and save the endpoint.

Creating the target endpoint is similar to creating the source, follow the same process with slightly different inputs:
* <b>Endpoint   type:</b> target
* <b>Identifier:</b> aurora-instance
* <b>Engine:</b> aurora
* <b>Server name:</b> < enter the endpoint for the Aurora instance that was created for this exercise. (don’t include the port.)>
* <b>SSL mode:</b> none
* <b>Username:</b> dbmaster
* <b>Password:</b> <whatever it was changed to>
* <b>VPC:</b> select the appropriate vpc
* <b>Replication instance:</b> select the replication instance you just created
* <b>--></b>  Now click “run test” and save the endpoint.

Excellent! We’re set! Now all that’s left is to create a task to migrate the data from shard1 into our Aurora database!
By now you know the drill: Head over to the AWS DMS console, select Tasks and click “Create task.” Choose the following inputs:
* <b>Task name:</b> shard1-migration
* <b>Replication instance:</b> select the replication instance created above
* <b>Source endpoint:</b> select the endpoint you just created for shard1
* <b>Target endpoint:</b> select the endpoint you create for your Aurora instance
* <b>Migration Type:</b> Migrate existing data and replicate ongoing changes
* <b>Target table preparation mode:</b> Do nothing  (With this selected DMS will create the tables if they don’t exist, if they do exist, it will do nothing.)
* <b>Enable Logging:</b> check this, it’s always a good idea!
* <b>Table Mappings:</b>
* <b>Schema name is:</b> dms_sample
* <b>Action:</b> include
* <b>--></b> Now click the add selection rule

Now we have a confession to make…  we wanted to give you the ability to generate transactions against the shards. To do this we installed a couple of procedures in the shards and for this, we needed the data in the person table. So… we included it on both shard. Yeah, we know, normally this information would come from the application but hey, we’re improvising here! Bottom line – we need to exclude it from the table being migrated to our Aurora source.  To do so… under “Selection rules” click “add a selection rule.” 
* <b>Schema name is:</b> dms_sample
* <b>Table name is like:</b> person
* <b>Action:</b> exclude
* <b>--></b> Now click the add selection rule

Okay – just accept the defaults for all other options and hit the “Create task” button!
Awesome! Your task should be off and running! You can monitor it in the console. Meanwhile, while it’s running, let’s generate a few transactions. Log into your MySQL instance again and issue the following commands:

```
MySQL> use dms_sample
Database changed

MySQL >call generateTicketActivity(100,0.01);
```

This will execute “ticket purchasing” transactions against your mysql shard!

At this point, we’ve successfully migrated shard1 into our Aurora database! Well… almost. We now need to stop taking transactions in shard1, let the final transactions flow through to the Aurora database and direct traffic that was once destined for shard1 to the Aurora database, and stop the task. Boom! One shard down!
Our system now looks as follows:

![alt tag](/images/shardConsolidationStageOne.png)

To migrate shard2 follow the same process we used for shard1. Once complete you’ll have successfully consolidated three MySQL systems into a single Aurora instance!

![alt tag](/images/shardConsolidationFinal.png)

Pretty cool stuff! However, our sharded sampledb was clean, what if our shards are dirty? As discussed earlier, if your shards are dirty you can consolidate them into different databases within the Aurora instance. To do this, you can use the transformation functionality of DMS. In our example, you would create two additional databases in your Aurora instance say: dms_sample_shard1 and dms_sample_shard2. You’d then create transformations to map the dms_sample database (schema) of shard1 into dms_sample_shard1 and the dms_sample schema of shard2 into dms_sample_shard1. Viola! Your resultant Aurora system will look like this: 

![alt tag](/images/shardConsolidationAlternative.png)

We hope you’ve enjoyed the post and working through the exercise. More importantly, we hope you can see how these tools can be leveraged to consolidate your sharded systems into Aurora, and save some money doing so.
