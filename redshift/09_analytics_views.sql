-- ============================================================
-- 09_analytics_views.sql
-- Analytics views for BI
-- ============================================================


-- ------------------------------------------------------------
-- Daily Sales
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_dw.v_daily_sales AS

SELECT
    d.full_date,
    d.year,
    d.month,
    d.month_name,
    d.quarter,

    COUNT(DISTINCT f.transaction_id) AS transactions,

    SUM(f.quantity) AS units_sold,

    SUM(f.revenue) AS revenue,

    SUM(f.profit) AS profit

FROM retail_dw.fact_sales f

JOIN retail_dw.dim_date d
    ON f.date_key = d.date_key

GROUP BY
    d.full_date,
    d.year,
    d.month,
    d.month_name,
    d.quarter;


-- ------------------------------------------------------------
-- Product Performance
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_dw.v_product_performance AS

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,

    SUM(f.quantity) AS units_sold,

    SUM(f.revenue) AS revenue,

    SUM(f.profit) AS profit

FROM retail_dw.fact_sales f

JOIN retail_dw.dim_product p
    ON f.product_key = p.product_key

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.brand;


-- ------------------------------------------------------------
-- Store / State Performance
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_dw.v_store_performance AS

SELECT
    s.state,
    s.region,
    s.store_id,
    s.store_name,

    SUM(f.quantity) AS units_sold,

    SUM(f.revenue) AS revenue,

    SUM(f.profit) AS profit

FROM retail_dw.fact_sales f

JOIN retail_dw.dim_store s
    ON f.store_key = s.store_key

GROUP BY
    s.state,
    s.region,
    s.store_id,
    s.store_name;


-- ------------------------------------------------------------
-- Category Performance
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_dw.v_category_performance AS

SELECT
    p.category,

    SUM(f.quantity) AS units_sold,

    SUM(f.revenue) AS revenue,

    SUM(f.profit) AS profit

FROM retail_dw.fact_sales f

JOIN retail_dw.dim_product p
    ON f.product_key = p.product_key

GROUP BY
    p.category;


-- ------------------------------------------------------------
-- Payment Method Performance
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW retail_dw.v_payment_method_performance AS

SELECT
    f.payment_method,

    COUNT(DISTINCT f.transaction_id) AS transactions,

    SUM(f.revenue) AS revenue,

    SUM(f.profit) AS profit

FROM retail_dw.fact_sales f

GROUP BY
    f.payment_method;