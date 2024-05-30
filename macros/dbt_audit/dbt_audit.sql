{% macro dbt_audit_started_exec() %}

{% set audit_start_query %}

{% if this.name %}
INSERT INTO {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }} (invocation_id, execution_type, model, status, start_time)
VALUES ('{{ invocation_id }}', 'Model', '{{ this.name }}', 'Started Execution', CURRENT_TIMESTAMP())

{% else %}
INSERT INTO {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }} (invocation_id, execution_type, model, status, start_time)
VALUES ('{{ invocation_id }}', 'Full Execution', 'Full Execution', 'Started Execution', CURRENT_TIMESTAMP())

{% endif %}
{% endset %}

{% do run_query(audit_start_query) %}

{% endmacro %}

{% macro dbt_audit_finished_exec() %}

{% set audit_finish_query %}

{% if this.name %}
UPDATE {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }}
SET status = 'Finished Execution', end_time = CURRENT_TIMESTAMP()
WHERE invocation_id = '{{ invocation_id }}' AND model = '{{ this.name }}'

{% else %}
UPDATE {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }}
SET status = 'Finished Execution', end_time = CURRENT_TIMESTAMP()
WHERE invocation_id = '{{ invocation_id }}' AND model = 'Full Execution'

{% endif %}
{% endset %}

{% do run_query(audit_finish_query) %}

{% endmacro %}