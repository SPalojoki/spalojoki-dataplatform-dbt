with

daily_electricity_price_avgs as (
  select *
  from {{ ref('int_daily_electricity_price_avgs') }}
),

with_rolling_avgs as (
  select
    price_date,
    avg_total,
    avg_day,
    avg_night,
    round(
      avg(avg_total)
        over (order by price_date rows between 6 preceding and current row),
      2
    ) as rolling_avg_total_7d,
    round(
      avg(avg_total)
        over (order by price_date rows between 29 preceding and current row),
      2
    ) as rolling_avg_total_30d,
    round(
      avg(avg_day)
        over (order by price_date rows between 6 preceding and current row),
      2
    ) as rolling_avg_day_7d,
    round(
      avg(avg_day)
        over (order by price_date rows between 29 preceding and current row),
      2
    ) as rolling_avg_day_30d,
    round(
      avg(avg_night)
        over (order by price_date rows between 6 preceding and current row),
      2
    ) as rolling_avg_night_7d,
    round(
      avg(avg_night)
        over (order by price_date rows between 29 preceding and current row),
      2
    ) as rolling_avg_night_30d,
    sdp_metadata
  from daily_electricity_price_avgs
  -- Due to the time zone difference between NordPool and Helsinki,
  -- next day's data includes an additional hour from the following day
  -- Let's exclude incomplete days from the averages.
  where num_records != 1
)

select
  * except (sdp_metadata)
  , {{ cast_published_at('sdp_metadata') }}
from with_rolling_avgs
order by price_date desc
