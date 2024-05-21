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
   - the GitHub user's avatar   
   - the number of PRs submitted in the last month
   - the list of repositories where the PR's were submitted to

The proposed format would be:

```
RUN_DATE, MONTH, GH_HANDLE, GH_HANDLE_URL, GH_HANDLE_AVATAR, NBR_PR, REPOSITORIES
2024-05-15T13:02:24, 2024-04, olamy, https://github.com/olamy, https://avatars.githubusercontent.com/u/19728?v=4,  14, "jenkinsci/myproject jenkinsci/mysecondprj" 
```

The file name will be "https://github.com/jmMeessen/jenkins-submitter-stats/tree/main/consolidated_data/honored_contributor.csv". A prototype file will be made available asap to allow concurrent work on the UI. Note that the org and repository will change as it will be moved to the JenkinsCi org.

## Technical Specification

Seen that the extracted data files contain only part of the required information, a dedicated processing option will have to be created. 
It will be implemented as a new command of the `jenkins-stats` application.

### New CLI command

- command: `honored`
- required parameter: `YYYY-MM` (month to use to pick the honored user from.)
- options
   - `--data_dir`: directory where the consolidated files are stored. We will be looking for `pr_per_submitter-YYYY-MM.csv`
   - `--output`: where the resulting file will be written (default: `[data_dir]/honored_contributor.csv`)


### Workflow

- check the required month parameter
- check existence of the data directory
- compute the correct input filename (`pr_per_submitter-YYYY-MM.csv`)
- fail if the file does not exist else open the file
- validate that it has the correct format (CSV and column names)
- load the file in memory
- pick a data line randomly
- make a GitHub query to retrieve the contributors information (URL, avatar)
- for the given user, retrieve all the PRs of that user in the given month
- pick the required data and assemble it so that it can be outputed
- output the file

### Data

| field | meaning | provenance |
|-------|---------|------------|
| RUN_DATE | current date/time| computed |
| MONTH | source month (`YYYY-MM`) | from the parameters |
| GH_HANDLE | GitHub User's name | as read from file |
| GH_HANDLE_URL | URL to the user's page | retrieved via a GH call |
| GH_HANDLE_AVATAR | URL to the user's avatar | retrieved via a GH call |
| NBR_PR | number of PRs in source month| as read from file |
| REPOSITORIES | Space delimited list of repos where PRs were submitted | retrieved via a GH call  |

### GitHub call

This GitHub V4 query can be validated at https://docs.github.com/en/graphql/overview/explorer. 
It validates that multiple orgs can be searched.

```Typescript
{
  search(query: "org:jenkinsci org:jenkins-infra is:pr author:dduportal created:2024-04-01..2024-04-30", type: ISSUE, first: 100) {
    issueCount
    edges {
      node {
        ... on PullRequest {
          author {
            login
            avatarUrl
            url
          }
          url
          title
          createdAt
          repository {
            name
          }
        }
      }
    }
  }
}
```

Begin of the resulting json. 
Note that to avoid multiple API calls, the author's details are returned for every pull request.

This particular query has 1 PR in `jenkinsci` and 27 PR in `jenkins-infra`

```json
{
  "data": {
    "search": {
      "issueCount": 28,
      "edges": [
        {
          "node": {
            "author": {
              "login": "dduportal",
              "avatarUrl": "https://avatars.githubusercontent.com/u/1522731?u=5153c23fbf9260c8c1d183fb5388b7308bd8faae&v=4",
              "url": "https://github.com/dduportal"
            },
            "url": "https://github.com/jenkins-infra/kubernetes-management/pull/5171",
            "title": "chore(updatecli) fix JDK tool manifests",
            "createdAt": "2024-04-24T18:40:53Z",
            "repository": {
              "name": "kubernetes-management"
            }
          }
        },
        {
          "node": {
            "author": {
              "login": "dduportal",
              "avatarUrl": "https://avatars.githubusercontent.com/u/1522731?u=5153c23fbf9260c8c1d183fb5388b7308bd8faae&v=4",
              "url": "https://github.com/dduportal"
            },
            "url": "https://github.com/jenkins-infra/update-center2/pull/776",
            "title": "chore(publish.sh) set up `httpd` fallback redirection to mirrors [new UC]",
            "createdAt": "2024-04-24T17:20:07Z",
            "repository": {
              "name": "update-center2"
            }
          }
        },
        {
          "node": {
            "author": {
              "login": "dduportal",
              "avatarUrl": "https://avatars.githubusercontent.com/u/1522731?u=5153c23fbf9260c8c1d183fb5388b7308bd8faae&v=4",
              "url": "https://github.com/dduportal"
            },
            "url": "https://github.com/jenkins-infra/docker-inbound-agents/pull/155",
            "title": "chore(updatecli) fix JDK and agent manifests to ensure new versions are tracked",
            "createdAt": "2024-04-24T15:33:54Z",
            "repository": {
              "name": "docker-inbound-agents"
            }
          }
        },
```

## Notes
- This specification proposal is for discussion and subject to change based on feasibility. The objective is to deliver quickly a proof of concept of the full feature.
- It can and will be enhanced in later phases once the initial version is running.