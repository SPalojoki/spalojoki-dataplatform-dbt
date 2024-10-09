with

netatmo_stations_data as (
  select *
  from {{ ref('stg_netatmo_stations_data') }}
),

extracted_modules as (
  select
    json_value(sub_module._id) as _id,
    json_value(sub_module.module_name) as module_name,
    _id as main_module_id,
    sub_module.dashboard_data,
    json_value_array(sub_module.data_type) as data_type,
    cast(json_value(sub_module.battery_percent) as integer) as battery_percent,
    cast(json_value(sub_module.battery_vp) as integer) as battery_vp,
    cast(json_value(sub_module.last_message) as integer) as last_message,
    cast(json_value(sub_module.last_seen) as integer) as last_seen,
    cast(json_value(sub_module.last_setup) as integer) as last_setup,
    cast(json_value(sub_module.reachable) as boolean) as reachable,
    cast(json_value(sub_module.rf_status) as integer) as rf_status,
    cast(json_value(sub_module.firmware) as integer) as firmware,
    json_value(sub_module.type) as module_type,
    sdp_metadata
  from netatmo_stations_data,
    unnest(modules) as sub_module
)

select *
from extracted_modules
