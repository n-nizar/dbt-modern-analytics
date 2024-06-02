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
        date_day                                            AS date_day,
        TO_CHAR(date_day,'DD')                              AS day,
        DECODE(DAYNAME(date_day), 'Mon', 'Monday', 'Tue',
        'Tuesday', 'Wed', 'Wednesday',
        'Thu', 'Thursday', 'Fri', 'Friday',
        'Sat', 'Saturday', 'Sun', 'Sunday')                 AS day_name,
        TO_CHAR(date_day,'MM')                              AS month,
        TO_CHAR(date_day,'MMMM')                            AS month_name,
        'Q' || DATE_PART('quarter', date_day)               AS quarter,
        DATE_PART('year', date_day)                         AS year
    FROM
    date_spine
)

SELECT * 
FROM final
{% if is_incremental() %}
WHERE date_day > (SELECT MAX(date_day) FROM {{ this }})
{% endif %}