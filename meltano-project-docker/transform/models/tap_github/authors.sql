{{
  config(
    materialized='table'
  )
}}

with base as (
    select *
    from {{ source('tap_github', 'commits') }}
)
select distinct (commit -> 'author' -> 'name') as authors
from base
