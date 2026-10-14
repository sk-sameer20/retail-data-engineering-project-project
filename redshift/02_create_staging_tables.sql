-- ============================================================
-- 02_create_staging_tables.sql
-- Create staging tables
-- ============================================================

-- ------------------------------------------------------------
-- Sales raw staging
--
-- Your Glue output is partitioned by transaction_date.
-- The daily partition supplies the date during the load.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.sales_stage_raw
(
    transaction_id      VARCHAR(100),
    store_id            VARCHAR(50),
    product_id          VARCHAR(50),
    customer_id         VARCHAR(100),
    quantity            INTEGER,
    unit_price          DECIMAL(12,2),
    payment_method      VARCHAR(20),
    revenue             DECIMAL(14,2),
    profit              DECIMAL(14,2),
    source_file         VARCHAR(255),
    ingestion_timestamp TIMESTAMP,
    data_quality_status VARCHAR(20)
);

-- ------------------------------------------------------------
-- Sales staging with transaction date
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.sales_stage
(
    transaction_id      VARCHAR(100),
    transaction_date    DATE,
    store_id            VARCHAR(50),
    product_id          VARCHAR(50),
    customer_id         VARCHAR(100),
    quantity            INTEGER,
    unit_price          DECIMAL(12,2),
    payment_method      VARCHAR(20),
    revenue             DECIMAL(14,2),
    profit              DECIMAL(14,2),
    source_file         VARCHAR(255),
    ingestion_timestamp TIMESTAMP,
    data_quality_status VARCHAR(20)
);

-- ------------------------------------------------------------
-- Product staging
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.product_stage
(
    product_id   VARCHAR(50),
    product_name VARCHAR(200),
    category     VARCHAR(100),
    brand        VARCHAR(100),
    cost_price   DECIMAL(12,2)
);

-- ------------------------------------------------------------
-- Store staging
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.store_stage
(
    store_id   VARCHAR(50),
    store_name VARCHAR(200),
    city       VARCHAR(100),
    state      VARCHAR(100),
    region     VARCHAR(100)
);

-- Verify tables
SELECT schemaname, tablename
FROM pg_table_def
WHERE schemaname = 'retail_dw'
ORDER BY tablename;