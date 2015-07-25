#!/bin/bash

mongod --storageEngine $STORAGE_ENGINE &

fg


RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for MongoDB to start"
  sleep 5
  mongo admin --eval "help" >/dev/null 2>&1
  RET=$?
done

echo "************************************************************"
echo "Setting up users..."
echo "************************************************************"

# create root user
mongo admin --eval "db.createUser({user: '$MONGO_ROOT_USER', pwd: '$MONGO_ROOT_PASSWORD', roles:[{ role: 'root', db: 'admin' }]});"

# create app user/database
mongo $MONGO_APP_DATABASE --eval "db.createUser({user: '$MONGO_APP_USER', pwd: '$MONGO_APP_PASSWORD', roles:[{role:'readWrite', db:'$MONGO_APP_DATABASE'}]});"


echo "************************************************************"
echo "Shutting down"
echo "************************************************************"
mongo admin --eval "db.shutdownServer();"

sleep 3
