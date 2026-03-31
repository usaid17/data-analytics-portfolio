___

This folder contains exported outputs from the SQL queries in `queries.sql`.  
All results are filtered to **delivered orders only** unless stated otherwise.  
Currency is in **Brazilian Real (R$)**.

---

## Files

### `monthly_revenue.csv`

Monthly revenue trend from Sep 2016 to Aug 2018.  
Columns: `order_month`, `total_orders`, `total_revenue`

> Revenue grew 137% over the period with a sharp peak in Nov 2017 (Black Friday).

---

### `revenue_by_state.csv`

Total revenue and order count broken down by customer state (all 27 Brazilian states).  
Columns: `state`, `total_orders`, `total_revenue`, `avg_item_value`

> São Paulo (SP) alone accounts for 38% of all revenue.

---

### `revenue_by_category.csv`

Revenue performance across all 71 product categories, sorted by total revenue.  
Columns: `category`, `total_orders`, `total_revenue`, `avg_item_price`

> Health & Beauty is the #1 category at R$1.4M.

---

### `repeat_purchase_rate.csv`

Overall repeat purchase rate across all customers.  
Columns: `total_customers`, `repeat_customers`, `repeat_rate_pct`

> Only 3.1% of customers made more than one purchase — a major retention gap.

---

### `customer_segments.csv`

Customers grouped into 4 spending tiers based on lifetime spend.  
Columns: `customer_segment`, `total_customers`, `avg_spend`, `avg_orders`

> 96% of customers fall below R$500 lifetime spend.

---

### `delivery_by_state.csv`

Average actual vs estimated delivery days by state.  
Columns: `state`, `total_orders`, `avg_delivery_days`, `avg_estimated_days`

> Olist consistently delivers faster than its own estimates (12.5d actual vs 23.9d estimated).

---

### `ontime_vs_late.csv`

Share of orders delivered on time vs late across the entire network.  
Columns: `delivery_result`, `total_orders`, `percentage`

> 91.9% of orders were delivered on time.

---

### `marketing_priority.csv`

States segmented by order volume and average order value to identify marketing opportunities.  
Columns: `state`, `total_orders`, `total_revenue`, `avg_order_value`, `marketing_priority`

> Flags high-volume, low-spend states as upsell targets.

---

### `delivery_health.csv`

State-level delivery health diagnosis including avg delay days and late rate percentage.  
Columns: `state`, `total_orders`, `avg_actual_days`, `avg_estimated_days`, `avg_delay_days`, `late_rate_pct`, `delivery_health`

> Identifies states with critical delivery issues for logistics investment.