{% macro dbt_audit_finish_exec(invocation_id, model) %}

UPDATE {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }}
SET status = 'Finished Execution', end_time = CURRENT_TIMESTAMP()
WHERE invocation_id = '{{ invocation_id }}' AND model = '{{ model }}' 

{% endmacro %}