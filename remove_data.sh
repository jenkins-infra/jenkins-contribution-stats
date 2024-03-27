#!/usr/bin/env bash

set -e

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