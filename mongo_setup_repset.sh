#!/bin/bash

echo "************************************************************"
echo "Setting up replica set"
echo "************************************************************"

RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for MongoDB to start"
  sleep 5
  mongo admin --eval "help" >/dev/null 2>&1
  RET=$?
done

# Login as root and configure replica set
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.initiate();"
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.add('$MONGO_SECONDARY');"
mongo admin -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD --eval "rs.addArb('$MONGO_ARBITER');"
