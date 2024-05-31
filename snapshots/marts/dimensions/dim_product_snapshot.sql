{% snapshot dim_product_snapshot %}

{{ config({
    "unique_key": "ProductID",
    "strategy": "check",
    "check_cols": ["ProductSK"]
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('sales_staging') }}
),

prep AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['ProductID', 'Product', 'Category', 'Segment', 'UnitCost', 'UnitPrice']) }}
                                                                        AS ProductSK,
        ProductID                                                       AS ProductID,
        Product                                                         AS Product,
        Category                                                        AS Category,
        Segment                                                         AS Segment,
        UnitCost                                                        AS UnitCost,
        UnitPrice                                                       AS UnitPrice
    FROM source_data
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ       AS UpdatedTS
FROM prep src

{% endsnapshot %}