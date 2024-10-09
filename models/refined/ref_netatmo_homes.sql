with

netatmo_stations_data_latest as (
  select *
  from {{ ref('int_netatmo_stations_data_latest') }}
),

renamed as (
  select
    home_id as id,
    home_name,
    place,
    sdp_metadata
  from netatmo_stations_data_latest
),

with_place_json_as_columns as (
  select
    * except (place),
    json_value(place.city) as city,
    json_value(place.country) as country,
    json_value(place.timezone) as timezone,
    cast(json_value(place.location[0]) as numeric) as latitude,
    cast(json_value(place.location[1]) as numeric) as longitude,
    cast(json_value(place.altitude) as integer) as altitude
  from renamed
)

select
  id,
  home_name,
  city,
  country,
  timezone,
  latitude,
  longitude,
  altitude,
  -- Repeat for reordering
  {{ cast_refined_at('sdp_metadata') }}
from with_place_json_as_columns
