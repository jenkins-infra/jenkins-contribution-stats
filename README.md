# Jenkins contribution statistics

A set of tools to extract and analyze the number of software contributions and their submitter.
This is a strict interpretation of "contribution". Other statistics (lile those from the Linux Foundation), analyse *all* interactions with a project (PR, comment, issue creation, review).

## Suggested usage

1. Retrieve data since the last time the script ran with `./collect-missing-data.sh`.
1. Update/create the consolidated data file with `./consolidate-data.sh`.
1. Update/create global summary file (nbr submitters and submissions per month) with `./submission-submitter-report.sh`.

All the above operations can be performed with `update-stats.sh`

## Script list

Following scripts are available:
- `check-prerequisites.sh` checks whether all required programs are available on the system
- `extract-monthly-submissions.sh` extracts the monthly data from GitHub and stores it in ,/data/ directory as a CSV file. It also generates a list with the number of PR for each submitter in the given month.
- `consolidate-data.sh` takes all the available monthly data and creates a single data file, `consolidated_data/submissions.csv`. If a data file already exists, it is backuped.
- `collect-missing-data.sh` will extract all the monthly data files since **JAN-2020**. If the output already exists, it will skip that particular month.
- `submission-submitter-report.sh` uses the existing monthly data to generate a summary CSV with the number of submissions and the number of submitters. The resulting output is stored in `consolidated_data/summary_counts.csv`

- `update-stats.sh` is the script that performs the necessary update operation in sequence

## Produced datafiles

| File name | Comment | produced by |
| -------------------------------------------- | ------------------------------------------------ | -------------------------------- |
| `data/submissions-YYYY-MM.csv`               | List of PRs created in a given month             | `extract-monthly-submissions.sh` |
| `data/pr_per_submitter-YYYY-MM.csv`          | Nbr of PRs submitted by a user for a given month | `extract-monthly-submissions.sh` |
| `data/comments_YYYY-MM.csv`                  | List of comments created in a given month        | `extract-monthly-submissions.sh` |
| `data/comments_per__commenter-YYYY-MM.csv`   | Nbr of comments made by a user for a given month | `extract-monthly-submissions.sh` |
| `consolidated_data/submissions.csv`          | All extracted submissions (since Jan 2020)       | `consolidate-data.sh submissions` |
| `consolidated_data/submissions_overview.csv` | Global submissions pivot table (user/month -> nbr prs)   | `consolidate-data.sh submissions` |
| `consolidated_data/top_submissions.csv`      | 35 top submitters over the last 12 month                 | `consolidate-data.sh submissions` |
| `consolidated_data/top_submissions_evolution.csv` | New or churned top submitters (compared to 3 months before) | `consolidate-data.sh submissions` |
| `consolidated_data/comments.csv`             | All extracted comments (since Jan 2020)                  | `consolidate-data.sh comments` |
| `consolidated_data/submissions_overview.csv` | Global comments pivot table (user/month -> nbr comments) | `consolidate-data.sh comments` |
| `consolidated_data/top_submissions.csv`      | 35 Top commenters over the last 12 months                | `consolidate-data.sh comments` |
| `consolidated_data/top_submissions_evolution.csv` | New or churned top commenters (compared to 3 months before) | `consolidate-data.sh comments` |


## pre-requisite

Prerequisites are checked with `check-prerequisite.sh`. 
This is the list of executables that have to be installed in order for the automation to work.

- `gh` : the Github command line utility
- `jq` : Json query tool
- `datamash` : data manipulation tool (CSV pivots)
- `jenkins-top-submitters` : extracts the to submitters or commenters from the global pivot tables
- `jenkins-stats` : various extraction and jenkins data handling tools
- `gdate` : GNU date manipulation tool for Mac OS (part of `coreutils`, installable with brew)

## Data and process flow

Not to self: to generate the mermaid graphic by hand `docker run -i -t --rm -v "$PWD:/data"  jmmeessen/render-md-mermaid:v2`

![data & process flowchart](flowchart.svg)
<details>
  <summary>diagram source</summary>
  This details block is collapsed by default when viewed in GitHub. This hides the mermaid graph definition, while the rendered image
  linked above is shown. The details tag has to follow the image tag. (newlines allowed)


```mermaid
flowchart TD
	start1(("`Start
	(others)
	 `"))

    start2(("`Start
    (jenkins)
     `"))

    extract_end((End))

    %% Processes

	A[[update-benchmark-stats.sh]]
	B[[update-stats.sh]]
    C[[collect-missing-data.sh]]
    D[[consolidate-data.sh submissions]]
    E[[consolidate-data.sh comments]]
    F[[submission-submitter-report.sh]]
    G[[comment-commenter-report.sh]]
    extracData[[extract-montlhly-submissions.sh]]
    get_submitters{{"jenkins-stats get submitters {org}"}}
    get_commenters{{"jenkins-stats get commenters"}}
    top_extract{{jenkins-top-submitters </br> extract}}
    top_compare{{jenkins-top-submitters </br>compare}}

    %% data files
    submission_month[(submission_YYMM.csv)]
    monththlyPivot_submit[(pr_per_submitter.csv)]
    comments_month[(comments_YYMM.csv)]
    monththlyPivot_comment[(comments_per_</br>_commenter.csv)]
    global_submissions[(submissions.csv)]
    global_submissionsOverview[(submissions_overview.csv)]
    top_submission[(top_submissions.csv)]
    top_submission_evol[(top_submissions_evolution.csv)]

    global_comments[(comments.csv)]
    global_commentsOverview[(comments_overview.csv)]

    %% legend
    legend_app[[Application </br>or script]]
    legend_sub{{sub routine}}
    legend_data[(data file)]
    legend_app --> legend_sub -.-> legend_data

    %% pivot processes
    monthlypivot_subm{{pivot monthly data}}
    monthlypivot_comment{{pivot monthly data}}
    subm_overview_pivot{{pivot}}
    comment_overview_pivot{{pivot}}

    
    %% flow
	start1 --> A -- loops through orgs --> B
	start2 --> B
    B --> C -- monthly data missing ? --> extracData  --> get_submitters
    get_submitters -.-> submission_month --> monthlypivot_subm -.-> monththlyPivot_submit --> extract_end --> C
    submission_month --> get_commenters -.-> comments_month --> monthlypivot_comment -.-> monththlyPivot_comment --> extract_end
    B --> D -.-> global_submissions
    global_submissions --> subm_overview_pivot -.-> global_submissionsOverview
    global_submissions --> top_extract --> top_submission
    global_submissions --> top_compare --> top_submission_evol
    B --> E -.-> global_comments --> comment_overview_pivot -.-> global_commentsOverview
    B --> F 
    B --> G
```
</details>