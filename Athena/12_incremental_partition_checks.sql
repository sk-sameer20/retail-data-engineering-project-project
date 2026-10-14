-- ============================================================
-- 12_incremental_partition_checks.sql
-- Incremental partition verification
-- ============================================================


-- ------------------------------------------------------------
-- Available transaction dates
-- ------------------------------------------------------------

SELECT DISTINCT
    transaction_date
FROM retail_curated_db.curated_sales
ORDER BY transaction_date;


-- ------------------------------------------------------------
-- Row count by partition
-- ------------------------------------------------------------

SELECT
    transaction_date,

    COUNT(*) AS rows_loaded,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY transaction_date

ORDER BY transaction_date;


-- ------------------------------------------------------------
-- Latest loaded partition
-- ------------------------------------------------------------

SELECT
    MAX(transaction_date) AS latest_transaction_date
FROM retail_curated_db.curated_sales;


-- ------------------------------------------------------------
-- Latest day's summary
-- ------------------------------------------------------------

SELECT

    transaction_date,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE transaction_date =
(
    SELECT MAX(transaction_date)
    FROM retail_curated_db.curated_sales
)

AND data_quality_status = 'VALID'

GROUP BY transaction_date;