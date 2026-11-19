{{ config(materialized='table') }}

SELECT
    order_id,
    order_date,
    store,
    customer_name,
    customer_email,
    product,
    quantity,
    unit_price,
    source_file
FROM {{ ref('int_sales_classified') }}
WHERE reject_reason IS NULL