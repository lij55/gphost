#!/bin/bash
set -e -x

docker build . -t mygreenplum5

docker-compose up -d
