-- Shared location dimension for NYC 311 traffic-safety requests
-- and motor vehicle collisions.
-- Grain: one row per distinct borough and ZIP code combination.

WITH stg_311 AS (
    SELECT * FROM {{ ref('stg_311_traffic') }}
),

stg_mv AS (
    SELECT * FROM {{ ref('stg_mv_collisions') }}
),

-- Collect distinct locations from both datasets
all_locations AS (

    SELECT DISTINCT
        CAST(borough AS STRING) AS borough,
        CAST(zip AS STRING) AS zip
    FROM stg_311
    WHERE borough IS NOT NULL
       OR zip IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        CAST(borough AS STRING) AS borough,
        CAST(zip AS STRING) AS zip
    FROM stg_mv
    WHERE borough IS NOT NULL
       OR zip IS NOT NULL

),

-- Generate a unique surrogate key for each location
location_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'borough', 'zip'
        ]) }} AS location_key,

        borough,
        zip

    FROM all_locations

),

-- Unknown location record for missing borough and ZIP values
null_placeholder AS (

    SELECT
        '-1' AS location_key,
        CAST(NULL AS STRING) AS borough,
        CAST(NULL AS STRING) AS zip

)

-- Combine valid locations with the unknown record
SELECT * FROM location_dimension

UNION ALL

SELECT * FROM null_placeholder
