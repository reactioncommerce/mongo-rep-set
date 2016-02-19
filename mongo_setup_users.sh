#!/bin/bash

mongodb_setup_cmd="mongod --storageEngine $STORAGE_ENGINE"

if [ "$MONGO_DB_PATH" != "" ]; then
  if [ ! -d "$MONGO_DB_PATH" ]; then
    echo "Creating custom directory for MongoDB data at $MONGO_DB_PATH"
    mkdir -p $MONGO_DB_PATH
  fi
  mongodb_setup_cmd="$mongodb_setup_cmd --dbpath $MONGO_DB_PATH"
fi

$mongodb_setup_cmd &

fg


mongo admin --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongo admin --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1
done

echo "************************************************************"
echo "Setting up users..."
echo "************************************************************"

# create root user
mongo admin --eval "db.createUser({user: '$MONGO_ROOT_USER', pwd: '$MONGO_ROOT_PASSWORD', roles:[{ role: 'root', db: 'admin' }]});"

# create app user/database
mongo $MONGO_APP_DATABASE --eval "db.createUser({ user: '$MONGO_APP_USER', pwd: '$MONGO_APP_PASSWORD', roles: [{ role: 'readWrite', db: '$MONGO_APP_DATABASE' }, { role: 'read', db: 'local' }]});"


echo "************************************************************"
echo "Shutting down"
echo "************************************************************"
mongo admin --eval "db.shutdownServer();"

sleep 3
