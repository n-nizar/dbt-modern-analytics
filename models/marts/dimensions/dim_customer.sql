{{ config({
    "materialized": "incremental",
    "unique_key": "customer_id",
    "incremental_strategy": "merge"
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_geo', 'dim_geo')]) 
}},

deduped as (
  {{ dbt_utils.deduplicate(
      relation='sales_staging',
      partition_by='customer_id',
      order_by='load_date DESC NULLS LAST',
     )
  }}
),

final AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'email', 'first_name', 'last_name', 'deduped.zip_code']) }}
                                                                                        AS customer_sk,
        customer_id                                                                     AS customer_id,
        email                                                                           AS email,
        first_name                                                                      AS first_name,
        last_name                                                                       AS last_name,
        geo_sk                                                                          AS geo_sk
    FROM deduped
    INNER JOIN dim_geo
    ON deduped.zip_code = dim_geo.zip_code
)

SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ                       AS updated_ts
FROM final src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.customer_sk = dest.customer_sk)
{% endif %}