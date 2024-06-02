{{ config({
    "materialized": "incremental",
    "unique_key": "sales_id",
    "incremental_strategy": "merge"
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_customer', 'dim_customer'), 
('dim_geo', 'dim_geo'), 
('dim_manufacturer', 'dim_manufacturer'), 
('dim_product', 'dim_product')])
}},

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['sales_id', 'units']) }}
                                                                                        AS sales_sk,
        sales_id                                                                        AS sales_id,
        customer_sk                                                                     AS customer_sk,
        order_date                                                                      AS order_date,
        dim_geo.geo_sk                                                                  AS geo_sk,
        manufacturer_sk                                                                 AS manufacturer_sk,
        product_sk                                                                      AS product_sk,
        campaign_id                                                                     AS campaign_id,
        units                                                                           AS units
    FROM sales_staging
    INNER JOIN dim_customer                                                             ON sales_staging.customer_id = dim_customer.customer_id
    INNER JOIN dim_geo                                                                  ON sales_staging.zip_code = dim_geo.zip_code
    INNER JOIN dim_manufacturer                                                         ON sales_staging.manufacturer_id = dim_manufacturer.manufacturer_id
    INNER JOIN dim_product                                                              ON sales_staging.product_id = dim_product.product_id
    {{ dedupe_records('sales_id', 'load_date') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ                       AS updated_ts
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.sales_sk = dest.sales_sk)
{% endif %}