with

source as (
  select
    start_date,
    end_date,
    price,
    sdp_metadata
  from {{ source('sdp_landing', 'electricity_prices') }}
)

select * from source
