{{ config(materialized='table') }}

SELECT
    order_id,
    order_date,
    store,
    product,
    quantity,
    unit_price,
    quantity * unit_price AS sales_amount
FROM {{ ref('clean_sales') }}