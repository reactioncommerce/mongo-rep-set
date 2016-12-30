#!/bin/bash
set -m

if [ "$MONGO_ROLE" == "primary" ]; then
  $MONGO_SCRIPTS_DIR/mongo_setup_users.sh
fi

mongodb_cmd="gosu mongodb mongod --storageEngine $MONGO_STORAGE_ENGINE --keyFile $MONGO_KEYFILE"
cmd="$mongodb_cmd --httpinterface --rest --replSet $REP_SET"

if [ "$AUTH" == true ]; then
  cmd="$cmd --auth"
fi

if [ "$JOURNALING" == false ]; then
  cmd="$cmd --nojournal"
fi

if [[ "$OPLOG_SIZE" ]]; then
  cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

if [[ "$MONGO_DB_PATH" ]]; then
  if [ ! -d "$MONGO_DB_PATH" ]; then
    echo "Creating custom directory for MongoDB data at $MONGO_DB_PATH"
    mkdir -p $MONGO_DB_PATH
  fi
  cmd="$cmd --dbpath $MONGO_DB_PATH"
fi

printf "Starting MongoDB with command: \n"
printf "\n$cmd \n"

$cmd &

if [ "$MONGO_ROLE" == "primary" ]; then
  $MONGO_SCRIPTS_DIR/mongo_setup_repset.sh
fi

fg
