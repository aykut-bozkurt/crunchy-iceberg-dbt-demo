
{{ config(
    materialized='incremental',
    unique_key='created_at',
    pre_hook="SET default_table_access_method TO 'iceberg'; SET crunchy_iceberg.default_location_prefix = 's3://testbucket/'",
    post_hook="RESET default_table_access_method; RESET crunchy_iceberg.default_location_prefix;"
) }}

select (actor::jsonb)->>'login' AS commenter,
        COUNT(*) AS comments,
       date_trunc('day', created_at)::date as created_at
from {{ source('pgparquet_repo_analysis', 'pg_parquet_events') }}
where type IN ('IssueCommentEvent', 'PullRequestReviewCommentEvent')
group by date_trunc('day', created_at)::date, commenter

{% if is_incremental() %}
having (date_trunc('day', created_at)::date >= (select coalesce(max(created_at),'1900-01-01') from {{ this }} ))
{% endif %}
