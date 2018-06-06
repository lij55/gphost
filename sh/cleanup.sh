#!/bin/bash


killall -9 postgres || pkill -9 postgres || echo "failed to kill postgress?"

rm -f /tmp/.s.PGSQL.*
rm -rf data/* master/* mirror/*
