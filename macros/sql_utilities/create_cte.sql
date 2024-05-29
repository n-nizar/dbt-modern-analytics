{% macro create_cte(list) %}

WITH {% for table in list %} {{ table[0] }} AS(
    SELECT * FROM {{ table[1] }}
)
    {% if not loop.last %}
    ,
    {% endif %}

    {% endfor %}


{% endmacro %}
