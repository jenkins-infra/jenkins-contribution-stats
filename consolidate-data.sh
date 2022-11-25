#!/usr/bin/env bash

set -e

# cosntants
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
echo "org,repository,url,state,created_at,merged_at,user.login,title" > $consolidation_filename
# Loop through the data files and make sure that they are in the correct order to append
monthly_file_spec="./data/contributions*.csv"
for FILE in $(find $monthly_file_spec | sort -g)
do 
    echo "Appending $FILE to $consolidation_filename"; 
    tail -n +2 "$FILE" >> $consolidation_filename
done

