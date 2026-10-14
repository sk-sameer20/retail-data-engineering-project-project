import os
import json
import boto3
from pathlib import Path

# Load project config
CONFIG_PATH = Path(__file__).resolve().parent.parent / "config" / "project_config.json"
with open(CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

BUCKET_NAME = config.get("s3_bucket", "sameer-retail-sales-pipeline")
REGION = config.get("aws_region", "us-east-1")

s3 = boto3.client("s3", region_name=REGION)

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

FILES_TO_UPLOAD = [
    (RAW_DIR / "products" / "products.csv", "raw/products/products.csv"),
    (RAW_DIR / "stores" / "stores.csv", "raw/stores/stores.csv"),
    (RAW_DIR / "sales" / "sales_2026_09_25.csv", "raw/sales/sales_2026_09_25.csv"),
]

def main():
    print(f"Target Bucket: s3://{BUCKET_NAME} (Region: {REGION})")
    
    # Check or create bucket if needed
    try:
        s3.head_bucket(Bucket=BUCKET_NAME)
        print(f"[OK] Bucket {BUCKET_NAME} exists.")
    except Exception:
        print(f"Bucket {BUCKET_NAME} not found. Attempting creation...")
        try:
            if REGION == "us-east-1":
                s3.create_bucket(Bucket=BUCKET_NAME)
            else:
                s3.create_bucket(
                    Bucket=BUCKET_NAME,
                    CreateBucketConfiguration={"LocationConstraint": REGION}
                )
            print(f"[OK] Bucket {BUCKET_NAME} created successfully.")
        except Exception as e:
            print(f"Error creating bucket: {e}")
            return

    for local_path, s3_key in FILES_TO_UPLOAD:
        if local_path.exists():
            print(f"Uploading {local_path.name} -> s3://{BUCKET_NAME}/{s3_key}...")
            s3.upload_file(str(local_path), BUCKET_NAME, s3_key)
            print(f"[OK] Uploaded {s3_key}")
        else:
            print(f"[WARN] Local file {local_path} not found. Run generate_sample_data.py first.")

    print("\nAll raw files uploaded successfully!")

if __name__ == "__main__":
    main()
