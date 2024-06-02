{% snapshot dim_manufacturer_snapshot %}

{{ config({
    "unique_key": "manufacturer_id",
    "strategy": "check",
    "check_cols": ["manufacturer_sk"]
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

SELECT *
FROM final

{% endsnapshot %}