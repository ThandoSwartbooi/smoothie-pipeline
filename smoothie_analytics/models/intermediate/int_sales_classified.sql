{{ config(materialized='table') }}

WITH deduped AS (
    SELECT *
    FROM {{ ref('stg_sales') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY loaded_at
    ) = 1
),

fixed AS (
    SELECT
        order_id,

        CASE
            WHEN order_date RLIKE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                THEN TRY_TO_DATE(order_date, 'YYYY-MM-DD')
            WHEN order_date LIKE '%/%'
                THEN TRY_TO_DATE(order_date, 'DD/MM/YYYY')
            WHEN order_date RLIKE '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                THEN TRY_TO_DATE(order_date, 'MM-DD-YYYY')
            ELSE TRY_TO_DATE(order_date, 'DD MON YYYY')
        END AS order_date,

        store,
        customer_name,
        customer_email,

        CASE LOWER(REGEXP_REPLACE(TRIM(product), ' +', ' '))
            WHEN 'berry blast'      THEN 'Berry Blast'
            WHEN 'bery blast'       THEN 'Berry Blast'
            WHEN 'mango tango'      THEN 'Mango Tango'
            WHEN 'mango tanggo'     THEN 'Mango Tango'
            WHEN 'green machine'    THEN 'Green Machine'
            WHEN 'gren machine'     THEN 'Green Machine'
            WHEN 'green machin'     THEN 'Green Machine'
            WHEN 'banana bliss'     THEN 'Banana Bliss'
            WHEN 'banna bliss'      THEN 'Banana Bliss'
            WHEN 'banana blis'      THEN 'Banana Bliss'
            WHEN 'tropical sunrise' THEN 'Tropical Sunrise'
            WHEN 'tropical sunrize' THEN 'Tropical Sunrise'
            WHEN 'tropicl sunrise'  THEN 'Tropical Sunrise'
        END AS product,

        TRY_TO_NUMBER(quantity, 10, 0) AS quantity,
        TRY_TO_DECIMAL(unit_price, 10, 2) AS unit_price,
        source_file
    FROM deduped
)

SELECT
    *,
    CASE
        WHEN order_date IS NULL THEN 'bad date'
        WHEN product IS NULL THEN 'unknown product'
        WHEN unit_price IS NULL THEN 'missing price'
        WHEN quantity IS NULL THEN 'missing quantity'
        WHEN quantity <= 0 THEN 'negative quantity'
    END AS reject_reason
FROM fixed