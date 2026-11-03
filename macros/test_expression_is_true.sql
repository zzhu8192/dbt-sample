{% test expression_is_true(model, column_name, expression) %}
/*
  Generic test: expression_is_true

  Ensures that the provided SQL expression evaluates to TRUE for every row
  in the model. The expression can reference any column in the model,
  typically the column being tested.

  Arguments:
    - model: The relation (model) being tested.
    - column_name: The name of the column under test (required by dbt's
      generic test signature, but not used directly in this test).
    - expression: A SQL boolean expression as a string, e.g.
        "claim_amount >= 0"

  Returns:
    A SELECT statement that returns rows where the expression is NOT true.
    If the test passes, the result set will be empty.
*/
SELECT *
FROM {{ model }}
WHERE NOT ({{ expression }})
{% endtest %}
