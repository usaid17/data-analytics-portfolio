-- ================================================================
-- Project  : E-Commerce Sales Performance Analysis
-- Dataset  : Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- Database : MySQL 8.4.8
-- Author   : Usaid Khan
-- ================================================================


USE olist;

-- ================================================================
-- Q1: Monthly Revenue Over Time
-- Concepts : JOIN, DATE_FORMAT, GROUP BY, ORDER BY
-- Question : How has total revenue trended month by month?
-- ================================================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)        AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;


-- ================================================================
-- Q2: Revenue by Customer State
-- Concepts : 3-table JOIN, GROUP BY, ORDER BY DESC
-- Question : Which Brazilian states generate the most revenue?
-- ================================================================

SELECT
    c.customer_state                               AS state,
    COUNT(DISTINCT o.order_id)                     AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)     AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2)     AS avg_item_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ================================================================
-- Q3: Revenue by Product Category
-- Concepts : 4-table JOIN, COALESCE for null handling, LIMIT
-- Question : Which product categories drive the most revenue?
-- ================================================================

SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;
SET SESSION wait_timeout = 600;

SELECT
    COALESCE(ct.product_category_name_english,
             p.product_category_name,
             'Unknown')                             AS category,
    COUNT(DISTINCT o.order_id)                      AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)      AS total_revenue,
    ROUND(AVG(oi.price), 2)                         AS avg_item_price
FROM orders o
JOIN order_items oi   ON o.order_id = oi.order_id
JOIN products p       ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
                      ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 15;


-- ================================================================
-- Q4: Customer Repeat Purchase Rate
-- Concepts : CTEs, CASE WHEN inside SUM, calculated fields
-- Question : What percentage of customers made more than one purchase?
-- ================================================================

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
repeat_buyers AS (
    SELECT
        COUNT(*) AS total_customers,
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers
    FROM customer_order_counts
)
SELECT
    total_customers,
    repeat_customers,
    ROUND((repeat_customers / total_customers) * 100, 2) AS repeat_rate_pct
FROM repeat_buyers;


-- ================================================================
-- Q5: Customer Segmentation by Lifetime Spend
-- Concepts : CTE, CASE WHEN bucketing, GROUP BY segment
-- Question : How are customers distributed across spending tiers?
-- ================================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS lifetime_spend,
        COUNT(DISTINCT o.order_id)                  AS total_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN lifetime_spend < 100                THEN '1 - Low (< R$100)'
        WHEN lifetime_spend BETWEEN 100 AND 500  THEN '2 - Mid (R$100-500)'
        WHEN lifetime_spend BETWEEN 500 AND 1000 THEN '3 - High (R$500-1000)'
        ELSE                                          '4 - VIP (> R$1000)'
    END                           AS customer_segment,
    COUNT(*)                      AS total_customers,
    ROUND(AVG(lifetime_spend), 2) AS avg_spend,
    ROUND(AVG(total_orders), 2)   AS avg_orders
FROM customer_spending
GROUP BY customer_segment
ORDER BY customer_segment;


-- ================================================================
-- Q6: Average Delivery Time by State
-- Concepts : DATEDIFF, AVG, 3-table JOIN, GROUP BY, ORDER BY
-- Question : Which states have the fastest and slowest deliveries?
-- ================================================================

SELECT
    c.customer_state                                        AS state,
    COUNT(DISTINCT o.order_id)                              AS total_orders,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp)), 1)                    AS avg_delivery_days,
    ROUND(AVG(DATEDIFF(
        o.order_estimated_delivery_date,
        o.order_purchase_timestamp)), 1)                    AS avg_estimated_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC;


-- ================================================================
-- Q7: On-Time vs Late Delivery Rate
-- Concepts : CASE WHEN classification, percentage calculation, CTE
-- Question : What percentage of orders were delivered late?
-- ================================================================

