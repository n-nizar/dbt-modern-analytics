{% macro dedupe_records(partition_by, order_by) %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY {{ partition_by }} ORDER BY {{ order_by }} DESC NULLS LAST) = 1
{% endmacro %}