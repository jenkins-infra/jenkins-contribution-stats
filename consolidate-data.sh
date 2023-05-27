#!/usr/bin/env bash

set -e

# constants
monthly_file_spec="./data/submissions*.csv"
data_dir="./consolidated_data"
backup_dir="./consolidated_data/backup"
consolidation_filename="${data_dir}/submissions.csv"

# create the data directory if it doesn't exist
[ -d $data_dir ] || mkdir $data_dir
[ -d $backup_dir ] || mkdir $backup_dir

# If a previous consolidation already exists, make a backup.
if [ -f "$consolidation_filename" ]; then
    backup_timestamp=$(date '+%Y%m%d%H%M%S')
    echo "Consolidated data already exists."
    echo "Storing a backup as $backup_dir/submissions_backup_${backup_timestamp}.csv"
    cp "$consolidation_filename" "$backup_dir/submissions_backup_${backup_timestamp}.csv"
fi

# create a new file
echo "org,repository,url,state,created_at,merged_at,user.login,month_year,title" > $consolidation_filename
# Loop through the data files and make sure that they are in the correct order to append
for FILE in $(find $monthly_file_spec | sort -g)
do 
    echo "Appending $FILE to $consolidation_filename"; 
    tail -n +2 "$FILE" >> $consolidation_filename
done

#Create a pivot table for the whole dataset on submitter, month, count of PR
overview_file="${data_dir}/overview.csv"
awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$consolidation_filename" | datamash -t, --sort --headers crosstab 7,8 count 1 | sed "s/N\/A/0/g" > "$overview_file"
#The generated CSV file doesn't have a valid format. The first line must removed
tail -n +2 "$overview_file" > "$overview_file.tmp" && mv "$overview_file.tmp" "$overview_file"