# crunchy-iceberg-dbt-demo

The dbt project to showcase transformations on Crunchy Iceberg tables.
We use [Github events archive](https://www.gharchive.org) as source dataset.
We analyze the various activities on [CrunchyData](https://github.com/CrunchyData/) organization.

> [!IMPORTANT]  
> Do not forget to `export ICEBERG_LOCATION_PREFIX=s3://...` before running any dbt command.

### How to and create source table and ingest more data?
You can create raw table `events` to store raw Github events for repos under CrunchyData organization via the following command `dbt run-operation create_crunchy_events`.

You can also ingest a specific day's events for repos under CrunchyData organization via `dbt run-operation copy_crunchy_events --args "{event_date: 2024-10-17}"` (takes ~5 min for a single day on 16 cores 256GB RAM aarch64).

### How to build analysis models?
In the [models](models/crunchy_gh_events) folder, we have the models for different analysis on CrunchyData organization.
- [daily_comments](./models/crunchy_gh_events/daily_comments.sql)
- [daily_contributor_activity](./models/crunchy_gh_events/daily_contributor_activity.sql)
- [daily_event_types](./models/crunchy_gh_events/daily_event_types.sql)
- [daily_forks](./models/crunchy_gh_events/daily_forks.sql)
- [daily_stars](./models/crunchy_gh_events/daily_stars.sql)
- [pr_merge_times](./models/crunchy_gh_events/pr_merge_times.sql)

You can run `dbt build` (or selectively `dbt build --model <model_name>`), which creates analysis tables when it is run the first time or inserts new records into the analysis tables if new events are ingested into events table (incremental processing) since the last time we run the command.


### TL;DR; Steps
1. `export ICEBERG_LOCATION_PREFIX=s3://...`
2. `dbt run-operation create_crunchy_events`
3. `dbt run-operation copy_crunchy_events --args "{event_date: 2024-10-17}"` (you can replace with any date)
4. `dbt build` (all models) or `dbt build --models <model_name>` (selective model)
5. Optional: You can run step 2 to ingest events from different days. And then you can run step 4 to incrementally process new events. Then, view the models' tables with updated content.
