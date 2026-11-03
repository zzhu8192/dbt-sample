# Purpose

Sample dbt project demonstrating:
- Fast, reproducible dependency management via [Astral uv](https://github.com/astral-sh/uv)
- Spark adapter integration (`dbt-spark` via Thrift server or local Spark session)
- Strict model contracts with enforced column types and shared YAML anchors
- Dynamic environment-aware schema generation (`generate_schema_name`)
- Comprehensive testing strategy: native dbt unit tests (mock data verification) and data tests
