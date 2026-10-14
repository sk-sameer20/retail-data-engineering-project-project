-- ============================================================
-- 08_data_quality_checks.sql
-- Data quality validation
-- ============================================================


-- ------------------------------------------------------------
-- 1. NULL transaction IDs
-- ------------------------------------------------------------

SELECT COUNT(*) AS null_transaction_ids
FROM retail_dw.fact_sales
WHERE transaction_id IS NULL;


-- ------------------------------------------------------------
-- 2. Invalid quantities
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_quantities
FROM retail_dw.fact_sales
WHERE quantity <= 0;


-- ------------------------------------------------------------
-- 3. Invalid revenue
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_revenue
FROM retail_dw.fact_sales
WHERE revenue <= 0;


-- ------------------------------------------------------------
-- 4. Duplicate transactions
-- ------------------------------------------------------------

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM retail_dw.fact_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 5. Missing product dimension
-- ------------------------------------------------------------

SELECT COUNT(*) AS missing_products
FROM retail_dw.fact_sales f
LEFT JOIN retail_dw.dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- ------------------------------------------------------------
-- 6. Missing store dimension
-- ------------------------------------------------------------

SELECT COUNT(*) AS missing_stores
FROM retail_dw.fact_sales f
LEFT JOIN retail_dw.dim_store s
    ON f.store_key = s.store_key
WHERE s.store_key IS NULL;


-- ------------------------------------------------------------
-- 7. Missing date dimension
-- ------------------------------------------------------------

SELECT COUNT(*) AS missing_dates
FROM retail_dw.fact_sales f
LEFT JOIN retail_dw.dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;


-- ------------------------------------------------------------
-- 8. Invalid payment methods
-- ------------------------------------------------------------

SELECT
    payment_method,
    COUNT(*) AS transaction_count
FROM retail_dw.fact_sales
GROUP BY payment_method
ORDER BY transaction_count DESC;


-- ------------------------------------------------------------
-- 9. Daily record totals
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