{% macro cast_refined_at(json_col) %}
  json_set({{ json_col }}, '$.refined_at', current_timestamp)
{% endmacro %}
