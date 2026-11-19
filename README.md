# Smoothie Sales Analytics Pipeline

An analytics pipeline built with Snowflake, dbt, and SQL to transform smoothie sales data into reporting tables.

## Pipeline

Raw sales data is loaded into Snowflake, then transformed through dbt models:

`RAW_SALES → STG_SALES → INT_SALES_CLASSIFIED → CLEAN_SALES / REJECTS → FACT_SALES and dimensions`

The models standardize and classify sales records, separate rejected rows, and create reporting tables for sales, dates, products, and stores.

## Results

- 3,640 raw rows
- 3,500 rows after deduplication
- 3,131 clean sales rows
- 369 rejected rows
- Total sales: 371,874.00

## Models

- `stg_sales`: selects raw sales fields
- `int_sales_classified`: deduplicates and classifies records
- `clean_sales` and `rejects`: separates valid and rejected records
- `fact_sales`: sales facts and calculated sales amount
- `dim_date`, `dim_product`, `dim_store`: reporting dimensions

## Run locally

Configure a Snowflake connection in your local dbt profile at `~/.dbt/profiles.yml`. Keep credentials out of this repository.

From the repository folder:

```shell
cd smoothie_analytics
dbt debug
dbt run
```

Raw CSV files are excluded from this public repository.
