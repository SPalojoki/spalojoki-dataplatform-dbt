with

netatmo_extracted_modules_latest as (
    select *
    from {{ ref('int_netatmo_extracted_modules_latest') }}
),

renamed as (
    select
        _id as id,
        module_name as name,
        type,
        reachable as is_reachable,
        battery_percent as battery_percentage,
        battery_vp as battery_voltage,
        rf_status as rf_strength,
        last_setup as latest_setup_modified_time,
        last_message as latest_message_time,
        last_seen as last_seen_time,
        firmware as firmware_version,
        main_module_id,
        sdp_metadata
    from netatmo_extracted_modules_latest
),

with_formatted_time as (
    select
        * except(latest_setup_modified_time, latest_message_time, last_seen_time),
        TIMESTAMP_SECONDS(latest_setup_modified_time) as latest_setup_modified_time,
        TIMESTAMP_SECONDS(latest_message_time) as latest_message_time,
        TIMESTAMP_SECONDS(last_seen_time) as last_seen_time
    from renamed
)

select
        id,
        name,
        main_module_id,
        type,
        latest_setup_modified_time,
        latest_message_time,
        last_seen_time,
        is_reachable,
        battery_percentage,
        battery_voltage,
        rf_strength,
        firmware_version,
        -- Repeat for reordering
        {{ cast_refined_at('sdp_metadata') }}
from with_formatted_time