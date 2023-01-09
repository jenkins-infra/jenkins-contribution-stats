CREATE TABLE submissions (
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

\copy submissions FROM '/tmp/submissions.csv' DELIMITER ',' CSV HEADER;
