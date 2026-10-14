-- ============================================================
-- 03_load_staging_data.sql
-- Load S3 data into Redshift staging tables
-- ============================================================

-- ------------------------------------------------------------
-- Configuration
-- ------------------------------------------------------------

-- Current daily sales partition:
-- transaction_date=2026-09-25/

-- Redshift IAM role:
-- YOUR_REDSHIFT_IAM_ROLE_ARN


-- ------------------------------------------------------------
-- Clear current staging batch
-- ------------------------------------------------------------

TRUNCATE TABLE retail_dw.sales_stage_raw;

TRUNCATE TABLE retail_dw.sales_stage;

TRUNCATE TABLE retail_dw.product_stage;

TRUNCATE TABLE retail_dw.store_stage;


-- ------------------------------------------------------------
-- Load Products
-- ------------------------------------------------------------

COPY retail_dw.product_stage
FROM 's3://sameer-retail-sales-pipeline/raw/products/products.csv'
IAM_ROLE 'YOUR_REDSHIFT_IAM_ROLE_ARN'
FORMAT AS CSV
IGNOREHEADER 1;


-- ------------------------------------------------------------
-- Load Stores
-- ------------------------------------------------------------

COPY retail_dw.store_stage
FROM 's3://sameer-retail-sales-pipeline/raw/stores/stores.csv'
IAM_ROLE 'YOUR_REDSHIFT_IAM_ROLE_ARN'
FORMAT AS CSV
IGNOREHEADER 1;


-- ------------------------------------------------------------
-- Load one daily curated Parquet partition
-- ------------------------------------------------------------

COPY retail_dw.sales_stage_raw
FROM 's3://sameer-retail-sales-pipeline/curated/sales/transaction_date=2026-09-25/'
IAM_ROLE 'YOUR_REDSHIFT_IAM_ROLE_ARN'
FORMAT AS PARQUET;


-- ------------------------------------------------------------
-- Add the partition date to sales_stage
-- ------------------------------------------------------------

INSERT INTO retail_dw.sales_stage
(
    transaction_id,
    transaction_date,
    store_id,
    product_id,
    customer_id,
    quantity,
    unit_price,
    payment_method,
    revenue,
    profit,
    source_file,
    ingestion_timestamp,
    data_quality_status
)
SELECT
    transaction_id,
    CAST('2026-09-25' AS DATE),
    store_id,
    product_id,
    customer_id,
    quantity,
    unit_price,
    payment_method,
    revenue,
    profit,
    source_file,
    ingestion_timestamp,
    data_quality_status
FROM retail_dw.sales_stage_raw;


-- ------------------------------------------------------------
-- Verify load
-- ------------------------------------------------------------

SELECT COUNT(*) AS sales_stage_raw_count
FROM retail_dw.sales_stage_raw;

SELECT COUNT(*) AS sales_stage_count
FROM retail_dw.sales_stage;

SELECT COUNT(*) AS product_stage_count
FROM retail_dw.product_stage;

SELECT COUNT(*) AS store_stage_count
FROM retail_dw.store_stage;