# Jenkins contribution statistics

A set of tools to extract and analyze the number of software contributions and their submitter.
This is a strict interpretation of "contribution". Other statistics (lile those from the Linux Foundation), analyse *all* interactions with a project (PR, comment, issue creation, review).

## Suggested usage

1. Retrieve data since the last time the script ran with `./collect-missing-data.sh`.
1. Update/create the consolidated data file with `./consolidate-data.sh`.
1. Update/create global summary file (nbr submitters and submissions per month) with `./submission-submitter-report.sh`.

All the above operations can be performed with `update-stats.sh`

## available consolidated data

## Script list

Following scripts are available:
- `check-prerequisites.sh` checks whether all required programs are available on the system
- `extract-monthly-submissions.sh` extracts the monthly data from GitHub and stores it in ,/data/ directory as a CSV file. It also generates a list with the number of PR for each submitter in the given month.
- `consolidate-data.sh` takes all the available monthly data and creates a single data file, `consolidated_data/submissions.csv`. If a data file already exists, it is backuped.
- `collect-missing-data.sh` will extract all the monthly data files since **JAN-2020**. If the output already exists, it will skip that particular month.
- `submission-submitter-report.sh` uses the existing monthly data to generate a summary CSV with the number of submissions and the number of submitters. The resulting output is stored in `consolidated_data/summary_counts.csv`

- `update-stats.sh` is the script that performs the necessary update operation in sequence

## pre-requisite

#FIXME: add information about jenkins-top-submitters

## Data and process flow

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

    %% data files
    submission_month[(submission_YYMM.csv)]
    monththlyPivot_submit[(pr_per_submitter.csv)]
    comments_month[(comments_YYMM.csv)]
    monththlyPivot_comment[("`comments_per_
    _commenter.csv`")]
    global_submissions[(submissions.csv)]
    global_submissionsOverview[(submissions_overview.csv)]

    global_comments[(comments.csv)]
    global_commentsOverview[(comments_overview.csv)]

    %% pivot processes
    monthlypivot_subm{{pivot monthly data}}
    monthlypivot_comment{{pivot monthly data}}
    subm_overview_pivot{{pivot}}
    comment_overview_pivot{{pivot}}

    

	start1 --> A -- loops through orgs --> B
	start2 --> B
    B --> C -- monthly data missing ? --> extracData  --> get_submitters
    get_submitters -.-> submission_month --> monthlypivot_subm -.-> monththlyPivot_submit --> extract_end --> C
    submission_month --> get_commenters -.-> comments_month --> monthlypivot_comment -.-> monththlyPivot_comment --> extract_end
    B --> D -.-> global_submissions --> subm_overview_pivot -.-> global_submissionsOverview
    B --> E -.-> global_comments --> comment_overview_pivot -.-> global_commentsOverview
    B --> F 
    B --> G
```
</details>