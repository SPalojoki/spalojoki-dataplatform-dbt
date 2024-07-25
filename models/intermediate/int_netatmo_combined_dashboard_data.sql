with

netatmo_stations_data as (
    select *
    from {{ ref('stg_netatmo_stations_data')}}
),

netatmo_extracted_modules as (
    select *
    from {{ ref('int_netatmo_extracted_modules') }}
),

combined as (
    select
        _id,
        dashboard_data,
        sdp_metadata
    from netatmo_stations_data
    union all
    select
        _id,
        dashboard_data,
        sdp_metadata
    from netatmo_extracted_modules
)

select *
from combined