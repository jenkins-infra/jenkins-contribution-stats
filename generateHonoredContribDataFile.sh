#!/usr/bin/env bash

set -e

if [ -z ${GITHUB_TOKEN+x} ]; then echo "Error: the GitHub Personal Access token (\$GITHUB_TOKEN) is not defined. Aborting..."; exit; fi

# check wether required tools are available
./check-prerequisites.sh


# Make sure that we are using GNU Date on MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    gnu_date="gdate"
else
    gnu_date="date"
fi

month_to_process="$1"

# Has month to process been specified? If not compute it. 
if [ -z "$month_to_process" ];
then
    to_process_year=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%Y)
    to_process_month=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%m)

    month_to_process="${to_process_year}-${to_process_month}"
    echo "no specific target month supplied. Taking the previous month."
fi

# no specific parameter check: it is handled by the application
echo "Picking the submitter to honor in ${month_to_process}"

# perform the query and generates the data file data/honored_contributor.csv
jenkins-stats honor "$month_to_process" --data_dir=data/ -v

# Add all changes to the staging area
git add .

# Commit the changes with a message
echo "Committing the changes to the local repository"
git commit -m "Latest changes made by jenkins-stats"

# Push the changes to the remote repository
echo "Pushing the changes to the remote repository"
git push
