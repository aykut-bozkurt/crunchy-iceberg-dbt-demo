# crunchy-iceberg-dbt-demo

The dbt project to showcase transformations on Crunchy Iceberg tables.
We use [Github events archive](https://www.gharchive.org) as source dataset.
We analyze the various activities on [pg_parquet](https://github.com/CrunchyData/pg_parquet/) Github repository.

### How to and create source table and ingest more data?
I already put a parquet file of github events, which spans a period between 2024-10-17 and 2024-10-22, into the folder [dataset](dataset).

You can create raw table `pg_parquet_events` to store raw Github events for pg_parquet repository via the following command `dbt run-operation create_pg_parquet_events`.

You can also ingest a specific day's events for pg_parquet repo via `dbt run-operation copy_pg_parquet_events --args "{event_date: 2024-10-23, event_start_hour: 0, event_end_hour: 23}"`.

### How to build analysis models?
In the [models](models/pg_parquet_repo_analysis) folder, we have the models for different analysis on pg_parquet repo.
- [daily_comments](./models/pg_parquet_repo_analysis/daily_comments.sql)
- [daily_contributor_activity](./models/pg_parquet_repo_analysis/daily_contributor_activity.sql)
- [daily_event_types](./models/pg_parquet_repo_analysis/daily_event_types.sql)
- [daily_stars](./models/pg_parquet_repo_analysis/daily_stars.sql)
- [pr_merge_times](./models/pg_parquet_repo_analysis/pr_merge_times.sql)

You can run `dbt build`, which creates analysis tables when it is run the first time or inserts new records into the analysis tables if new events are ingested into pg_parquet_events table (incremental processing) since the last time we run the command.
