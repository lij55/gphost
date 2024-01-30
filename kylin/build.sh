#!/bin/bash
set -e -x

docker build . -t kypdb6

docker-compose up -d
