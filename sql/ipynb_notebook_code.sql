with

paths as (
  -- Get counts and ranks of the repo count
  -- Distinct repo count is an indicator of breadth of use
  -- We want notebooks and code used by a larger based of people
  select *,
  rank() over(order by repos desc) as repo_rank,
  percent_rank() over(order by repos) as repo_prank,
  from (
    -- Count the number of times a particular repo_path 
    -- (ie notebook file) has been created.
    SELECT 
      repo_path,
      count(distinct repo_name) as repos,
    FROM `the-data-strategist.the_most_python.ipynb_notebook_cells` 
    GROUP BY 1
  )
),

cell_code as (
  select distinct
    repo_path,
    cell.cell as cell,
    regexp_replace(
      regexp_replace(
        coalesce(cell.cell_source, cell.cell_input), 
        r'\\n\"\,\s+\"', '\n'), 
        r'^"|"$|",$|^\[\s+"|\],$', '')  as cell_code
  from `the-data-strategist.the_most_python.ipynb_notebook_cells` c,
  unnest(c.cells) as cell
  where cell.cell_type = 'code'
)

select 
  c.*,
  p.* except(repo_path)
from cell_code c
join paths p using(repo_path)
