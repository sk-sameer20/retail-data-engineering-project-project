-- ============================================================
-- 10_revenue_profit_analysis.sql
-- Revenue and profitability analytics
-- ============================================================


-- Overall KPIs
SELECT

    COUNT(DISTINCT transaction_id) AS total_transactions,

    SUM(quantity) AS total_units_sold,

    SUM(revenue) AS total_revenue,

    SUM(profit) AS total_profit,

    ROUND(
        100.0 * SUM(profit)
        / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_percent

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID';


-- Revenue and profit by month
SELECT

    DATE_TRUNC('month', transaction_date) AS month,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY DATE_TRUNC('month', transaction_date)

ORDER BY month;


-- Highest revenue day
SELECT
    transaction_date,
    SUM(revenue) AS revenue
FROM retail_curated_db.curated_sales
WHERE data_quality_status = 'VALID'
GROUP BY transaction_date
ORDER BY revenue DESC
LIMIT 1;