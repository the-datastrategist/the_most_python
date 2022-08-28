-- Python libraries in each ipynb notebook

WITH
  repo_libraries AS (
  -- Append libraries refenced using import and from
  SELECT
    repo_name,
    repo_path,
    library
  FROM
    `the-data-strategist.the_most_python.ipynb_notebook_cell_contents`,
    UNNEST(libraries_from) AS library
  
  UNION DISTINCT
  
  SELECT
    repo_name,
    repo_path,
    library
  FROM
    `the-data-strategist.the_most_python.ipynb_notebook_cell_contents`,
    UNNEST(libraries_import) AS library ),
  
  totals AS (
  -- Calculate total metrics
  SELECT
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total,
  FROM
    repo_libraries ),
  
  library_agg AS (
  -- Calculate metrics by library
  SELECT
    library,
    APPROX_COUNT_DISTINCT(repo_name) AS repos,
    APPROX_COUNT_DISTINCT(repo_path) AS files,
  FROM
    repo_libraries
  GROUP BY
    1 )

SELECT
  *,
  SAFE_DIVIDE(files, repos) AS files_repo,
  SAFE_DIVIDE(repos, repos_total) AS pct_repos,
  SAFE_DIVIDE(files, files_total) AS pct_files
FROM
  library_agg a
JOIN
  totals
ON
  1=1
ORDER BY
  files DESC
