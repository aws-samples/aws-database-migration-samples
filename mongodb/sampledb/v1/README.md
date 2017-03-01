#Amazon DMS Sample Database for MongoDB: version 1.0

**Installation**
* launch and log in to an ec2 instance running amazon linux
* Update your system

```
sudo yum update
```

**Install git**

```
sudo yum install -y git
```

**download the code from repository (awslabs/aws-database-migration-samples) to the linux machine**
```
git clone https://github.com/awslabs/aws-database-migration-samples.git
```

**Install mongodb community edition:**
  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-amazon/

```
cd ~/aws-database-migration-samples/mongodb/sampledb/v1
sudo cp ./config/mongodb-org-3.4.repo /etc/yum.repos.d/mongodb-org-3.4.repo
sudo yum install -y mongodb-org
```

**start mongodb**
```
sudo service mongod start
```

**Configure mongodb to start on reboot**
```
sudo chkconfig mongod on
```

**Install the ruby driver for mongo and the bson extension**
```
./install_ruby.sh
```

**Install sample db:**
```
./install_sampledb.sh
```

**create the dms user **
```
mongo < ./user/create_dms_user.js
```

**Set up mongo for remote access**

edit the /etc/mongod.conf file so it looks like:
```
# network interfaces
net:
  port: 27017
#  bindIp: 127.0.0.1  <- comment out this line


security:
  authorization: 'enabled'
```

**restart mongodb ***
```
sudo service mongod restart
```


##Entity Relationship Style Diagram of the System
![alt tag](/images/mongo_sampledb.png)


![alt tag](/images/mongo_sampledb_doc.png)


##Collections
**sport**
```json
{
    "_id": ObjectId("58b39c1172e49e79cfd87654"),
    "name": "football",
    "description": "description of football...",
    "league": "NFL",
    "league_name": "National Football League",
    "divisions": [{
            "name": "AFC East",
            "description": "American Football Conference East"
        },
        {
            "name": "AFC West",
            "description": "American Football Conference West"
        }
    ]
}
```

**sport location**
```json
{
    "_id": ObjectId("58b39c1e72e49e79d82b8c59"),
    "id": 1,
    "name": "Angel Stadium",
    "city": "Anaheim California",
    "seating_capacity": 45483,
    "levels": 2,
    "sections": 45,
    "seats": {
        "luxury": ["1.1.b.11", "1.1.b.21"],
        "premium": ["2.1.b.11", "2.1.b.21"],
        "standard": ["1.2.b.11", "1.2.b.21"],
        "subStandard": ["1.1.c.11", "1.1.c.21"],
        "obstructed": ["1.1.b.10", "1.1.b.20"]
    }
```

**sport team**
```json
{
    "_id": ObjectId("58b39c2f72e49e79e14310fa"),
    "sport_oid": ObjectId("58b39c1172e49e79cfd87654"),
    "sport": "football",
    "name": "Indianapolis Colts",
    "short_name": "IND",
    "division": "AFC South",
    "home_field": "Lucas Oil Stadium",
    "home_field_id": ObjectId("58b39c2a72e49e79d82b8c8d"),
    "players": [{
            "name": "Kevin Graf",
            "number": "66",
            "position": "OT",
            "status": "ACT",
            "stats": []
        },
        {
            "name": "Winston Guy",
            "number": "27",
            "position": "FS",
            "status": "ACT",
            "stats": [{
                    "TCKL": "6"
                },
                {
                    "SCK": "0"
                },
                {
                    "FF": "0"
                }
            ]
        }
    ]
}
```

**sporting event**
```json
{
	"_id" : ObjectId("58b39c3172e49e79ea1d8f4b"),
	"sport" : "baseball",
	"home_team_oid" : ObjectId("58b39c3072e49e79e143111a"),
	"home_team_name" : "San Diego Padres",
	"away_team_oid" : ObjectId("58b39c3072e49e79e143111b"),
	"away_team_name" : "Tampa Bay Rays",
	"location_oid" : ObjectId("58b39c2172e49e79d82b8c6c"),
	"event_date" : ISODate("2017-04-01T15:00:00Z")
}
```

**sporting event ticket**
```json
{
    "_id": ObjectId("58b39c3372e49e79f3b0b704"),
    "event_oid": ObjectId("58b39c3172e49e79ea1d8f4b"),
    "event_location_oid": ObjectId("58b39c2172e49e79d82b8c6c"),
    "seat_quality": "luxury",
    "price": 147.15,
    "level": "1",
    "section": "1",
    "row": "c",
    "seat": "5",
    "number": "1.1.c.5"
}
```

**person**
```json
{
    "_id": ObjectId("58b36a1272e49e772ec96962"),
    "id": 16589,
    "first_name": "Willie",
    "last_name": "Mac",
    "full_name": "Willie Mac"
}
```
