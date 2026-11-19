{{ config(materialized='table') }}

SELECT DISTINCT product
FROM {{ ref('clean_sales') }}