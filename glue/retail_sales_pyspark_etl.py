import sys

from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window


# ---------------------------------------------------------
# 1. Read job arguments
# ---------------------------------------------------------

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "SOURCE_BUCKET",
        "SOURCE_KEY",
        "PRODUCTS_KEY",
        "STORES_KEY",
        "CURATED_PATH",
        "REJECTED_PATH"
    ]
)


# ---------------------------------------------------------
# 2. Start Spark
# ---------------------------------------------------------

spark = SparkSession.builder \
    .appName(args["JOB_NAME"]) \
    .getOrCreate()


# ---------------------------------------------------------
# 3. Build S3 paths
# ---------------------------------------------------------

bucket = args["SOURCE_BUCKET"]

sales_path = f"s3://{bucket}/{args['SOURCE_KEY']}"
products_path = f"s3://{bucket}/{args['PRODUCTS_KEY']}"
stores_path = f"s3://{bucket}/{args['STORES_KEY']}"

curated_path = args["CURATED_PATH"]
rejected_path = args["REJECTED_PATH"]


print("Sales source:", sales_path)
print("Products source:", products_path)
print("Stores source:", stores_path)


# ---------------------------------------------------------
# 4. Read daily sales file
# ---------------------------------------------------------

sales_df = (
    spark.read
    .option("header", "true")
    .option("inferSchema", "true")
    .csv(sales_path)
)


# ---------------------------------------------------------
# 5. Read master/reference data
# ---------------------------------------------------------

products_df = (
    spark.read
    .option("header", "true")
    .option("inferSchema", "true")
    .csv(products_path)
)

stores_df = (
    spark.read
    .option("header", "true")
    .option("inferSchema", "true")
    .csv(stores_path)
)


# ---------------------------------------------------------
# 6. Standardize column types
# ---------------------------------------------------------

sales_df = (
    sales_df
    .withColumn(
        "transaction_date",
        F.to_date("transaction_date")
    )
    .withColumn(
        "quantity",
        F.col("quantity").cast("int")
    )
    .withColumn(
        "unit_price",
        F.col("unit_price").cast("double")
    )
)


products_df = products_df.withColumn(
    "cost_price",
    F.col("cost_price").cast("double")
)


# ---------------------------------------------------------
# 7. Data quality validation
# ---------------------------------------------------------

valid_condition = (
    F.col("transaction_id").isNotNull()
    & F.col("transaction_date").isNotNull()
    & F.col("store_id").isNotNull()
    & F.col("product_id").isNotNull()
    & (F.col("quantity") > 0)
    & (F.col("unit_price") > 0)
)


valid_df = sales_df.filter(valid_condition)

rejected_df = sales_df.filter(~valid_condition)


# ---------------------------------------------------------
# 8. Remove duplicate transactions
# ---------------------------------------------------------

window_spec = Window.partitionBy(
    "transaction_id"
).orderBy(
    F.col("transaction_date").desc()
)

valid_df = (
    valid_df
    .withColumn(
        "row_num",
        F.row_number().over(window_spec)
    )
    .filter(
        F.col("row_num") == 1
    )
    .drop("row_num")
)


# ---------------------------------------------------------
# 9. Join product master
# ---------------------------------------------------------

sales_products_df = valid_df.join(
    products_df,
    on="product_id",
    how="left"
)


# ---------------------------------------------------------
# 10. Join store master
# ---------------------------------------------------------

final_df = sales_products_df.join(
    stores_df,
    on="store_id",
    how="left"
)


# ---------------------------------------------------------
# 11. Calculate business metrics
# ---------------------------------------------------------

final_df = final_df.withColumn(
    "revenue",
    F.round(
        F.col("quantity") * F.col("unit_price"),
        2
    )
)

final_df = final_df.withColumn(
    "profit",
    F.round(
        (
            F.col("unit_price")
            - F.col("cost_price")
        ) * F.col("quantity"),
        2
    )
)


# ---------------------------------------------------------
# 12. Add processing metadata
# ---------------------------------------------------------

final_df = final_df.withColumn(
    "processed_timestamp",
    F.current_timestamp()
)


# ---------------------------------------------------------
# 13. Write rejected records
# ---------------------------------------------------------

if rejected_df.limit(1).count() > 0:

    rejected_df.write \
        .mode("append") \
        .option("header", "true") \
        .csv(rejected_path)


# ---------------------------------------------------------
# 14. Write curated Parquet
# ---------------------------------------------------------

(
    final_df
    .write
    .mode("append")
    .partitionBy("transaction_date")
    .parquet(curated_path)
)


print("ETL completed successfully.")

print("Valid records:", valid_df.count())
print("Rejected records:", rejected_df.count())


spark.stop()