#!/bin/bash
set -m

if [ "$MONGO_ROLE" == "primary" ]; then
  $MONGO_SCRIPTS_DIR/mongo_setup_users.sh
fi

mongodb_cmd="gosu mongodb mongod --storageEngine $MONGO_STORAGE_ENGINE --keyFile $MONGO_KEYFILE"
cmd="$mongodb_cmd --httpinterface --rest --replSet $MONGO_REP_SET"

if [ "$MONGO_AUTH" == true ]; then
  cmd="$cmd --auth"
fi

if [ "$MONGO_JOURNALING" == false ]; then
  cmd="$cmd --nojournal"
fi

if [[ "$MONGO_OPLOG_SIZE" ]]; then
  cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

if [ ! -d "$MONGO_DB_PATH" ]; then
  mkdir -p $MONGO_DB_PATH
fi

chown -R mongodb:mongodb $MONGO_DB_PATH

$cmd --dbpath $MONGO_DB_PATH &

if [ "$MONGO_ROLE" == "primary" ]; then
  $MONGO_SCRIPTS_DIR/mongo_setup_repset.sh
fi

fg
