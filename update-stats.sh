#!/usr/bin/env bash

set -e

# to process another org than Jenkins define the "target_org" variable
# export target_org="toto"

# pro tip: define it at console level and not in this file
# export target_org="toto"

./collect-missing-data.sh "$target_org"
exit

./consolidate-data.sh submissions
./consolidate-data.sh comments
./submission-submitter-report.sh
./comment-commenter-report.sh
