#!/usr/bin/env bash

set -e

./collect-missing-data.sh
./consolidate-data.sh submissions
./consolidate-data.sh comments
./submission-submitter-report.sh
./comment-commenter-report.sh
