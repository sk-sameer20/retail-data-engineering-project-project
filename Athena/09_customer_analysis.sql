-- ============================================================
-- 09_customer_analysis.sql
-- Customer-level analysis
-- ============================================================


-- Customer spending
SELECT
    customer_id,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_bought,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY customer_id

ORDER BY revenue DESC;


-- Top 10 customers
SELECT
    customer_id,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY customer_id

ORDER BY revenue DESC

LIMIT 10;