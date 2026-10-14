-- ============================================================
-- 07_merge_incremental_sales.sql
-- Incremental sales load
-- ============================================================


-- ------------------------------------------------------------
-- File control table
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.etl_file_control
(
    source_file   VARCHAR(255),
    batch_date    DATE,
    row_count     INTEGER,
    load_status   VARCHAR(20),
    loaded_at     TIMESTAMP
);


-- ------------------------------------------------------------
-- Prepare unique source rows
-- ------------------------------------------------------------

DROP TABLE IF EXISTS retail_dw.fact_sales_source;

CREATE TEMP TABLE fact_sales_source AS
SELECT
    s.transaction_id,
    s.transaction_date,
    d.date_key,
    p.product_key,
    st.store_key,
    s.customer_id,
    s.quantity,
    s.unit_price,
    s.revenue,
    s.profit,
    s.payment_method,
    s.source_file,
    s.ingestion_timestamp
FROM
(
    SELECT
        s.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY transaction_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn
    FROM retail_dw.sales_stage s
    WHERE s.data_quality_status = 'VALID'
) s

JOIN retail_dw.dim_product p
    ON s.product_id = p.product_id

JOIN retail_dw.dim_store st
    ON s.store_id = st.store_id

JOIN retail_dw.dim_date d
    ON s.transaction_date = d.full_date

WHERE s.rn = 1;


-- ------------------------------------------------------------
-- MERGE into fact table
-- ------------------------------------------------------------

MERGE INTO retail_dw.fact_sales AS target
USING retail_dw.fact_sales_source AS source

ON target.transaction_id = source.transaction_id

WHEN MATCHED THEN
    UPDATE SET
        transaction_date    = source.transaction_date,
        date_key            = source.date_key,
        product_key         = source.product_key,
        store_key           = source.store_key,
        customer_id         = source.customer_id,
        quantity             = source.quantity,
        unit_price           = source.unit_price,
        revenue              = source.revenue,
        profit               = source.profit,
        payment_method       = source.payment_method,
        source_file          = source.source_file,
        ingestion_timestamp  = source.ingestion_timestamp

WHEN NOT MATCHED THEN
    INSERT
    (
        transaction_id,
        transaction_date,
        date_key,
        product_key,
        store_key,
        customer_id,
        quantity,
        unit_price,
        revenue,
        profit,
        payment_method,
        source_file,
        ingestion_timestamp
    )
    VALUES
    (
        source.transaction_id,
        source.transaction_date,
        source.date_key,
        source.product_key,
        source.store_key,
        source.customer_id,
        source.quantity,
        source.unit_price,
        source.revenue,
        source.profit,
        source.payment_method,
        source.source_file,
        source.ingestion_timestamp
    );


-- ------------------------------------------------------------
-- Record successful file load
-- ------------------------------------------------------------

MERGE INTO retail_dw.etl_file_control AS target

USING
(
    SELECT
        MAX(source_file) AS source_file,
        MAX(transaction_date) AS batch_date,
        COUNT(*) AS row_count
    FROM retail_dw.sales_stage
) AS source

ON target.source_file = source.source_file

WHEN MATCHED THEN
    UPDATE SET
        batch_date  = source.batch_date,
        row_count   = source.row_count,
        load_status = 'SUCCESS',
        loaded_at   = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT
    (
        source_file,
        batch_date,
        row_count,
        load_status,
        loaded_at
    )
    VALUES
    (
        source.source_file,
        source.batch_date,
        source.row_count,
        'SUCCESS',
        CURRENT_TIMESTAMP
    );


-- ------------------------------------------------------------
-- Verify fact load
-- ------------------------------------------------------------

SELECT COUNT(*) AS fact_sales_count
FROM retail_dw.fact_sales;