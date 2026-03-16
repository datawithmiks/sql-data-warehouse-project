/*
==============================================================================
Quality Checks
==============================================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy,
	and standardization across the 'silver' schemas. It includes checks for:
	- Null or duplicates primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid data ranges and orders.
	- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading the Silver Layer.
	- Investigate and resolve any discrepancies	found during the checks.
==============================================================================
*/

-- =================================================================
-- Checking 'silver.crm_cust_info'
-- =================================================================

-- Checks for NULLS or Duplicates in Primary Key IN  silver.crm_cust_info
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Expectation: No Result 
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted Spaces
SELECT cst_firstname, cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) AND
		cst_lastname != TRIM(cst_lastname)
-- Expectation: No Result 
SELECT cst_firstname, cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) AND
		cst_lastname != TRIM(cst_lastname)

-- Standardization & Consistency
-- Check the uniqe values to cst_marital status
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;
-- Expectation: No 'S' = 'Single' AND 'M' = 'Married' 
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;	

-- Check the uniqe values to cst_marital status
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
-- Expectation: No 'F' = 'Female' AND 'M' = 'Male' 
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;	

-- =================================================================
-- Checking 'silver.crm_prd_info'
-- =================================================================

-- Checks for Null and Duplicates in PK
SELECT prd_id, 
		COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR
		prd_id IS NULL;
-- Expectation: No result
SELECT prd_id, 
		COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR
		prd_id IS NULL;

-- Check for Unwanted Spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Expectation: No results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLS or Negative numbers
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR
		prd_cost IS NULL;
-- Expectation: No results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR
		prd_cost IS NULL;

-- Check distinct values Data Normalization
SELECT DISTINCT prd_line 
FROM bronze.crm_prd_info;
-- Expectation: With meaningful name not only abbreviation
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Check for invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
-- Expectation: No results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check the cat_id from bronze.crm_prd_info
SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;
-- Check the cat_id from silver.crm_prd_info. Results matched.
SELECT DISTINCT cat_id
FROM silver.crm_prd_info;

-- Check the product key of bronze.crm_sales_details
SELECT sls_prd_key
FROM bronze.crm_sales_details;
-- Check the product key of silver.crm_prd_info. Results matched
SELECT prd_key
FROM silver.crm_prd_info;

-- =================================================================
-- Checking 'silver.crm_sales_details'
-- =================================================================

-- Check the Unwanted spaces sales order number
-- Expectation: No results
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
-- Expectation: No results in silver
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check the key in order to connect to other tables
-- Expectation: No results
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN ( SELECT sls_prd_key FROM silver.crm_prd_info);
-- Expectation: No results in silver
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN ( SELECT sls_prd_key FROM silver.crm_prd_info);

-- Check the id in order to connect to other tables
-- Expectation: No results
SELECT	*
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN ( SELECT cst_id FROM silver.crm_cust_info);					
-- Expectation: No results in silver
SELECT	*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN ( SELECT cst_id FROM silver.crm_cust_info);	

-- Check if the order date IS NULL/0 OR is not valid date
SELECT DISTINCT sls_order_dt
FROM bronze.crm_sales_details
WHERE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) IS NULL AND
		sls_order_dt IS NOT NULL;
-- Expectation: Valid date
SELECT DISTINCT sls_order_dt
FROM silver.crm_sales_details
WHERE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) IS NULL AND
		sls_order_dt IS NOT NULL;

-- Handle bad values where 0 become NULL & not valid date = NULL
SELECT sls_order_dt,
		CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
			 ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112)
		END AS sls_order_dt_test
FROM bronze.crm_sales_details
WHERE sls_order_dt IN (
					SELECT DISTINCT sls_order_dt
					FROM bronze.crm_sales_details
					WHERE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) IS NULL AND
							sls_order_dt IS NOT NULL);

-- Check if the sales order first than sales ship
-- Expectation: No results in silver
SELECT sls_order_dt,
		sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt;

-- Check if the ship date IS NULL/0 OR is not valid date
-- Expectation: Valid date
SELECT DISTINCT sls_ship_dt
FROM silver.crm_sales_details
WHERE TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112) IS NULL AND
		sls_ship_dt IS NOT NULL;

-- Check if the sales order first than sales ship
-- Expectation: No results in silver
SELECT sls_ship_dt,
		sls_due_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quantity, and Pricec
-- Values must not be Null, Zero, or, Negative
-- Expectation: No results in silver
SELECT DISTINCT sls_sales,
		sls_quantity,
		sls_price
FROM silver.crm_sales_details
WHERE	(sls_sales != sls_quantity * sls_price) OR
		(sls_sales <= 0 OR sls_sales IS NULL) OR 
		(sls_quantity <= 0 OR sls_quantity IS NULL) OR
		(sls_price <= 0 OR sls_price IS NULL)
ORDER BY sls_sales, sls_quantity, sls_price;
-- Check all the columns
SELECT *
FROM bronze.crm_sales_details;

-- =================================================================
-- Checking 'silver.erp_cust_az12'
-- =================================================================

-- Check the column to connect the tables
SELECT *
FROM bronze.erp_cust_az12;
SELECT *
FROM silver.crm_cust_info;

-- Check if certain key values in cid table
-- Expectation: Matched
SELECT cid,
		bdate,
		gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

-- Check the if there's any unwanted keys
-- Expectation: No result
SELECT cid,
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
		END AS cid,
		bdate,
		gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
	  END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

-- Identify Out-of-Range Dates 
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();
-- Expectation: No result in silver
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Data Standarization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- Final look table
SELECT *
FROM silver.erp_cust_az12;

-- =================================================================
-- Checking 'silver.erp_loc_a101'
-- =================================================================

-- Check the FK of each tables
SELECT *
FROM bronze.erp_loc_a101;

SELECT cst_key
FROM silver.crm_cust_info

-- Check if correct the transformation
-- Expectation: No result
SELECT
		REPLACE(cid, '-','') AS cid_new,
		cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-','') NOT IN (SELECT cst_key
									FROM silver.crm_cust_info);

-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;
-- Check if the values are correct
SELECT DISTINCT cntry,
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
			 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
			 ELSE cntry
		END AS cntry_new
FROM bronze.erp_loc_a101;

-- Check the whole content in table
SELECT *
FROM silver.erp_loc_a101;

-- =================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =================================================================

-- Check the FK of each tables
SELECT *
FROM bronze.erp_px_cat_g1v2;

SELECT cat_id
FROM silver.crm_prd_info;

-- Check for Unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR 
		subcat != TRIM(subcat) OR 
		maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM silver.erp_px_cat_g1v2;
