#!/bin/bash

mongodb_setup_cmd="gosu mongodb mongod --storageEngine $MONGO_STORAGE_ENGINE"

if [ ! -d "$MONGO_DB_PATH" ]; then
  mkdir -p $MONGO_DB_PATH
fi

chown -R mongodb:mongodb $MONGO_DB_PATH

mongodb_setup_cmd="$mongodb_setup_cmd --dbpath $MONGO_DB_PATH"

$mongodb_setup_cmd &

fg


gosu mongodb mongo admin --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  gosu mongodb mongo admin --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1
done

echo "************************************************************"
echo "Setting up users..."
echo "************************************************************"

# create root user
gosu mongodb mongo admin --eval "db.createUser({user: '$MONGO_ROOT_USER', pwd: '$MONGO_ROOT_PASSWORD', roles:[{ role: 'root', db: 'admin' }]});"

# create app user/database
gosu mongodb mongo $MONGO_APP_DATABASE --eval "db.createUser({ user: '$MONGO_APP_USER', pwd: '$MONGO_APP_PASSWORD', roles: [{ role: 'readWrite', db: '$MONGO_APP_DATABASE' }, { role: 'read', db: 'local' }]});"


echo "************************************************************"
echo "Shutting down"
echo "************************************************************"
gosu mongodb mongo admin --eval "db.shutdownServer();"

sleep 3
