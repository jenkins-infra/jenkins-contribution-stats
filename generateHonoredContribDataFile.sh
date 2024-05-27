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

# This command is used to add the current working directory to the list of directories
# that Git considers to be safe. This is useful in situations where the ownership of the
# directory might be dubious, such as when running inside a Docker container with a different
# user than the one who owns the directory on the host machine. By adding the directory to
# the safe list, Git will not complain about the ownership of the directory.
git config --global --add safe.directory "$PWD"

# Add all changes to the staging area
git add .

# Read the third field (GitHub handle) from the honored_contributor.csv file
github_handle=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f3)

# Read the fourth field (name) from the honored_contributor.csv file
honored_contributor=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f4)

# If the name is empty, use the GitHub handle
if [ -z "$honored_contributor" ]; then
    honored_contributor=$github_handle
fi
# Commit the changes with a message that includes the honored contributor's name
echo "Adding $honored_contributor as the honored contributor."
git commit -m "Latest changes made by jenkins-stats for $honored_contributor"

# Push the changes to the remote repository
echo "Pushing the changes to the remote repository"
git push
