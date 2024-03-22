#!/usr/bin/env bash

set -e

# Check if we have to deal with another organisation then Jenkins
# if requested, its name is passed as a paramter. (undefined means "jenkins")

org_to_process="$1"

# Has the org parameter been given?
if [ -z "$org_to_process" ];
then
    echo "Processing the Jenkins org (no alternate org specified)"
    org_to_process="jenkins"
fi

if [[ "$org_to_process" == "jenkins" ]];
then
    org_data_dir="data"
else
    org_data_dir="alt_orgs/${org_to_process}/data"
fi


# create the data directory if it doesn't exist
[ -d "$org_data_dir" ] || mkdir -p "$org_data_dir"


## All is setup, let's go to work

oldest_year=2020
oldest_month=01

today_year=$(date '+%Y')
today_month=$(date '+%b')
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
    to_process_month=$(${gnu_date} -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%b")
    to_process_month_decimal=$(${gnu_date} -d "${oldest_year}/${oldest_month}/1 + ${i} month" "+%m")

    full_to_process_date="${to_process_month} ${to_process_year}"

    if [[ "$current_year_month" == "$full_to_process_date" ]]; then
        echo "done..."
        break
    fi    

    echo " "
    echo "Processing ${full_to_process_date}"

    csv_filename="${org_data_dir}/submissions-${to_process_year}-${to_process_month_decimal}.csv"
    if [ -f "$csv_filename" ] 
    then
        echo "Data file \"$csv_filename\" already exist. Skipping....."
    else
        ./extract-montlhly-submissions.sh "$to_process_year" "$to_process_month" "$org_to_process"
        echo "Creating $csv_filename"
    fi

    # # For Debug
    # if [[ "$i" == '3' ]]; then
    #     echo "STOP !!!!"
    #     break
    # fi

    i=$((i+1))
done


