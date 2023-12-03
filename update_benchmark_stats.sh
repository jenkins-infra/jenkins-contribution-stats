#!/usr/bin/env bash

set -e

./update-stats.sh "FFmpeg"
./update-stats.sh "gradle"
./update-stats.sh "nodejs"
./update-stats.sh "symfony"
./update-stats.sh "updateCLI"
