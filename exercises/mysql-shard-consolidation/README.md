Our sample database is based on a mock sports ticketing system. The gist of the system is to sell tickets to sporting events. An entity relationship of the system looks as follows:

![alt tag](/images/sampledb.jpg)

In our system the sporting_event_ticket and ticket_purchase_history tables are the “active” tables. All of the other tables are relatively static. Therefore, we’ve decided to shard just those two tables and consider other data as reference data. We’ve divided the system into a master node and two shards.  Data was distributed to each shard based on the sporting_event_id. So, tickets for any given sporting event will reside in a single shard, (can anyone see the problem with this?) In any case, while perhaps not ideal, it’s good enough for illustrative purposes. Our sharded system now looks like this:


![alt tag](/images/shardedERD.jpg)

![alt tag](/images/unconsolidatedShards.png)

![alt tag](/images/shardConsolidationStageOne.png)

![alt tag](/images/shardConsolidationFinal.png)

![alt tag](/images/shardConsolidationAlternative.png)
