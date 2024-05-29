{{ config({
    "materialized": "incremental",
    "tags": ["yearly-run"]
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