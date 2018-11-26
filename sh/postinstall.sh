#!/bin/bash
set -xe

if [ -z ${MASTER_DATA_DIRECTORY+x} ]; then echo "MASTER_DATA_DIRECTORY is unset";exit 1 ; fi

gpssh -f hostfile "source /usr/local/greenplum-db/greenplum_path.sh && python /home/gpadmin/artifact/get-pip.py --no-warn-script-location"

echo "host all gpadmin 0.0.0.0/0 trust"  >> $MASTER_DATA_DIRECTORY/pg_hba.conf

gppkg -i /home/gpadmin/artifact/madlib.gppkg

gpstop -u

echo "source /home/gpadmin/env.sh" >> /home/gpadmin/.bashrc