#!/usr/bin/env bash

set -e


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
    org_data_consolidation_dir="./consolidated_data"
else
    org_data_dir="alt_orgs/${org_to_process}/data"
    org_data_consolidation_dir="alt_orgs/${org_to_process}/consolidated_data"
fi

# create the data directory if it doesn't exist
[ -d "$org_data_dir" ] || mkdir -p "$org_data_dir"
[ -d "$org_data_consolidation_dir" ] || mkdir -p "$org_data_consolidation_dir"





# Constants
oldest_year=2020
oldest_month=01

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


output_dir="$org_data_consolidation_dir"
[ -d $output_dir ] || mkdir $output_dir

report_filename="${output_dir}/summary_comment_counts.csv"
echo "month,comments,commenter" > $report_filename


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


    csv_filename="$org_data_dir/comments-${to_process_year}-${to_process_month}.csv"
    if [ -f "$csv_filename" ] 
    then
        temp_nbr=$(tail -n +2 "$csv_filename" | wc -l)
        number_submissions=$(echo "$temp_nbr" | xargs)
    else
        number_submissions="0"
    fi

    submitter_csv_filename="$org_data_dir/comments_per_commenter-${to_process_year}-${to_process_month}.csv"
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
    i=$((i+1))
 done