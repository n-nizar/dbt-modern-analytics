{% docs dbt_audit_started_exec %}
The dbt_audit_started_exec macro is designed to log audit records into an audit table, capturing metadata and execution details of dbt models and snapshots. It records the start of the dbt run, providing a comprehensive audit trail.
{% enddocs %}

{% docs dbt_audit_finished_exec %}
The dbt_audit_finished_exec macro is designed to log audit records into an audit table, capturing metadata and execution details of dbt models and snapshots. It records the end of the dbt run, providing a comprehensive audit trail.
{% enddocs %}

{% docs create_cte %}
The create_cte macro is designed to streamline the process of writing Common Table Expressions (CTEs) within dbt models. By leveraging this macro, dbt users can define multiple CTEs in a concise and organized manner, improving readability and maintainability of SQL code.
{% enddocs %}