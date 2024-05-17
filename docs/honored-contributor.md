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

## Notes
- The process will be built using bash and data files already extracted for the Jenkins Submitter Stats. Should some key features or information not be available using this strategy, a specific GOlang extractor or a new option to jenkins-stats will be written.
- This specification proposal is for discussion and subject to change based on feasibility. The objective is to deliver quickly a proof of concept of the full feature.
- It can and will be enhanced in later phases once the initial version is running.