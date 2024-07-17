with

electricity_prices as (
  select *
  from {{ ref('ref_electricity_prices') }}
),

with_time_of_day as (
  select
    period_start_date as date,
    case
      when extract (hour from period_start_time) between 0 and 7 then 'night'
      else 'day'
    end as time_of_day,
    price,
    sdp_metadata
  from electricity_prices
),

averages as (
  select
    date,
    round(avg(price), 2) as avg_total,
    round(avg(case when time_of_day = 'day' then price end), 2) as avg_day,
    round(avg(case when time_of_day = 'night' then price end), 2) as avg_night,
    count(*) as num_records,
    any_value(sdp_metadata) as sdp_metadata
  from with_time_of_day
  group by date
)

select
  *
from averages
