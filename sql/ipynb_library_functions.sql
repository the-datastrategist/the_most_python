-- For a given Python library, what Python functions were used in the notebook
-- Includes all functions in the notebook, regardless of whether they're part of 
-- the given function.

WITH

  repo_functions AS (
    -- 1. Get the functions referenced in each ipynb file
    -- 2. Remove leading '.' and trailing '(' from function reference
    -- 3. Remove user-defined functions
    -- TO DO: Ensure unnests don't duplicate references
  SELECT
    repo_name,
    repo_path,
    function
  FROM (
    SELECT
      repo_name,
      repo_path,
      REGEXP_EXTRACT(function_ud, r'def ([A-Za-z0-9_]+)') AS function_ud,
      REGEXP_REPLACE(function, r'(^\.|\()', '') AS function
    FROM
      `the-data-strategist.the_most_python.ipynb_notebook_cell_contents` c,
      UNNEST(c.functions_ud) AS function_ud,
      UNNEST(c.functions) AS function )
  WHERE
    function != function_ud ),
  
  repo_libraries AS (
  -- Get all libraries referenced in each file
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
  
  repo_library_functions AS (
  -- Create dataset containing all libraries and functions referenced in each file
  -- Disregards the cell the library/function was referenced in
  -- WARNING: Function may not be part of the given library
  SELECT
    repo_name,
    repo_path,
    library,
    function,
  FROM
    repo_libraries l
  JOIN
    repo_functions f
  USING
    (repo_name,
      repo_path) ),
  
  library_functions_agg AS (
  -- Aggregate metrics by library and function
  -- WARNING: Function may not be part of the given library
  SELECT
    library,
    function,
    SUM(1) AS references,
    APPROX_COUNT_DISTINCT(repo_name) AS repos,
    APPROX_COUNT_DISTINCT(repo_path) AS files,
  FROM
    repo_library_functions
  GROUP BY
    1,
    2 ),
  
  totals AS (
  SELECT
    SUM(1) AS references_total,
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total
  FROM
    repo_library_functions )

SELECT
  *,
  SAFE_DIVIDE(references, references_total) AS pct_references,
  SAFE_DIVIDE(repos, repos_total) AS pct_repos,
  SAFE_DIVIDE(files, files_total) AS pct_files
FROM
  library_functions_agg
JOIN
  totals
ON
  1=1
