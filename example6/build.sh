#!/bin/bash
set -e -x

docker build . -t mygreenplum6

docker-compose up -d
