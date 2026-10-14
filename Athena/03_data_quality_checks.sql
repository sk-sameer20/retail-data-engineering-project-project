-- ============================================================
-- 03_data_quality_checks.sql
-- Data quality checks
-- ============================================================


-- ------------------------------------------------------------
-- 1. NULL transaction IDs
-- ------------------------------------------------------------

SELECT COUNT(*) AS null_transaction_ids
FROM retail_curated_db.curated_sales
WHERE transaction_id IS NULL;


-- ------------------------------------------------------------
-- 2. Duplicate transactions
-- ------------------------------------------------------------

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM retail_curated_db.curated_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3. Invalid quantity
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_quantity_rows
FROM retail_curated_db.curated_sales
WHERE quantity <= 0;


-- ------------------------------------------------------------
-- 4. Invalid unit price
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_price_rows
FROM retail_curated_db.curated_sales
WHERE unit_price <= 0;


-- ------------------------------------------------------------
-- 5. Invalid revenue
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_revenue_rows
FROM retail_curated_db.curated_sales
WHERE revenue <= 0;


-- ------------------------------------------------------------
-- 6. Invalid payment methods
-- ------------------------------------------------------------

SELECT
    payment_method,
    COUNT(*) AS row_count
FROM retail_curated_db.curated_sales
GROUP BY payment_method
ORDER BY row_count DESC;


-- ------------------------------------------------------------
-- 7. Data quality status
-- ------------------------------------------------------------

SELECT
    data_quality_status,
    COUNT(*) AS row_count
FROM retail_curated_db.curated_sales
GROUP BY data_quality_status
ORDER BY row_count DESC;