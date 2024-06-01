{{ config({
    "materialized": "incremental",
    "unique_key": "ManufacturerID",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['ManufacturerID', 'Manufacturer']) }}::STRING
                                                                        AS ManufacturerSK,
        ManufacturerID                                                  AS ManufacturerID,
        Manufacturer                                                    AS Manufacturer
    FROM source_data
    {{ dedupe_records('ManufacturerID', 'LoadDate') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ      AS UpdatedTS
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.ManufacturerSK = dest.ManufacturerSK)
{% endif %}