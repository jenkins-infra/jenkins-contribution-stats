#!/usr/bin/env bash

# This script is used to honor a contributor based on their contributions in a specific month.
# If no month is specified, it defaults to the previous month.

set -e  # Exit immediately if a command exits with a non-zero status.

# Check if the GitHub Personal Access token is defined.
# If not, print an error message and exit the script.
if [ -z ${GITHUB_TOKEN+x} ]; then echo "Error: the GitHub Personal Access token (\$GITHUB_TOKEN) is not defined. Aborting..."; exit; fi

# Check whether required tools are available.
# This script is expected to be in the same directory as check-prerequisites.sh.
./check-prerequisites.sh

# Make sure that we are using GNU Date on MacOS.
# If the script is running on MacOS, use gdate. Otherwise, use date.
if [[ "$OSTYPE" == "darwin"* ]]; then
    gnu_date="gdate"
else
    gnu_date="date"
fi

month_to_process="$1"

# Has month to process been specified? If not compute it.
# If the user did not provide a month to process, compute the previous month.
if [ -z "$month_to_process" ];
then
    # Compute the year and month for the previous month.
    to_process_year=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%Y)
    to_process_month=$(${gnu_date} -d "$(date +%Y-%m-1) -1 month" +%m)

    month_to_process="${to_process_year}-${to_process_month}"
    echo "no specific target month supplied. Taking the previous month."
fi

# Perform the query and generate the data file data/honored_contributor.csv.
# The jenkins-stats command is expected to be in the PATH.
jenkins-stats honor "$month_to_process" --data_dir=data/ -v

# Add the current working directory to the list of directories that Git considers to be safe.
# This is to prevent Git from refusing to work with files in the current directory.
git config --global --add safe.directory "$PWD"

# Add all changes to the staging area.
# This prepares the changes for a commit.
git add .

# Read the third field (GitHub handle) from the honored_contributor.csv file
# This is the GitHub handle of the honored contributor.
github_handle=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f3 | tr -d '[:space:]' | tr -d '"')

# Read the fourth field (name) from the honored_contributor.csv file
# This is the name of the honored contributor.
honored_contributor=$(tail -n 1 data/honored_contributor.csv | cut -d',' -f4 | tr -d '[:space:]' | tr -d '"')

# If the name is empty, use the GitHub handle
# This is to ensure that the honored contributor is always identified.
if [ -z "$honored_contributor" ]; then
    honored_contributor=$github_handle
fi

# Print a message indicating that the honored contributor is being added.
echo "Adding $honored_contributor as the honored contributor."

#echo "GitHub ENV file is: $GITHUB_ENV"

# Set the honored_contributor as an output variable using an environment file.
echo "HONORED_CONTRIBUTOR=$honored_contributor" >> $GITHUB_ENV
