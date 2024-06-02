{% snapshot fact_sales_snapshot %}

{{ config({
    "unique_key": "sales_id",
    "strategy": "check",
    "check_cols": ["sales_sk"]
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_customer_snapshot', 'dim_customer_snapshot'), 
('dim_geo_snapshot', 'dim_geo_snapshot'), 
('dim_manufacturer_snapshot', 'dim_manufacturer_snapshot'), 
('dim_product_snapshot', 'dim_product_snapshot')])
}},

deduped AS (
  {{ dbt_utils.deduplicate(
      relation='sales_staging',
      partition_by='sales_id',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['sales_id', 'units']) }}
                                                                                        AS sales_sk,
        sales_id                                                                        AS sales_id,
        customer_sk                                                                     AS customer_sk,
        order_date                                                                      AS order_date,
        dim_geo_snapshot.geo_sk                                                         AS geo_sk,
        manufacturer_sk                                                                 AS manufacturer_sk,
        product_sk                                                                      AS product_sk,
        campaign_id                                                                     AS campaign_id,
        units                                                                           AS units
    FROM deduped
    INNER JOIN dim_customer_snapshot                                                    ON deduped.customer_id = dim_customer_snapshot.customer_id
    INNER JOIN dim_geo_snapshot                                                         ON deduped.zip_code = dim_geo_snapshot.zip_code
    INNER JOIN dim_manufacturer_snapshot                                                ON deduped.manufacturer_id = dim_manufacturer_snapshot.manufacturer_id
    INNER JOIN dim_product_snapshot                                                     ON deduped.product_id = dim_product_snapshot.product_id
    WHERE dim_customer_snapshot.dbt_valid_to IS NULL
    AND dim_geo_snapshot.dbt_valid_to IS NULL
    AND dim_manufacturer_snapshot.dbt_valid_to IS NULL
    AND dim_product_snapshot.dbt_valid_to IS NULL
)


SELECT *
FROM final

{% endsnapshot %}