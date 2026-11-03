@echo off
REM Wrapper script to execute dbt within the uv managed environment on Windows
uv run dbt --profiles-dir .dbt %*
