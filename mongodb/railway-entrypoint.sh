#!/bin/bash
# Single-node MongoDB replica set with auth, for Railway.
# First boot: initiates the replica set and creates the root user. Restarts: idempotent.
set -euo pipefail
: "${MONGO_INITDB_ROOT_USERNAME:?set MONGO_INITDB_ROOT_USERNAME}" "${MONGO_INITDB_ROOT_PASSWORD:?set MONGO_INITDB_ROOT_PASSWORD}"
export RS_NAME="${MONGO_REPLICA_SET:-rs0}"
# The member advertises 127.0.0.1, which never changes (a renamed service keeps working).
# ponytail: single member only - clients must connect with directConnection=true; a multi-node set needs real hostnames.
export RS_HOST=127.0.0.1:27017

# Railway volumes mount root-owned with lost+found.
chown -R mongodb:mongodb /data/db
# ponytail: keyfile is regenerated every boot - fine for one member; persist it on the volume before adding members.
KEY=/etc/mongo-keyfile
head -c 756 /dev/urandom | base64 -w0 > "$KEY"
chmod 400 "$KEY"; chown mongodb:mongodb "$KEY"

# --ipv6 + bind_ip_all: Railway private networking is IPv6.
gosu mongodb mongod --replSet "$RS_NAME" --bind_ip_all --ipv6 --keyFile "$KEY" --dbpath /data/db "$@" &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null; wait "$pid"; exit $?' TERM INT

until mongosh --quiet "mongodb://127.0.0.1:27017/?directConnection=true" --eval 'db.adminCommand("ping")' >/dev/null 2>&1; do
  kill -0 "$pid" 2>/dev/null || { echo "mongod exited during startup"; wait "$pid"; exit 1; }
  sleep 1
done
mongosh --quiet "mongodb://127.0.0.1:27017/admin?directConnection=true" /usr/local/share/rs-setup.js \
  || echo "WARNING: replica set setup failed (see above) - mongod keeps running"

wait "$pid"
