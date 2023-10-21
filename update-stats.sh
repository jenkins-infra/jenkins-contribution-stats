#!/usr/bin/env bash

set -e

# if no org is specified, the jenkins org is processed
target_org="$1"

./collect-missing-data.sh "$target_org"
./consolidate-data.sh submissions "$target_org"
./consolidate-data.sh comments "$target_org"
./submission-submitter-report.sh "$target_org"
./comment-commenter-report.sh "$target_org"
