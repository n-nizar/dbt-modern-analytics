{{config({
    "materialized": "incremental",
    "unique_key": ["OrderDate", "ProductID", "CampaignID", "CustomerID", "ManufacturerID", "ZipCode"],
    "incremental_strategy": "merge"
})}}


WITH source AS(
    SELECT *
    FROM {{ ref('sales_source') }}
),

updated AS(
    SELECT *,
    CURRENT_TIMESTAMP               AS ModifiedTS
    FROM source
)

SELECT *
FROM updated

{% if is_incremental() %}
WHERE LoadDate >= (SELECT MAX(LoadDate) FROM {{ this }})
{% endif %}