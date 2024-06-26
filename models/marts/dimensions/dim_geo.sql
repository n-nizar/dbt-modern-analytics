{{ config({
    "materialized": "incremental",
    "unique_key": "zip_code",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped as (
  {{ dbt_utils.deduplicate(
      relation='source_data',
      partition_by='zip_code',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['zip_code', 'city', 'district', 'state', 'region', 'country']) }}::STRING
                                                                        AS geo_sk,
        zip_code                                                        AS zip_code,
        city                                                            AS city,
        state                                                           AS state,
        district                                                        AS district,
        region                                                          AS region,
        country                                                         AS country
    FROM deduped
)

SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ      AS updated_ts
FROM final src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.geo_sk = dest.geo_sk)
{% endif %}