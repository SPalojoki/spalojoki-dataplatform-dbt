with

electricity_prices as (
  select *
  from {{ ref('ref_electricity_prices') }}
),

only_start_time as (
  select
    period_start_date as date,
    extract(hour from period_start_time) as hour,
    price,
    sdp_metadata
  from
    electricity_prices
)

select
  *
from
  only_start_time
order by date desc, hour desc
