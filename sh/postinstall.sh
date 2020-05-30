#!/bin/bash
set -xe

if [ -z ${MASTER_DATA_DIRECTORY+x} ]; then echo "MASTER_DATA_DIRECTORY is unset";exit 1 ; fi


echo "host all gpadmin 0.0.0.0/0 trust"  >> $MASTER_DATA_DIRECTORY/pg_hba.conf

gpstop -u

echo "source /home/gpadmin/env.sh" >> /home/gpadmin/.bashrc

