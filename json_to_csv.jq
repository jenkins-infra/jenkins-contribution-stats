map(.items)
| add
| map(
    select(
      # Spec: - Status is either open or merged
      ((.state == "open" or .pull_request.merged_at != null) and (.user.type != "Bot"))
      )
    | [
        $org,
        # Hacky, but requires far less API calls
        (.repository_url | split("/") | last),
        .number,
        .html_url,
        .state,
        .created_at,
        .pull_request.merged_at,
        .user.login,
        $month_year,
        (.title | split("\n") | first)

      ]
  )[]
| @csv