WITH delivery_status AS (
    SELECT
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On-Time'
            ELSE 'Late'
        END AS delivery_result
    FROM orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    delivery_result,
    COUNT(*)                                    AS total_orders,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2)               AS percentage
FROM delivery_status
GROUP BY delivery_result
ORDER BY delivery_result;



-- ================================================================
-- Q8: Month-over-Month Revenue Growth
-- Concepts : Window function LAG(), CTE, growth % calculation
-- Question : How did revenue grow or shrink month over month?
-- ================================================================


WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2)       AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month)  AS prev_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        / LAG(total_revenue) OVER (ORDER BY order_month) * 100
    , 2)                                             AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;


-- ================================================================
-- Q9: Top and Bottom Performing Categories
-- Concepts : CTEs, RANK() window function, UNION ALL
-- Question : Which categories are the best and worst performers?
-- ================================================================

WITH category_revenue AS (
    SELECT
        COALESCE(ct.product_category_name_english,
                 p.product_category_name, 'Unknown') AS category,
        COUNT(DISTINCT o.order_id)                    AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2)    AS total_revenue,
        ROUND(AVG(oi.price), 2)                       AS avg_item_price
    FROM orders o
    JOIN order_items oi  ON o.order_id = oi.order_id
    JOIN products p      ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
                         ON p.product_category_name = ct.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY category
),
ranked_categories AS (
    SELECT *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY total_revenue ASC)  AS bottom_rank
    FROM category_revenue
)
-- Top 5 categories
SELECT category, total_orders, total_revenue, avg_item_price,
       revenue_rank AS rank_position, 'Top 5' AS category_tier
FROM ranked_categories
WHERE revenue_rank <= 5

UNION ALL

-- Bottom 5 categories
SELECT category, total_orders, total_revenue, avg_item_price,
       bottom_rank AS rank_position, 'Bottom 5' AS category_tier
FROM ranked_categories
WHERE bottom_rank <= 5

ORDER BY category_tier, rank_position;


-- ================================================================
-- Extra: Seller Performance Tiers using NTILE
-- Concepts : Window function NTILE(), performance bucketing
-- Question : How do sellers distribute across performance tiers?
-- ================================================================


WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)                AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
        ROUND(AVG(oi.price), 2)                    AS avg_item_price
    FROM order_items oi
    JOIN orders o  ON oi.order_id = o.order_id
    JOIN sellers s ON oi.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id, s.seller_state
),
tiered_sellers AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS performance_tier
    FROM seller_metrics
)
SELECT
    CASE performance_tier
        WHEN 1 THEN 'Tier 1 - Top 25%'
        WHEN 2 THEN 'Tier 2 - Upper Mid 25%'
        WHEN 3 THEN 'Tier 3 - Lower Mid 25%'
        WHEN 4 THEN 'Tier 4 - Bottom 25%'
    END                           AS seller_tier,
    COUNT(*)                      AS total_sellers,
    ROUND(AVG(total_revenue), 2)  AS avg_revenue,
    ROUND(AVG(total_orders), 2)   AS avg_orders,
    ROUND(AVG(avg_item_price), 2) AS avg_item_price
FROM tiered_sellers
GROUP BY performance_tier
ORDER BY performance_tier;


-- ================================================================
-- Q10: Which States Should Marketing Focus On?
-- Concepts : CTE, calculated fields, business segmentation
-- Question : Find states with high order volume but low revenue
--            (upsell opportunity — lots of buyers, low spend)
-- ================================================================

WITH state_metrics AS (
    SELECT
        c.customer_state                                AS state,
        COUNT(DISTINCT o.order_id)                      AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2)      AS total_revenue,
        ROUND(AVG(oi.price + oi.freight_value), 2)      AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT
    state,
    total_orders,
    total_revenue,
    avg_order_value,
    CASE
        WHEN total_orders >= 1000 AND avg_order_value < 100
        THEN 'High Priority — many buyers, low spend'
        WHEN total_orders >= 1000 AND avg_order_value >= 100
        THEN 'Strong Market — protect and grow'
        WHEN total_orders < 1000 AND avg_order_value >= 150
        THEN 'Emerging — high value, low volume'
        ELSE 'Low Priority'
    END AS marketing_priority
