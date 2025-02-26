
{{ config(
    materialized='incremental',
    unique_key='created_at',
    pre_hook="SET default_table_access_method TO 'iceberg'; SET crunchy_iceberg.default_location_prefix = '{{ env_var('ICEBERG_LOCATION_PREFIX', '') }}';",
    post_hook="RESET default_table_access_method; RESET crunchy_iceberg.default_location_prefix;"
) }}

select date_trunc('day', created_at)::date as created_at,
       (repo::jsonb)->>'name' AS repo,
       count(*) as stars
from {{ source('crunchy_gh', 'events') }}
where type = 'WatchEvent'
group by date_trunc('day', created_at)::date, (repo::jsonb)->>'name'

{% if is_incremental() %}
having (date_trunc('day', created_at)::date >= (select coalesce(max(created_at),'1900-01-01') from {{ this }} ))
{% endif %}
