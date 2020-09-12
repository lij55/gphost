#!/bin/bash
source /opt/greenplum/greenplum_path.sh

function initgp {
    set -e
    BASE_PORT=40000
    MASTER_PORT=5432
    NUM_SEGMENTS=3
    BASE_DIR=${1:-opt}

    initdb -k -n -D ${BASE_DIR}/data-master

    cat >> ${BASE_DIR}/data-master/postgresql.conf <<EOF
max_connections=150
shared_buffers=64MB
port=$MASTER_PORT
listen_addresses='0.0.0.0'
EOF

    for (( i=0; i<$NUM_SEGMENTS; i++ ))
    do
        cp -a ${BASE_DIR}/data-master ${BASE_DIR}/data-seg$i
    done

    cat >> ${BASE_DIR}/data-master/postgresql.conf <<EOF
gp_dbid=1
gp_contentid=-1
fsync=off
optimizer=off
EOF

    for (( i=0; i<$NUM_SEGMENTS; i++ ))
    do
    cat >> ${BASE_DIR}/data-seg$i/postgresql.conf <<EOF
gp_dbid=$(($i + 2))
gp_contentid=$i
port=$(($BASE_PORT + $i))
fsync=off
EOF
    done


    postgres --single -D ${BASE_DIR}/data-master postgres <<EOF
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) values (1, -1, 'p', 'p', 's', 'u', $MASTER_PORT, 'localhost', 'localhost');
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) select g+1, g-1, 'p', 'p', 's', 'u', $BASE_PORT+g-1, 'localhost', 'localhost' from generate_series(1, $NUM_SEGMENTS) g;
EOF

    for (( i=0; i<$NUM_SEGMENTS; i++ ))
    do
    postgres --single -D ${BASE_DIR}/data-seg$i postgres <<EOF
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) values (1, -1, 'p', 'p', 's', 'u', $MASTER_PORT, 'localhost', 'localhost');
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) select g+1, g-1, 'p', 'p', 's', 'u', $BASE_PORT+g-1, 'localhost', 'localhost' from generate_series(1, $NUM_SEGMENTS) g;
EOF
    done
}

function startgp {
    BASE_DIR=${1:-opt}
    pg_ctl start -D ${BASE_DIR}/data-seg0/ >${BASE_DIR}/log-seg0.log
    pg_ctl start -D ${BASE_DIR}/data-seg1/ >${BASE_DIR}/log-seg1.log
    pg_ctl start -D ${BASE_DIR}/data-seg2/ >${BASE_DIR}/log-seg2.log
    pg_ctl start -D ${BASE_DIR}/data-master/ -o '-E' >${BASE_DIR}/log-master.log
}

function stopgp {
    BASE_DIR=${1:-opt}
    pg_ctl stop -D ${BASE_DIR}/data-master/ -m fast
    pg_ctl stop -D ${BASE_DIR}/data-seg0/
    pg_ctl stop -D ${BASE_DIR}/data-seg1/
    pg_ctl stop -D ${BASE_DIR}/data-seg2/
}

FILE=/home/gpadmin/.gp_init_done
if [ ! -f "$FILE" ]; then
    initgp /home/gpadmin
    echo "host all gpadmin 0.0.0.0/0 trust"  >> /home/gpadmin/data-master/pg_hba.conf
fi

if [ ! -f "$FILE" ]; then
    startgp /home/gpadmin
fi

while :
do
	sleep 30
done
