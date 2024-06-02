{% snapshot dim_product_snapshot %}

{{ config({
    "unique_key": "product_id",
    "strategy": "check",
    "check_cols": ["product_sk"]
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped AS (
  {{ dbt_utils.deduplicate(
      relation='source_data',
      partition_by='product_id',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['product_id', 'product', 'category', 'segment', 'unit_cost', 'unit_price']) }}::STRING
                                                                        AS product_sk,
        product_id                                                      AS product_id,
        product                                                         AS product,
        category                                                        AS category,
        segment                                                         AS segment,
        unit_cost                                                       AS unit_cost,
        unit_price                                                      AS unit_price
    FROM deduped
)

SELECT *
FROM final

{% endsnapshot %}