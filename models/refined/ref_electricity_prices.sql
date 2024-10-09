with

electricity_prices_latest as (
  select *
  from {{ ref('int_electricity_prices_latest') }}
),

with_finnish_datetime as (
  select
    datetime(start_date, 'Europe/Helsinki') as start_datetime,
    datetime(end_date, 'Europe/Helsinki') as end_datetime,
    price,
    sdp_metadata
  from electricity_prices_latest
),

with_separated_datetimes as (
  select
    date(start_datetime) as period_start_date,
    time(start_datetime) as period_start_time,
    date(end_datetime) as period_end_date,
    time(end_datetime) as period_end_time,
    price,
    sdp_metadata
  from with_finnish_datetime
)

select
  * except (sdp_metadata)
  , {{ cast_refined_at('sdp_metadata') }}
from with_separated_datetimes
