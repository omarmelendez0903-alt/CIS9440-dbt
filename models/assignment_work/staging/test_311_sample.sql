SELECT *
FROM {{ source('nyc_homework_raw_data', 'source_service_requests_homework') }}
LIMIT 10