{% macro copy_pg_parquet_events(event_date, event_start_hour, event_end_hour) %}
{% set sql %}
    CREATE OR REPLACE PROCEDURE copy_pg_parquet_events(event_date date,
                                                       event_start_hour int,
                                                       event_end_hour int)
    LANGUAGE plpgsql
    AS $$
    BEGIN
    FOR event_hour IN event_start_hour..event_end_hour LOOP
        RAISE NOTICE 'Copying data for hour %', event_hour;

        BEGIN
            EXECUTE 'copy pgparquet_repo_analysis.pg_parquet_events from ''https://data.gharchive.org/' || event_date::text || '-' || event_hour || '.json.gz'' with (format ''json'') where repo like ''%CrunchyData/pg_parquet%'';';
        EXCEPTION
            WHEN OTHERS THEN
                EXECUTE 'copy pgparquet_repo_analysis.pg_parquet_events from ''https://data.gharchive.org/' || event_date::text || '-' || event_hour || '.json.gz'' with (format ''json'', compression ''none'') where repo like ''%CrunchyData/pg_parquet%'';';
        END;

    END LOOP;
    END
    $$;

    CALL copy_pg_parquet_events('{{ event_date }}', {{ event_start_hour }}, {{ event_end_hour }});
{% endset %}

{% do run_query(sql) %}
{% do log("copy_pg_parquet_events finished", info=True) %}
{% endmacro %}
