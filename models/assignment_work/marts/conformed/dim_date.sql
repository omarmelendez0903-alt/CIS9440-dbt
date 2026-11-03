-- CIS 9440 Homework 4
-- Shared Date Dimension: NYC 311 and DOB Job Filings

WITH stg_311 AS (
    SELECT *
    FROM {{ ref('stg_nyc_311_dot') }}
),

stg_dob AS (
    SELECT *
    FROM {{ ref('stg_nyc_dob_job_filings') }}
),

-- Collect dates from both staging models
all_dates AS (

    -- NYC 311 created date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(created_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_311

    UNION DISTINCT

    -- NYC 311 closed date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(closed_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_311

    UNION DISTINCT

    -- DOB filing date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(filing_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_dob

    UNION DISTINCT

    -- DOB current status date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(current_status_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_dob

    UNION DISTINCT

    -- DOB first permit date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(first_permit_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_dob

    UNION DISTINCT

    -- DOB approved date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(approved_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_dob

    UNION DISTINCT

    -- DOB signoff date
    SELECT
        SAFE_CAST(
            SUBSTR(CAST(signoff_date AS STRING), 1, 10)
            AS DATE
        ) AS full_date
    FROM stg_dob
),

-- Exclude missing or invalid dates
valid_dates AS (
    SELECT DISTINCT full_date
    FROM all_dates
    WHERE full_date IS NOT NULL
),

-- Generate date dimension attributes
date_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['full_date']) }}
            AS date_key,

        full_date,

        EXTRACT(YEAR FROM full_date) AS year,

        EXTRACT(QUARTER FROM full_date) AS quarter,

        EXTRACT(MONTH FROM full_date) AS month,

        FORMAT_DATE('%B', full_date) AS month_name,

        EXTRACT(DAY FROM full_date) AS day_of_month,

        EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week,

        FORMAT_DATE('%A', full_date) AS weekday_name,

        EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7)
            AS is_weekend,

        CASE
            WHEN EXTRACT(MONTH FROM full_date) >= 7
                THEN EXTRACT(YEAR FROM full_date) + 1
            ELSE EXTRACT(YEAR FROM full_date)
        END AS fiscal_year

    FROM valid_dates
),

-- Unknown or missing date placeholder
null_placeholder AS (
    SELECT
        '-1' AS date_key,
        CAST(NULL AS DATE) AS full_date,
        CAST(NULL AS INT64) AS year,
        CAST(NULL AS INT64) AS quarter,
        CAST(NULL AS INT64) AS month,
        CAST(NULL AS STRING) AS month_name,
        CAST(NULL AS INT64) AS day_of_month,
        CAST(NULL AS INT64) AS day_of_week,
        CAST(NULL AS STRING) AS weekday_name,
        CAST(NULL AS BOOLEAN) AS is_weekend,
        CAST(NULL AS INT64) AS fiscal_year
)

-- Final date dimension
SELECT *
FROM date_dimension

UNION ALL

SELECT *
FROM null_placeholder


