with

source as (
  select *
  from {{ source('sdp_landing', 'electricity_prices')}}
)

select *
from source