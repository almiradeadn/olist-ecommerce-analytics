/*
=========================================================
Project  : Brazilian E-Commerce Analysis
File     : 02_data_quality_check.sql
Author   : Almira Dea Dara Ninggar

Purpose:
Melakukan Data Quality Check (DQC) terhadap dataset
sebelum proses data cleaning.

Validation Performed:
- Candidate Primary Key Check
- Missing Value Check
- Duplicate Row Check
- Referential Integrity Check
- Domain Validation
- Business Rule Validation

Output:
- Temuan data quality issue.
- Data anomaly.
- Dokumentasi hasil validasi.
=========================================================
*/


/*=========================================================
DATASET OVERVIEW
=========================================================*/
-- Business Purpose:
-- Verify the number of records imported for each table.

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;


/*=========================================================
SECTION 1 - CANDIDATE PRIMARY KEY CHECK
=========================================================*/
-- Business Purpose:
-- Ensure that each table has a unique identifier and
-- contains no duplicate primary key values.

-- Check duplicate customer_id
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate order_id
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check duplicate product_id
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check duplicate seller_id
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Check duplicate product_category_name
SELECT product_category_name, COUNT(*)
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


/*=========================================================
SECTION 2 - MISSING VALUE CHECK
=========================================================*/
-- Business Purpose:
-- Identify missing, empty, or incomplete values that may
-- affect data quality and business analysis.


-- Check missing values in important columns
SELECT COUNT(*) AS missing_category
FROM products
WHERE product_category_name = '';

SELECT
	SUM(product_category_name = '') AS name_empty,
    SUM(product_category_name_english = '') AS name_english_empty
FROM product_category_name_translation;

SELECT
    SUM(product_category_name = '') AS category_empty,
    SUM(product_name_length = '') AS name_length_empty,
    SUM(product_description_length = '') AS description_length_empty,
    SUM(product_photos_qty = '') AS photos_empty,
    SUM(product_weight_g = '') AS weight_empty,
    SUM(product_length_cm = '') AS length_empty,
    SUM(product_height_cm = 0) AS height_empty,
    SUM(product_width_cm = '') AS width_empty
FROM products;

SELECT *
FROM products
WHERE product_description_length = ''
LIMIT 20;


-- Count products with missing category translation
SELECT
	p.product_category_name,
	COUNT(*) AS total_products
FROM products p
LEFT JOIN product_category_name_translation nt
    ON p.product_category_name = nt.product_category_name
WHERE p.product_category_name <> ''
  AND nt.product_category_name IS NULL
GROUP BY p.product_category_name;


-- Check products with empty category names
SELECT -- cek category
	p.product_id,
    p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation nt
    ON p.product_category_name = nt.product_category_name
WHERE p.product_category_name = '';


-- Check missing values in important columns
SELECT
	SUM(customer_id = '') AS customer_id_empty,
    SUM(customer_unique_id = '') AS unique_id_empty,
    SUM(customer_zip_code_prefix = '') AS zip_code_empty,
    SUM(customer_city = '') AS city_empty,
    SUM(customer_state = '') AS state_empty
FROM customers;


-- Check missing values in important columns
SELECT
	SUM(order_id = '') AS order_id_empty,
    SUM(customer_id = '') AS customer_id_empty,
    SUM(order_status = '') AS status_empty,
    SUM(order_purchase_timestamp = 0) AS purchase_empty,
    SUM(order_approved_at = 0) AS approved_empty,
    SUM(order_delivered_carrier_date = 0) AS carrier_date_empty,
    SUM(order_delivered_customer_date = 0) AS customer_date_empty,
    SUM(order_estimated_delivery_date = 0) AS delivery_date_empty
FROM orders;

SELECT *
FROM orders
WHERE order_delivered_customer_date = 0
LIMIT 10;

SELECT order_status,
       SUM(order_approved_at = 0) AS approved_missing,
       SUM(order_delivered_carrier_date = 0) AS carrier_missing,
       SUM(order_delivered_customer_date = 0) AS customer_missing
FROM orders
GROUP BY order_status;

SELECT *
FROM orders
WHERE order_delivered_customer_date = 0
AND order_delivered_carrier_date = 0
AND order_status = 'delivered';


-- Check missing values in important columns
SELECT
	SUM(seller_id = '') AS name_empty,
    SUM(seller_zip_code_prefix = '') AS name_english_empty,
    SUM(seller_city = '') AS city_empty,
    SUM(seller_state = '') AS state_empty
