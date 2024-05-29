{{ config({
    "materialized": "incremental",
    "unique_key": "ProductID",
    "incremental_strategy": "merge"
}) }}

WITH source_data AS(
    SELECT *
    FROM {{ ref('internal_stage_sales_source') }}
),

prep AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['ProductID', 'Product', 'Category', 'Segment', 'UnitCost', 'UnitPrice']) }}
                                                                        AS ProductKey,
        ProductID                                                       AS ProductID,
        Product                                                         AS Product,
        Category                                                        AS Category,
        Segment                                                         AS Segment,
        UnitCost                                                        AS UnitCost,
        UnitPrice                                                       AS UnitPrice,
        CURRENT_TIMESTAMP                                               AS ModifiedTS
    FROM source_data
)


SELECT *
FROM prep src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.ProductID = dest.ProductID
        AND     src.Product = dest.Product
        AND     src.Category = dest.Category
        AND     src.Segment = dest.Segment
        AND     src.UnitCost = dest.UnitCost
        AND     src.UnitPrice = dest.UnitPrice)

{% endif %}


