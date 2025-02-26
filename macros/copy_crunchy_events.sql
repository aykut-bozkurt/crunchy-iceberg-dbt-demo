{% macro copy_crunchy_events(event_date) %}
{% set sql %}
    CREATE OR REPLACE PROCEDURE copy_crunchy_events(event_date date)
    LANGUAGE plpgsql
    AS $$
    BEGIN

        FOR h IN 0..23 LOOP
            RAISE NOTICE 'Executing hour: %', h;

            BEGIN
                EXECUTE 'COPY crunchy_gh.events                                                                                                                                                                                        
                         FROM ''s3://clickhouse-public-datasets/gharchive/original/' || event_date || '-' || h || '.json.gz''                                                                                                                                                   
                         WITH (format ''json'')                                                                                                                                                                                                              
                         WHERE repo LIKE ''%%CrunchyData/%%'';';
            EXCEPTION
                WHEN OTHERS THEN
                    -- sometimes files are not compressed as expected
                    EXECUTE 'COPY crunchy_gh.events                                                                                                                                                                                        
                             FROM ''s3://clickhouse-public-datasets/gharchive/original/' || event_date || '-' || h || '.json.gz''                                                                                                                                                   
                             WITH (format ''json'', compression ''none'')                                                                                                                                                                                                              
                             WHERE repo LIKE ''%%CrunchyData/%%'';';
            END;                                                                                                                                                                                                               
        END LOOP;                                                                                                                                                                                                                                      

    END
    $$;

    CALL copy_crunchy_events('{{ event_date }}');
{% endset %}

{% do run_query(sql) %}
{% do log("copy_crunchy_events finished", info=True) %}
{% endmacro %}
