WITH

  notebook_cells AS (
  -- Get all content and metadata about each notebook cell
  SELECT
    repo_name,
    repo_path,
    content,
    -- 1. Remove newline references in contents
    -- 2. Extract information in cells list of dicts
    -- 3. Split on cell_type since it's the first key in each cell content dictionary
    SPLIT(REGEXP_EXTRACT(REPLACE(content, '\n', ''), r'cells\"\:(.*)'), 'cell_type') AS cells,
  FROM
    `the-data-strategist.the_most_python.python_file_contents`
  WHERE
    repo_path LIKE '%.ipynb' )


-- For each cell, extract metadata (eg type) and contents (eg source, input)
SELECT
  repo_name,
  repo_path,
  ARRAY_AGG( STRUCT( cell,
      REGEXP_EXTRACT(cell, r'^":\s+\"(\w+)\"') AS cell_type,
      REGEXP_EXTRACT(cell, r'source\"\:\s+\[\s+(.*?)\s+]\s+}') AS cell_source,
      REGEXP_EXTRACT(cell, r'input\"\:\s+(.*?)\s*\"\w+\":') AS cell_input,
      REGEXP_REPLACE(REGEXP_EXTRACT(cell, r'metadata\"\:\s+(.*?)\,'), r'\s+', ' ') AS cell_metadata,
      REGEXP_EXTRACT(cell, r'execution_count":\s+(\d+)') AS execution_count,
      REGEXP_EXTRACT(cell, r'output_type":\s+\"(\w+)\",') AS output_type,
      REGEXP_EXTRACT(cell, r'language\"\:\s*\"(\w+)') AS LANGUAGE,
      REGEXP_EXTRACT(cell, r'prompt_number\"\:\s(\d+)') AS prompt_number )) AS cells
FROM
  notebook_cells c,
  UNNEST(cells) AS cell
GROUP BY
  1,
  2
