with

source as (
  select
    _id,
    date_setup,
    last_setup,
    type,
    last_status_store,
    module_name,
    firmware,
    wifi_status,
    reachable,
    co2_calibrating,
    data_type,
    place,
    station_name,
    home_id,
    home_name,
    dashboard_data,
    modules,
    sdp_metadata
  from {{ source('sdp_landing', 'netatmo_weather_readings') }}
)

select * from source