# Olist E-Commerce — Sales Performance Analysis

> End-to-end SQL analytics project on 100,000+ real Brazilian e-commerce orders.  
> Built to answer real business questions — not just demonstrate SQL syntax.

![Dashboard Preview](./03%20-%20Dashboard/dashboard.png)

🔗 **[View Live Tableau Dashboard](https://public.tableau.com/app/profile/usaid.khan/viz/OlistE-CommerceSalesAnalysis/Dashboard1)**

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

| Table | Description | Rows |
|---|---|---|
| `orders` | Core fact table — status, timestamps | 99,441 |
| `order_items` | Price, freight, product per order line | 112,650 |
| `customers` | Buyer location — state, city | 99,441 |
| `products` | Category, dimensions, weight | 32,951 |
| `sellers` | Seller location and ID | 3,095 |
| `payments` | Payment type and installments | 103,886 |
| `order_reviews` | Star rating and review text | 99,224 |
| `geolocation` | Zip code to lat/lng mapping | 1,000,163 |
| `category_translation` | Portuguese to English category names | 71 |

---

## Tools Used

| Tool | Purpose |
|---|---|
| **MySQL 8.4** | All analytical queries |
| **Python + pandas + SQLAlchemy** | Loading CSVs into MySQL |
| **Tableau Public** | Interactive dashboard |
| **MySQL Workbench** | Query development and testing |

---

## SQL Concepts Demonstrated

| Concept | Used In |
|---|---|
| Multi-table JOINs (up to 4 tables) | Q1, Q2, Q3, Q10, Q11 |
| CTEs (Common Table Expressions) | Q4, Q5, Q7, Q8, Q10–Q13 |
| Window functions — `LAG()`, `RANK()` | Q8, Q9 |
| `CASE WHEN` — segmentation and flags | Q5, Q7, Q10–Q13 |
| `DATE_FORMAT`, `DATEDIFF` | Q1, Q6, Q7, Q13 |
| `COALESCE` — null handling | Q3, Q9, Q11 |
| Aggregations & Subqueries | All queries |

---

## Key Findings

### Revenue & Growth
- **R$15.4M total revenue** generated across 24 months of delivered orders.
- Revenue grew **137% from Sep 2016 to Aug 2018** — a consistent upward trend.
- **São Paulo (SP) alone generates 38% of all revenue** — heavy geographic concentration that represents both dominance and risk.

### Customer Behaviour
- Only **3.1% of customers made a repeat purchase** — pointing to a major retention problem.
- **96% of customers spend under R$500** in their lifetime. The VIP segment (>R$1,000) represents just 1,149 customers but significant revenue per head.

### Product Categories
- **Health & Beauty is the #1 revenue category at R$1.4M**, followed by Watches & Gifts and Bed & Bath.
- High-volume, low-margin categories like Furniture & Decor have strong order counts but lower average item prices, requiring a pricing strategy review.

### Delivery & Seller Performance
- **91.9% of orders were delivered on time** with an average actual delivery time of **12.5 days** (consistently beating estimates).
- A subset of sellers with 10+ orders show **late delivery rates above 30%** — these are flagged as high-risk partners.

---

## Business Recommendations

| Finding | Recommendation |
|---|---|
| **38% revenue from SP** | Diversify marketing spend into RJ, MG, and RS — high order volume states with upsell potential. |
| **3.1% repeat rate** | Invest in post-purchase email campaigns, loyalty incentives, and personalised recommendations. |
| **High-risk sellers** | Implement seller scorecards — put sellers with >30% late rates on performance improvement plans. |
| **Northern delivery delays** | Partner with regional carriers or build fulfilment capacity closer to underserved states. |

---

## Project Structure

```text
data-analytics-portfolio/
└── 02 - Olist Ecommerce Analysis/
    ├── 01 - Scripts/
    │   ├── load_data.py             ← Python script to load CSVs into MySQL
    │   └── queries.sql              ← All 13 analytical SQL queries
    ├── 02 - Data/                   
    │   ├── data_source.txt          ← Link to raw Kaggle datasets
    │   └── results/                 ← Exported query results (CSVs)
    ├── 03 - Dashboard/
    │   └── dashboard.png            ← Tableau dashboard preview
    └── README.md                    ← Project documentation
```

*Note: The original 9 CSV files (~45MB total) are not uploaded to this repo. Download them directly from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place them in the `02 - Data/` folder before running the load script.*

---

## How to Run Locally

If you wish to replicate this analysis on your local machine:

**1. Clone the main portfolio repository and navigate to this project:**
```bash
git clone [https://github.com/usaid17/data-analytics-portfolio.git](https://github.com/usaid17/data-analytics-portfolio.git)
cd data-analytics-portfolio
cd "02 - Olist Ecommerce Analysis"
```

**2. Download the dataset:**
Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place all 9 CSV files inside the `02 - Data/` folder.

**3. Install Python dependencies:**
```bash
pip install pandas sqlalchemy mysql-connector-python
```

**4. Set up MySQL & Load Data:**
Create a database called `olist` in MySQL. Update your MySQL credentials inside `01 - Scripts/load_data.py`, then run the script to populate the database:
```bash
python "01 - Scripts/load_data.py"
```

**5. Run the queries:**
Open `01 - Scripts/queries.sql` in MySQL Workbench to view and execute the analysis.

---

## About the Author

Built as a portfolio project to demonstrate real-world SQL analytical skills.  
**Author:** Usaid Khan  
**LinkedIn:** [linkedin.com/in/usaid7](https://www.linkedin.com/in/usaid7/)
