-- ============================================================
-- 06_store_state_performance.sql
-- Store and state performance
-- ============================================================


-- ------------------------------------------------------------
-- Store performance
-- ------------------------------------------------------------

SELECT
    store_id,
    store_name,
    city,
    state,
    region,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY
    store_id,
    store_name,
    city,
    state,
    region

ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- State performance
-- ------------------------------------------------------------

SELECT
    state,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY state

ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- Region performance
-- ------------------------------------------------------------

SELECT
    region,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY region

ORDER BY revenue DESC;