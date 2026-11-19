{{ config(materialized='view') }}

SELECT
    order_id,
    order_date,
    store,
    customer_name,
    customer_email,
    product,
    quantity,
    unit_price,
    source_file,
    loaded_at
FROM {{ source('raw', 'raw_sales') }}