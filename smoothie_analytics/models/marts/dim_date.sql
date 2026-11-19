{{ config(materialized='table') }}

SELECT DISTINCT
    order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DAY(order_date) AS day,
    DAYNAME(order_date) AS day_name
FROM {{ ref('clean_sales') }}