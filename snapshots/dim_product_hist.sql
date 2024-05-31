{% snapshot dim_product_hist %}

{{ config({
    "target_schema": "sales_mart",
    "unique_key": "ProductID",
    "strategy": "timestamp",
    "updated_at": "LoadDate"
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
        UnitPrice                                                       AS UnitPrice,
        MAX(LoadDate)                                                   AS LoadDate
    FROM source_data
    GROUP BY ProductSK, ProductID, Product, Category, Segment, UnitCost, UnitPrice
)


SELECT *,
        CURRENT_TIMESTAMP                                               AS UpdatedTS
FROM prep src

{% endsnapshot %}