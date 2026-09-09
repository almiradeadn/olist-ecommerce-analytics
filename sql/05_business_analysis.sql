/*
=========================================================
Project  : Brazilian E-Commerce Analysis
File     : 05_business_analysis.sql
Author   : Almira Dea Dara Ninggar

Purpose:
Analyze business performance and answer key business
questions using validated and cleaned data.

Analysis:
- Sales Performance
- Product Performance
- Customer Analysis
- Seller Performance
- Delivery Performance
- Customer Satisfaction
- Cross Analysis

Output:
- Business KPIs
- Business Insights
- Business Recommendations
=========================================================
*/

-- ==========================================
-- 1. Sales Performance
-- ==========================================
-- Business Question:
-- How is the marketplace performing in terms of Product Sales and completed orders?

-- 1.1 Total Product Sales
-- Calculate total Product Sales from completed orders.
SELECT
    ROUND(SUM(op.payment_value),2) AS total_Product Sales
FROM orders_clean o
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
  AND op.payment_value > 0;

-- 1.2 Total Completed Orders
-- Count total completed orders.
SELECT
	COUNT(*) AS complete_orders
FROM orders_clean
WHERE order_status = 'delivered';

-- 1.3 Average Order Value (AOV) (Total Product Sales / Jumlah Order Selesai)
-- Calculate Average Order Value (AOV).
SELECT
	ROUND(SUM(op.payment_value) / COUNT(DISTINCT o.order_id), 2) AS Average_Order_Value
FROM orders_clean o
JOIN order_payments op
	ON op.order_id = o.order_id
WHERE order_status = 'delivered'
AND payment_value > 0;

-- 1.4 Monthly Product Sales Trend
-- Analyze monthly Product Sales trend.
SELECT
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(op.payment_value), 2) AS total_Product Sales
FROM orders_clean o
JOIN order_payments op
	ON op.order_id = o.order_id
WHERE order_status = 'delivered'
AND payment_value > 0
GROUP BY month
ORDER BY month;

-- 1.5 Product Sales by Customer State
-- Analyze Product Sales by customer state.
SELECT
    c.customer_state AS customer_state,
	ROUND(SUM(op.payment_value), 2) AS total_Product Sales
FROM orders_clean o
JOIN order_payments op
	ON op.order_id = o.order_id
JOIN customers c
	ON c.customer_id = o.customer_id
WHERE order_status = 'delivered'
AND payment_value > 0
GROUP BY customer_state
ORDER BY total_Product Sales DESC;


-- ==========================================
-- 2. Product Performance
-- ==========================================
-- Business Question:
-- Which products and categories contribute the most to marketplace sales?

-- 2.1 Product Sales by Product Category
-- Identify product categories generating the highest Product Sales.
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS Product Sales
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY Product Sales DESC;

-- 2.2 Quantity Sold by Category
-- Identify the most sold product categories.
SELECT
	p.product_category_name AS category_product,
	COUNT(*) AS total_items_sold
FROM orders_clean o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products_clean p
	ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC;

-- 2.3 Average Product Price by Category
-- Compare average selling price across product categories.
SELECT
	p.product_category_name AS category_product,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM orders_clean o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products_clean p
	ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY avg_price DESC;

-- 2.4 Top 10 Best Selling Products
-- Identify the best-selling products.
SELECT
	oi.product_id,
	COUNT(*) AS total_sold
FROM orders_clean o
JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY total_sold DESC
LIMIT 10;

-- 2.5 Product Sales Contribution per Category
-- Measure each category's contribution to total product Product Sales.
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price),2) AS Product Sales,
    ROUND(
        SUM(oi.price) * 100 /
        (
            SELECT SUM(price)
            FROM order_items oi
            JOIN orders_clean o
                ON oi.order_id = o.order_id
            WHERE o.order_status='delivered'
        ),
        2
    ) AS Product Sales_percentage
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
WHERE o.order_status='delivered'
GROUP BY p.product_category_name
ORDER BY Product Sales DESC;

-- 2.6 Total_items_sold by product category
SELECT
    p.product_category_name,
    COUNT(oi.order_item_id) AS total_items_sold
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products_clean p
	ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND oi.price > 0
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC;


