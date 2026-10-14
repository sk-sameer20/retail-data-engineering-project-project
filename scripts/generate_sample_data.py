import os
import csv
import random
from datetime import datetime, timedelta

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data", "raw")

PRODUCTS_DIR = os.path.join(DATA_DIR, "products")
STORES_DIR = os.path.join(DATA_DIR, "stores")
SALES_DIR = os.path.join(DATA_DIR, "sales")

os.makedirs(PRODUCTS_DIR, exist_ok=True)
os.makedirs(STORES_DIR, exist_ok=True)
os.makedirs(SALES_DIR, exist_ok=True)

# -------------------------------------------------------------
# 1. Generate Products Master Data
# -------------------------------------------------------------
products = [
    ("P101", "Smartphone Pro 5G", "Electronics", "Apple", 650.00),
    ("P102", "Wireless Noise-Canceling Headphones", "Electronics", "Sony", 180.00),
    ("P103", "4K Ultra HD Smart TV", "Electronics", "Samsung", 420.00),
    ("P104", "Mechanical Gaming Keyboard", "Accessories", "Logitech", 75.00),
    ("P105", "Ergonomic Office Chair", "Furniture", "Herman Miller", 250.00),
    ("P106", "Stainless Steel Water Bottle", "Home & Kitchen", "Hydro Flask", 18.00),
    ("P107", "Running Shoes Nitro", "Apparel", "Nike", 65.00),
    ("P108", "Smart Fitness Tracker", "Electronics", "Fitbit", 95.00),
    ("P109", "Organic Arabica Coffee Beans 1kg", "Grocery", "Lavazza", 12.00),
    ("P110", "USB-C Fast Charging Hub", "Accessories", "Anker", 25.00),
]

products_file = os.path.join(PRODUCTS_DIR, "products.csv")
with open(products_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["product_id", "product_name", "category", "brand", "cost_price"])
    writer.writerows(products)
print(f"[OK] Generated {len(products)} products: {products_file}")

# -------------------------------------------------------------
# 2. Generate Stores Master Data
# -------------------------------------------------------------
stores = [
    ("S001", "Downtown Flagship Store", "New York", "NY", "East"),
    ("S002", "Silicon Valley Express", "San Jose", "CA", "West"),
    ("S003", "Metro Center Outlet", "Chicago", "IL", "Midwest"),
    ("S004", "Lone Star Supercenter", "Dallas", "TX", "South"),
    ("S005", "Pacific Retail Hub", "Seattle", "WA", "West"),
    ("S006", "Sunshine Plaza Store", "Miami", "FL", "South"),
]

stores_file = os.path.join(STORES_DIR, "stores.csv")
with open(stores_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["store_id", "store_name", "city", "state", "region"])
    writer.writerows(stores)
print(f"[OK] Generated {len(stores)} stores: {stores_file}")

# -------------------------------------------------------------
# 3. Generate Daily ERP Sales Transactions
# -------------------------------------------------------------
payment_methods = ["Credit Card", "Debit Card", "UPI", "Cash", "Gift Card"]
target_date = "2026-09-25"

sales_rows = []
for i in range(1, 501):
    tx_id = f"TXN_{target_date.replace('-', '')}_{i:05d}"
    store = random.choice(stores)[0]
    prod = random.choice(products)
    prod_id = prod[0]
    cost = prod[4]
    
    # Unit price with markup (20% to 50%)
    unit_price = round(cost * random.uniform(1.20, 1.50), 2)
    quantity = random.randint(1, 5)
    cust_id = f"CUST_{random.randint(1001, 1250)}"
    pay_method = random.choice(payment_methods)
    
    sales_rows.append([
        tx_id,
        target_date,
        store,
        prod_id,
        cust_id,
        quantity,
        unit_price,
        pay_method
    ])

# Introduce 2 invalid records to test data-quality / rejected records branch
sales_rows.append(["TXN_ERR_0001", target_date, "S001", "P101", "CUST_9999", -1, 100.00, "Credit Card"])  # negative quantity
sales_rows.append(["TXN_ERR_0002", target_date, "S002", "P102", "CUST_9998", 2, 0.00, "Cash"])           # zero price

sales_file = os.path.join(SALES_DIR, f"sales_{target_date.replace('-', '_')}.csv")
with open(sales_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "transaction_id",
        "transaction_date",
        "store_id",
        "product_id",
        "customer_id",
        "quantity",
        "unit_price",
        "payment_method"
    ])
    writer.writerows(sales_rows)
print(f"[OK] Generated {len(sales_rows)} sales records: {sales_file}")
