WITH source AS(
    SELECT * 
    FROM {{ source('internal_stage', 'sales')}}
),

renamed AS(
    SELECT 
        
        -- ID Columns
        Date::DATE                  AS OrderDate,
        ProductID::NUMBER           AS ProductID,
        CampaignID::NUMBER          AS CampaignID,
        CustomerID::NUMBER          AS CustomerID,
        ManufacturerID::NUMBER      AS ManufacturerID,
        ZipCode::NUMBER             AS ZipCode,

        -- Entity = Geography
        City::VARCHAR               AS City,
        State::VARCHAR              AS State,
        District::VARCHAR           AS District,
        Region::VARCHAR             AS Region,
        Country::VARCHAR            AS Country,

        -- Entity = Product
        Product::VARCHAR            AS Product,
        Category::VARCHAR           AS Category,
        Segment::VARCHAR            AS Segment,
        "Unit Cost"::FLOAT          AS UnitCost,
        "Unit Price"::FLOAT         AS UnitPrice,

        -- Entity = Customer
        "Email Name"::VARCHAR       AS EmailName,

        -- Entity = Manufacturer
        Manufacturer::VARCHAR       AS Manufacturer,

        -- Metrics
        Units::NUMBER               AS Units,

        -- Metadata
        LoadDate::DATE              AS LoadDate

    FROM source
)

SELECT * 
FROM renamed