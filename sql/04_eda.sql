/*
=========================================================
Project  : Brazilian E-Commerce Analysis
File     : 04_eda.sql
Author   : Almira Dea Dara Ninggar

EXPLORATORY DATA ANALYSIS
Purpose:
Memahami karakteristik dataset sebelum melakukan
Business Performance Analysis.

Analysis:
- Orders
- Customers
- Sellers
- Products
- Order Items
- Payments
- Reviews
- Delivery & Fulfillment
=========================================================
*/

/*=======================================================
-- 1. Orders
=======================================================*/
-- 1.1 Total Orders
-- Count the total number of orders
SELECT COUNT(*) AS total_orders
FROM orders_clean;

-- 1.2 Order Status Distribution
-- Analyze the distribution of order statuses
SELECT
	order_status,
    COUNT(*) AS total_order,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders_clean), 2) AS percentage
FROM orders_clean
GROUP BY order_status
ORDER BY total_order DESC;

-- 1.3 Dataset Time Range
-- Identify the time range covered by the dataset.
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders_clean;

-- 1.4 Monthly Order Trend
-- Analyze monthly order trends.
SELECT
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders_clean
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY month;

-- 1.5 Annual Order Trend
-- Analyze annual order trends.
SELECT
    YEAR(order_purchase_timestamp) AS year,
    COUNT(*) AS total_orders
FROM orders_clean
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY year;

/*=======================================================
-- 2. Customers
=======================================================*/
-- 2.1 Total Customers
-- Count the total number of customer records.
SELECT COUNT(*) AS total_customers
FROM customers;

-- 2.2 Unique Customers
-- Compare customer_id and customer_unique_id counts.
SELECT 
	COUNT(DISTINCT customer_id) AS customer_id,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- 2.3 Top 10 State
-- Identify the top 10 customer states.
SELECT
	customer_state,
	COUNT(*) AS total_customer
FROM customers
GROUP BY customer_state
ORDER BY total_customer DESC
LIMIT 10;

-- 2.4 Top 10 City
-- Identify the top 10 customer cities.
SELECT
	customer_city,
    COUNT(*) AS total_customer
FROM customers
GROUP BY customer_city
ORDER BY total_customer DESC
LIMIT 10;

-- 2.5 Repeat Customers
-- Count repeat customers.
SELECT
	COUNT(*) AS repeat_customer
FROM (
	SELECT customer_unique_id
    FROM customers
    GROUP BY customer_unique_id
    HAVING COUNT(*) > 1
) AS t;


/*=======================================================
-- 3. Sellers
=======================================================*/
-- 3.1 Total Sellers
-- Count the total number of sellers.
SELECT COUNT(*) AS total_sellers
FROM sellers;

-- 3.2 Distribusi Seller per State
-- Analyze seller distribution by state.
SELECT
	seller_state,
    COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;

-- 3.3 Top 10 Seller City
-- Identify the top 10 seller cities.
SELECT
	seller_city,
    COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_city
ORDER BY total_sellers DESC
LIMIT 10;


/*=======================================================
-- 4. Products
=======================================================*/
-- 4.1 Total Products
-- Count the total number of products.
SELECT COUNT(*) AS total_products
FROM products_clean;

-- 4.2 Total Product Categories
-- Count distinct product categories.
SELECT COUNT(DISTINCT product_category_name) AS total_categories
FROM products_clean;

-- 4.3 TOP 10 Products Categories
-- Identify the top 10 product categories by number of products.
SELECT
    COALESCE(t.product_category_name_english, 'Unknown') AS category,
    COUNT(*) AS total_products
FROM products_clean p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_products DESC
LIMIT 10;

-- 4.4 Distribusi Jumlah Foto Produk
-- Analyze the distribution of product photos.
SELECT
	product_photos_qty,
    COUNT(*) AS total_products
FROM products_clean
GROUP BY product_photos_qty
ORDER BY product_photos_qty;

-- 4.5 Statistik Berat Produk
-- Summarize product weight statistics.
SELECT
	MIN(product_weight_g) AS min_weight,
    MAX(product_weight_g) AS max_weight,
    ROUND(AVG(product_weight_g), 2) AS avg_weight
FROM products_clean;

-- 4.6 Statistik Dimensi Produk
-- Summarize product dimension statistics.
SELECT
	ROUND(AVG(product_length_cm), 2) AS avg_length,
    ROUND(AVG(product_height_cm), 2) AS avg_height,
    ROUND(AVG(product_width_cm), 2) AS avg_width
FROM products_clean;

-- 4.7 Total Sold Products
-- Quantity sold.
SELECT COUNT(*) AS quantity_sold
FROM order_items oi
JOIN orders_clean o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';
    

