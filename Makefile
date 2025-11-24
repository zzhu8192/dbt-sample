.PHONY: all sync build run test clean debug

all: sync build run test

sync:
	uv sync
	
build:
	# Use the dbt executable from the virtual‑env (forward slashes work everywhere)
	.venv/scripts/dbt build

run:
	.venv/scripts/dbt run

test:
	.venv/scripts/dbt test

debug:
	.venv/scripts/dbt debug
