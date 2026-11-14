
WITH source AS (
    SELECT *
    FROM {{ source('raw', 'source_mv_collisions') }}
),
cleaned AS (
    SELECT
        * EXCEPT (
            collision_id,
            crash_date,
            crash_time,
            borough,
            zip_code,
            latitude,
            longitude
        ),

        -- Collision identifier
        CAST(collision_id AS STRING) AS collision_id,

        -- Crash date and time
        CAST(crash_date AS DATE) AS crash_date,
        CAST(crash_time AS STRING) AS crash_time,

        -- Standardize borough names
        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEENS COUNTY') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
            ELSE NULL
        END AS borough,

        -- Clean collision ZIP codes
        CASE
            WHEN REGEXP_CONTAINS(
                TRIM(CAST(zip_code AS STRING)),
                r'^\d{5}$'
            )
            THEN TRIM(CAST(zip_code AS STRING))
            ELSE NULL
        END AS zip,

        -- Geographic coordinates
        SAFE_CAST(latitude AS FLOAT64) AS latitude,
        SAFE_CAST(longitude AS FLOAT64) AS longitude,

        -- Staging metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Keep records with a valid collision ID
    WHERE collision_id IS NOT NULL

    -- Remove duplicate collision IDs
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY collision_id
        ORDER BY crash_date DESC
    ) = 1
)

SELECT * FROM cleaned
