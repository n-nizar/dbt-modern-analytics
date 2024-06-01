{% macro create_cte(list) %}

WITH {% for cte in list %} {{ cte[0] }} AS(
    SELECT * FROM {{ ref(cte[1]) }}
)
    {% if not loop.last %}
    ,
    {% endif %}

    {% endfor %}


{% endmacro %}
