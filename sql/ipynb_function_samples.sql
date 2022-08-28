-- For each function, output code samples
-- Each code sample is a single notebook cell

WITH

top_repo_code as (
  SELECT DISTINCT
  repo_path,
  repos,
  repo_rank,
  repo_prank,
  cell_code,
  length(cell_code) as code_length
  FROM `the-data-strategist.the_most_python.ipynb_notebook_code` 
  where repo_prank >= 0.999
  and cell_code NOT LIKE '%SECRET%'
  and cell_code NOT LIKE '%KEY%'
  and length(cell_code) >= 50
  and repo_path NOT LIKE '%Untitled%ipynb'
  and repo_path NOT IN (
    'index.ipynb', 
    'test.ipynb', 
    'demo.ipynb')
  ),

top_functions as (
  select 
  function,
  concat(function, r'\(') as function_regex,
  referenes_file,
  referenes_repo,
  pct_referenes,
  pct_repos,
  pct_files,
  from `the-data-strategist.the_most_python.ipynb_functions`
  where pct_files > 0.005
  and length(function) > 2
  ),

function_code as (
  select *,
  SUM(1) over (partition by repo_path) as n_paths,
  SUM(1) over (partition by cell_code) as n_cells  
  from top_repo_code trc
  join top_functions f 
  on regexp_contains(cell_code, function_regex)
)

select *
from (
  select *,
    (repos_rank / 2 + length_rank + paths_rank + cells_rank) / 4 as avg_rank,
    rank() over (partition by function order by (repos_rank / 2 + length_rank + paths_rank + cells_rank)) as composite_rank,
    rank() over (partition by function, repo_path order by (repos_rank / 2 + length_rank + paths_rank + cells_rank)) as dupe_path_rank,
  from (
    select 
      *,
      rank() over (partition by function order by repos desc) as repos_rank,
      rank() over (partition by function order by code_length) as length_rank,
      rank() over (partition by function order by n_paths) as paths_rank,
      rank() over (partition by function order by n_cells) as cells_rank,
    from function_code
    )
)

