{% set pre_hook = dbt_audit_start_exec() %}
{% set post_hook = dbt_audit_finish_exec() %}

{{ config({
    "materialized": "incremental",
    "tags": ["yearly-run"],
    "pre_hook": pre_hook,
    "post_hook": post_hook
})
}}

WITH date_spine AS (

  {{ dbt_utils.date_spine(
      start_date="to_date('01/01/2010', 'mm/dd/yyyy')",
      datepart="day",
      end_date="dateadd(year, 2, current_date)"
     )
  }}

), final as (
    SELECT 
        date_day                                         AS date_day,
        DATE_PART('dayofmonth', date_day)                AS dayofmonth,
        DATE_PART('month', date_day)                     AS month,
        DATE_PART('year', date_day)                      AS year
    FROM
    date_spine
)

SELECT * 
FROM final
{% if is_incremental() %}
WHERE date_day > (SELECT MAX(date_day) FROM {{ this }})
{% endif %}