-- ==========================================
-- 3. Customer Analysis
-- ==========================================
-- Business Question:
-- How valuable and loyal are marketplace customers?

-- 3.1 Total Active Customer
-- Customer yang benar-benar berkontribusi pada Product Sales platform
SELECT
    COUNT(DISTINCT c.customer_unique_id) AS total_customers
FROM customers c
JOIN orders_clean o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
AND op.payment_value > 0;

-- 3.2 Repeat Customer Rate
-- Calculate repeat customer rate.
SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM customers c
    JOIN orders_clean o
		ON c.customer_id = o.customer_id
    WHERE order_status = 'delivered'
    GROUP BY c.customer_unique_id
) t;

-- 3.3 Average Customer Spending
-- Calculate average customer spending.
SELECT
    ROUND(AVG(customer_spending),2) AS avg_customer_spending
FROM (
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS customer_spending
    FROM customers c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) t;


-- 3.4 Top Customers by Spending
-- Identify top customers by spending.
SELECT
	c.customer_unique_id,
    ROUND(SUM(op.payment_value), 2) AS total_spending
FROM customers c
JOIN orders_clean o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
AND op.payment_value > 0
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 10;

-- 3.5 Average Orders per Customer
SELECT
    ROUND(COUNT(*) / COUNT(DISTINCT c.customer_unique_id), 2) AS avg_orders_per_customer
FROM customers c
JOIN orders_clean o
	ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';


-- ==========================================
-- 4. Seller Performance
-- ==========================================
-- Business Question:
-- Which sellers contribute the most to marketplace performance?

-- 4.1 Product Sales by Seller
-- Identify sellers generating the highest Product Sales.
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS Product Sales
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status='delivered'
GROUP BY oi.seller_id
ORDER BY Product Sales DESC
LIMIT 10;

-- 4.2 Quantity Sold by Seller
-- Identify sellers with the highest sales volume.
SELECT
    oi.seller_id,
    COUNT(*) AS total_items_sold
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status='delivered'
GROUP BY oi.seller_id
ORDER BY total_items_sold DESC
LIMIT 10;

-- 4.3 Average Product Sales per Seller
-- Calculate average Product Sales generated per seller.
SELECT
    ROUND(AVG(seller_Product Sales),2) AS avg_Product Sales_per_seller
FROM (
    SELECT
        oi.seller_id,
        SUM(oi.price) AS seller_Product Sales
    FROM orders_clean o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY oi.seller_id
) t;

-- 4.4 Seller Contribution
-- Measure each seller's contribution to marketplace Product Sales.
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS Product Sales,
    ROUND(
        SUM(oi.price) * 100 /
        (
            SELECT SUM(oi2.price)
            FROM order_items oi2
            JOIN orders_clean o2
                ON oi2.order_id = o2.order_id
            WHERE o2.order_status='delivered'
        ),
        2
    ) AS contribution_pct
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status='delivered'
GROUP BY oi.seller_id
ORDER BY Product Sales DESC
LIMIT 10;

-- 4.5 Distribusi Product Sales Seller (Product Sales Tier)
-- Analyze seller Product Sales distribution.
SELECT
    Product Sales_tier,
    COUNT(*) AS total_sellers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT
        seller_id,
        SUM(oi.price) AS seller_Product Sales,
        CASE
            WHEN SUM(oi.price) < 1000 THEN '< 1K'
            WHEN SUM(oi.price) < 5000 THEN '1K - 5K'
            WHEN SUM(oi.price) < 10000 THEN '5K - 10K'
            WHEN SUM(oi.price) < 50000 THEN '10K - 50K'
            WHEN SUM(oi.price) < 100000 THEN '50K - 100K'
            ELSE '> 100K'
        END AS Product Sales_tier
    FROM orders_clean o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY seller_id
) t
GROUP BY Product Sales_tier
ORDER BY
    CASE Product Sales_tier
        WHEN '< 1K' THEN 1
        WHEN '1K - 5K' THEN 2
        WHEN '5K - 10K' THEN 3
        WHEN '10K - 50K' THEN 4
        WHEN '50K - 100K' THEN 5
        WHEN '> 100K' THEN 6
    END;
    
-- 4.6 Average Seller Review Score
SELECT
    ROUND(AVG(orv.review_score), 2) AS average_seller_review_score
