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

