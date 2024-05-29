{{ config({
    "materialized": "view",
    "tags": ["not-ready"]
})}}

{{ create_cte([('internal_stage_sales_source', 'internal_stage_sales_source')]) }}