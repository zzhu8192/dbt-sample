.PHONY: all sync build run test unit-test clean debug

all: sync build run test

sync:
	uv sync

build:
	uv run dbt build --profiles-dir .dbt

run:
	uv run dbt run --profiles-dir .dbt

test:
	uv run dbt test --profiles-dir .dbt

unit-test:
	uv run dbt test --select "test_type:unit" --profiles-dir .dbt

debug:
	uv run dbt debug --profiles-dir .dbt

clean:
	uv run dbt clean
