{% macro cast_refined_at(json_col) %}
  json_set({{ json_col }}, '$.refined_at', current_timestamp) as {{ json_col }}
{% endmacro %}

{% macro cast_published_at(json_col) %}
  json_set({{ json_col }}, '$.published_at', current_timestamp) as {{ json_col }}
{% endmacro %}
