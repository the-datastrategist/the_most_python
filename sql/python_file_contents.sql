-- Collect all Python files from Github
-- WARNING: This is a 2.7TB query

WITH
  repo_files AS (
  -- get list of Github file references
  SELECT
    DISTINCT id,
    repo_name,
    ref AS repo_ref,
    path AS repo_path
  FROM
    `bigquery-public-data.github_repos.files`
  WHERE
    (path LIKE '%ipynb%' OR path LIKE '%.py')
    AND ref LIKE '%master%' )

-- join file references to contents
-- disregard null content
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
