{% macro count_records(model_name) %}

    {% set count_query %}
        SELECT COUNT(*) AS count FROM {{ model_name }}
    {% endset %}

    {% set results = run_query(count_query) %}

    {% if execute %}
        {% set record_count = results.columns[0].values()[0] %}
    {% else %}
        {% set record_count = 0 %}
    {% endif %}

    {{ log("Record Count: " ~record_count, info=True) }}

    {{ return(record_count) }}

{% endmacro %}