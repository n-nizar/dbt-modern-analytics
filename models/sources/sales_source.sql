WITH source AS(
    SELECT * 
    FROM {{ source('internal_stage', 'sales')}}
),

renamed AS(
    SELECT 
        
        -- ID Columns
        Date::DATE                  AS order_date,
        ProductID::NUMBER           AS product_id,
        CampaignID::NUMBER          AS campaign_id,
        CustomerID::NUMBER          AS customer_id,
        ManufacturerID::NUMBER      AS manufacturer_id,
        ZipCode::NUMBER             AS zip_code,

        -- Entity = Geography
        City::VARCHAR               AS city,
        State::VARCHAR              AS state,
        District::VARCHAR           AS district,
        Region::VARCHAR             AS region,
        Country::VARCHAR            AS country,

        -- Entity = Product
        Product::VARCHAR            AS product,
        Category::VARCHAR           AS category,
        Segment::VARCHAR            AS segment,
        "Unit Cost"::FLOAT          AS unit_cost,
        "Unit Price"::FLOAT         AS unit_price,

        -- Entity = Customer
        "Email Name"::VARCHAR       AS email_name,

        -- Entity = Manufacturer
        Manufacturer::VARCHAR       AS manufacturer,

        -- Metrics
        Units::NUMBER               AS units,

        -- Metadata
        LoadDate::DATE              AS load_date

    FROM source
)

SELECT * 
FROM renamed