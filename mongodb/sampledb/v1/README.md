#Amazon DMS Sample Database for MongoDB: version 1.0

**Installation**
* launch and log in to an ec2 instance running amazon linux
* Update your system

`sudo yum update`

**Install git

`sudo yum install -y git`

* download the code from repository (awslabs/aws-database-migration-samples) to the linux machine

  `git clone https://github.com/awslabs/aws-database-migration-samples.git`

**Install mongodb community edition
  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-amazon/

`cd ~/aws-database-migration-samples/mongodb/sampledb/v1`
`sudo cp ./config/mongodb-org-3.4.repo /etc/yum.repos.d/mongodb-org-3.4.repo`
`sudo yum install -y mongodb-org`

**start mongodb
`sudo service mongod start`

**Configure mongodb to start on reboot
`sudo chkconfig mongod on`

**Install the ruby driver for mongo and the bson extension
`sudo yum update ruby`
`sudo yum install -y gcc`
`sudo yum install -y rubygems`
`sudo yum install -y ruby-devel`
`sudo gem update --system`
`sudo gem install mongo`
`sudo gem install bson_ext`

**Install sample db:
```
./schema/load_mlb_data.rb
./schema/load_nfl_data.rb
./schema/load_name_data.rb
./schema/load_nfl_stadium_data.rb
./schema/load_sport.rb
./schema/load_sport_location.rb
./schema/load_sports_teams.rb
./schema/generate_sporting_events.rb
./schema/generate_tickets.rb
./schema/load_person.rb
```

