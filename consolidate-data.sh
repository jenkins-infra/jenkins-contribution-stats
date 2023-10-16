#!/usr/bin/env bash

set -e


consolidation_type="$1"
# Has the parameter been given?
if [ -z "$consolidation_type" ];
then
    echo "Usage: \"consolidate-data.sh [TYPE]\""
    echo "   where"
    echo "      TYPE is the consolidation type requested (\"submissions\" or \"comments\")"
    exit 1
fi
test_value=$(echo "$consolidation_type" | awk '{print toupper($0)}')
case "$test_value" in
    SUBMISSIONS) 
        ;;
    COMMENTS) 
        ;;
    *) echo "Unsupported consolidation type ($consolidation_type). Should be either : \"submissions\" or \"comments\"."
        exit 1
        ;;
esac


# constants
monthly_file_spec="./data/$consolidation_type*.csv"
data_dir="./consolidated_data"
backup_dir="./consolidated_data/backup"
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

# create a new file
echo "org,repository,number,url,state,created_at,merged_at,user.login,month_year,title" > $consolidation_filename
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
awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$consolidation_filename" | datamash -t, --sort --headers crosstab 8,9 count 1 | sed "s/N\/A/0/g" > "$overview_file"
#The generated CSV file doesn't have a valid format. The first line must removed
tail -n +2 "$overview_file" > "$overview_file.tmp" && mv "$overview_file.tmp" "$overview_file"


#Generate the latest top-35 submitters with the generated data
echo " "
echo "Computing top ${consolidation_type}"
jenkins-top-submitters extract "$overview_file" -o ./consolidated_data/top_"$consolidation_type".csv
jenkins-top-submitters compare "$overview_file" -o ./consolidated_data/top_"$consolidation_type"_evolution.csv -c=3
