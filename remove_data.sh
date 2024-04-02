#!/usr/bin/env bash

set -e

# The target version of the jenkins-stats tool that we want to have installed.
target_version=0.2.14

# Fetch the currently installed version of the jenkins-stats tool.
# The 'awk' command is used to extract the version number from the output of the 'jenkins-stats version' command.
installed_version=$(jenkins-stats version | awk '{print $NF}')

# Compare the installed version with the target version.
# The 'sort -V' command is used to sort the version numbers in version sort order, and 'head -n 1' is used to get the smallest version.
# If the smallest version is not the target version, it means the installed version is less than the target version.
if [[ $(echo -e "$target_version\n$installed_version" | sort -V | head -n 1) != "$target_version" ]]; then
    # If the installed version is less than the target version, print an error message in red and bold.
    echo -e "\e[1;31mError: installed version ($installed_version) is less than target version ($target_version).\e[0m"
    # Suggest the user to update the jenkins-stats tool using the 'brew upgrade' command.
    echo -e "Please update the jenkins-stats tool thanks to the following command:"
    # Print the 'brew upgrade' command in blue and bold.
    echo -e "\e[1;34mbrew\e[0m upgrade jenkins-stats"
    # Exit the script with a status of 1 to indicate an error.
    exit 1
fi

# Constants
oldest_year=2020
oldest_month=01
org_data_dir="data"

# initialize data
today_year=$(date '+%Y')
today_month=$(date '+%m')
current_year_month="${today_month} ${today_year}"

# Make sure that we are using GNU Date on MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    gnu_date="gdate"
else
    gnu_date="date"
fi


i=0
while :
do
    to_process_year=$(${gnu_date} -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%Y")
    to_process_month=$(${gnu_date} -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%m")

    full_to_process_date="${to_process_month} ${to_process_year}"

    if [[ "$current_year_month" == "$full_to_process_date" ]]; then
        echo "done..."
        break
    fi    

    submission_filename="$org_data_dir/submissions-${to_process_year}-${to_process_month}.csv"
    comment_filename="$org_data_dir/comments-${to_process_year}-${to_process_month}.csv"
    per_submitter_filename="$org_data_dir/pr_per_submitter-${to_process_year}-${to_process_month}.csv"
    per_comment_filename="$org_data_dir/comments_per_commenter-${to_process_year}-${to_process_month}.csv"

    jenkins-stats remove file:jenkins-excluded-users.txt "$submission_filename"
    jenkins-stats remove file:jenkins-excluded-users.txt "$comment_filename"
    jenkins-stats remove file:jenkins-excluded-users.txt "$per_submitter_filename"
    jenkins-stats remove file:jenkins-excluded-users.txt "$per_comment_filename"
    echo "--"

    # For Debug
    # if [[ "$i" == '2' ]]; then
    #     echo "STOP !!!!"
    #     break
    # fi
    i=$((i+1))
done
