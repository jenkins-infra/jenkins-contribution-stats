# Jenkins contribution statistics

A set of tools to extract and analyze the number of software contributions and their submitter.
This is a strict interpretation of "contribution". Other statistics (lile those from the Linux Foundation), analyse *all* interactions with a project (PR, comment, issue creation, review).

Following scripts are available:
- `check-prerequisites.sh` checks whether all required programs are available on the system
- `extract-monthly-submissions.sh` extracts the monthly data from GitHub and stores it in ,/data/ directory as a CSV file. It also generates a list with the number of PR for each submitter in the given month.
- `consolidate-data.sh` takes all the available monthly data and creates a single data file, `consolidated_data/submissions.csv`. If a data file already exists, it is backuped.
- `collect-missing-data.sh` will extract all the monthly data files since JAN-2020. If the output already exists, it will skip that particular month.