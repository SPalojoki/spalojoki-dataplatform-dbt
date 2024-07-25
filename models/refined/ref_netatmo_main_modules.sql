with

netatmo_stations_data_latest as (
    select *
    from {{ ref('int_netatmo_stations_data_latest') }}
),

renamed as (
    select
        _id as id,
        module_name as name,
        type,
        date_setup as initial_setup_time,
        last_setup as latest_setup_modified_time,
        last_status_store as latest_update_time,
        firmware as firmware_version,
        wifi_status as wifi_strength,
        reachable as is_reachable,
        co2_calibrating as is_co2_calibrating,
        home_id,
        sdp_metadata
    from netatmo_stations_data_latest
),

with_formatted_time as (
    select
        * except(initial_setup_time, latest_setup_modified_time, latest_update_time),
        TIMESTAMP_SECONDS(initial_setup_time) as initial_setup_time,
        TIMESTAMP_SECONDS(latest_setup_modified_time) as latest_setup_modified_time,
        TIMESTAMP_SECONDS(latest_update_time) as latest_update_time
    from renamed
)

select
        id,
        name,
        home_id,
        type,
        initial_setup_time,
        latest_setup_modified_time,
        is_reachable,
        is_co2_calibrating,
        latest_update_time,
        wifi_strength,
        firmware_version,
        -- Repeat for reordering
        {{ cast_refined_at('sdp_metadata') }}
from with_formatted_time