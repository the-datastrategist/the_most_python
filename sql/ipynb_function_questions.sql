-- For each function, output its most common StackOverflow (SO) questions
-- Matching occurs when function is found in SO question tags

WITH
  questions AS (
  -- Select top 100k questions from StackOverflow
  SELECT
    tags,
    tags_list,
    title,
    body AS question,
    accepted_answer,
    question_url,
    answer_url,
    answer_count,
    favorite_count,
    view_count
  FROM
    `the-data-strategist.the_most_python.stackoverflow_python_questions`
  ORDER BY
    view_count DESC
  LIMIT
    100000 ),
  
  functions AS (
  -- Select top 2K functions, based on file references
  -- Limit to functions with 2+ characters
  SELECT
    f.function,
    -- Create function parent
    -- This helps with join between the function and SO question tag
    case 
      when f.function like '%np.%' then 'numpy'
      when f.function like '%pd.%' then 'pandas'
      when f.function like '%df.%' then 'dataframe'
      when f.function like '%tf.%' then 'tensorflow'
      when f.function like 'time.%' then 'time'
      when f.function like '%dt.%' then 'datetime'
      when f.function like '%plt.%' then 'matplotlib'
      when f.function like '%plot.%' then 'matplotlib'
      when f.function like '%random.%' then 'random'
      when f.function like '%re.%' then 'regex'
      when f.function like '%sys.%' then 'sys'
      when f.function like '%os.%' then 'os'
      else null end as function_parent,
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
      ARRAY_REVERSE(split(f.function, '.'))[offset(0)],
      'zeros', 'zero'),
      'float', 'floating-point'),
      '__init__', 'init'),
      'array', 'numpy-ndarray'),
      'str', 'string'),
      'print', 'printing')
       as function_child,
    references,
    repos,
    files,
    safe_divide(references, files) as references_file,
    safe_divide(references, repos) as references_repo,
    pct_referenes,
    pct_repos,
    pct_files
  FROM
    `the-data-strategist.the_most_python.ipynb_functions` f
  WHERE
    LENGTH(f.function) > 2
  ORDER BY
    files DESC
  LIMIT
    2000 )
  

-- Select questions where the function is found in the question tags
-- NOTE: also considered JOIN ON regexp_contains(q.tags, f.python_function)
SELECT
  f.*,
  q.*,
FROM
  functions f
JOIN
  questions q
ON
  f.function_child IN UNNEST(SPLIT(q.tags, '|'))
  AND (
    f.function_parent IN UNNEST(SPLIT(q.tags, '|'))
    OR f.function_parent IS NULL)
ORDER BY view_count DESC
