with

netatmo_stations_data as (
  select *
  from {{ ref('stg_netatmo_stations_data') }}
),

with_loaded_at as (
  select
    *,
    parse_timestamp(
      '%Y-%m-%dT%H:%M:%E6S%Ez', json_extract_scalar(sdp_metadata, '$.loaded_at')
    ) as loaded_at
  from netatmo_stations_data
),

with_sequence_no as (
  select
    *,
    row_number() over (partition by _id order by loaded_at desc) as sequence_no
  from with_loaded_at
),

only_latest as (
  select *
  from with_sequence_no
  where sequence_no = 1
)

select * except (sequence_no, loaded_at)
from only_latest
