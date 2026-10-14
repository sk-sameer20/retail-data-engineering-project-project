-- ============================================================
-- 11_analytics_views.sql
-- Athena analytics views
-- ============================================================


-- ------------------------------------------------------------
-- Daily Sales View
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_curated_db.v_daily_sales AS

SELECT
    transaction_date,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY transaction_date;


-- ------------------------------------------------------------
-- Product Performance View
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_curated_db.v_product_performance AS

SELECT
    product_id,
    product_name,
    category,
    brand,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY
    product_id,
    product_name,
    category,
    brand;


-- ------------------------------------------------------------
-- State Performance View
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_curated_db.v_state_performance AS

SELECT
    state,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY state;


-- ------------------------------------------------------------
-- Payment Method View
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_curated_db.v_payment_methods AS

SELECT
    payment_method,

    COUNT(DISTINCT transaction_id) AS transactions,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY payment_method;


-- ------------------------------------------------------------
-- Category Performance View
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_curated_db.v_category_performance AS

SELECT
    category,

    SUM(quantity) AS units_sold,

    SUM(revenue) AS revenue,

    SUM(profit) AS profit

FROM retail_curated_db.curated_sales

WHERE data_quality_status = 'VALID'

GROUP BY category;