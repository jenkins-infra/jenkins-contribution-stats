# Honored Contributor data

Open Source projects rely on the work of contributors.
To encourage and retain them, a "thank you" is always an important reward.
The Jenkins project puts key contributors in the limelight as a token of gratitude.
But also less active contributors are entitled to public recognition.

This is why the Jenkins Advocacy and Outreach committee wants to add this recognition to the https://contributors.jenkins.io/ page.
It is based on something done by the Adoptium project as in [this example](https://adoptium.net/en-GB/blog/2021/12/eclipse-temurin-linux-installers-available/).

To drive this User Interface feature, data must be made available.
This document specifies this data and extraction process.

- a github action will run the extraction process on regular base (daily or weekly). It will
   - generate a data file (CSV format) with always the same name and at the same location (consolidated_data)
   - commit and push it to the GitHub repository

- the process will pick, randomly, a GitHub user that submitted at least one PR during the previous month

- the resulting data will show: 
   - the time stamp of the extraction
   - the month examined
   - the GitHub handle of the contributor
   - the URL of the GitHub user's page
   - the number of PRs submitted in the last month
   - the list of repositories where the PR's were submitted to

The proposed format would be:

```
RUN_DATE, MONTH, GH_HANDLE, GH_HANDLE_URL, NBR_PR, REPOSITORIES
2024-05-15T13:02:24, 2024-04, olamy, https://github.com/olamy, 14, "jenkinsci/myproject jenkinsci/mysecondprj" 
```

The file name will be "https://github.com/jmMeessen/jenkins-submitter-stats/tree/main/consolidated_data/honored_contributor.csv". A prototype file will be made available asap to allow concurrent work on the UI. Note that the org and repository will change as it will be moved to the JenkinsCi org.

## Technical Specification

Seen that the extracted data files contain only part of the required information, a dedicated processing option will have to be created. 
It will be implemented as a new command of the `jenkins-stats` application.

- command: `honored`
- options
   - `--data_dir`: directory where the consolidated files are stored. We will be looking for `pr_per_submitter-YYYY-MM.csv`
   - `--output`: where the resulting file will be written (default: `[data_dir]/honored_contributor.csv`)
   - `--month` : month to use to pick the honored user from.

- Workflow:
   - get the month to use as reference
      - use `--month` parameter
      - if no month is specified, compute it => month before the current one
   - compute the correct input filename (`pr_per_submitter-YYYY-MM.csv`)
   - fail if the file does not exist else open the file
   - validate that it has the correct format (CSV and column names)
   - load the file in memory
   - pick a data line randomly
   - make a GitHub query to retrieve the contributors information (URL, avatar)
   - for the given user, retrieve all the PRs of that user in the given month
   - pick the required data and assemble it so that it can be outputed
   - output the file

## Notes
- This specification proposal is for discussion and subject to change based on feasibility. The objective is to deliver quickly a proof of concept of the full feature.
- It can and will be enhanced in later phases once the initial version is running.