#!/bin/bash
set -m

if [ "$MONGO_ROLE" == "primary" ]; then
  /opt/mongo/mongo_setup_users.sh
fi

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE --keyFile /opt/mongo/mongodb-keyfile"
cmd="$mongodb_cmd --httpinterface --rest --replSet $REP_SET"

if [ "$AUTH" == "yes" ]; then
  cmd="$cmd --auth"
fi

if [ "$JOURNALING" == "no" ]; then
  cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
  cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

$cmd &

if [ "$MONGO_ROLE" == "primary" ]; then
  /opt/mongo/mongo_setup_repset.sh
fi

fg


