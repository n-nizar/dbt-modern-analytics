{% snapshot dim_geo_snapshot %}

{{ config({
    "unique_key": "zip_code",
    "strategy": "check",
    "check_cols": ["geo_sk"]
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

SELECT *
FROM final

{% endsnapshot %}