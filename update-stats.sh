#!/usr/bin/env bash

set -e

./collect-missing-data.sh
./consolidate-data.sh
./submission-submitter-report.sh
