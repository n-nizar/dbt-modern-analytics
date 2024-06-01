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

    -- ID Columns
    {{ dbt_utils.generate_surrogate_key(['OrderDate', 'ProductID', 'CampaignID', 'CustomerID', 'ManufacturerID', 'ZipCode']) }}::STRING
                                                                                        AS SalesID,
        OrderDate                                                                       AS OrderDate,
        ProductID                                                                       AS ProductID,
        CampaignID                                                                      AS CampaignID,
        CustomerID                                                                      AS CustomerID,
        ManufacturerID                                                                  AS ManufacturerID,
        ZipCode                                                                         AS ZipCode,

        -- Entity = Geography
        SPLIT_PART(City, ', ', 1)::STRING                                               AS City,
        State                                                                           AS State,
        SPLIT_PART(District, ' #', 2)::STRING                                           AS District,
        Region                                                                          AS Region,
        Country                                                                         AS Country,

        -- Entity = Product
        Product                                                                         AS Product,
        Category                                                                        AS Category,
        Segment                                                                         AS Segment,
        UnitCost                                                                        AS UnitCost,
        UnitPrice                                                                       AS UnitPrice,

        -- Entity = Customer
        LOWER(TRIM(REGEXP_SUBSTR(EmailName, '\\(([^)]+)\\)', 1, 1, 'e', 1)))::STRING    AS Email,
        TRIM(REGEXP_SUBSTR(EmailName, ', ([^ ]+)', 1, 1, 'e', 1))::STRING               AS FirstName,
        TRIM(REGEXP_SUBSTR(EmailName, ': ([^,]+),', 1, 1, 'e', 1))::STRING              AS LastName,

        -- Entity = Manufacturer
        Manufacturer                                                                    AS Manufacturer,

        -- Metrics
        Units                                                                           AS Units,

        -- Metadata
        LoadDate                                                                        AS LoadDate,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ                       AS UpdatedTS
    FROM source
    {{ dedupe_records('SalesID', 'LoadDate') }}
)

SELECT *
FROM deduped

{% if is_incremental() %}
WHERE LoadDate >= (SELECT MAX(LoadDate) FROM {{ this }})
{% endif %}