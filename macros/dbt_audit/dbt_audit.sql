{% macro dbt_audit_started_exec() %}

{% set audit_start_query %}

{% if this.name %}
INSERT INTO {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }} (invocation_id,  object_type, object, status, start_time)
VALUES ('{{ invocation_id }}', '{{ model.resource_type | title }}', '{{ this.name }}', 'started', CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ)

{% else %}
INSERT INTO {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }} (invocation_id,  object_type, object, status, start_time)
VALUES ('{{ invocation_id }}', '{{ model.resource_type | title }}', '{{ model.resource_type | title }}', 'started', CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ)

{% endif %}
{% endset %}

{% do run_query(audit_start_query) %}

{% endmacro %}

{% macro dbt_audit_finished_exec() %}

{% set audit_finish_query %}

{% if this.name %}
UPDATE {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }}
SET status = 'Finished Execution', end_time = CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ
WHERE invocation_id = '{{ invocation_id }}' AND object = '{{ this.name }}'

{% else %}
UPDATE {{ var('dbt_audit_database') }}.{{ var('dbt_audit_schema') }}.{{ var('dbt_audit_table') }}
SET status = 'Finished Execution', end_time = CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP)::TIMESTAMP_NTZ
WHERE invocation_id = '{{ invocation_id }}' AND  object = 'Operation'

{% endif %}
{% endset %}

{% do run_query(audit_finish_query) %}

{% endmacro %}