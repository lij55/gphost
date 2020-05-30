#!/bin/bash
set -xe

if [ -z ${MASTER_DATA_DIRECTORY+x} ]; then echo "MASTER_DATA_DIRECTORY is unset";exit 1 ; fi

gpssh -f hostfile "source /usr/local/greenplum-db/greenplum_path.sh && python /home/gpadmin/artifact/get-pip.py --no-warn-script-location"

#gppkg -i /home/gpadmin/artifact/madlib.gppkg

