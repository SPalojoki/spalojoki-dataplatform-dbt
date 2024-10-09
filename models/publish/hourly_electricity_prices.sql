with

electricity_prices as (
  select *
  from {{ ref('ref_electricity_prices') }}
),

only_start_time as (
  select
    period_start_date as price_date,
    extract(hour from period_start_time) as price_hour,
    price,
    sdp_metadata
  from
    electricity_prices
)

select
  * except (sdp_metadata)
  , {{ cast_published_at('sdp_metadata') }}
from
  only_start_time
order by price_date desc, price_hour desc
