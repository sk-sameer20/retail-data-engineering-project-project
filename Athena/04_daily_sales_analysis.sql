-- ============================================================
-- 04_daily_sales_analysis.sql
-- Daily sales analysis
-- ============================================================

SELECT
    transaction_date,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS total_revenue,

    SUM(profit) AS total_profit,

    ROUND(
        SUM(revenue) / NULLIF(COUNT(DISTINCT transaction_id), 0),
        2
    ) AS average_transaction_value

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY transaction_date

ORDER BY transaction_date;