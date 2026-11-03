
SELECT
    unique_key,
    created_date,
    closed_date,
    agency,
    agency_name,
    complaint_type,
    descriptor,
    location_type,
    incident_zip,
    incident_address,
    borough,
    latitude,
    longitude
FROM {{ source('nyc_homework_raw_data', 'source_service_requests_homework') }}
