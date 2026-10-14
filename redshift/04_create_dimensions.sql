-- ============================================================
-- 04_create_dimensions.sql
-- Create dimension tables
-- ============================================================

-- ------------------------------------------------------------
-- Product Dimension
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.dim_product
(
    product_key  BIGINT IDENTITY(1,1),
    product_id   VARCHAR(50),
    product_name VARCHAR(200),
    category     VARCHAR(100),
    brand        VARCHAR(100),
    cost_price   DECIMAL(12,2)
);


-- ------------------------------------------------------------
-- Store Dimension
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.dim_store
(
    store_key  BIGINT IDENTITY(1,1),
    store_id   VARCHAR(50),
    store_name VARCHAR(200),
    city       VARCHAR(100),
    state      VARCHAR(100),
    region     VARCHAR(100)
);


-- ------------------------------------------------------------
-- Date Dimension
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS retail_dw.dim_date
(
    date_key     INTEGER,
    full_date    DATE,
    day          INTEGER,
    month        INTEGER,
    month_name   VARCHAR(20),
    quarter      INTEGER,
    year         INTEGER,
    day_of_week  INTEGER,
    day_name     VARCHAR(20)
);


-- Verify
SELECT tablename
FROM pg_table_def
WHERE schemaname = 'retail_dw'
  AND tablename IN
  (
      'dim_product',
      'dim_store',
      'dim_date'
  )
GROUP BY tablename
ORDER BY tablename;