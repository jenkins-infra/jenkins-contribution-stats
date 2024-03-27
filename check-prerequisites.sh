#!/usr/bin/env bash

set -e

# check wether required tools are available
if ! command -v "gh" >/dev/null 2>&1
then
    echo "ERROR: command line 'gh' required but not found. Exiting."
    exit 1
fi

if ! command -v "jq" >/dev/null 2>&1
then
    echo "ERROR: command line 'jq' required but not found. Exiting."
    exit 1
fi

if ! command -v "datamash" >/dev/null 2>&1
then
    echo "ERROR: command line 'datamash' required but not found. Exiting."
    exit 1
fi

if ! command -v "jenkins-top-submitters" >/dev/null 2>&1
then
    echo "ERROR: command line 'jenkins-top-submitters' required but not found. Exiting."
    exit 1
fi

if ! command -v "jenkins-stats" >/dev/null 2>&1
then
    echo "ERROR: command line 'jenkins-stats' required but not found. Exiting."
    exit 1
fi

# The scripts require the GNU date. A special executable needs to be installed 
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v "gdate" >/dev/null 2>&1
    then
        echo "ERROR: command line 'gdate' required but not found."
        echo "You should be able to install it with \"brew install coreutils\""
        echo ""
        echo "exiting...."
        exit 1
    fi
fi



