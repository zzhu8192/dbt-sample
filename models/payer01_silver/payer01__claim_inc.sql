{{ config(materialized='incremental', alias = 'claim_inc') }}

with source as (
    select *
    from {{ source('payer01_ingested', 'payer01_claim') }}
)

select
    claim_id,
    patient_id,
    service_date,
    claim_amount,
    diagnosis_code
from source
{% if is_incremental() %}
  where claim_id > (select max(claim_id) from {{ this }})
{% endif %}