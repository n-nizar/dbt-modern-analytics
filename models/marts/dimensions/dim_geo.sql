{{ config({
    "materialized": "incremental",
    "unique_key": "ZipCode",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['ZipCode', 'City', 'District', 'State', 'Region', 'Country']) }}::STRING
                                                                        AS GeoSK,
        ZipCode                                                         AS ZipCode,
        City                                                            AS City,
        State                                                           AS State,
        District                                                        AS District,
        Region                                                          AS Region,
        Country                                                         AS Country
    FROM source_data
    {{ dedupe_records('ZipCode', 'LoadDate') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ      AS UpdatedTS
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.GeoSK = dest.GeoSK)
{% endif %}