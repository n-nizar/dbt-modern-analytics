{{ config({
    "materialized": "incremental",
    "unique_key": "manufacturer_id",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped as (
  {{ dbt_utils.deduplicate(
      relation='source_data',
      partition_by='manufacturer_id',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['manufacturer_id', 'manufacturer']) }}::STRING
                                                                        AS manufacturer_sk,
        manufacturer_id                                                 AS manufacturer_id,
        manufacturer                                                    AS manufacturer
    FROM deduped
)

SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ       AS updated_ts
FROM final src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.manufacturer_sk = dest.manufacturer_sk)
{% endif %}