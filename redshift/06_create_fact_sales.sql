-- ============================================================
-- 06_create_fact_sales.sql
-- Create sales fact table
-- ============================================================

CREATE TABLE IF NOT EXISTS retail_dw.fact_sales
(
    sales_key            BIGINT IDENTITY(1,1),

    transaction_id       VARCHAR(100),

    transaction_date     DATE,
    date_key             INTEGER,

    product_key          BIGINT,
    store_key            BIGINT,

    customer_id          VARCHAR(100),

    quantity             INTEGER,
    unit_price           DECIMAL(12,2),

    revenue              DECIMAL(14,2),
    profit               DECIMAL(14,2),

    payment_method       VARCHAR(20),

    source_file          VARCHAR(255),
    ingestion_timestamp  TIMESTAMP
);


-- Verify structure

SELECT
    schemaname,
    tablename,
    "column",
    type
FROM pg_table_def
WHERE schemaname = 'retail_dw'
  AND tablename = 'fact_sales'
ORDER BY ordinal;