#!/usr/bin/env bash

set -e

# Constants
oldest_year=2020
oldest_month=01

# initialize data
today_year=$(date '+%Y')
today_month=$(date '+%m')
current_year_month="${today_month} ${today_year}"

output_dir="consolidated_data"
[ -d $output_dir ] || mkdir $output_dir

report_filename="${output_dir}/summary_comment_counts.csv"
echo "month,comments,commenter" > $report_filename


i=0
while :
do
    to_process_year=$(gdate -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%Y")
    to_process_month=$(gdate -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%m")

    full_to_process_date="${to_process_month} ${to_process_year}"

    if [[ "$current_year_month" == "$full_to_process_date" ]]; then
        echo "done..."
        break
    fi    


    csv_filename="data/comments-${to_process_year}-${to_process_month}.csv"
    if [ -f "$csv_filename" ] 
    then
        temp_nbr=$(tail -n +2 "$csv_filename" | wc -l)
        number_submissions=$(echo "$temp_nbr" | xargs)
    else
        number_submissions="0"
    fi

    submitter_csv_filename="data/comments_per_commenter-${to_process_year}-${to_process_month}.csv"
    if [ -f "$submitter_csv_filename" ] 
    then
        temp_nbr=$(tail -n +2 "$submitter_csv_filename" | wc -l)
        number_submitters=$(echo "$temp_nbr" | xargs)
    else
        number_submitters="0"
    fi

    echo "\"${to_process_month}-${to_process_year}\",${number_submissions},${number_submitters}"
    echo "\"${to_process_month}-${to_process_year}\",${number_submissions},${number_submitters}" >> $report_filename

    # For Debug
    # if [[ "$i" == '4' ]]; then
    #     echo "STOP !!!!"
    #     break
    # fi
    ((i++))
done