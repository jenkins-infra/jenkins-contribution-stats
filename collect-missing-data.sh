#!/usr/bin/env bash

set -e

oldest_year=2020
oldest_month=01

today_year=$(date '+%Y')
today_month=$(date '+%b')
current_year_month="${today_month} ${today_year}"


i=0
while :
do
    to_process_year=$(gdate -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%Y")
    to_process_month=$(gdate -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%b")
    to_process_month_decimal=$(gdate -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%m")

    full_to_process_date="${to_process_month} ${to_process_year}"

    if [[ "$current_year_month" == "$full_to_process_date" ]]; then
        echo "done..."
        break
    fi    

    echo " "
    echo "Processing ${full_to_process_date}"

    csv_filename="data/submissions-${to_process_year}-${to_process_month_decimal}.csv"
    if [ -f "$csv_filename" ] 
    then
        echo "Data file \"$csv_filename\" already exist. Skipping....."
    else
        ./extract-montlhly-submissions.sh "$to_process_year" "$to_process_month"
    fi

    # For Debug
    if [[ "$i" == '4' ]]; then
        echo "STOP !!!!"
        break
    fi
    ((i++))
done


