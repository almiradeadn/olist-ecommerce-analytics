/*
====================================================
Project  : Brazilian E-Commerce Analysis
File     : 01_import_validation.sql
Author   : Almira Dea Dara Ninggar

Purpose:
Build the database from scratch by creating tables,
importing raw CSV files, and validating the import.

Contents:
1. Create Database
2. Create Tables
3. Import CSV Files
4. Validate Imported Data
====================================================
*/

USE ecommerce_analytics;
SHOW TABLES;


/*====================================================
SECTION 1 - CREATE TABLES
====================================================*/
-- Business Purpose:
-- Create database tables with the appropriate data types and structure
-- to support the e-commerce analysis.

/*
CREATE CUSTOMERS TABLE

The customers table was imported using
MySQL Workbench Table Data Import Wizard.

Therefore, CREATE TABLE and LOAD DATA LOCAL INFILE
statements are not included in this script.
*/


-- CREATE ORDERS TABLE 
CREATE TABLE orders (
	order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


-- CREATE SELLERS TABLE
CREATE TABLE sellers (
	seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);


-- CREATE PRODUCTS TABLE
CREATE TABLE products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- CREATE ORDER_ITEMS TABLE
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);


-- CREATE ORDER_PAYMENTS TABLE
CREATE TABLE order_payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value DECIMAL(10,2)
);


-- CREATE ORDER_REVIEWS TABLE
CREATE TABLE order_reviews (
	review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);


-- CREATE PRODUCT_CATEGORY_NAME_TRANSLATION TABLE
CREATE TABLE product_category_name_translation (
	product_category_name TEXT,
    product_category_name_english TEXT
);


-- CREATE GEOLOCATION TABLE
CREATE TABLE geolocation (
	geolocation_zip_code_prefix TEXT,
    geolocation_lat DECIMAL(11,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city TEXT,
    geolocation_state TEXT
);


/*====================================================
SECTION 2 - IMPORT DATA
====================================================*/
-- Business Purpose:
-- Import raw datasets into the database to prepare them for analysis.

-- LOAD DATA LOCAL INFILE orders
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE sellers
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE products
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE order_items
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE order_payments
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE order_reviews
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE product_category_name_translation
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- LOAD DATA LOCAL INFILE geolocation
LOAD DATA LOCAL INFILE 'D:/PROJECT SQL/archive/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



/*====================================================
SECTION 3 - IMPORT VALIDATION
====================================================*/
-- Business Purpose:
-- Verify that all datasets have been imported successfully and ensure
-- the number of records matches the source files.

-- Validasi jumlah row customers
SELECT COUNT(*) AS total_customers
FROM customers;

SELECT *
FROM customers
LIMIT 5;


-- Validasi jumlah row orders
SELECT COUNT(*) AS total_orders
FROM orders;

SELECT *
FROM orders
LIMIT 5;


-- Validasi jumlah row sellers
SELECT COUNT(*) AS total_sellers
FROM sellers;

SELECT *
FROM sellers
LIMIT 5;


-- -- Validasi jumlah row products
SELECT COUNT(*) AS total_products
FROM products;

SELECT * 
FROM products
LIMIT 5;


-- Validasi jumlah row order_items
SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT *
FROM order_items
LIMIT 5;


-- Validasi jumlah row order_payments
SELECT COUNT(*) AS total_order_payments
FROM order_payments;

SELECT *
FROM order_payments
LIMIT 5;


-- Validasi jumlah row order_reviews
SELECT COUNT(*) AS total_order_reviews
FROM order_reviews;

SELECT *
FROM order_reviews
LIMIT 5;


-- Validasi jumlah row product_categoty_name_translation
SELECT COUNT(*) AS total_category_translation
FROM product_category_name_translation;

SELECT *
FROM product_category_name_translation
LIMIT 5;


-- Validasi jumlah row geolocation
SELECT COUNT(*) AS total_geolocation
FROM geolocation;

SELECT *
FROM geolocation
LIMIT 5;



/*====================================================
SECTION 4 - TABLE STRUCTURE
====================================================*/
-- Business Purpose:
-- Verify table structures, column names, and data types to ensure
-- they are correctly defined before data quality checks.

DESCRIBE customers;
DESCRIBE orders;
DESCRIBE sellers;
DESCRIBE products;
DESCRIBE order_items;
DESCRIBE order_payments;
DESCRIBE order_reviews;
DESCRIBE product_category_name_translation;
DESCRIBE geolocation;
