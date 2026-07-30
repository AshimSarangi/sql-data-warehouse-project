/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables
    - Referential integrity between fact and dimension tables
    - Validation of relationships in the data model for analytical purposes

Usage Notes:
    Run these checks after creating/refreshing the gold layer views.
    Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ============================================================================
-- Checking gold.dim_customers
-- ============================================================================
-- Check for Uniqueness of Customer Key
-- Expectation: No Results (each customer_key should map to exactly one row)
SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check for Nulls in Customer Key
-- Expectation: No Results
SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- Data Standardization & Consistency
-- Expectation: 'Male', 'Female', 'n/a' only
SELECT DISTINCT gender
FROM gold.dim_customers;


-- ============================================================================
-- Checking gold.dim_products
-- ============================================================================
-- Check for Uniqueness of Product Key
-- Expectation: No Results (each product_key should map to exactly one row)
SELECT 
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check for Nulls in Product Key
-- Expectation: No Results
SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- Check for Duplicate Product Numbers (e.g. historization filter not applied correctly)
-- Expectation: No Results
SELECT
	product_number,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


-- ============================================================================
-- Checking gold.fact_sales - Referential Integrity
-- ============================================================================
-- Check that every sale links to a valid product and customer
-- Expectation: No Results
SELECT 
	f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL 
   OR p.product_key IS NULL;

-- Check for Nulls in Fact Table Foreign Keys
-- Expectation: No Results
SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL 
   OR customer_key IS NULL;


-- ============================================================================
-- Checking gold.fact_sales - Data Consistency
-- ============================================================================
-- Check for Invalid Dates (Order Date after Shipping/Due Date)
-- Expectation: No Results
SELECT *
FROM gold.fact_sales
WHERE order_date > shipping_date 
   OR order_date > due_date;

-- Check for Negative or Null Measures
-- Expectation: No Results
SELECT *
FROM gold.fact_sales
WHERE sales_amount IS NULL OR sales_amount < 0
   OR quantity IS NULL OR quantity < 0
   OR price IS NULL OR price < 0;

-- Check Sales Consistency (Sales = Quantity * Price)
-- Expectation: No Results
SELECT *
FROM gold.fact_sales
WHERE sales_amount != quantity * price;
