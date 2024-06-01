{{ config({
    "materialized": "incremental",
    "unique_key": "CustomerID",
    "incremental_strategy": "merge"
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_geo', 'dim_geo')]) 
}},

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['CustomerID', 'Email', 'FirstName', 'LastName', 'sales_staging.ZipCode']) }}
                                                                                        AS CustomerSK,
        CustomerID                                                                      AS CustomerID,
        Email                                                                           AS Email,
        FirstName                                                                       AS FirstName,
        LastName                                                                        AS LastName,
        GeoSK                                                                           AS GeoSK
    FROM sales_staging
    INNER JOIN dim_geo
    ON sales_staging.ZipCode = dim_geo.ZipCode
    {{ dedupe_records('CustomerID', 'LoadDate') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ      AS UpdatedTS
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.CustomerSK = dest.CustomerSK)
{% endif %}