#!/bin/bash
set -e -x

docker build . -t mygreenplum7

docker-compose up -d
