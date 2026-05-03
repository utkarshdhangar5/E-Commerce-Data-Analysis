CREATE DATABASE OLIST;
USE OLIST;

SELECT TOP 5 * FROM CUSTOMERS
SELECT TOP 5 * FROM GEOLOCATION
SELECT TOP 5 * FROM ORDER_ITEMS
SELECT TOP 5 * FROM ORDER_PAYMENT
SELECT TOP 5 * FROM ORDER_REVIEW
SELECT TOP 5 * FROM Orders
SELECT TOP 5 * FROM PRODUCTS
SELECT TOP 5 * FROM SELLERS
SELECT TOP 5 * FROM PRODUCT_CATEGORY_NAME_TRANS

-- Data Cleaning and Validation

--CHECK TABLE SIZES
SELECT 'customers' AS table_name, COUNT(*) FROM CUSTOMERS
UNION ALL
SELECT 'orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM ORDER_ITEMS
UNION ALL
SELECT 'payments', COUNT(*) FROM ORDER_PAYMENT
UNION ALL
SELECT 'reviews', COUNT(*) FROM ORDER_REVIEW
UNION ALL
SELECT 'products', COUNT(*) FROM PRODUCTS
UNION ALL
SELECT 'sellers', COUNT(*) FROM SELLERS;

--CHECK NULL VALUES
--1. ORDERS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(customer_id) AS customer_id_not_null,
    COUNT(order_purchase_timestamp) AS purchase_time_not_null
FROM Orders;

--2. CUSTOMERS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS customer_id_not_null,
    COUNT(customer_unique_id) AS customer_unique_id_not_null,
    COUNT(customer_city) AS purchase_time_not_null,
    COUNT(customer_state) AS customer_state_not_null
FROM CUSTOMERS;

--3. ORDER_ITEMS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(order_item_id) AS order_item_id_not_null,
    COUNT(product_id) AS product_id_not_null,
    COUNT(seller_id) AS seller_id_not_null,
    COUNT(price) AS price_not_null,
    COUNT(freight_value) AS freight_value_not_null
FROM ORDER_ITEMS;

--4. ORDER_PAYMENT
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(payment_sequential) AS sequential_not_null,
    COUNT(payment_type) AS payment_type_not_null,
    COUNT(payment_installments) AS pay_inst_not_null,
    COUNT(payment_value) AS pay_value_not_null
FROM ORDER_PAYMENT;

--5. ORDER REVIEW
SELECT 
    COUNT(*) AS total_rows,
    COUNT(review_id) AS review_id_not_null,
    COUNT(order_id) AS order_id_not_null,
    COUNT(review_score) AS review_score_not_null
FROM ORDER_REVIEW;

--6. products
SELECT 
    COUNT(*) AS total_rows,
    COUNT(product_id) AS product_id_not_null,
    COUNT(product_category_name) AS product_category_name_not_null,
    COUNT(product_photos_qty) AS product_photos_qty_not_null,
    COUNT(product_weight_g) AS product_weight_g_not_null
FROM PRODUCTS;

--7. seller
SELECT 
    COUNT(*) AS total_rows,
    COUNT(seller_id) AS seller_id_not_null,
    COUNT(seller_city) AS seller_city_not_null,
    COUNT(seller_state) AS seller_state_not_null
FROM SELLERS;

-- Check duplicate records
--1. customers
SELECT customer_id, count(*)
from CUSTOMERS
group by customer_id
having count(*) > 1;

--2. orders
SELECT order_id, COUNT(*)
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--3. order items
SELECT order_id, order_item_id, COUNT(*)
FROM ORDER_ITEMS
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

--4. payment
SELECT order_id, payment_sequential, COUNT(*)
FROM ORDER_PAYMENT
GROUP BY order_id,payment_sequential
HAVING COUNT(*) > 1;

--5. reviews
-- I found that some orders had multiple reviews. Instead of removing data blindly, 
-- I retained the most recent review per order using ROW_NUMBER and window functions.
WITH review_clean AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_creation_date DESC, review_answer_timestamp DESC
           ) AS rn
    FROM ORDER_REVIEW
)
SELECT *
INTO clean_reviews
FROM review_clean
WHERE rn = 1;
select * from clean_reviews

