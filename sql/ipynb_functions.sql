-- Python functions for each ipynb notebook

WITH
  repo_functions AS (
  -- Get the functions referenced for each ipynb file
  -- TO DO: Ensure unnests don't duplicate references
  SELECT
    repo_name,
    repo_path,
    REGEXP_EXTRACT(function_ud, r'def ([A-Za-z0-9_]+)') AS function_ud,
    REPLACE(FUNCTION, '(', '') AS function
  FROM
    `the-data-strategist.the_most_python.ipynb_notebook_cell_contents` c,
    UNNEST(c.functions_ud) AS function_ud,
    UNNEST(c.functions) AS function ),
  
  totals AS (
  -- Get metrics for all repos and files
  -- Remove user-defined functions
  SELECT
    SUM(1) AS references_total,
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total
  FROM
    repo_functions
  WHERE
    function_ud != function ),
  
  function_agg AS (
  -- 1. Remove user-defined functions (WHERE)
  -- 2. Remove leading . from functions (REGEXP_REPLACE)
  -- 3. Calculate the # of references, files, and repos for each function
  SELECT
    REGEXP_REPLACE(function, r'^\.', '') AS function,
    SUM(1) AS references,
    APPROX_COUNT_DISTINCT(repo_path) AS files,
    APPROX_COUNT_DISTINCT(repo_name) AS repos,
  FROM
    repo_functions
  WHERE
    function_ud != function
  GROUP BY
    1
  ORDER BY
    2 DESC )

SELECT
  f.*,
  t.*,
  SAFE_DIVIDE(f.references, f.files) AS referenes_file,
  SAFE_DIVIDE(f.references, f.repos) AS referenes_repo,
  SAFE_DIVIDE(f.references, t.references_total) AS pct_referenes,
  SAFE_DIVIDE(f.repos, t.repos_total) AS pct_repos,
  SAFE_DIVIDE(f.files, t.files_total) AS pct_files,
FROM
  function_agg f
JOIN
  totals t
ON
  1=1
ORDER BY
  references DESC
