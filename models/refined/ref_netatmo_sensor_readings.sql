with

netatmo_combined_dashboard_data as (
  select *
  from {{ ref('int_netatmo_combined_dashboard_data') }}
),

extracted_readings as (
  select
    _id as module_id,
    cast(json_value(dashboard_data.time_utc) as integer) as measurement_time,
    cast(json_value(dashboard_data.temperature) as numeric) as temperature,
    cast(json_value(dashboard_data.humidity) as numeric) as humidity,
    cast(json_value(dashboard_data.gustangle) as numeric) as gust_angle,
    cast(json_value(dashboard_data.guststrength) as numeric) as gust_strength,
    cast(json_value(dashboard_data.windangle) as numeric) as wind_angle,
    cast(json_value(dashboard_data.windstrength) as numeric) as wind_strength,
    cast(json_value(dashboard_data.absolutepressure) as numeric)
      as absolute_pressure,
    cast(json_value(dashboard_data.co2) as integer) as co2,
    cast(json_value(dashboard_data.noise) as integer) as noise,
    cast(json_value(dashboard_data.pressure) as numeric) as pressure,
    sdp_metadata
  from netatmo_combined_dashboard_data
),

with_formatted_time as (
  select
    * except (measurement_time),
    timestamp_seconds(measurement_time) as measurement_time
  from extracted_readings
)

select
  module_id,
  measurement_time,
  temperature,
  humidity,
  gust_angle,
  gust_strength,
  wind_angle,
  wind_strength,
  absolute_pressure,
  co2,
  noise,
  pressure,
  -- Repeat for reordering
  {{ cast_refined_at('sdp_metadata') }}
from with_formatted_time
order by measurement_time desc, module_id asc
