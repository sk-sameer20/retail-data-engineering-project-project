-- ============================================================
-- 05_load_dimensions.sql
-- Load dimension tables
-- ============================================================


-- ------------------------------------------------------------
-- Product Dimension
-- ------------------------------------------------------------

MERGE INTO retail_dw.dim_product AS target
USING
(
    SELECT DISTINCT
        product_id,
        product_name,
        category,
        brand,
        cost_price
    FROM retail_dw.product_stage
) AS source
ON target.product_id = source.product_id

WHEN MATCHED THEN
    UPDATE SET
        product_name = source.product_name,
        category     = source.category,
        brand        = source.brand,
        cost_price   = source.cost_price

WHEN NOT MATCHED THEN
    INSERT
    (
        product_id,
        product_name,
        category,
        brand,
        cost_price
    )
    VALUES
    (
        source.product_id,
        source.product_name,
        source.category,
        source.brand,
        source.cost_price
    );


-- ------------------------------------------------------------
-- Store Dimension
-- ------------------------------------------------------------

MERGE INTO retail_dw.dim_store AS target
USING
(
    SELECT DISTINCT
        store_id,
        store_name,
        city,
        state,
        region
    FROM retail_dw.store_stage
) AS source
ON target.store_id = source.store_id

WHEN MATCHED THEN
    UPDATE SET
        store_name = source.store_name,
        city       = source.city,
        state      = source.state,
        region     = source.region

WHEN NOT MATCHED THEN
    INSERT
    (
        store_id,
        store_name,
        city,
        state,
        region
    )
    VALUES
    (
        source.store_id,
        source.store_name,
        source.city,
        source.state,
        source.region
    );


-- ------------------------------------------------------------
-- Date Dimension
-- ------------------------------------------------------------

INSERT INTO retail_dw.dim_date
(
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    day_of_week,
    day_name
)
SELECT
    CAST(TO_CHAR(s.transaction_date, 'YYYYMMDD') AS INTEGER),
    s.transaction_date,
    EXTRACT(DAY FROM s.transaction_date)::INTEGER,
    EXTRACT(MONTH FROM s.transaction_date)::INTEGER,
    TRIM(TO_CHAR(s.transaction_date, 'Month')),
    EXTRACT(QUARTER FROM s.transaction_date)::INTEGER,
    EXTRACT(YEAR FROM s.transaction_date)::INTEGER,
    EXTRACT(DOW FROM s.transaction_date)::INTEGER,
    TRIM(TO_CHAR(s.transaction_date, 'Day'))
FROM
(
    SELECT DISTINCT transaction_date
    FROM retail_dw.sales_stage
) s
LEFT JOIN retail_dw.dim_date d
    ON d.full_date = s.transaction_date
WHERE d.full_date IS NULL;


-- ------------------------------------------------------------
-- Verify dimensions
-- ------------------------------------------------------------

SELECT COUNT(*) AS products
FROM retail_dw.dim_product;

SELECT COUNT(*) AS stores
FROM retail_dw.dim_store;

SELECT COUNT(*) AS dates
FROM retail_dw.dim_date;