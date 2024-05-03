#!/usr/bin/env bash

set -e

if [ -z ${GITHUB_TOKEN+x} ]; then echo "Error: the GitHub Personal Access token (\$GITHUB_TOKEN) is not defined. Aborting..."; exit; fi

# if no org is specified, the jenkins org is processed
target_org="$1"

./collect-missing-data.sh "$target_org"
./consolidate-data.sh submissions "$target_org"
./consolidate-data.sh comments "$target_org"
./submission-submitter-report.sh "$target_org"
./comment-commenter-report.sh "$target_org"

if [ -z "$target_org" ];
then
    target_org="jenkins"
fi

echo ""
echo "🍻 - Processing of $target_org successfuly ended"
echo ""
