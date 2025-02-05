{% macro create_pg_parquet_events() %}
{% set sql %}
    set crunchy_iceberg.default_location_prefix TO 's3://testbucket/';

    create table pgparquet_repo_analysis.pg_parquet_events (
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
{% do log("create_pg_parquet_events finished", info=True) %}
{% endmacro %}
