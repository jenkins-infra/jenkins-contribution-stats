#!/usr/bin/env bash

set -e

cp ../consolidated_data/submissions.csv ./DB_dockerDir/

docker compose build db
docker compose up -d
