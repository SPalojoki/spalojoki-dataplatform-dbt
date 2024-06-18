with

electricity_prices as (
  select *
  from {{ ref('stg_electricity_prices') }}
),

with_loaded_at as (
  select
    *,
    PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E6S%Ez', JSON_EXTRACT_SCALAR(sdp_metadata, '$.loaded_at')) AS loaded_at
  from electricity_prices
),

with_sequence_no as (
  select
    *,
    row_number() over (partition by start_date, end_date order by loaded_at desc) as sequence_no,
  from with_loaded_at
),

only_latest as (
  select *
  from with_sequence_no
  where sequence_no = 1
)

select
  * EXCEPT(sequence_no, loaded_at)
from only_latest
