

-- unload the data to /tmp by default
use dms_sample
source ./shard/unload_person.sql
source ./shard/unload_sporting_event_ticket.sql
