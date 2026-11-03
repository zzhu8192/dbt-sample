# Purpose

Sample dbt project demonstrating:
- Fast, reproducible dependency management via [Astral uv](https://github.com/astral-sh/uv)
- Spark adapter integration (`dbt-spark`) supporting both local open-source Spark distributions (Thrift/Session) and Databricks clusters
- Systematic development and testing architecture suitable for local iteration and automated CI/CD pipelines
- Strict model contracts with enforced column types and shared YAML anchors
- Dynamic environment-aware schema generation (`generate_schema_name`)
- Comprehensive testing strategy: native dbt unit tests (mock data verification) and data tests
