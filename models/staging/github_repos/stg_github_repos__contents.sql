
/*
    stg_github_repos__contents.sql

    Pulls all Github file contents from BigQuery public data.

    WARNING: This is a massive query; use with caution.

*/

{{ config(materialized='view') }}

SELECT
  f.*,
  c.content,
  c.copies
FROM
  `bigquery-public-data.github_repos.contents` c
JOIN
  repo_files f
USING
  (id)
WHERE
  c.content IS NOT NULL