FROM state_metrics
ORDER BY total_orders DESC;


-- ================================================================
-- Q11: Which Product Categories Need Improvement?
-- Concepts : CTE, RANK(), business flags
-- Question : Find categories with high order volume but low avg price
--            (high demand but low margin — needs pricing strategy)
-- ================================================================

WITH category_metrics AS (
    SELECT
        COALESCE(ct.product_category_name_english,
                 p.product_category_name, 'Unknown')    AS category,
        COUNT(DISTINCT o.order_id)                      AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2)      AS total_revenue,
        ROUND(AVG(oi.price), 2)                         AS avg_item_price
    FROM orders o
    JOIN order_items oi  ON o.order_id = oi.order_id
    JOIN products p      ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
                         ON p.product_category_name = ct.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY category
)
SELECT
    category,
    total_orders,
    total_revenue,
    avg_item_price,
    CASE
        WHEN total_orders > 500 AND avg_item_price < 50
        THEN 'High volume, low margin — review pricing'
        WHEN total_orders > 500 AND avg_item_price >= 50
        THEN 'Strong category — maintain'
        WHEN total_orders <= 500 AND avg_item_price < 50
        THEN 'Weak category — consider dropping'
        ELSE 'Niche — high value, low volume'
    END AS category_flag
FROM category_metrics
ORDER BY total_orders DESC
LIMIT 20;


-- ================================================================
-- Q12: Which Sellers Are Risky Partners?
-- Concepts : CTE, CASE WHEN, late delivery rate per seller
-- Question : Which sellers have high late delivery rates?
--            (risk flag for partnership review)
-- ================================================================


WITH seller_delivery AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT o.order_id)  AS total_orders,
        SUM(CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END)                        AS late_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    total_orders,
    late_orders,
    ROUND((late_orders / total_orders) * 100, 2)    AS late_rate_pct,
    CASE
        WHEN (late_orders / total_orders) * 100 >= 30
        THEN 'High Risk — review partnership'
        WHEN (late_orders / total_orders) * 100 BETWEEN 15 AND 29
        THEN 'Medium Risk — monitor closely'
        ELSE 'Low Risk — good partner'
    END AS risk_flag
FROM seller_delivery
WHERE total_orders >= 10        -- ignore sellers with very few orders
ORDER BY late_rate_pct DESC
LIMIT 30;


-- ================================================================
-- Q13: How Can Delivery Delays Be Reduced?
-- Concepts : CTE, DATEDIFF, AVG, state-level diagnosis
-- Question : Which states have the worst delivery performance
--            and how far off are estimates?
-- ================================================================

WITH delivery_analysis AS (
    SELECT
        c.customer_state                                        AS state,
        COUNT(DISTINCT o.order_id)                              AS total_orders,
        ROUND(AVG(DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp)), 1)                    AS avg_actual_days,
        ROUND(AVG(DATEDIFF(
            o.order_estimated_delivery_date,
            o.order_purchase_timestamp)), 1)                    AS avg_estimated_days,
        ROUND(AVG(DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date)), 1)               AS avg_delay_days,
        SUM(CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END)                                                    AS late_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
    GROUP BY c.customer_state
)
SELECT
    state,
    total_orders,
    avg_actual_days,
    avg_estimated_days,
    avg_delay_days,
    ROUND((late_orders / total_orders) * 100, 2)    AS late_rate_pct,
    CASE
        WHEN avg_delay_days > 5  THEN 'Critical — major delay issue'
        WHEN avg_delay_days > 0  THEN 'Needs attention — consistently late'
        ELSE                          'On track — meeting estimates'
    END AS delivery_health
FROM delivery_analysis
ORDER BY avg_delay_days DESC;