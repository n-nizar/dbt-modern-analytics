{{ config({
    "materialized": "incremental",
    "unique_key": "manufacturer_id",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['manufacturer_id', 'manufacturer']) }}::STRING
                                                                        AS manufacturer_sk,
        manufacturer_id                                                 AS manufacturer_id,
        manufacturer                                                    AS manufacturer
    FROM source_data
    {{ dedupe_records('manufacturer_id', 'load_date') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ       AS updated_ts
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.manufacturer_sk = dest.manufacturer_sk)
{% endif %}