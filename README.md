# Event-Driven Retail Sales Data Engineering Platform on AWS

![AWS](https://img.shields.io/badge/AWS-Cloud_Platform-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![PySpark](https://img.shields.io/badge/PySpark-3.5-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![AWS Glue](https://img.shields.io/badge/AWS_Glue-Serverless_ETL-blueviolet?style=for-the-badge&logo=amazonaws&logoColor=white)
![AWS Step Functions](https://img.shields.io/badge/Step_Functions-Workflow_Orchestration-FF4F8B?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon Redshift](https://img.shields.io/badge/Amazon_Redshift-Cloud_Data_Warehouse-red?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon Athena](https://img.shields.io/badge/Amazon_Athena-Serverless_SQL-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)

An enterprise-grade, **event-driven retail data engineering pipeline** deployed on AWS. The platform automates daily ERP/POS transaction ingestion, orchestrates serverless workflows, validates data quality, performs distributed PySpark transformations, catalogs metadata, models a star schema in Amazon Redshift, and delivers BI-ready datasets.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Enterprise Architecture](#-enterprise-architecture)
- [End-to-End Pipeline Workflow](#-end-to-end-pipeline-workflow)
- [Technology Stack](#-technology-stack)
- [Data Lake & S3 Layout](#-data-lake--s3-layout)
- [Data Quality & ETL Engine (AWS Glue)](#-data-quality--etl-engine-aws-glue)
- [Data Warehouse Modeling (Amazon Redshift)](#-data-warehouse-modeling-amazon-redshift)
- [Repository Structure](#-repository-structure)
- [Step-by-Step Deployment Guide](#-step-by-step-deployment-guide)
  - [Prerequisites](#prerequisites)
  - [Step 1: Environment & Secrets Setup](#step-1-environment--secrets-setup)
  - [Step 2: Generate & Ingest Raw Data](#step-2-generate--ingest-raw-data)
  - [Step 3: Orchestrate with Step Functions](#step-3-orchestrate-with-step-functions)
  - [Step 4: Query via Athena & Redshift](#step-4-query-via-athena--redshift)
- [SQL Analytics & Business Views](#-sql-analytics--business-views)
- [Monitoring & Alerting](#-monitoring--alerting)
- [Author & Contact](#-author--contact)

---

## 🚀 Project Overview

Modern retail enterprises generate millions of Point-of-Sale (POS) and ERP transactions across hundreds of stores daily. Common challenges include:
- **Late-arriving or duplicate files** causing inaccurate revenue figures.
- **Corrupt, negative, or missing values** degrading warehouse reporting.
- **Uncoordinated pipelines** failing without immediate alert mechanisms.
- **High operational costs** from scanning full raw files instead of partitioned delta files.

### The Solution:
This project delivers a **100% automated, serverless, event-driven data platform** that:
1. **Listens** for daily ERP batch arrivals via S3 ObjectCreated events.
2. **Triggers** an AWS Lambda function to validate filenames and invoke AWS Step Functions.
3. **Orchestrates** AWS Glue PySpark jobs with dynamic retry logic and error boundaries.
4. **Isolates** bad records to an S3 Rejected quarantine zone while writing valid records into partitioned Snappy Parquet.
5. **Catalogs** partitions automatically via AWS Glue Crawlers.
6. **Loads & Merges** dimensional data into Amazon Redshift Serverless via an idempotent star schema.
7. **Notifies** data engineering teams via Amazon SNS in the event of pipeline failures.

---

## 🏗️ Enterprise Architecture

```text
               ERP / POS DAILY SALES CSV FILE
                             │
                             ▼
               ┌───────────────────────────┐
               │     Amazon S3 (Raw)       │  ◄── s3://sameer-retail-sales-pipeline/raw/sales/
               └─────────────┬─────────────┘
                             │  ObjectCreated Event
                             ▼
               ┌───────────────────────────┐
               │        AWS Lambda         │  ◄── Validates filename & payload
               └─────────────┬─────────────┘
                             │  states:StartExecution
                             ▼
               ┌───────────────────────────┐
               │    AWS Step Functions     │  ◄── End-to-End Orchestrator
               └─────────────┬─────────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
   [ AWS Glue PySpark ETL ]            [ Failure Catch ]
    • Schema casting & validation             │
    • Deduplication via Window specs          ▼
    • Joins Product & Store masters     [ Amazon SNS ]
    • Splits Valid vs Invalid                 │
            │                                 ▼
     ┌──────┴──────┐                   Email / SMS Alert
     ▼             ▼
┌───────────┐ ┌───────────┐
│S3 Curated │ │S3 Rejected│ (Quarantine audit log)
│  Parquet  │ └───────────┘
└─────┬─────┘
      │
      ▼
┌───────────────────────────┐
│   AWS Glue Data Catalog   │  ◄── Automated Crawler Partition Discovery
└─────┬───────────────┬─────┘
      │               │
      ▼               ▼
┌───────────┐   ┌───────────────────────────┐
│  Amazon   │   │  Amazon Redshift (DW)     │
│  Athena   │   │  • Staging Table          │
│(Serverless│   │  • Star Schema Modeling   │
│   SQL)    │   │  • Incremental Merge      │
└───────────┘   └─────────────┬─────────────┘
                              │
                              ▼
                     [ Amazon QuickSight ]
                     Executive BI Dashboard
```

---

## 🛠️ Technology Stack

| Service / Tool | Role in Platform | Key Value |
|---|---|---|
| **Amazon S3** | Cloud Storage / Data Lake | Scalable storage across Raw, Curated, and Rejected tiers |
| **AWS Lambda** | Event Trigger | Microsecond event ingestion without provisioned compute |
| **AWS Step Functions** | Workflow Orchestration | Visual state machine with automated retries and error handling |
| **AWS Glue (PySpark)** | Serverless ETL Engine | Distributed in-memory data cleaning, joins, and Parquet generation |
| **AWS Glue Data Catalog** | Metadata Repository | Centralized schema registry for Athena and Redshift Spectrum |
| **Amazon Athena** | Interactive Query Engine | Serverless ad-hoc ANSI SQL queries directly on S3 Parquet |
| **Amazon Redshift** | Cloud Data Warehouse | MPP analytical database running Star Schema dimensional analytics |
| **Amazon SNS** | Notification Service | Real-time email/SMS alerts on pipeline failure |
| **Amazon CloudWatch** | Observability | Centralized execution logging, metrics, and audit trails |

---

## 🗄️ Data Lake & S3 Layout

The data lake enforces strict domain partitioning:

```text
s3://sameer-retail-sales-pipeline/
├── raw/
│   ├── products/
│   │   └── products.csv             # Product master catalog
│   ├── stores/
│   │   └── stores.csv               # Store location master
│   └── sales/
│       └── sales_YYYY_MM_DD.csv     # Daily transactional batch
│
├── curated/
│   └── sales/
│       └── transaction_date=YYYY-MM-DD/
│           └── *.snappy.parquet     # Cleaned, enriched, partitioned Parquet
│
└── rejected/
    └── sales/
        └── transaction_date=YYYY-MM-DD/
            └── *.csv                # Quarantined invalid records for audit
```

---

## 🧹 Data Quality & ETL Engine (AWS Glue)

The PySpark script ([glue/retail_sales_pyspark_etl.py](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/glue/retail_sales_pyspark_etl.py)) executes enterprise quality gates:

1. **Schema Standardization:**
   - Casts `transaction_date` to `DateType`.
   - Casts `quantity` to `IntegerType`, `unit_price` and `cost_price` to `DoubleType`.
2. **Quality Validation Rule:**
   $$\text{Valid} \iff (\text{IDs} \neq \text{Null}) \land (\text{quantity} > 0) \land (\text{unit\_price} > 0)$$
3. **Deduplication:**
   - Window partition over `transaction_id` ordering by `transaction_date DESC` ensures only the latest unique record enters the warehouse.
4. **Master Enrichment:**
   - Left joins `products` master to retrieve `category`, `brand`, and `cost_price`.
   - Left joins `stores` master to enrich with `city`, `state`, and `region`.
5. **Business Metric Derivations:**
   $$\text{Revenue} = \text{quantity} \times \text{unit\_price}$$
   $$\text{Profit} = (\text{unit\_price} - \text{cost\_price}) \times \text{quantity}$$

---

## 🏛️ Data Warehouse Modeling (Amazon Redshift)

The warehouse ([redshift/](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/redshift/)) implements a production **Star Schema** optimized for high-performance aggregations:

```
                      +-------------------+
                      |    dim_product    |
                      +-------------------+
                      | product_id (PK)   |
                      | product_name      |
                      | category          |
                      | brand             |
                      | cost_price        |
                      +---------+---------+
                                |
                                | 1:N
                                v
+------------------+     +------+------------+     +------------------+
|    dim_store     |     |    fact_sales     |     |     dim_date     |
+------------------+     +-------------------+     +------------------+
| store_id (PK)    |     | sale_id (PK)      |     | date_key (PK)    |
| store_name       |◄────| transaction_id    |────►| full_date        |
| city             | 1:N | store_id (FK)     | 1:N | day_of_week      |
| state            |     | product_id (FK)   |     | month, quarter   |
| region           |     | customer_id       |     | year             |
+------------------+     | date_key (FK)     |     +------------------+
                         | quantity          |
                         | unit_price        |
                         | revenue           |
                         | profit            |
                         +-------------------+
```

### Incremental Merge Strategy
To prevent double-counting upon re-running daily loads:
1. Load partition into `sales_stage_raw`.
2. Delete matching `transaction_id`s in `fact_sales` that exist in staging:
   ```sql
   DELETE FROM retail_dw.fact_sales
   USING retail_dw.sales_stage
   WHERE fact_sales.transaction_id = sales_stage.transaction_id;
   ```
3. Insert all records from staging into `fact_sales`.

---

## 📂 Repository Structure

```
retail-sales-data-engineering/
│
├── Athena/                                         # Athena Serverless SQL Analytics
│   ├── 01_verify_catalog.sql                       # Verifies Glue catalog tables
│   ├── 02_basic_exploration.sql                    # Initial data exploration
│   ├── 03_data_quality_checks.sql                  # Automated data quality assertions
│   ├── 04_daily_sales_analysis.sql                 # Daily revenue and volume metrics
│   ├── 05_product_performance.sql                  # Product-level profitability
│   ├── 06_store_state_performance.sql              # Store and regional KPIs
│   ├── 07_payment_method_analysis.sql              # Payment distribution
│   ├── 09_customer_analysis.sql                    # Customer purchasing patterns
│   ├── 10_revenue_profit_analysis.sql              # Gross margin calculations
│   ├── 11_analytics_views.sql                      # Reusable analytical views
│   └── 12_incremental_partition_check.sql          # Partition discovery verification
│
├── config/
│   └── project_config.json                         # Centralized AWS resource definitions
│
├── data/
│   └── raw/                                        # Local sample datasets
│       ├── products/products.csv
│       ├── stores/stores.csv
│       └── sales/sales_2026_09_25.csv
│
├── glue/
│   └── retail_sales_pyspark_etl.py                 # AWS Glue PySpark ETL script
│
├── lambda/
│   └── retail_s3_ingestion_trigger.py              # S3-to-Step-Functions trigger function
│
├── redshift/                                       # Redshift Star Schema DDL & DML
│   ├── 01_create_schema.sql                        # Schema definition
│   ├── 02_create_staging_tables.sql                # Staging DDL
│   ├── 03_load_staging_data.sql                    # S3 COPY commands
│   ├── 04_create_dimensions.sql                    # Dimension tables DDL
│   ├── 05_load_dimensions.sql                      # Dimension population logic
│   ├── 06_create_fact_sales.sql                    # Fact table DDL
│   ├── 07_merge_incremental_sales.sql              # Idempotent incremental merge
│   ├── 08_data_quality_checks.sql                  # Referential integrity checks
│   ├── 09_analytics_views.sql                      # Business reporting views
│   └── 10_verify_incremental_load.sql              # Verification tests
│
├── scripts/
│   ├── generate_sample_data.py                     # Synthetic data generator
│   └── upload_to_s3.py                             # S3 automated ingestion script
│
├── step-functions/
│   └── retail_daily_sales_pipeline.json            # Step Functions State Machine definition
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## ⚡ Step-by-Step Deployment Guide

### Prerequisites
- AWS Account with S3, Lambda, Step Functions, Glue, Athena, and Redshift access.
- Python 3.8+ & AWS CLI configured (`aws configure`).

### Step 1: Configure Resource Identifiers
Review and adapt [config/project_config.json](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/config/project_config.json):
```json
{
  "aws_region": "us-east-1",
  "s3_bucket": "sameer-retail-sales-pipeline"
}
```

### Step 2: Generate & Ingest Raw Data
```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Generate synthetic master & transactional datasets
python scripts/generate_sample_data.py

# 3. Upload raw CSV files to Amazon S3
python scripts/upload_to_s3.py
```

### Step 3: Orchestrate with AWS Step Functions
1. Create the AWS Glue Job `retail-sales-pyspark-etl` using [glue/retail_sales_pyspark_etl.py](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/glue/retail_sales_pyspark_etl.py).
2. Deploy the AWS Lambda function using [lambda/retail_s3_ingestion_trigger.py](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/lambda/retail_s3_ingestion_trigger.py).
3. Create the Step Functions State Machine with [step-functions/retail_daily_sales_pipeline.json](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/step-functions/retail_daily_sales_pipeline.json).
4. Configure S3 Event Notification on `raw/sales/` prefix to invoke the Lambda function.

### Step 4: Query via Athena & Redshift
Execute analytical queries directly in Athena or Redshift query editor:
- **Athena:** Execute queries from `Athena/04_daily_sales_analysis.sql`
- **Redshift:** Execute scripts `01` through `07` in `redshift/` to populate warehouse marts.

---

## 📊 SQL Analytics & Business Views

Sample analytical query from [Athena/05_product_performance.sql](file:///C:/Users/Sameer%20Khan/OneDrive/Desktop/AWS%20TUTORIAL/retail-sales-data-engineering-main/Athena/05_product_performance.sql):

```sql
SELECT 
    product_name,
    category,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(revenue)) * 100, 2) AS profit_margin_pct
FROM retail_curated_db.sales
GROUP BY product_name, category
ORDER BY total_revenue DESC;
```

---

## 🔔 Monitoring & Alerting

- **Amazon CloudWatch:** Comprehensive execution logging for Lambda and Glue jobs.
- **AWS Step Functions:** Real-time visual monitoring of pipeline stage completions and retries.
- **Amazon SNS:** Automatic high-priority notifications sent to data engineers upon pipeline failures.

---

## 👨‍💻 Author & Contact

**Sameer Khan**  
*Data Engineer*  

- **GitHub:** [@sk-sameer20](https://github.com/sk-sameer20)  
- **LinkedIn:** [Sameer Khan](https://www.linkedin.com/)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