FROM sellers;


-- Check missing values in important columns
SELECT
	SUM(geolocation_zip_code_prefix = '') AS zip_code_empty,
    SUM(geolocation_lat IS NULL) AS lat_empty,
    SUM(geolocation_lng IS NULL) AS long_empty,
    SUM(geolocation_city = '') AS city_empty,
    SUM(geolocation_state = '') AS state_empty
FROM geolocation;


-- Check missing values in important columns
SELECT
	SUM(order_id ='') AS order_id_empty,
    SUM(order_item_id IS NULL) AS item_id_empty,
    SUM(product_id ='') AS product_id_empty,
    SUM(seller_id ='') AS seller_empty,
    SUM(shipping_limit_date = 0) AS shipping_date_empty,
    SUM(price IS NULL) AS price_empty,
    SUM(freight_value is null) AS freight_empty
FROM order_items;

SELECT *
FROM order_items
WHERE freight_value = 0
LIMIT 5;

SELECT
	SUM(order_id = '') AS id_empty,
    SUM(payment_sequential IS NULL) AS sequential_empty,
    SUM(payment_type = '') AS type_empty,
    SUM(payment_installments IS NULL) AS installments_empty,
    SUM(payment_value IS NULL) AS value_empty
FROM order_payments;

SELECT *
FROM order_payments
WHERE payment_value = 0;


-- Check missing values in important columns
SELECT
	SUM(review_id = '') AS review_id_empty,
    SUM(order_id = '') AS order_id_empty,
    SUM(review_score IS NULL) AS score_empty,
    SUM(review_comment_title = '') AS comment_title_empty,
    SUM(review_comment_message = '') AS comment_message_empty,
    SUM(review_creation_date = 0) AS creation_date_empty,
    SUM(review_answer_timestamp = 0) AS timestamp_empty
FROM order_reviews;

SELECT *
FROM order_reviews
WHERE review_answer_timestamp = 0
LIMIT 5;


/*=========================================================
SECTION 3 - DUPLICATE ROW CHECK
=========================================================*/
-- Business Purpose:
-- Detect duplicated records that may lead to inaccurate
-- aggregation and analysis.

-- Check duplicate rows in the customers table
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    COUNT(*) AS total_duplicate
FROM customers
GROUP BY
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
HAVING COUNT(*) > 1;

-- Check duplicate rows in the orders table
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    COUNT(*) AS total_duplicate
FROM orders
GROUP BY
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
HAVING COUNT(*) > 1;

-- Check duplicate rows in the products table
SELECT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    COUNT(*) AS total_duplicate
FROM products
GROUP BY
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
HAVING COUNT(*) > 1;

-- Check duplicate rows in the sellers table
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    COUNT(*) AS total_duplicate
FROM sellers
GROUP BY
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
HAVING COUNT(*) > 1;

-- Check duplicate rows in the order_items table
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    COUNT(*) AS total_duplicate
FROM order_items
GROUP BY
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
HAVING COUNT(*) > 1;

-- Check duplicate rows in the order_payments table
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    COUNT(*) AS total_duplicate
FROM order_payments
GROUP BY
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
HAVING COUNT(*) > 1;

-- Check duplicate rows in the order_reviews table
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    COUNT(*) AS total_duplicate
FROM order_reviews
GROUP BY
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
HAVING COUNT(*) > 1;

-- Check duplicate rows in the product_category_name_translation table
SELECT
    product_category_name,
    product_category_name_english,
    COUNT(*) AS total_duplicate
FROM product_category_name_translation
GROUP BY
    product_category_name,
    product_category_name_english
HAVING COUNT(*) > 1;

-- Check duplicate rows in the geolocation table
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS total_duplicate
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
LIMIT 10;


/*=========================================================
SECTION 4 - REFERENTIAL INTEGRITY CHECK
=========================================================*/
-- Business Purpose:
-- Verify relationships between tables to ensure there are
-- no orphan records or broken references.


-- Check orders with invalid customer_id references
SELECT COUNT(*) AS orphan_customer
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check order items with invalid order_id references
SELECT COUNT(*) AS orphan_order
FROM order_items oi
LEFT JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check order items with invalid product_id references
SELECT COUNT(*) AS orphan_product
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Check order items with invalid seller_id references
SELECT COUNT(*) AS orphan_seller
FROM order_items oi
LEFT JOIN sellers s
	ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Check reviews with invalid order_id references
