{{config({
    "materialized": "incremental",
    "unique_key": ["SalesID"],
    "incremental_strategy": "merge"
})}}


WITH source AS(
    SELECT *
    FROM {{ ref('sales_source') }}
),

deduped AS(
    SELECT 
    {{ dbt_utils.generate_surrogate_key(['OrderDate', 'ProductID', 'CampaignID', 'CustomerID', 'ManufacturerID', 'ZipCode']) }}
                                                                    AS SalesID,
    *,
    CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ       AS UpdatedTS
    FROM source
    {{ dedupe_records('SalesID', 'LoadDate') }}
)

SELECT *
FROM deduped

{% if is_incremental() %}
WHERE LoadDate >= (SELECT MAX(LoadDate) FROM {{ this }})
{% endif %}