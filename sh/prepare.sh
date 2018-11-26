#!/bin/bash

set -x
if [ -z ${GPHOME+x} ]; then echo "GPHOME is unset";exit 1 ; fi


MASTERHOST=`hostname`
SEG_PREFIX=sdw
SEG_HOSTNUM=0 # 0 means muster only
SEG_NUMPERHOST=1
VERBOSE=0

function help()
{
    echo "help:"
    echo "-v: verbose"
    echo "-n number_of_segments_per_host"
    echo "-s number_of_host: default is 0, means same host as master"
}

function checkInt()
{
    expr $1 + 0 &>/dev/null
    if [ $? -ne 0 ]; then
	echo "$0: $OPTARG is not a number." >&2
	exit 1
    fi
}

while getopts :hvm:n:s: arg
do
    case $arg in
        h) help
	    exit 1
	    ;;
	
        m) MASTER="$OPTARG"
	    checkInt $MASTER
            ;;
	
        n) SEG_NUMPERHOST="$OPTARG"
	    checkInt $SEG_NUMPERHOST
            ;;
	s) SEG_HOSTNUM="$OPTARG"
	    checkInt $SEG_HOSTNUM
	    ;;
        :) echo "$0: Must supply an argument to -$OPTARG." >&2
	    help
            exit 1
            ;;
	
        \?) echo "Invalid option -$OPTARG ignored." >&2
	    help
            ;;
    esac
done


CURDIR=$(cd $(dirname $0); pwd)
PREFIX=$(pwd)
CONFIGFILE=$PREFIX/gpinitsystem_config
CONFIGTEMPLATE=$CURDIR/gpinitsystem_config_template
HOSTFILE=$PREFIX/hostfile


PORT_BASE=10000
MASTER_PORT=5432
MIRROR_PORT_BASE=30000
REPLICATION_PORT_BASE=31000
MIRROR_REPLICATION_PORT_BASE=32000
STARTDB=test


rm -rf $PREFIX/master $PREFIX/data $PREFIX/mirror
mkdir $PREFIX/master $PREFIX/data $PREFIX/mirror

SEGDATASTR=""

for i in $(seq 1 $SEG_NUMPERHOST);  do 
    SEGDATASTR="$SEGDATASTR  $PREFIX/data"
done

sed "s/%%PORT_BASE%%/$PORT_BASE/g; s|%%PREFIX%%|$PREFIX|g; s|%%SEGDATASTR%%|$SEGDATASTR|g; s/%%MASTERHOST%%/$MASTERHOST/g; s/%%MASTER_PORT%%/$MASTER_PORT/g; s/%%MIRROR_PORT_BASE%%/$MIRROR_PORT_BASE/g; s/%%REPLICATION_PORT_BASE%%/$REPLICATION_PORT_BASE/g; s/%%MIRROR_REPLICATION_PORT_BASE%%/$MIRROR_REPLICATION_PORT_BASE/g; s/%%STARTDB%%/$STARTDB/g;" $CONFIGTEMPLATE >$CONFIGFILE 

>$HOSTFILE
if [ $SEG_HOSTNUM -eq 0 ];then
    echo $MASTERHOST >  $HOSTFILE 
else
    for i in $(seq 1 $SEG_HOSTNUM); do
	echo $SEG_PREFIX$i >> $HOSTFILE
    done
fi

cat <<EOF > $PREFIX/env.sh
source $GPHOME/greenplum_path.sh
SRCDIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
export MASTER_DATA_DIRECTORY=\$SRCDIR/master/gpseg-1
export PGPORT=$MASTER_PORT
export PGHOST=$MASTER
export PGDATABASE=$STARTDB
EOF
