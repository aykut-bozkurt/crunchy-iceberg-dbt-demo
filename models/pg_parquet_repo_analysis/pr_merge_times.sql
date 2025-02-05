
{{ config(
    materialized='incremental',
    unique_key='created_at',
    pre_hook="SET default_table_access_method TO 'iceberg'; SET crunchy_iceberg.default_location_prefix = 's3://testbucket/'",
    post_hook="RESET default_table_access_method; RESET crunchy_iceberg.default_location_prefix;"
) }}

WITH prs AS (
    SELECT
        (payload::jsonb)->'pull_request'->>'id' AS pr_id,
        ((payload::jsonb)->'pull_request'->>'created_at')::timestamp AS created_at,
        ((payload::jsonb)->'pull_request'->>'merged_at')::timestamp AS merged_at
    FROM {{ source('pgparquet_repo_analysis', 'pg_parquet_events') }}
    WHERE type = 'PullRequestEvent'
    AND (payload::jsonb)->'pull_request'->>'merged_at' IS NOT NULL
    {% if is_incremental() %}
      AND ((payload::jsonb)->'pull_request'->>'merged_at')::timestamp > (select coalesce(max(merged_at),'1900-01-01') from {{ this }} )
    {% endif %}
)
SELECT
    pr_id,
    created_at,
    merged_at,
    EXTRACT(EPOCH FROM (merged_at - created_at)) / 3600 AS hours_to_merge
FROM prs