SELECT COUNT(*) AS orphan_review
FROM order_reviews r
LEFT JOIN orders o
	ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check payments with invalid order_id references
SELECT COUNT(*) AS orphan_payment
FROM order_payments op
LEFT JOIN orders o
	ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check category translation with invalid product_category_name references
SELECT COUNT(*) AS orphan_category
FROM product_category_name_translation nt
LEFT JOIN products p
	ON nt.product_category_name = p.product_category_name
WHERE p.product_category_name IS NULL;

-- Check products with invalid product_category_name_translation references
SELECT COUNT(*) AS orphan_category
FROM products p
LEFT JOIN product_category_name_translation nt
    ON p.product_category_name = nt.product_category_name
WHERE p.product_category_name <> ''
  AND nt.product_category_name IS NULL;

-- Check product categories without translation mapping
SELECT distinct
	p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation nt
    ON p.product_category_name = nt.product_category_name
WHERE p.product_category_name <> ''
  AND nt.product_category_name IS NULL;
  

/*=========================================================
SECTION 5 - DOMAIN VALIDATION
=========================================================*/
-- Business Purpose:
-- Validate whether column values fall within acceptable
-- business domains and expected ranges.

-- Check invalid review score values
SELECT DISTINCT review_score
FROM order_reviews
ORDER BY review_score;

-- Check invalid order status values
SELECT
    order_status,
    COUNT(*) AS total_order
FROM orders
GROUP BY order_status
ORDER BY total_order DESC;

-- Check latitude and longitude value ranges
SELECT
    MIN(geolocation_lat) AS min_lat,
    MAX(geolocation_lat) AS max_lat,
     MIN(geolocation_lng) AS min_lng,
    MAX(geolocation_lng) AS max_lng
FROM geolocation;

-- Check product price range
SELECT
	MIN(price) AS min_price,
    MAX(price) AS max_price
FROM order_items;

-- Check negative product prices
SELECT COUNT(*) AS invalid_price
FROM order_items
WHERE price < 0;

-- Check freight value range
SELECT
	MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight
FROM order_items;

-- Check negative freight values
SELECT COUNT(*) AS invalid_freight
FROM order_items
WHERE freight_value < 0;

-- Check payment value range
SELECT
	MIN(payment_value) AS min_payment_v,
    MAX(payment_value) AS max_payment_v
FROM order_payments;

-- Check zero or negative payment values
SELECT COUNT(*) AS invalid_payment
FROM order_payments
WHERE payment_value <= 0;

-- Check undefined payment types
SELECT 
    o.order_id,
    o.order_status,
    p.payment_type,
    p.payment_value
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE p.payment_type = 'not_defined';

-- Check payment installment range
SELECT
	MIN(payment_installments) AS min_payment,
    MAX(payment_installments) AS max_payment
FROM order_payments;

-- Check invalid payment installments
SELECT COUNT(*) AS invalid_payment
FROM order_payments
WHERE payment_installments < 1;



/*=========================================================
SECTION 6 - BUSINESS RULE VALIDATION
=========================================================*/
-- Business Purpose:
-- Verify that business processes follow logical chronological
-- rules and operational constraints.

-- Check orders approved before purchase
SELECT COUNT(*) AS invalid_purchase_approved
FROM orders
WHERE order_approved_at <> 0
AND order_purchase_timestamp > order_approved_at;

-- Check orders shipped to carrier before approval
SELECT COUNT(*) invalid_approved_carrier
FROM orders
WHERE order_approved_at <> 0
AND order_delivered_carrier_date <> 0
AND order_approved_at > order_delivered_carrier_date;

-- Check carrier delivery recorded after customer delivery
SELECT COUNT(*) AS invalid_carrier_customer
FROM orders
WHERE order_delivered_carrier_date <> 0
AND order_delivered_customer_date <> 0
AND order_delivered_carrier_date > order_delivered_customer_date;

-- Check orders purchased after customer delivery
SELECT COUNT(*) AS invalid_purchase_delivery
FROM orders
WHERE order_delivered_customer_date <> 0
AND order_purchase_timestamp > order_delivered_customer_date;

-- Check orders purchased after estimated delivery date
SELECT COUNT(*) AS invalid_estimated_delivery
FROM orders
WHERE order_estimated_delivery_date <> 0
AND order_purchase_timestamp > order_estimated_delivery_date;