--6. products 
SELECT product_id, COUNT(*)
FROM PRODUCTS
GROUP BY product_id
HAVING COUNT(*) > 1;

--7. seller
SELECT seller_id, COUNT(*)
FROM SELLERS
GROUP BY seller_id
HAVING COUNT(*) > 1;

--8. PRODUCT_CATEGORY_NAME_TRANS
SELECT product_category_name, COUNT(*)
FROM PRODUCT_CATEGORY_NAME_TRANS
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- Rename column1
EXEC sp_rename 
    'PRODUCT_CATEGORY_NAME_TRANS.column1', 
    'product_category_name', 
    'COLUMN';

-- Rename column2
EXEC sp_rename 
    'PRODUCT_CATEGORY_NAME_TRANS.column2', 
    'product_category_name_english', 
    'COLUMN';

-- Delete incorrect header row
DELETE FROM PRODUCT_CATEGORY_NAME_TRANS 
WHERE product_category_name = 'product_category_name';

-- add constraints pk and fk --
-- Add primary key to customers
ALTER TABLE CUSTOMERS
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

-- Add primary key to orders
ALTER TABLE Orders
ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);

-- Add primary key to products
ALTER TABLE PRODUCTS
ADD CONSTRAINT pk_products PRIMARY KEY (product_id)

-- Add primary key to sellers
ALTER TABLE SELLERS
ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);

-- Composite PK
ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

-- Add primary key to PRODUCT_CATEGORY_NAME_TRANS 
ALTER TABLE PRODUCT_CATEGORY_NAME_TRANS
ADD CONSTRAINT PK_category_translation PRIMARY KEY (product_category_name);

-- Add primary key to order_payment
ALTER TABLE ORDER_PAYMENT
ADD CONSTRAINT PK_order_payments PRIMARY KEY (order_id, payment_sequential);

-- Add surrogate primary key
ALTER TABLE ORDER_REVIEW
ADD review_pk INT IDENTITY(1,1);

-- Set as primary key
ALTER TABLE ORDER_REVIEW
ADD CONSTRAINT pk_reviews PRIMARY KEY (review_pk);


-- Orders → Customers(fk)
ALTER TABLE Orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- Order Items → Orders(fk)
ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT fk_items_orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id);

-- -- Order Items → PRODUCTS(fk)
ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id);

-- Order Items → Sellers(fk)
ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id)
REFERENCES SELLERS(seller_id);

-- Payments → Orders(fk)
ALTER TABLE ORDER_PAYMENT
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id);

-- Reviews → Orders(fk)
ALTER TABLE ORDER_REVIEW
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id);


-- =========================================
-- Clean Orders View (for analysis)
-- =========================================
CREATE VIEW clean_orders AS
SELECT 
    order_id,
    customer_id,
    order_status,

    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    -- Delivery Time (only for delivered orders)(in days)
    CASE 
        WHEN order_delivered_customer_date IS NOT NULL 
        THEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)
        ELSE NULL
    END AS delivery_days,

    -- Delivery Delay 
    -- Negtive - early, Positive - late
    CASE 
        WHEN order_delivered_customer_date IS NOT NULL 
        THEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)
        ELSE NULL
    END AS delivery_delay

FROM Orders;

SELECT TOP 10 * FROM clean_orders

-- =========================================
-- Order Revenue View
-- Purpose:
-- Calculate total revenue per order
-- =========================================

-- =========================================
-- Order Value View (GMV)
-- We treat it as Total Order Value (GMV - Gross Merchandise Value)
-- Purpose:
-- Calculate total order value (customer paid amount)
-- =========================================

CREATE VIEW order_value AS
SELECT 
    order_id,

    -- Total amount paid by customer (price + shipping)
    SUM(price + freight_value) AS order_value

FROM ORDER_ITEMS
GROUP BY order_id;

select top 10 * from order_value 

