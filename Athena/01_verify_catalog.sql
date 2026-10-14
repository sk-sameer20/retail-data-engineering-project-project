-- ============================================================
-- 01_verify_catalog.sql
-- Verify Glue Catalog database and curated table
-- ============================================================

SHOW DATABASES;

SHOW TABLES IN retail_curated_db;

DESCRIBE retail_curated_db.curated_sales;