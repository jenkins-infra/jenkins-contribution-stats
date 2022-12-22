CREATE TABLE submitters (
    org TEXT,
    repository TEXT,
    pr_url TEXT PRIMARY KEY,
    pr_state TEXT,
    created_at TEXT,
    merged_at TEXT,
    pr_owner TEXT,
    month_year TEXT,
    title TEXT
);