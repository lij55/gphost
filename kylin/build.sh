#!/bin/bash
set -e -x

docker build . -t kygp6

docker-compose up -d
