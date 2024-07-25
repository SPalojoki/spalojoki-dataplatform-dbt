with

netatmo_combined_dashboard_data as (
    select *
    from {{ ref('int_netatmo_combined_dashboard_data') }}
),

extracted_readings as (
    select
        _id as module_id,
        cast(json_value(dashboard_data.time_utc) as integer) as measurement_time,
        cast(json_value(dashboard_data.Temperature) as numeric) as temperature,
        cast(json_value(dashboard_data.Humidity) as numeric) as humidity,
        cast(json_value(dashboard_data.GustAngle) as numeric) as gust_angle,
        cast(json_value(dashboard_data.GustStrength) as numeric) as gust_strength,
        cast(json_value(dashboard_data.WindAngle) as numeric) as wind_angle,
        cast(json_value(dashboard_data.WindStrength) as numeric) as wind_strength,
        cast(json_value(dashboard_data.AbsolutePressure) as numeric) as absolute_pressure,
        cast(json_value(dashboard_data.CO2) as integer) as co2,
        cast(json_value(dashboard_data.Noise) as integer) as noise,
        cast(json_value(dashboard_data.Pressure) as numeric) as pressure,
        sdp_metadata
    from netatmo_combined_dashboard_data
),

with_formatted_time as (
    select
        * except(measurement_time),
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
order by measurement_time desc, module_id