FROM order_reviews orv
JOIN orders_clean o
    ON orv.order_id = o.order_id
JOIN (
    SELECT DISTINCT order_id, seller_id
    FROM order_items
) oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- 4.7 Active Sellers
SELECT COUNT(DISTINCT seller_id) AS active_sellers
FROM order_items oi
JOIN orders_clean o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- 4.8 Top 10 Sellers by Orders
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS delivered_orders
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND oi.price > 0
GROUP BY oi.seller_id
ORDER BY delivered_orders DESC
LIMIT 10;

-- 4.9 AOV per Seller
SELECT 
    oi.seller_id,
    SUM(oi.price) AS total_product_Product Sales,
    COUNT(DISTINCT oi.order_id) AS total_delivered_orders,
    SUM(oi.price) / COUNT(DISTINCT oi.order_id) AS aov_product
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    o.order_status = 'delivered' 
    AND oi.price > 0
GROUP BY 
    oi.seller_id
ORDER BY 
    total_product_Product Sales DESC;
    
    
-- ==========================================
-- 5. Delivery Performance
-- ==========================================
-- Business Question:
-- How efficient is the order fulfillment and delivery process?

-- 5.1 Average Delivery Time
-- Calculate average delivery time.
SELECT
	ROUND(AVG(timestampdiff(DAY, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS avg_delivery_days
FROM orders_clean
WHERE order_status = 'delivered'
AND order_delivered_carrier_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL;

-- 5.2 Average Fulfillment Time
-- Calculate average fulfillment time.
SELECT
	ROUND(AVG(timestampdiff(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_Fulfillment_days
FROM orders_clean
WHERE order_status = 'delivered'
AND order_purchase_timestamp IS NOT NULL
AND order_delivered_customer_date IS NOT NULL;

-- 5.3 On-Time Delivery Rate
-- Measure on-time delivery rate.
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM orders_clean
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;

-- 5.4 Average Delivery Time by Customer State
-- Compare average delivery time across customer states.
SELECT
	c.customer_state,
    ROUND(AVG(timestampdiff(DAY, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS avg_delivery_days
FROM orders_clean o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
AND order_delivered_carrier_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- 5.5 Average Delay Days (Late Orders Only)
-- Calculate average delay for late deliveries.
SELECT
	ROUND(AVG(timestampdiff(DAY, order_estimated_delivery_date, order_delivered_customer_date)), 2) AS avg_delay_days
FROM orders_clean
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_customer_date > order_estimated_delivery_date;

-- 5.6 total delivered orders
SELECT COUNT(DISTINCT o.order_id) AS total_delivered_orders
FROM orders_clean o
JOIN order_payments op
	ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
AND op.payment_value > 0;

-- 5.7 total delivered items
SELECT COUNT(*) AS total_delivered_items
FROM order_items oi
JOIN orders_clean o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND EXISTS (
      SELECT 1
      FROM order_payments op
      WHERE op.order_id = o.order_id
        AND op.payment_value > 0
  );

-- 5.8 cancellation rate
SELECT 
    COUNT(CASE WHEN order_status = 'canceled' THEN order_id END) AS canceled_orders,
    COUNT(order_id) AS total_orders,
    ROUND(
        COUNT(CASE WHEN order_status = 'canceled' THEN order_id END) * 100.0 / COUNT(order_id), 
        2
    ) AS cancellation_rate_percentage
FROM orders_clean;

-- 5.9 Order Fulfillment Rate
SELECT 
    COUNT(CASE WHEN order_status = 'delivered' THEN order_id END) AS delivered_orders,
    COUNT(order_id) AS total_orders,
    ROUND(
        COUNT(CASE WHEN order_status = 'delivered' THEN order_id END) * 100.0 / COUNT(order_id), 
        2
    ) AS fulfillment_rate_percentage
FROM orders_clean;

-- 5.10 In-Progress Orders Rate
SELECT 
    COUNT(CASE WHEN order_status NOT IN ('delivered', 'canceled') THEN order_id END) AS in_progress_orders,
    COUNT(order_id) AS total_orders,
    ROUND(
        COUNT(CASE WHEN order_status NOT IN ('delivered', 'canceled') THEN order_id END) * 100.0 / COUNT(order_id), 
        2
    ) AS in_progress_rate_percentage
FROM orders_clean;

-- 5.11 Freight Product Sales
SELECT 
    SUM(oi.freight_value) AS freight_Product Sales
FROM order_items oi
JOIN orders_clean o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND EXISTS (
      SELECT 1 
      FROM order_payments op 
      WHERE op.order_id = o.order_id 
        AND op.payment_value > 0
  );

-- 5.12 Late Delivery by State
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_late_delivered_orders
FROM customers c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY total_late_delivered_orders DESC;


-- 5.13 Average Delivery Delay by State
SELECT
    c.customer_state,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delivery_delay_days
FROM customers c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY average_delivery_delay_days DESC;


-- ==========================================
-- 6. Customer Satisfaction
-- ==========================================
-- Business Question:
-- How satisfied are customers with their shopping experience?

-- 6.1 Average Review Score
-- Calculate average customer review score.
SELECT
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- 6.2 Review Score Distribution
-- Analyze review score distribution.
SELECT
    r.review_score,
    COUNT(*) AS total_reviews,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score DESC;

-- 6.3 Average Review Score by Delivery Status
-- Compare customer satisfaction between on-time and late deliveries.
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(r.review_score),2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM orders_clean o
JOIN order_reviews_clean r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY delivery_status;

-- Analyze review score distribution for late deliveries.
SELECT
	r.review_score,
    COUNT(*) AS total_reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS precentage
FROM order_reviews_clean r
JOIN orders_clean o
	ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND order_delivered_customer_date > order_estimated_delivery_date
GROUP BY r.review_score
ORDER BY r.review_score;

-- 6.4 Review Score by Customer State
-- Compare customer satisfaction across customer states.
SELECT
	c.customer_state,
    ROUND(AVG(r.review_score), 2) AS score_by_state,
    COUNT(*) AS total_reviews
FROM customers c
JOIN orders_clean o
	ON c.customer_id = o.customer_id
JOIN order_reviews_clean r
	ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY score_by_state DESC;


-- 6.5 Review Score by Product Category
-- Compare customer satisfaction across product categories.
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score),2) AS avg_review_score,
    COUNT(*) AS total_reviews
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
HAVING COUNT(*) >= 100
ORDER BY avg_review_score DESC;



-- ==========================================
-- 7. Cross Analysis
-- ==========================================
-- Business Question:
-- What relationships exist between Product Sales, delivery performance, and customer satisfaction?

-- 7.1 Apakah kategori dengan Product Sales tinggi juga memiliki kepuasan tinggi?
-- Analyze the relationship between product Product Sales and customer satisfaction.
SELECT
	p.product_category_name,
    ROUND(SUM(oi.price), 2) AS Product Sales_category,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
HAVING COUNT(*) >= 100 
ORDER BY Product Sales_category DESC;


-- 7.2 Apakah wilayah dengan Product Sales tinggi memiliki pengiriman lebih cepat?
-- Analyze the relationship between regional Product Sales and delivery performance.
SELECT
	c.customer_state,
	ROUND(SUM(oi.price), 2) AS Product Sales_state,
    ROUND(AVG(timestampdiff(DAY, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS avg_delivery_days
FROM customers c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY Product Sales_state DESC;

-- 7.3 Apakah seller dengan Product Sales tinggi juga memiliki rating tinggi?
-- Analyze the relationship between seller Product Sales and customer satisfaction.
SELECT
	oi.seller_id,
	ROUND(SUM(oi.price), 2) AS Product Sales_seller,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM orders_clean o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN order_reviews_clean r
	ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
HAVING COUNT(*) >= 30
ORDER BY Product Sales_seller DESC
LIMIT 20;

-- 7.4 Apakah pelanggan dengan pengeluaran tinggi memberikan review lebih tinggi?
-- Analyze the relationship between seller Product Sales and customer satisfaction.
SELECT
    c.customer_unique_id,
    ROUND(SUM(op.payment_value),2) AS total_spending,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM customers c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
JOIN order_reviews_clean r
    ON o.order_id = r.order_id
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status='delivered'
GROUP BY c.customer_unique_id
HAVING COUNT(*) > 1
ORDER BY total_spending DESC
LIMIT 20;
