-- ============================================================
-- 05_product_performance.sql
-- Product performance analysis
-- ============================================================


-- Product sales
SELECT
    product_id,
    product_name,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY
    product_id,
    product_name

ORDER BY revenue DESC;


-- Top 10 products by revenue
SELECT
    product_id,
    product_name,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY
    product_id,
    product_name

ORDER BY revenue DESC

LIMIT 10;


-- Product profitability
SELECT
    product_id,
    product_name,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit,

    ROUND(
        100.0 * SUM(profit)
        / NULLIF(SUM(revenue), 0),
        2
    ) AS profit_margin_percent

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY
    product_id,
    product_name

ORDER BY profit DESC;