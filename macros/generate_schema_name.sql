{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set env = target.schema | upper -%}
    {%- set exempt_envs = ['PRD', 'SBX', 'DEV', 'UAT', ''] -%}

    {%- set default_schema = target.schema -%}

    {# If user didn't specify custom schema, use default #}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {%- if env in exempt_envs -%}

            {# Do NOT append suffix for PRD/SBX/DEV/UAT/'' #}
            {{ custom_schema_name | trim }}

        {%- else -%}

            {# Normal case: suffix with __target_schema #}
            {{ custom_schema_name | trim }}__{{ default_schema }}

        {%- endif -%}

    {%- endif -%}
{%- endmacro %}
