#!/usr/bin/env bash

# This script is used to honor a contributor based on their contributions in a specific month.
# If no month is specified, it defaults to the previous month.

# Exit immediately if a command exits with a non-zero status.
set -e

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

# The month to process is passed as an argument to the script.
# If no month is specified, it defaults to the previous month.
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

# Path to the CSV file
csv_file="data/honored_contributor.csv"
# Red color
RED='\033[31m'
# No color
NC='\033[0m'

# Check if the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo -e "${RED}Error: ${NC}$csv_file does not exist."
    exit 1
fi

# Check if the CSV file is not empty
if [ ! -s "$csv_file" ]; then
    echo -e "${RED}Error: ${NC}$csv_file is empty."
    exit 1
fi

# Check if the CSV file is valid (i.e., it has the correct number of columns)
num_columns=$(head -n 1 "$csv_file" | tr ',' '\n' | wc -l)
if [ "$num_columns" -ne 9 ]; then
    echo -e "${RED}Error: ${NC}$csv_file is not valid. It should have 9 columns but it has $num_columns."
    cat "$csv_file"
    exit 1
fi

python3 .github/workflows/check-csv.py $csv_file

# If the CSV file is valid and not empty, print a success message.
echo -e "\e[36m$csv_file\e[33m is valid and not empty."

# Read the third field (GitHub handle) from the honored_contributor.csv file
# This is the GitHub handle of the honored contributor.
github_handle=$(tail -n 1 $csv_file | cut -d',' -f3 | tr -d '[:space:]' | tr -d '"')

# Read the fourth field (name) from the honored_contributor.csv file
# This is the name of the honored contributor.
honored_contributor=$(tail -n 1 $csv_file | cut -d',' -f4 | tr -d '[:space:]' | tr -d '"')

# If the name is empty, use the GitHub handle
# This is to ensure that the honored contributor is always identified.
if [ -z "$honored_contributor" ]; then
    honored_contributor=$github_handle
fi

# Print a message indicating that the honored contributor is being added.
echo -e "Adding \e[36m$honored_contributor\e[33m as the honored contributor."

# Check if the GITHUB_ENV variable is defined.
# If not, create it using mktemp.
if [ -z ${GITHUB_ENV+x} ]; then
    GITHUB_ENV=$(mktemp)
    echo -e "\e[36mGITHUB_ENV \e[33mis unset (I guess you're not in a GitHub action), so I'm creating a new temporary file \e[36m$GITHUB_ENV\e[33m so the script won't fail.\e[0m"
    # Set a trap to delete the temporary file when the script exits.
    trap "rm -f $GITHUB_ENV" EXIT
else
    echo "GITHUB_ENV is set to '$GITHUB_ENV'"
fi
# Set the honored_contributor as an output variable using an environment file.
echo "HONORED_CONTRIBUTOR=$honored_contributor" >> $GITHUB_ENV
