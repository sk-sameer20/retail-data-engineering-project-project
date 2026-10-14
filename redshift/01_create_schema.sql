-- ============================================================
-- 01_create_schema.sql
-- Create the Redshift warehouse schema
-- ============================================================

CREATE SCHEMA IF NOT EXISTS retail_dw;

-- Verify
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'retail_dw';