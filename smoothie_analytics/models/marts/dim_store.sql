{{ config(materialized='table') }}

SELECT DISTINCT store
FROM {{ ref('clean_sales') }}