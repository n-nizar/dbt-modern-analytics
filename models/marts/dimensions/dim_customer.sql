{{ config({
    "materialized": "incremental",
    "unique_key": "customer_id",
    "incremental_strategy": "merge"
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_geo', 'dim_geo')]) 
}},

deduped AS (
    SELECT DISTINCT 
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'email', 'first_name', 'last_name', 'sales_staging.zip_code']) }}
                                                                                        AS customer_sk,
        customer_id                                                                     AS customer_id,
        email                                                                           AS email,
        first_name                                                                      AS first_name,
        last_name                                                                       AS last_name,
        geo_sk                                                                          AS geo_sk
    FROM sales_staging
    INNER JOIN dim_geo
    ON sales_staging.zip_code = dim_geo.zip_code
    {{ dedupe_records('customer_id', 'load_date') }}
)


SELECT *,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ                       AS updated_ts
FROM deduped src

{% if is_incremental() %}
WHERE NOT EXISTS (
        SELECT 1
        FROM {{this}} dest
        WHERE   src.customer_sk = dest.customer_sk)
{% endif %}