# Jenkins contribution statistics

A set of tools to extract and analyze the number of software contributions and their submitter.
This is a strict interpretation of "contribution". Other statistics (lile those from the Linux Foundation), analyse *all* interactions with a project (PR, comment, issue creation, review).

## Suggested usage

1. Retrieve data since the last time the script ran with `./collect-missing-data.sh`.
1. Update/create the consolidated data file with `./consolidate-data.sh`.
1. Update/create global summary file (nbr submitters and submissions per month) with `./submission-submitter-report.sh`.

## Script list

Following scripts are available:
- `check-prerequisites.sh` checks whether all required programs are available on the system
- `extract-monthly-submissions.sh` extracts the monthly data from GitHub and stores it in ,/data/ directory as a CSV file. It also generates a list with the number of PR for each submitter in the given month.
- `consolidate-data.sh` takes all the available monthly data and creates a single data file, `consolidated_data/submissions.csv`. If a data file already exists, it is backuped.
- `collect-missing-data.sh` will extract all the monthly data files since **JAN-2020**. If the output already exists, it will skip that particular month.
- `submission-submitter-report.sh` uses the existing monthly data to generate a summary CSV with the number of submissions and the number of submitters. The resulting output is stored in `consolidated_data/summary_counts.csv`