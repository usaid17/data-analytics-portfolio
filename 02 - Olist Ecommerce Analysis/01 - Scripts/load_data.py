import pandas as pd
from sqlalchemy import create_engine
import os

MYSQL_USER     = "root"
MYSQL_PASSWORD = "Souluk456"   # your actual password
MYSQL_HOST     = "localhost"
MYSQL_DB       = "olist"

engine = create_engine(
    f"mysql+mysqlconnector://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DB}"
)

csv_files = {
    "olist_orders_dataset.csv":               "orders",
    "olist_order_items_dataset.csv":          "order_items",
    "olist_customers_dataset.csv":            "customers",
    "olist_products_dataset.csv":             "products",
    "olist_sellers_dataset.csv":              "sellers",
    "olist_order_payments_dataset.csv":       "payments",
    "olist_order_reviews_dataset.csv":        "order_reviews",
    "olist_geolocation_dataset.csv":          "geolocation",
    "product_category_name_translation.csv":  "category_translation",
}

data_folder = "data"

for filename, table_name in csv_files.items():
    filepath = os.path.join(data_folder, filename)
    df = pd.read_csv(filepath)

    # chunksize=10000 breaks large tables into batches of 10,000 rows
    # this prevents MySQL from timing out on big inserts like geolocation
    df.to_sql(table_name, con=engine, if_exists="replace", index=False, chunksize=10000)
    print(f"✓  {table_name:30s} {len(df):>7,} rows")

print("\nAll done — olist database is ready in MySQL!")