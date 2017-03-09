#
#  Copyright 2017 Amazon.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.



# You can restore the following snapshots to create a sharded version of the sampledb that includes two shards
#      mysql-sampledb-master-shard
#      mysql-sampledb-shard1
#      mysql-sampledb-shard2



########################################################
# If you want to create the sharded system yourself you 
# can follow the following instructions
########################################################





########################################################
#
# To create a mock sharded system follow these instructions
#
# run them by hand
#

#########################################################

Start by creating a master instance on RDS. The instructions are located here:
../../mysql/sampledb/v1/READ.md
../../mysql/sampledb/v1/install-rds.sql


Once complete you will need to launch as many empty mysql instances as you need shards. For the default example, 2 should be sufficient.

#############################################################################
#                          export shard data
#############################################################################
#
# The following assumes you are connecting to your mysql instances from a linux server
#
# Dump the person, sporting_event_ticket, and ticket_purchase_hist tables
# You can create as many shards as you want. The below statements are set up
# for 1 reference data instance (master shard) and two shards.  
# NOTE: the first statement dumps the person table that should be loaded into 
# each shard.
#############################################################################
mysqldump -h <your sampledb source host> -u dbmaster --extended-insert --disable-keys -p  dms_sample person ticket_purchase_hist > /tmp/dms_sample_shard_data.dmp
mysqldump -h <your sampledb source host> -u dbmaster --extended-insert --disable-keys -p --where="mod(sporting_event_id,2)+1=1" dms_sample sporting_event_ticket  > /tmp/dms_sample_shard1_data.dmp
mysqldump -h <your sampledb source host> -u dbmaster --extended-insert --disable-keys -p --where="mod(sporting_event_id,2)+1=2" dms_sample sporting_event_ticket  > /tmp/dms_sample_shard2_data.dmp

########################-
# Log into each shard and do the following
########################-
source ../../mysql/sampledb/v1/schema/create_dms_sample.sql
source ../../mysql/sampledb/v1/user/create_dms_user.sql
source ../../mysql/sampledb/v1/user/dms_user_privileges.sql

use dms_sample
source /tmp/dms_sample_shard_data.dmp

###################################################################################
# Note the following should run a different loadd for each shard based on the data
# unloaded in the above statements.
#
# !!! Don't forget to replace the <n> with the shard number you intend to use  !!!
###################################################################################
source /tmp/dms_sample_shard<n>_data.dmp

###################################################################################
# The following should be run on all shards
###################################################################################
source ../../mysql/sampledb/v1/schema/sell_tickets.sql
source ./schema/generate_ticket_activity.sql
source ../../mysql/sampledb/v1/schema/generate_transfer_activity.sql

alter table sporting_event_ticket drop foreign key set_sporting_event_fk;
alter table sporting_event_ticket drop foreign key set_person_id;
alter table sporting_event_ticket drop foreign key set_seat_fk;
alter table ticket_purchase_hist drop foreign key tph_ticketholder_id;
alter table ticket_purchase_hist drop foreign key tph_transfer_from_id;
