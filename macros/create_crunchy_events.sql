{% macro create_crunchy_events() %}

{% set sql %}
    set crunchy_iceberg.default_location_prefix TO '{{ env_var('ICEBERG_LOCATION_PREFIX', '') }}';

    create schema if not exists crunchy_gh;

    create table crunchy_gh.events (
        id text,
        type text,
        actor text,
        repo text,
        payload text,
        public boolean,
        created_at timestamptz,
        org text)
    using iceberg;
{% endset %}

{% do run_query(sql) %}
{% do log("create_crunchy_events finished", info=True) %}
{% endmacro %}
