{{config({
    "materialized": "incremental",
    "unique_key": ["sales_id"],
    "incremental_strategy": "merge"
})}}


{{ create_cte([('sales_source', 'sales_source'), 
('state_names', 'state_names'), 
('country_names', 'country_names')]) 
}},

prep AS(
    SELECT 

    -- ID Columns
    {{ dbt_utils.generate_surrogate_key(['order_date', 'product_id', 'campaign_id', 'customer_id', 'manufacturer_id', 'zip_code']) }}::STRING
                                                                                        AS sales_id,
        order_date                                                                      AS order_date,
        product_id                                                                      AS product_id,
        campaign_id                                                                     AS campaign_id,
        customer_id                                                                     AS customer_id,
        manufacturer_id                                                                 AS manufacturer_id,
        zip_code                                                                        AS zip_code,

        -- Entity = Geography
        SPLIT_PART(city, ', ', 1)::STRING                                               AS city,
        state                                                                           AS state,
        SPLIT_PART(district, ' #', 2)::STRING                                           AS district,
        region                                                                          AS region,
        country                                                                         AS country,

        -- Entity = product
        product                                                                         AS product,
        category                                                                        AS category,
        segment                                                                         AS segment,
        unit_cost                                                                       AS unit_cost,
        unit_price                                                                      AS unit_price,

        -- Entity = Customer
        LOWER(TRIM(REGEXP_SUBSTR(email_name, '\\(([^)]+)\\)', 1, 1, 'e', 1)))::STRING   AS email,
        TRIM(REGEXP_SUBSTR(email_name, ', ([^ ]+)', 1, 1, 'e', 1))::STRING              AS first_name,
        TRIM(REGEXP_SUBSTR(email_name, ': ([^,]+),', 1, 1, 'e', 1))::STRING             AS last_name,

        -- Entity = manufacturer
        manufacturer                                                                    AS manufacturer,

        -- Metrics
        units                                                                           AS units,

        -- Metadata
        load_date                                                                       AS load_date,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ                       AS updated_ts
    FROM sales_source
),

deduped as (
  {{ dbt_utils.deduplicate(
      relation='prep',
      partition_by='sales_id',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS(
    SELECT 

        sales_id,
        order_date,
        product_id,
        campaign_id,
        customer_id,
        manufacturer_id,
        zip_code,

        city,
        state_names.state_name                  AS state,
        district,
        region,
        country_names.country_name              AS country,

        product,
        category,
        segment,
        unit_cost,
        unit_price,

        email,
        first_name,
        last_name,

        manufacturer,

        units,

        load_date,
        updated_ts
    FROM deduped
    JOIN state_names                    ON deduped.state = state_names.state
    JOIN country_names                  ON deduped.country = country_names.country   
)

SELECT *
FROM final

{% if is_incremental() %}
WHERE load_date >= (SELECT MAX(load_date) FROM {{ this }})
{% endif %}