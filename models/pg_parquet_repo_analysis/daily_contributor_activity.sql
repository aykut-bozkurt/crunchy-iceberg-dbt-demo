
{{ config(
    materialized='incremental',
    unique_key='created_at',
    pre_hook="SET default_table_access_method TO 'iceberg'; SET crunchy_iceberg.default_location_prefix = 's3://testbucket/'",
    post_hook="RESET default_table_access_method; RESET crunchy_iceberg.default_location_prefix;"
) }}

with user_activity as (
    select (actor::jsonb)->>'login' AS contributor,
        COUNT(*) FILTER (WHERE type = 'PushEvent') AS commits,
        COUNT(*) FILTER (WHERE type = 'PullRequestEvent') AS pull_requests,
        COUNT(*) FILTER (WHERE type = 'IssuesEvent') AS issues_opened,
        date_trunc('day', created_at)::date as created_at
    from {{ source('pgparquet_repo_analysis', 'pg_parquet_events') }}
    group by date_trunc('day', created_at)::date, (actor::jsonb)->>'login'
    {% if is_incremental() %}

    having (date_trunc('day', created_at)::date >= (select coalesce(max(created_at),'1900-01-01') from {{ this }} ))

    {% endif %}
)

select contributor, commits, pull_requests, issues_opened, created_at
from user_activity
where commits > 0 or pull_requests > 0 or issues_opened > 0