-- =========================================
-- Final Business View
-- Purpose:
-- Combine order details + revenue
-- Ready for KPI analysis & Power BI
-- =========================================

CREATE VIEW final_orders AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,

    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    o.delivery_days,
    o.delivery_delay,

    r.order_value

FROM clean_orders o
LEFT JOIN order_value r
ON o.order_id = r.order_id;

SELECT TOP 10 * FROM final_orders;

                        -- KPIs --

-- Total Revenue (GMV)
SELECT 
    SUM(order_value) AS total_revenue
FROM final_orders;


-- Total Orders
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM final_orders;


-- Average Order Value (AOV)
SELECT 
    AVG(order_value) AS avg_order_value
FROM final_orders;

-- Average Delivery Time (days)
SELECT 
    AVG(delivery_days) AS avg_delivery_days
FROM final_orders
WHERE delivery_days IS NOT NULL;

-- Late Delivery Percentage
SELECT 
    COUNT(CASE WHEN delivery_delay > 0 THEN 1 END) * 100.0 
    / COUNT(*) AS late_delivery_percent
FROM final_orders
WHERE delivery_delay IS NOT NULL;


---------------------- Customer Analysis -------------------

-- Top 10 Customers by Total Spending
SELECT Top 10
    customer_id,
    SUM(order_value) AS total_spent
FROM final_orders
GROUP BY customer_id
ORDER BY total_spent DESC;


-- Customer Analysis (NULL handled)
SELECT Top 10
    customer_id,
    COUNT(order_id) AS total_orders,
    -- Replace NULL with 0
    SUM(ISNULL(order_value, 0)) AS total_spent,
    AVG(ISNULL(order_value, 0)) AS avg_order_value
FROM final_orders
GROUP BY customer_id
ORDER BY total_spent DESC;

-------------- Geography Analysis (using geolocation) -----------------

-- Revenue by City
SELECT Top 10
    c.customer_city,
    SUM(ISNULL(f.order_value, 0)) AS total_revenue,
    COUNT(DISTINCT f.order_id) AS total_orders

FROM final_orders f
JOIN CUSTOMERS c 
    ON f.customer_id = c.customer_id

GROUP BY c.customer_city
ORDER BY total_revenue DESC;

---------- Category-wise Revenue Analysis ----------

-- Revenue by Product Category
SELECT Top 10
    isnull(ct.product_category_name_english, 'Unknown') AS category,

    -- Total revenue per category
    SUM(oi.price + oi.freight_value) AS total_revenue,

    -- Total orders per category
    COUNT(DISTINCT oi.order_id) AS total_orders

FROM ORDER_ITEMS oi

-- Join products to get category
JOIN PRODUCTS p 
    ON oi.product_id = p.product_id

-- Join translation table for English names
LEFT JOIN PRODUCT_CATEGORY_NAME_TRANS ct
    ON p.product_category_name = ct.product_category_name

GROUP BY isnull(ct.product_category_name_english, 'Unknown')
ORDER BY total_revenue DESC;

---------- Seller Performance ----------

-- Top Sellers by Revenue
SELECT TOP 10
    oi.seller_id,

    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders

FROM ORDER_ITEMS oi

GROUP BY oi.seller_id
ORDER BY total_revenue DESC;

---------- Review vs Delivery (Power Insight) ----------

-- Review Score vs Delivery Delay
SELECT 
    r.review_score,
    COUNT(*) AS total_orders,
    AVG(f.delivery_delay) AS avg_delay
FROM ORDER_REVIEW r
JOIN final_orders f 
    ON r.order_id = f.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


-- Category Revenue View

CREATE VIEW category_revenue AS
SELECT 
    ISNULL(ct.product_category_name_english, 'Unknown') AS category,
    SUM(oi.price + oi.freight_value) AS total_revenue

FROM ORDER_ITEMS oi
JOIN PRODUCTS p 
    ON oi.product_id = p.product_id
LEFT JOIN PRODUCT_CATEGORY_NAME_TRANS ct 
    ON p.product_category_name = ct.product_category_name

GROUP BY ISNULL(ct.product_category_name_english, 'Unknown');


