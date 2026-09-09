/*
=========================================================
Project  : Brazilian E-Commerce Analysis
File     : 03_data_cleaning.sql
Author   : Almira Dea Dara Ninggar

Business Purpose:
Create clean analytical views by standardizing missing values
while preserving the original raw tables.

Data Cleaning Strategy

1. Raw tables dipertahankan tanpa perubahan (no UPDATE).

2. Data cleaning dilakukan menggunakan VIEW agar
   raw data tetap terjaga dan proses analisis dapat
   direproduksi.

3. Normalisasi missing value pada Clean View:
   - TEXT '' -> NULL
   - DATETIME '0000-00-00 00:00:00' -> NULL
   - Numeric 0 (yang berasal dari string kosong pada CSV) -> NULL

4. Temuan yang tetap dipertahankan (tidak diperbaiki):
   - Duplicate pada geolocation
   - 13 product category tanpa translation
   - payment_value = 0
   - payment_installments = 0
   - Timestamp anomaly (Approved > Carrier)
   - Timestamp anomaly (Carrier > Customer)

Reason:
Anomali tersebut tidak memiliki bukti yang cukup untuk
menentukan nilai yang benar sehingga tidak dilakukan
perubahan pada data dan hanya didokumentasikan.
=========================================================
*/


/*=======================================================
Clean Views
=======================================================*/

/*ORDERS CLEAN VIEW*/
CREATE OR REPLACE VIEW orders_clean AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    NULLIF(order_approved_at, 0) AS order_approved_at,
    NULLIF(order_delivered_carrier_date, 0) AS order_delivered_carrier_date,
    NULLIF(order_delivered_customer_date, 0) AS order_delivered_customer_date,
    NULLIF(order_estimated_delivery_date, 0) AS order_estimated_delivery_date
FROM orders;


/*ORDER REVIEWS CLEAN VIEW*/
CREATE OR REPLACE VIEW order_reviews_clean AS
SELECT
    review_id,
    order_id,
    review_score,
    NULLIF(review_comment_title, '') AS review_comment_title,
    NULLIF(review_comment_message, '') AS review_comment_message,
    NULLIF(review_creation_date, 0) AS review_creation_date,
    NULLIF(review_answer_timestamp, 0) AS review_answer_timestamp
FROM order_reviews;


/*PRODUCTS CLEAN VIEW*/
CREATE OR REPLACE VIEW products_clean AS
SELECT
    product_id,
    NULLIF(product_category_name, '') AS product_category_name,
    NULLIF(product_name_length, 0) AS product_name_length,
    NULLIF(product_description_length, 0) AS product_description_length,
    NULLIF(product_photos_qty, 0) AS product_photos_qty,
    NULLIF(product_weight_g, 0) AS product_weight_g,
    NULLIF(product_length_cm, 0) AS product_length_cm,
    NULLIF(product_height_cm, 0) AS product_height_cm,
    NULLIF(product_width_cm, 0) AS product_width_cm
FROM products;


/*=========================================================
VALIDATION
=========================================================*/

-- Verify missing values after cleaning ORDERS CLEAN VIEW
SELECT
	SUM(order_id = '') AS order_id_empty,
    SUM(customer_id = '') AS customer_id_empty,
    SUM(order_status = '') AS status_empty,
    SUM(order_purchase_timestamp IS NULL) AS purchase_empty,
    SUM(order_approved_at IS NULL) AS approved_empty,
    SUM(order_delivered_carrier_date IS NULL) AS carrier_date_empty,
    SUM(order_delivered_customer_date IS NULL) AS customer_date_empty,
    SUM(order_estimated_delivery_date IS NULL) AS delivery_date_empty
FROM orders_clean;

-- Verify missing values after cleaning ORDER REVIEWS CLEAN VIEW
SELECT
	SUM(review_id = '') AS review_id_empty,
    SUM(order_id = '') AS order_id_empty,
    SUM(review_score IS NULL) AS score_empty,
    SUM(review_comment_title IS NULL) AS comment_title_empty,
    SUM(review_comment_message IS NULL) AS comment_message_empty,
    SUM(review_creation_date IS NULL) AS creation_date_empty,
    SUM(review_answer_timestamp IS NULL) AS timestamp_empty
FROM order_reviews_clean;

-- Verify missing values after cleaning PRODUCTS CLEAN VIEW
SELECT
    SUM(product_name_length IS NULL) AS name_length_zero,
    SUM(product_description_length IS NULL) AS desc_length_zero,
    SUM(product_photos_qty IS NULL) AS photos_zero,
    SUM(product_weight_g IS NULL) AS weight_zero,
    SUM(product_length_cm IS NULL) AS length_zero,
    SUM(product_height_cm IS NULL) AS height_zero,
    SUM(product_width_cm IS NULL) AS width_zero
FROM products_clean;