/*=======================================================
-- 5. Order Items
=======================================================*/
-- 5.1 Total Order Items
-- Count total order items.
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- 5.2 Avg Items per Order
-- Calculate the average number of items per order.
SELECT
	ROUND(AVG(item_count), 2) AS avg_item_per_order
FROM (
	SELECT order_id,
		COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS t;

-- 5.3 Price Statistics
-- Summarize product price statistics.
SELECT
	MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price
FROM order_items;

-- 5.4 Freight Statistics
-- Summarize freight value statistics.
SELECT 
	MIN(freight_value) AS min_freight_value,
    MAX(freight_value) AS max_freight_value,
    ROUND(AVG(freight_value), 2) AS avg_freight_value
FROM order_items;

-- 5.5 Top 10 Selling Products
-- Identify the top 10 best-selling products.
SELECT 
	product_id,
    COUNT(*) AS sold_products
FROM order_items
GROUP BY product_id
ORDER BY sold_products DESC
LIMIT 10;

-- 5.6 Distribution of Items per Order
-- Analyze the distribution of items per order.
SELECT
    item_count,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM order_items),
        2
    ) AS percentage
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) t
GROUP BY item_count
ORDER BY item_count;

-- 5.7 Order yang punya lebih dari 1 seller
SELECT
    seller_count,
    COUNT(*) AS total_orders
FROM (
    SELECT
        order_id,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM order_items
    GROUP BY order_id
) x
GROUP BY seller_count
ORDER BY seller_count;


/*=======================================================
-- 6. Payments
=======================================================*/
-- 6.1 Total Payment Records
-- Count total payment records.
SELECT COUNT(*) AS total_payment_records
FROM order_payments;

-- 6.2 Distribusi Payment Type
-- Analyze payment type distribution.
SELECT
	payment_type,
    COUNT(*) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS percentage
FROM order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;

-- 6.3 Statistik Nilai Pembayaran
-- Summarize payment value statistics.
SELECT
	MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments;

-- 6.4 Distribusi Jumlah Cicilan
-- Analyze payment installment distribution.
SELECT 
	payment_installments,
    COUNT(*) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS percentage
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- 6.5 Order dengan Multiple Payment Records
-- Count orders with multiple payment records.
SELECT
    COUNT(*) AS orders_multiple_payments
FROM (
    SELECT
        order_id
    FROM order_payments
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;


/*=======================================================
-- 7. Reviews
=======================================================*/
-- 7.1 Total Reviews
-- Count total reviews.
SELECT COUNT(*) AS total_reviews
FROM order_reviews_clean;

-- 7.2 Review Score Distribution
-- Analyze review score distribution.
SELECT
	review_score,
    COUNT(*) AS total_reviews,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_reviews_clean), 2) AS percentage
FROM order_reviews_clean
GROUP BY review_score
ORDER BY review_score;

-- 7.3 Comment vs No Comment
-- Compare reviews with and without comments.
SELECT
	CASE
		WHEN review_comment_message IS NULL THEN 'Without Comment'
        ELSE 'With Comment'
	END AS review_type,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_reviews_clean), 2) AS percentage
FROM order_reviews_clean
GROUP BY review_type
ORDER BY percentage;


/*=======================================================
-- 8. Delivery & Fulfillment
=======================================================*/
-- 8.1 Waktu Persetujuan Order
-- Summarize order approval time.
SELECT
    MIN(TIMESTAMPDIFF(HOUR,
        order_purchase_timestamp,
        order_approved_at)) AS min_hours,
    MAX(TIMESTAMPDIFF(HOUR,
        order_purchase_timestamp,
        order_approved_at)) AS max_hours,
    ROUND(AVG(TIMESTAMPDIFF(HOUR,
        order_purchase_timestamp,
        order_approved_at)),2) AS avg_hours
FROM orders_clean
WHERE order_approved_at IS NOT NULL;

-- 8.2 Lama Pengiriman ke Customer
-- Summarize delivery time from carrier to customer.
SELECT
    MIN(DATEDIFF(
        order_delivered_customer_date,
        order_delivered_carrier_date)) AS min_days,
    MAX(DATEDIFF(
        order_delivered_customer_date,
        order_delivered_carrier_date)) AS max_days,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_delivered_carrier_date)),2) AS avg_days
FROM orders_clean
WHERE order_delivered_customer_date IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL;

-- 8.3 Total Fulfillment Time
-- Summarize total order fulfillment time.
SELECT
    MIN(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp)) AS min_days,
    MAX(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp)) AS max_days,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp)),2) AS avg_days
FROM orders_clean
WHERE order_delivered_customer_date IS NOT NULL;

-- 8.4 Tepat Waktu vs Terlambat
-- Compare on-time and late deliveries.
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM orders_clean
            WHERE order_delivered_customer_date IS NOT NULL
        ),
        2
    ) AS percentage
FROM orders_clean
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
