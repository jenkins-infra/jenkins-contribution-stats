#!/usr/bin/env bash

# This script is used to honor a contributor based on their contributions in a specific month.
# If no month is specified, it defaults to the previous month.

set -e  # Exit immediately if a command exits with a non-zero status.

# Check if the GitHub Personal Access token is defined.
if [ -z ${GITHUB_TOKEN+x} ]; then echo "Error: the GitHub Personal Access token (\$GITHUB_TOKEN) is not defined. Aborting..."; exit; fi

# Check whether required tools are available.
./check-prerequisites.sh

# Make sure that we are using GNU Date on MacOS.
if [[ "$OSTYPE" == "darwin"* ]]; then
    gnu_date="gdate"
else
    gnu_date="date"
fi

month_to_process="$1"

# Has month to process been specified? If not compute it.
if [ -z "$month_to_process" ];
then
    # Compute the year and month for the previous month.
    to_process_year=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%Y)
    to_process_month=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%m)

    month_to_process="${to_process_year}-${to_process_month}"
    echo "no specific target month supplied. Taking the previous month."
fi

# Perform the query and generate the data file data/honored_contributor.csv.
jenkins-stats honor "$month_to_process" --data_dir=data/ -v

# Add the current working directory to the list of directories that Git considers to be safe.
git config --global --add safe.directory "$PWD"

# Add all changes to the staging area.
git add .

# Read the third field (GitHub handle) from the honored_contributor.csv file
github_handle=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f3 | tr -d '"')

# Read the fourth field (name) from the honored_contributor.csv file
honored_contributor=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f4 | tr -d '"')

# If the name is empty, use the GitHub handle
if [ -z "$honored_contributor" ]; then
    honored_contributor=$github_handle
fi

# Commit the changes with a message that includes the honored contributor's name or GitHub handle
echo "Adding $honored_contributor as the honored contributor."
git commit -m "Latest changes made by jenkins-stats for $honored_contributor"

# Push the changes to the remote repository
echo "Pushing the changes to the remote repository"
git push
