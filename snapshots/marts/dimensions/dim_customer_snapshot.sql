{% snapshot dim_customer_snapshot %}

{{ config({
    "unique_key": "customer_id",
    "strategy": "check",
    "check_cols": ["customer_sk"]
}) }}

{{ create_cte([('sales_staging', 'sales_staging'), 
('dim_geo_snapshot', 'dim_geo_snapshot')]) 
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
    INNER JOIN dim_geo_snapshot                                                         ON deduped.zip_code = dim_geo_snapshot.zip_code
    WHERE dim_geo_snapshot.dbt_valid_to IS NULL
)

SELECT *
FROM final

{% endsnapshot %}