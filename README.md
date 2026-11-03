# dbt-sample

[![dbt Core](https://img.shields.io/badge/dbt--core-1.11+-FF694B.svg?logo=dbt&logoColor=white)](https://docs.getdbt.com/)
[![dbt-spark](https://img.shields.io/badge/dbt--spark-1.11+-FF694B.svg?logo=dbt&logoColor=white)](https://github.com/dbt-labs/dbt-spark)
[![uv](https://img.shields.io/badge/managed%20by-uv-DE5FE9.svg)](https://github.com/astral-sh/uv)
[![Python](https://img.shields.io/badge/python-3.11+-3776AB.svg?logo=python&logoColor=white)](https://www.python.org/)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A reference implementation demonstrating modern **dbt (Data Build Tool)** practices with deterministic, blazing-fast dependency management using **[Astral uv](https://github.com/astral-sh/uv)**, Apache Spark execution via `dbt-spark`, and a comprehensive testing architecture combining **dbt v1.8+ native unit tests** with schema and custom generic data tests.

---

> [!NOTE] Architecture & Execution Parity: Local Spark Distributions & Databricks
> This project is designed for **systematic local development and automated CI/CD testing** across both **local Apache Spark distributions** and **Databricks clusters**:
> - **Local Spark Distributions**: Supports running directly against local, standalone open-source Apache Spark (e.g., via the Spark Thrift Server on port 10000 or in-process PySpark sessions), eliminating the requirement to spin up expensive cloud warehouses or Databricks clusters just to develop and run tests.
> - **Databricks & Cloud Parity**: The exact same models, strict contracts, custom macros, and tests deploy seamlessly to Databricks (SQL Warehouses or All-Purpose clusters via HTTP/ODBC) simply by toggling the dbt target.
> - **CI/CD Friendly**: Enables fast, hermetic, zero-cost pipeline runs in CI runners (e.g., executing `uv run dbt test` against a local Spark container or process without cloud credentials).

---

## Highlights

- **Dependency Management via `uv`**:
  - Eliminates dependency drift and global Python environment pollution.
  - Reproducible, lightning-fast virtual environment resolution (`uv sync`) pinned by `uv.lock`.
  - Zero-overhead command execution using `uv run dbt ...` without requiring manual virtual environment activation.
  - Unified cross-platform CLI wrapper scripts ([`dbt`](file:///home/zzhu/homerepos/dbt-sample/dbt) for Linux/macOS and [`dbt.bat`](file:///home/zzhu/homerepos/dbt-sample/dbt.bat) for Windows).
- **Comprehensive Testing Architecture**:
  - **Native Unit Tests (`unit_tests`)**: Unit test SQL transformation logic and incremental filter logic in isolation using synthetic in-memory rows (`given:` / `expect:`), without requiring external data pipelines.
  - **Schema & Data Tests**: Enforce `not_null` and `unique` constraints across models.
  - **Custom Generic Macros**: Custom parameterized tests such as [`expression_is_true`](file:///home/zzhu/homerepos/dbt-sample/macros/test_expression_is_true.sql) and [`dob_is_yyyymmdd`](file:///home/zzhu/homerepos/dbt-sample/macros/dob_is_yyyymmdd.sql).
- **Strict Model Contracts & DRY Schemas**:
  - Enforced model contracts (`contract: { enforced: true }`) ensuring schema and data type stability across layers.
  - Shared column definitions via YAML anchors (`&std_claim_line_columns`) in [`models/shared/claim.yml`](file:///home/zzhu/homerepos/dbt-sample/models/shared/claim.yml).
- **Environment-Aware Custom Schemas**:
  - Intelligent schema resolution in [`macros/generate_schema_name.sql`](file:///home/zzhu/homerepos/dbt-sample/macros/generate_schema_name.sql) that keeps production/staging schemas clean (`PRD`, `SBX`, `DEV`, `UAT`) while suffixing developer-specific schemas (`<schema>__<username>`) during local runs.
- **Spark & Iceberg Ready**:
  - Configured for Apache Spark (`dev-thrift` Spark Thrift Server or `dev-session` PySpark local session), with support for incremental tables and Iceberg managed tables.

---

## Project Structure

```text
dbt-sample/
├── .dbt/
│   └── profiles.yml             # Local dbt profile configuration (Spark Thrift & Session)
├── data/
│   ├── payer01_claim.csv        # Seed data for payer 01 claims
│   └── payer02_claim.csv        # Seed data for payer 02 claims
├── macros/
│   ├── generate_schema_name.sql # Custom macro for environment-aware schema naming
│   ├── test_expression_is_true.sql # Custom generic assertion test macro
│   └── dob_is_yyyymmdd.sql      # Regex-based date-of-birth format validator macro
├── models/
│   ├── payer01_silver/
│   │   ├── payer01__claim.sql       # Silver-layer claim table model
│   │   ├── payer01__claim_inc.sql   # Incremental silver-layer claim model
│   │   ├── payer01__claim_unit_test.yml # Native dbt unit tests for payer01
│   │   └── payer01__source.yml      # Raw ingested source definitions
│   ├── payer02_silver/
│   │   ├── payer02__claim.sql       # Silver-layer claim model for payer 02
│   │   └── payer02__source.yml      # Raw ingested source definitions
│   └── shared/
│       └── claim.yml            # Shared claim columns, contract definitions & tests
├── dbt                          # Bash wrapper script executing 'uv run dbt'
├── dbt.bat                      # Windows batch wrapper script
├── dbt_project.yml              # dbt project configuration & schema mappings
├── Makefile                     # Shortcut tasks for sync, build, run, test, and debug
├── packages.yml                 # External dbt packages manifest
├── pyproject.toml               # Python project configuration and dbt dependencies
└── uv.lock                      # Pinned dependency lockfile
```

---

## Dependency Management with `uv`

This repository uses [uv](https://docs.astral.sh/uv/) for Python and toolchain management.

### Why `uv` for dbt?

1. **Deterministic Builds**: `pyproject.toml` defines exact version ranges (`dbt-core>=1.11.2`, `dbt-spark[PyHive]>=1.10.0`), while [`uv.lock`](file:///home/zzhu/homerepos/dbt-sample/uv.lock) locks all 60+ transitive dependencies (Thrift, PySpark, PyHive, click, etc.) with cryptographic hashes.
2. **Speed**: Environments resolve and install in milliseconds.
3. **Reproducibility**: Team members and CI runners get identical package sets across macOS, Linux, and Windows without manual `python -m venv` or `pip install` commands.

### Initial Setup

Ensure `uv` is installed (see [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)):

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Sync the environment directly from [`uv.lock`](file:///home/zzhu/homerepos/dbt-sample/uv.lock):

```bash
uv sync
```

This creates an isolated `.venv` containing `dbt` and all Spark adapters.

---

## Testing Strategy

Testing in this project is split into two complementary layers: **Unit Tests** and **Data Tests**.

### 1. Native dbt Unit Tests (`unit_tests`)

Introduced natively in dbt 1.8+, unit tests validate SQL transformation logic and incremental logic against mocked in-memory test fixtures before querying database tables.

In [`models/payer01_silver/payer01__claim_unit_test.yml`](file:///home/zzhu/homerepos/dbt-sample/models/payer01_silver/payer01__claim_unit_test.yml):

```yaml
version: 2

unit_tests:
  - name: test_payer01__claim_transformation
    description: "Unit test verifying column projection and schema contract for payer01__claim"
    model: payer01__claim
    given:
      - input: source('payer01_ingested', 'payer01_claim')
        rows:
          - {claim_id: 100, patient_id: 11, service_date: "2023-01-10", claim_amount: 250.00, diagnosis_code: "A01"}
          - {claim_id: 101, patient_id: 11, service_date: "2023-02-15", claim_amount: 125.50, diagnosis_code: "B02"}
    expect:
      rows:
        - {claim_id: 100, patient_id: 11, service_date: "2023-01-10", claim_amount: 250.00, diagnosis_code: "A01"}
        - {claim_id: 101, patient_id: 11, service_date: "2023-02-15", claim_amount: 125.50, diagnosis_code: "B02"}

  - name: test_payer01__claim_inc_incremental_logic
    description: "Unit test verifying incremental logic filtering by max claim_id"
    model: payer01__claim_inc
    overrides:
      macros:
        is_incremental: true
    given:
      - input: this
        rows:
          - {claim_id: 100, patient_id: 11, service_date: "2023-01-10", claim_amount: 250.00, diagnosis_code: "A01"}
      - input: source('payer01_ingested', 'payer01_claim')
        rows:
          - {claim_id: 100, patient_id: 11, service_date: "2023-01-10", claim_amount: 250.00, diagnosis_code: "A01"}
          - {claim_id: 105, patient_id: 12, service_date: "2023-03-01", claim_amount: 300.00, diagnosis_code: "C03"}
    expect:
      rows:
        - {claim_id: 105, patient_id: 12, service_date: "2023-03-01", claim_amount: 300.00, diagnosis_code: "C03"}
```

To run unit tests exclusively:

```bash
uv run dbt test --select "test_type:unit" --profiles-dir .dbt
# Or via Makefile:
make unit-test
```

### 2. Schema and Custom Generic Data Tests

Data tests assert data quality rules on materialized tables.

In [`models/shared/claim.yml`](file:///home/zzhu/homerepos/dbt-sample/models/shared/claim.yml), reusable YAML anchors define contracts and tests for every claim model:

```yaml
std_claim_line_columns: &std_claim_line_columns
  - name: claim_id
    description: "claim id"
    data_type: bigint
    data_tests:
      - not_null
      - unique

  - name: patient_id
    description: "patient_id as int"
    data_type: bigint
    data_tests:
      - not_null

  - name: claim_amount
    description: "amount"
    data_type: double
    data_tests:
      - not_null
      - expression_is_true:
          arguments:
            expression: "claim_amount >= 0"
```

Custom generic macro [`macros/test_expression_is_true.sql`](file:///home/zzhu/homerepos/dbt-sample/macros/test_expression_is_true.sql):

```sql
{% test expression_is_true(model, column_name, expression) %}
SELECT *
FROM {{ model }}
WHERE NOT ({{ expression }})
{% endtest %}
```

---

## Configuration & Running dbt

### 1. Profiles: Local Spark & Databricks Parity

Profiles are located in [`.dbt/profiles.yml`](file:///home/zzhu/homerepos/dbt-sample/.dbt/profiles.yml). The setup supports seamless execution against local Apache Spark distributions and managed Databricks endpoints:

```yaml
sample_dbt_project:
  outputs:
    # 1. Local Open-Source Spark (Thrift Server via PyHive)
    dev-thrift:
      type: spark
      method: thrift
      schema: dbt
      host: localhost
      port: 10000

    # 2. Local Open-Source Spark (PySpark in-process session)
    dev-session:
      type: spark
      method: session
      schema: dbt
      host: local

    # 3. Databricks SQL Warehouse / All-Purpose Cluster
    databricks-dev:
      type: spark
      method: http
      schema: dbt
      host: "{{ env_var('DATABRICKS_HOST', '<workspace-id>.cloud.databricks.com') }}"
      http_path: "{{ env_var('DATABRICKS_HTTP_PATH', '/sql/1.0/endpoints/<endpoint-id>') }}"
      token: "{{ env_var('DATABRICKS_TOKEN', '') }}"

  target: dev-thrift
```

#### Running Against Local Spark
To spin up a local Spark Thrift Server for local development and CI testing:
```bash
# Start the local Spark Thrift Server in your Spark installation directory
$SPARK_HOME/sbin/start-thriftserver.sh --master "local[*]"

# Verify dbt connection
uv run dbt debug --profiles-dir .dbt
```

#### Running Against Databricks
```bash
export DATABRICKS_HOST="<workspace-id>.cloud.databricks.com"
export DATABRICKS_HTTP_PATH="/sql/1.0/endpoints/<endpoint-id>"
export DATABRICKS_TOKEN="<your-personal-access-token>"

uv run dbt run --target databricks-dev --profiles-dir .dbt
```

### 2. Common Commands

All commands can be run via `uv run dbt`, the [`Makefile`](file:///home/zzhu/homerepos/dbt-sample/Makefile), or the [`./dbt`](file:///home/zzhu/homerepos/dbt-sample/dbt) wrapper:

```bash
# Validate project and parse models/macros/tests
uv run dbt parse --profiles-dir .dbt

# Check connectivity to the database / Spark Thrift server
uv run dbt debug --profiles-dir .dbt

# Seed raw CSV test data into the warehouse
uv run dbt seed --profiles-dir .dbt

# Build all models, seeds, and snapshots
uv run dbt run --profiles-dir .dbt

# Execute all data tests and unit tests
uv run dbt test --profiles-dir .dbt

# Execute only unit tests
uv run dbt test --select "test_type:unit" --profiles-dir .dbt

# Clean build artifacts (target/, logs/)
uv run dbt clean
```

Or using `make`:

```bash
make sync       # uv sync
make build      # dbt build
make run        # dbt run
make test       # dbt test
make unit-test  # dbt unit tests
make debug      # dbt debug
```

---

## Model Contracts and Dynamic Schemas

### Model Contracts
Models enforce contracts in [`models/shared/claim.yml`](file:///home/zzhu/homerepos/dbt-sample/models/shared/claim.yml):
```yaml
models:
  - name: payer01__claim
    config:
      contract:
        enforced: true
    columns: *std_claim_line_columns
```
dbt validates column types at compile time before executing SQL DDL, guaranteeing that upstream changes cannot silently break downstream consumers.

### Dynamic Custom Schemas
In multi-tenant or shared data warehouses, multiple developers often run dbt against the same cluster. [`macros/generate_schema_name.sql`](file:///home/zzhu/homerepos/dbt-sample/macros/generate_schema_name.sql) automatically appends developer targets to custom schema names in development while keeping shared production schemas pristine:

- In `PRD`, `SBX`, `DEV`, `UAT`: outputs `payer01_silver`
- In developer local run with target schema `zzhu`: outputs `payer01_silver__zzhu`

Source declarations dynamically follow this rule without hardcoding developer names:
```yaml
sources:
  - name: payer01_ingested
    schema: "{{ 'payer01_ingested' if target.schema | upper in ['PRD', 'SBX', 'DEV', 'UAT', ''] else 'payer01_ingested__' ~ target.schema }}"
```

---

## License

This project is licensed under the [Apache License, Version 2.0](LICENSE).
