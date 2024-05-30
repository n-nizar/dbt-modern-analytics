{% macro dbt_audit_start_exec(invocation_id, execution_type, model) %}

INSERT INTO {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }} (invocation_id, execution_type, model, status, start_time)
VALUES ('{{ invocation_id }}', '{{ execution_type }}', '{{ model }}', 'Started Execution', CURRENT_TIMESTAMP())

{% endmacro %}