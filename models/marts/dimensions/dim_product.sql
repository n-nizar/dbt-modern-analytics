{{ config({
    "materialized": "incremental",
    "unique_key": "product_id",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['product_id', 'product', 'category', 'segment', 'unit_cost', 'unit_price']) }}::STRING
                                                                        AS product_sk,
        product_id                                                      AS product_id,
        product                                                         AS product,
        category                                                        AS category,
        segment                                                         AS segment,
        unit_cost                                                       AS unit_cost,
        unit_price                                                      AS unit_price
    FROM source_data
    {{ dedupe_records('product_id', 'load_date') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ       AS updated_ts
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.product_sk = dest.product_sk)
{% endif %}


