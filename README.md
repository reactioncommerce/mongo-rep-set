# Dockerized MongoDB Replica Set

This MongoDB Docker container is intended to be used to set up a 3 node replica set.

Mongo version:  **3.2.1**

## About

A MongoDB [replica set](https://docs.mongodb.org/v3.0/replication/) consists of at least 3 Mongo instances. In this case, they will be a primary, secondary, and an arbiter. To use this project as a replica set, you simply launch three instances of this container across three separate host servers and the primary will configure your users and replica set.  Also note that each server must be able to access the others (discovery must work in both directions).

## Setup

Before you build the container, you will need to create the keyfile that Mongo uses for [internal authentication](https://docs.mongodb.org/v3.0/tutorial/enable-internal-authentication/) between replica set members. Each of your members needs to have the same key. Do NOT commit your generated key to a public repo.

The file already exists in this repo (`mongodb-keyfile`), but it's blank. If you don't generate the key before attempting to build the container, the build script will throw an error remind you how to create the key (see below).

#### Generate keyfile

From the root of this project, run the following:

```sh
openssl rand -base64 741 > mongodb-keyfile
```

#### Build

```sh
docker build -t yourname/mongo-rep-set:latest .
```

#### Push

Push it to Docker Hub (or wherever you host Docker images).  Note that you now have a keyfile in this container that you do NOT want to share publicly.  So make sure that wherever you host this container is private.  (Another option is to use [Docker Machine](https://docs.docker.com/machine/) to [build this container on the remote servers](https://docs.docker.com/machine/get-started-cloud/) that you're going to be running them on.  That allows you to skip private container repo hosting).

```sh
docker push yourname/mongo-rep-set:latest
```

## Launch

Now you're ready to start launching containers.  You need to launch the secondary and arbiter first so they're ready for the primary to configure them when it starts.

#### Secondary

```sh
docker run -d -p 27017:27017 yourname/mongo-rep-set:latest
```

#### Arbiter

The only difference here is you can turn off journaling. From the [official docs](https://docs.mongodb.org/v3.0/tutorial/add-replica-set-arbiter/#considerations):
> An arbiter does not store data, but until the arbiter’s mongod process is added to the replica set, the arbiter will act like any other mongod process and start up with a set of data files and with a full-sized journal. To minimize the default creation of data, you can disable journaling.

```sh
docker run -d -p 27017:27017 -e JOURNLING=no yourname/mongo-rep-set:latest
```

#### Primary

The primary is responsible for setting up users and configuring the replica set, so this is where all of the configuration happens. Once your secondary and arbiter are up and running, launch your primary with:

```sh
docker run -d
  -p 27017:27017 \
  -e MONGO_ROLE="primary" \
  -e MONGO_SECONDARY="hostname or IP of secondary" \
  -e MONGO_ARBITER="hostname or IP of arbiter" \
  -e MONGO_ROOT_USER="myRootUser" \
  -e MONGO_ROOT_PASSWORD="myRootUserPassword" \
  -e MONGO_APP_USER="myAppUser" \
  -e MONGO_APP_PASSWORD="myAppUserPassword" \
  -e MONGO_APP_DATABASE="myAppDatabase" \
  yourname/mongo-rep-set:latest
```

The primary will start up, configure your root and app users, shut down, and then start up once more and configure the replica set.  Assuming the secondary and arbiter are reachable, the server will now be ready for authenticated connections.  You can use the standard two server Mongo URL to connect to the primary/secondary like this:

#### Connect

Note that the following connection url is using default env var values (more info below), so it should work if you haven't overwritten any of the variables yourself.

```sh

mongodb://myAppUser:myAppPassword@mongo1:27017,mongo2:27017/myAppDatabase?replicaSet=rs0
```

## Environment Variables

Here are all of the available environment variables and their defaults.  Note that if you set `REP_SET`, you must set it to the same value on all 3 containers.

```sh
# mongod config
STORAGE_ENGINE wiredTiger
JOURNALING yes
REP_SET rs0
AUTH yes
MONGO_SECONDARY mongo2:27017
MONGO_ARBITER mongo3:27017

# mongo root user
MONGO_ROOT_USER root
MONGO_ROOT_PASSWORD root123

# mongo app user + database (user is given oplog access)
MONGO_APP_USER myAppUser
MONGO_APP_PASSWORD myAppPassword
MONGO_APP_DATABASE myAppDatabase
```
