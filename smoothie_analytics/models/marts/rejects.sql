{{ config(materialized='table') }}

SELECT *
FROM {{ ref('int_sales_classified') }}
WHERE reject_reason IS NOT NULL