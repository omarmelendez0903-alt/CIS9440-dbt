-- CIS 9440 Homework 4
-- Clean and standardize NYC DOB job filings

WITH source AS (
    SELECT *
    FROM {{ source('nyc_homework_raw_data', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT
        * REPLACE (
            SAFE_CAST(
                SUBSTR(CAST(filing_date AS STRING), 1, 10)
                AS DATE
            ) AS filing_date,

            SAFE_CAST(
                SUBSTR(CAST(current_status_date AS STRING), 1, 10)
                AS DATE
            ) AS current_status_date,

            SAFE_CAST(
                SUBSTR(CAST(first_permit_date AS STRING), 1, 10)
                AS DATE
            ) AS first_permit_date,

            SAFE_CAST(
                SUBSTR(CAST(approved_date AS STRING), 1, 10)
                AS DATE
            ) AS approved_date,

            SAFE_CAST(
                SUBSTR(CAST(signoff_date AS STRING), 1, 10)
                AS DATE
            ) AS signoff_date
        )
    FROM source
)

SELECT *
FROM cleaned
