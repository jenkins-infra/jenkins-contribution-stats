#!/usr/bin/env bash

set -e


# check wether required tools are available
./check-prerequisites.sh

# create the data directory if it doesn't exist
[ -d data ] || mkdir data
[ -d json_data ] || mkdir json_data
##

###############
# Constants
###############



###############
# Functions
###############

# Function to retrieve the data for all organizations for a given month
# The month is split in two queries to avoid hitting limits.
getContributions(){
    local year="$1"  # example "2022"
    local month="$2"  # JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC


    # Convert the month to its numeric value
    case "$month" in
        JAN) month_decimal="01"
            ;;
        FEB) month_decimal="02"
            ;;
        MAR) month_decimal="03"
            ;;
        APR) month_decimal="04"
            ;;
        MAY) month_decimal="05"
            ;;
        JUN) month_decimal="06"
            ;;
        JUL) month_decimal="07"
            ;;
        AUG) month_decimal="08"
            ;;
        SEP) month_decimal="09"
            ;;
        OCT) month_decimal="10"
            ;;
        NOV) month_decimal="11"
            ;;
        DEC) month_decimal="12"
            ;;
        *) echo "Unsupported month: $month"
            exit 1
            ;;
    esac
    # Get the last day of that given month of that particular year
    # NOTE: gdate is the GNU implementation of date on Mac OS
    last_day=$(gdate -d "${year}/${month_decimal}/1 + 1 month - 1 day" "+%d")

    csv_filename="data/contributions-${year}-${month_decimal}.csv"
    echo 'org,repository,url,state,created_at,merged_at,user.login,title' >"$csv_filename"


    getOrganizationData jenkinsci "$year" "$month_decimal" 01 15 "$csv_filename"
    getOrganizationData jenkinsci "$year" "$month_decimal" 16 "$last_day" "$csv_filename"
    getOrganizationData jenkins-infra "$year" "$month_decimal" 01 15 "$csv_filename"
    getOrganizationData jenkins-infra "$year" "$month_decimal" 16 "$last_day" "$csv_filename"

    # Create the pivot table for the month we downloaded
    summaryContributors="data/pr_per_contributor-${year}-${month_decimal}.csv"
    #see https://medium.com/clarityai-engineering/back-to-basics-how-to-analyze-files-with-gnu-commands-fe9f41665eb3
    awk -F'"' -v OFS='"' '{for (i=2; i<=NF; i+=2) {gsub(",", "", $i)}}; $0' "$csv_filename" | datamash -t, --sort --headers groupby 7 count 1 > "$summaryContributors"
}


# Function that retrieves and processes the GitHub information for a given organization for a particular month
getOrganizationData() {
    local org="$1"                  # jenkinsci or jenkins-infra
    local year="$2"                 # example "2022"
    local month_nbr="$3"            # Numerical month. JAN=1 .. DEC=12
    local start_day="$4"            # first day of the query
    local end_day="$5"              # Last day of the query
    local output_csv_filename="$6"  # The CSV file to write the output to

    if [ "$start_day" = "01" ]; then
        batch="A"
    else
        batch="B"
    fi

    local query="is:pr -author:app/dependabot -author:app/renovate created:${year}-${month_nbr}-${start_day}..${year}-${month_nbr}-${end_day}"
    local json_filename_main="${org}-${month}-${year}-${batch}"
    local json_filename="json_data/${json_filename_main}-"


    # remove any old json files
    rm -f "$json_filename"*.json

    #Get the data as json 
    local url_encoded_query
    url_encoded_query=$(jq --arg query "org:$org $query" --raw-output --null-input '$query|@uri')
    local page=1
    while true; do
        echo "$json_filename_main get page $page"
        gh api -H "Accept: application/vnd.github+json Retry-After: 30" "/search/issues?q=$url_encoded_query&sort=updated&order=desc&per_page=100&page=$page" >"$json_filename$page.json"
        # less accurate, can make 1 useless call if the number of issues is a multiple of 100
        if test "$(jq --raw-output '.items|length' "$json_filename$page.json")" -ne 100; then
            break
        fi
        ((page++))
        # Dirty trick to a avoid hitting secondary rate limit.
        sleep 15
    done

    # filter the collected json data and convert it to a CSV
    jq --arg org "$org" --raw-output --slurp --from-file json_to_csv.jq "$json_filename"*.json >>"$output_csv_filename"

}

##################
# Main processing
##################

# TODO: check parameters before processing
getContributions 2022 SEP
#getContributions 2022 OCT