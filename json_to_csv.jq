map(.items)
| add
| map(
    select(
      # Spec: - Status is either open or merged
      ((.state == "open" or .pull_request.merged_at != null) and (.user.type != "Bot"))
      )
    # Spec: Produce a CSV list of PRs with following details: PR URL, PR Title, Repository, Status (Open, Merged), Creation date, Merge date (if applicable), PR Author, Is flag “Hacktoberfest-approved” set?
    | [
        $org,
        # Hacky, but requires far less API calls
        (.repository_url | split("/") | last),
        .html_url,
        .state,
        .created_at,
        .pull_request.merged_at,
        .user.login,
        (.title | split("\n") | first)

      ]
  )[]
| @csv