{% snapshot dim_product_snapshot %}

{{ config({
    "unique_key": "ProductID",
    "strategy": "check",
    "check_cols": ["ProductSK"]
}) }}

SELECT
    {{
          dbt_utils.star(
            from=ref('dim_product'),
            except=['UpdatedTS']
            )
      }}
    FROM {{ ref('dim_product') }}

{% endsnapshot %}