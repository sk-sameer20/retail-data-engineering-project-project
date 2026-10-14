-- ============================================================
-- 07_payment_method_analysis.sql
-- Payment method analytics
-- ============================================================


SELECT
    payment_method,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY payment_method

ORDER BY revenue DESC;


-- Category profitability:

SELECT
    category,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit,

    ROUND(
        100.0 * SUM(profit)
        / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_percent

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY category

ORDER BY profit DESC;