# Olist E-Commerce — Sales Performance Analysis

> End-to-end SQL analytics project on 100,000+ real Brazilian e-commerce orders.  
> Built to answer real business questions — not just demonstrate SQL syntax.

![Dashboard Preview](https://claude.ai/chat/dashboard.png)

🔗 **[View Live Tableau Dashboard](https://public.tableau.com/your-dashboard-link-here)**

---

## Business Problem

Olist is Brazil's largest e-commerce marketplace, connecting small merchants to major retail channels. With operations across 27 states and 70+ product categories, leadership needs clear answers to drive growth decisions:

- Where is revenue concentrated — and where are the growth opportunities?
- Are customers coming back, or is Olist losing them after one purchase?
- Which product categories and sellers are driving the most value?
- Is the delivery network performing — and where is it failing?

This project analyses 99,441 orders placed between September 2016 and August 2018 to answer these questions with data.

---

## Dataset

**Brazilian E-Commerce Public Dataset by Olist** — available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

A real-world, multi-table relational dataset with 9 tables and 100,000+ orders.

|Table|Description|Rows|
|---|---|---|
|`orders`|Core fact table — status, timestamps|99,441|
|`order_items`|Price, freight, product per order line|112,650|
|`customers`|Buyer location — state, city|99,441|
|`products`|Category, dimensions, weight|32,951|
|`sellers`|Seller location and ID|3,095|
|`payments`|Payment type and installments|103,886|
|`order_reviews`|Star rating and review text|99,224|
|`geolocation`|Zip code to lat/lng mapping|1,000,163|
|`category_translation`|Portuguese to English category names|71|

---

## Tools Used

|Tool|Purpose|
|---|---|
|**MySQL 8.4**|All analytical queries|
|**Python + pandas + SQLAlchemy**|Loading CSVs into MySQL|
|**Tableau Public**|Interactive dashboard|
|**MySQL Workbench**|Query development and testing|
|**PyCharm**|Project development environment|

---

## SQL Concepts Demonstrated

|Concept|Used In|
|---|---|
|Multi-table JOINs (up to 4 tables)|Q1, Q2, Q3, Q10, Q11|
|CTEs (Common Table Expressions)|Q4, Q5, Q7, Q8, Q10–Q13|
|Window functions — `LAG()`, `RANK()`|Q8, Q9|
|`CASE WHEN` — segmentation and flags|Q5, Q7, Q10–Q13|
|`DATE_FORMAT`, `DATEDIFF` — date arithmetic|Q1, Q6, Q7, Q13|
|`COALESCE` — null handling|Q3, Q9, Q11|
|Aggregations — `SUM`, `AVG`, `COUNT DISTINCT`|All queries|
|Subqueries|Q8, Q11|
|`UNION ALL`|Q9|

---

## Key Findings

### Revenue & Growth

- **R$15.4M total revenue** generated across 24 months of delivered orders
- Revenue grew **137% from Sep 2016 to Aug 2018** — consistent upward trend
- **November 2017 was the single highest revenue month**, driven by Black Friday — a clear seasonal pattern to plan for
- **São Paulo (SP) alone generates 38% of all revenue** — heavy geographic concentration that represents both dominance and risk

### Customer Behaviour

- Only **3.1% of customers made a repeat purchase** — the vast majority buy once and never return, pointing to a major retention problem
- **96% of customers spend under R$500** in their lifetime — the VIP segment (>R$1,000) represents just 1,149 customers but significant revenue per head
- The Low and Mid spend segments (under R$500) account for nearly all customers — a significant upsell opportunity exists

### Product Categories

- **Health & Beauty is the #1 revenue category at R$1.4M**, followed by Watches & Gifts (R$1.3M) and Bed & Bath (R$1.2M)
- High-volume, low-margin categories like Furniture & Decor have strong order counts but lower average item prices — pricing strategy review recommended
- The top 6 categories out of 71 account for a disproportionate share of revenue — long tail categories need attention

### Delivery Performance

- **91.9% of orders were delivered on time** — strong overall performance
- Average actual delivery time is **12.5 days** against an estimated 23.9 days — Olist consistently beats its own estimates
- However, certain northern and northeastern states show significantly higher late delivery rates — a logistics investment opportunity

### Seller Risk

- A subset of sellers with 10+ orders show **late delivery rates above 30%** — these are flagged as high-risk partners
- Seller performance is highly skewed — the top sellers by revenue dramatically outperform the bottom tier

---

## Business Recommendations

|Finding|Recommendation|
|---|---|
|38% revenue from SP|Diversify marketing spend into RJ, MG, and RS — high order volume states with upsell potential|
|3.1% repeat rate|Invest in post-purchase email campaigns, loyalty incentives, and personalised recommendations|
|96% spend under R$500|Create bundle offers and premium category promotions targeting the Mid segment|
|High-risk sellers (>30% late rate)|Implement seller scorecards — put high-risk sellers on performance improvement plans|
|Black Friday spike|Plan inventory and logistics capacity 6–8 weeks before November each year|
|Northern states delivery delays|Partner with regional carriers or build fulfilment capacity closer to underserved states|

---

## Project Structure

```
ecommerce-project/
├── data/                    ← raw Kaggle CSVs (not uploaded — see note below)
├── results/                 ← exported query results (CSV)
│   ├── monthly_revenue.csv
│   ├── revenue_by_state.csv
│   ├── revenue_by_category.csv
│   ├── customer_segments.csv
│   ├── ontime_vs_late.csv
│   └── delivery_health.csv
├── load_data.py             ← Python script to load CSVs into MySQL
├── queries.sql              ← all 13 analytical SQL queries
├── dashboard.png            ← dashboard screenshot
└── README.md
```

> **Note on raw data:** The original 9 CSV files (~45MB total) are not uploaded to this repo. Download them directly from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place them in the `data/` folder before running `load_data.py`.

---

## How to Run

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/ecommerce-project.git
cd ecommerce-project
```

### 2. Download the dataset

Download the Olist dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place all 9 CSV files in the `data/` folder.

### 3. Install Python dependencies

```bash
pip install pandas sqlalchemy mysql-connector-python
```

### 4. Set up MySQL

Create a database called `olist` in MySQL:

```sql
CREATE DATABASE olist;
```

### 5. Load the data

Update your MySQL credentials in `load_data.py`, then run:

```bash
python load_data.py
```

This loads all 9 tables into MySQL. The geolocation table (1M rows) takes ~60 seconds.

### 6. Run the queries

Open `queries.sql` in MySQL Workbench and run queries individually.  
Set session timeouts first to avoid disconnections on large queries:

```sql
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;
SET SESSION wait_timeout = 600;
```

### 7. View the dashboard

🔗 [Live Tableau Dashboard](https://public.tableau.com/app/profile/usaid.khan)

---

## About

Built as a portfolio project to demonstrate real-world SQL analytical skills.  
Dataset credit: [Olist](https://olist.com/) via [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

**Author:** Usaid Khan  
**LinkedIn:** https://www.linkedin.com/in/usaid7/
**Tools:** MySQL · Python · Tableau Public