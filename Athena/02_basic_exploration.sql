-- ============================================================
-- 02_basic_exploration.sql
-- Basic exploration of curated sales data
-- ============================================================

-- Total rows
SELECT COUNT(*) AS total_rows
FROM retail_curated_db.curated_sales;


-- Date range
SELECT
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date
FROM retail_curated_db.curated_sales;


-- Distinct transactions
SELECT COUNT(DISTINCT transaction_id) AS transactions
FROM retail_curated_db.curated_sales;


-- Distinct products
SELECT COUNT(DISTINCT product_id) AS products
FROM retail_curated_db.curated_sales;


-- Distinct stores
SELECT COUNT(DISTINCT store_id) AS stores
FROM retail_curated_db.curated_sales;


-- Payment methods
SELECT DISTINCT payment_method
FROM retail_curated_db.curated_sales
ORDER BY payment_method;