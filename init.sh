if [ -z "$MASTER_HOST" ]; then
    MASTER_HOST=master
fi

if [ -z "$MASTER_PORT" ]; then
    MASTER_PORT=5432
fi

if [ -z "$REPLICATION_USER" ]; then
    REPLICATION_USER=repuser
fi

if [ -z "$REPLICATION_PASS" ]; then
    REPLICATION_PASS=pass
fi

echo "Setting replication credentials"
echo "*:*:*:$REPLICATION_USER:$REPLICATION_PASS" >> ~/.pgpass
chmod 600 ~/.pgpass

echo "Wait for a second for master to start up"
sleep 3

echo "Running pg_basebackup as $REPLICATION_USER"
pg_basebackup -h $MASTER_HOST -p $MASTER_PORT -D "$PGDATA/datarep" -U $REPLICATION_USER --verbose

echo "Configuring mirror for standby + reads"
echo "listen_addresses = '*'" >> "$PGDATA/datarep/postgresql.conf"
echo "hot_standby = on" >> "$PGDATA/datarep/postgresql.conf"

echo "Writing recovery.conf file"
bash -c "cat > $PGDATA/datarep/recovery.conf <<- _EOF1_
  standby_mode = 'on'
  primary_conninfo = 'host=$MASTER_HOST port=$MASTER_PORT user=$REPLICATION_USER password=$REPLICATION_PASS'
  trigger_file = '/tmp/postgresql.trigger'
_EOF1_
"

echo "Setting permissions for new data directory"
chown -R postgres:postgres "$PGDATA/datarep"

