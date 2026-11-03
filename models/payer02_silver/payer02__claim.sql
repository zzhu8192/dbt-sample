{{ config(materialized='table', alias = 'claim') }}

with source as (
    select *
    from {{ source('payer02_ingested', 'payer02_claim') }}
)

select
    claim_id,
    patient_id,
    service_date,
    claim_amount,
    diagnosis_code
from source
