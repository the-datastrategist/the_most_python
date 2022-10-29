
/*
    stg_github_repos__python_files.sql

    Pulls all Github file that contain Python or are iPython notebooks

    WARNING: This is a massive query; use with caution.

*/

{{ config(materialized='view') }}

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
