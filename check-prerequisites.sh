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

# FIXME: This is Mac only. Make this portable for linux/Mac (Windows is excluded)
if ! command -v "gdate" >/dev/null 2>&1
then
    echo "ERROR: command line 'gdate' required but not found. Exiting."
    exit 1
fi

