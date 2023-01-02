#!/usr/bin/env bash

set -eu -o pipefail

cp ../consolidated_data/submissions.csv ./DB_dockerDir/

docker compose up -d —-build —-force-recreate
