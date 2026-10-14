-- ============================================================
-- 10_verify_incremental_load.sql
-- Verify the final Redshift warehouse
-- ============================================================


-- ------------------------------------------------------------
-- 1. Warehouse row count
-- ------------------------------------------------------------

SELECT COUNT(*) AS total_fact_rows
FROM retail_dw.fact_sales;


-- ------------------------------------------------------------
-- 2. Daily counts
-- ------------------------------------------------------------

SELECT
    transaction_date,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit
FROM retail_dw.fact_sales
GROUP BY transaction_date
ORDER BY transaction_date;


-- ------------------------------------------------------------
-- 3. Loaded files
-- ------------------------------------------------------------

SELECT
    source_file,
    batch_date,
    row_count,
    load_status,
    loaded_at
FROM retail_dw.etl_file_control
ORDER BY loaded_at DESC;


-- ------------------------------------------------------------
-- 4. Check for duplicate transaction IDs
-- ------------------------------------------------------------

SELECT
    transaction_id,
    COUNT(*) AS cnt
FROM retail_dw.fact_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- 5. Product analytics
-- ------------------------------------------------------------

SELECT *
FROM retail_dw.v_product_performance
ORDER BY revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 6. State analytics
-- ------------------------------------------------------------

SELECT *
FROM retail_dw.v_store_performance
ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- 7. Daily analytics
-- ------------------------------------------------------------

SELECT *
FROM retail_dw.v_daily_sales
ORDER BY full_date;


-- ------------------------------------------------------------
-- 8. Category analytics
-- ------------------------------------------------------------

SELECT *
FROM retail_dw.v_category_performance
ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- 9. Payment analytics
-- ------------------------------------------------------------

SELECT *
FROM retail_dw.v_payment_method_performance
ORDER BY revenue DESC;