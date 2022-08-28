-- Counts of library downloads from Python Package Index (PyPI)
-- Limited to 2022-06-01 to 2022-06-30
-- WARNING: This is a 400GB+ query

WITH

  library_downloads AS (
  SELECT
    project,
    file.version AS version,
    SUM(1) AS downloads
  FROM
    `bigquery-public-data.pypi.file_downloads`
  WHERE
    DATE(timestamp) BETWEEN "2022-06-01" AND "2022-06-30"
  GROUP BY 1,2 ),
  
  library_metadata AS (
  SELECT
    name,
    version,
    summary,
    author,
    keywords,
    home_page,
    download_url
  FROM
    `bigquery-public-data.pypi.distribution_metadata` )

SELECT
  d.*,
  m.* except (version)
FROM
  library_downloads d
LEFT JOIN
  library_metadata m
ON
  d.project = m.name
  AND d.version = m.version
