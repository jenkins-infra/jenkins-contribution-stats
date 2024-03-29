#!/usr/bin/env bash

set -e

target_version=1.2.6
installed_version=$(jenkins-top-submitters version | awk '{print $NF}')

if [[ $(echo -e "$target_version\n$installed_version" | sort -V | head -n 1) != "$target_version" ]]; then
    echo -e "\e[1;31mError: installed version ($installed_version) is less than target version ($target_version).\e[0m"
    echo -e "Please update the jenkins-top-submitters tool thanks to the following command:"
    echo -e "\e[1;34mbrew\e[0m upgrade jenkins-top-submitters"
    exit 1
fi

consolidation_type="$1"
# Has the parameter been given?
if [ -z "$consolidation_type" ];
then
    echo "Usage: \"consolidate-data.sh [TYPE]\""
    echo "   where"
    echo "      TYPE is the consolidation type requested (\"submissions\" or \"comments\")"
    exit 1
fi
top_type="unknown"
uppercased_consolidation_type=$(echo "$consolidation_type" | awk '{print toupper($0)}')
case "$uppercased_consolidation_type" in
    SUBMISSIONS) 
        top_type="submitters"
        ;;
    COMMENTS) 
        top_type="commenters"
        ;;
    *) echo "Unsupported consolidation type ($consolidation_type). Should be either : \"submissions\" or \"comments\"."
        exit 1
        ;;
esac

org_to_process="$2"
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




# constants
monthly_file_spec="$org_data_dir/$consolidation_type-*.csv"
data_dir="$org_data_consolidation_dir"
backup_dir="$org_data_consolidation_dir/backup"
consolidation_filename="${data_dir}/$consolidation_type.csv"

# create the data directory if it doesn't exist
[ -d $data_dir ] || mkdir $data_dir
[ -d $backup_dir ] || mkdir $backup_dir

# If a previous consolidation already exists, make a backup.
if [ -f "$consolidation_filename" ]; then
    backup_timestamp=$(date '+%Y%m%d%H%M%S')
    echo "Consolidated data already exists."
    backup_filename="$backup_dir/${consolidation_type}_backup_${backup_timestamp}.csv"
    echo "Storing a backup as $backup_filename"
    cp "$consolidation_filename" "$backup_filename"
fi

case "$uppercased_consolidation_type" in
    SUBMISSIONS) 
        pivot_columns="8,9"
        consolidation_header="org,repository,number,url,state,created_at,merged_at,user.login,month_year,title"
        ;;
    COMMENTS) 
        pivot_columns="2,3"
        consolidation_header="PR_ref,commenter,month"
        ;;
    *) echo "Unsupported consolidation type ($consolidation_type). Should be either : \"submissions\" or \"comments\"."
        exit 1
        ;;
esac

# create a new file
# FIXME: Header should be different per type
echo "$consolidation_header" > $consolidation_filename
# Loop through the data files and make sure that they are in the correct order to append
for FILE in $(find $monthly_file_spec | sort -g)
do 
    echo "Appending $FILE to $consolidation_filename"; 
    tail -n +2 "$FILE" >> $consolidation_filename
done

echo " "
echo "creating pivot table"


#Create a pivot table for the whole dataset on submitter, month, count of PR
overview_file="${data_dir}/${consolidation_type}_overview.csv"
awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$consolidation_filename" | datamash -t, --sort --headers crosstab "$pivot_columns" count 1 | sed "s/N\/A/0/g" > "$overview_file"
#The generated CSV file doesn't have a valid format. The first line must removed
tail -n +2 "$overview_file" > "$overview_file.tmp" && mv "$overview_file.tmp" "$overview_file"


#Generate the latest top-35 submitters over a year with the generated data
echo " "
echo "Computing top ${consolidation_type}"
jenkins-top-submitters extract "$overview_file" -o $org_data_consolidation_dir/top_"$consolidation_type".md --month=latest --period=12 --topSize=35 --type="$top_type"
jenkins-top-submitters compare "$overview_file" -o $org_data_consolidation_dir/top_"$consolidation_type"_evolution.md --compare=3 --month=latest --period=12 --topSize=35 --type="$top_type" --history
