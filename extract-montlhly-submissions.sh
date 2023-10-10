#!/usr/bin/env bash

set -e


# check wether required tools are available
./check-prerequisites.sh

# create the data directory if it doesn't exist
[ -d data ] || mkdir data
[ -d json_data ] || mkdir json_data
##

###############
# Constants
###############



###############
# Functions
###############

# Function to retrieve the data for all organizations for a given month
# The month is split in two queries to avoid hitting limits.
getContributions(){
    local year="$1"  
    local month_decimal="$2"



    csv_filename="data/submissions-${year}-${month_decimal}.csv"

    local searched_month="${year}-${month_decimal}"
    # Jenkins-stats is a tool that will retrieve the required data from GitHub
    jenkins-stats get submitters jenkinsci "${searched_month}" -a -o "${csv_filename}"
    jenkins-stats get submitters jenkins-infra "${searched_month}" -a -o "${csv_filename}"

    # Create the pivot table for the month we downloaded
    summaryContributors="data/pr_per_submitter-${year}-${month_decimal}.csv"
    echo "user,PR" > "$summaryContributors" 
    #see https://medium.com/clarityai-engineering/back-to-basics-how-to-analyze-files-with-gnu-commands-fe9f41665eb3
    awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$csv_filename" | datamash -t, --sort --headers groupby 8 count 1 | tail -n +2 | sort  -t ',' -nr --key=2 >> "$summaryContributors"

    # retrieve the commenters for that month
    commenters_csv_filename="data/comments-${year}-${month_decimal}.csv"
    jenkins-stats get commenters "${csv_filename}" -o "${commenters_csv_filename}" 

    # Create the pivot table for the month we downloaded
    summaryCommenters="data/comments_per_commenter-${year}-${month_decimal}.csv"
    echo "user,PR" > "${summaryCommenters}"
    #see https://medium.com/clarityai-engineering/back-to-basics-how-to-analyze-files-with-gnu-commands-fe9f41665eb3
    awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$commenters_csv_filename" | datamash -t, --sort --headers groupby 2 count 1 | tail -n +2 | sort  -t ',' -nr --key=2 >> "$summaryCommenters"

}


##################
# Main processing
##################

year_to_process="$1"
# Has the year parameter been given?
if [ -z "$year_to_process" ];
then
    echo "Usage: \"extract-montlhly-contributions.sh YYYY MMM\""
    echo "   where"
    echo "      YYYY is the year (ex 2022)"
    echo "      MMM is the month in three letters (ex OCT)"
    exit 1
fi
case "$year_to_process" in
    2020) 
        ;;
    2021) 
        ;;
    2022) 
        ;;
    2023) 
        ;;
    *) echo "Unsupported year: $year_to_process"
        exit 1
        ;;
esac


month_input="$2"
# Has the year parameter been given?
if [ -z "$month_input" ];
then
    echo "Error: no month specified"
    echo "Usage: \"extract-montlhly-contributions.sh YYYY MMM\""
    echo "   where"
    echo "      YYYY is the year (ex 2022)"
    echo "      MMM is the month in three letters (ex OCT)"
    exit 1
fi
# set to uppercase
month_to_process=$(echo "$month_input" | tr '[:lower:]' '[:upper:]')
# Convert the month to its numeric value
case "$month_to_process" in
    JAN) numerical_month="01"
        ;;
    FEB) numerical_month="02"
        ;;
    MAR) numerical_month="03"
        ;;
    APR) numerical_month="04"
        ;;
    MAY) numerical_month="05"
        ;;
    JUN) numerical_month="06"
        ;;
    JUL) numerical_month="07"
        ;;
    AUG) numerical_month="08"
        ;;
    SEP) numerical_month="09"
        ;;
    OCT) numerical_month="10"
        ;;
    NOV) numerical_month="11"
        ;;
    DEC) numerical_month="12"
        ;;
    *) echo "Unsupported month: $month_to_process"
        exit 1
        ;;
esac

getContributions "$year_to_process" "$numerical_month"
