import json
import logging
import re
import urllib.parse

import boto3
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(logging.INFO)

sfn = boto3.client("stepfunctions")

STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]
def create_execution_name(file_name: str) -> str:
    """
    Convert an ERP file name into a valid Step Functions execution name.

    Example:
    sales_2026_09_22.csv
    ->
    sales_2026_09_22_csv
    """

    execution_name = re.sub(
        r"[^A-Za-z0-9_-]",
        "_",
        file_name
    )

    return execution_name[:80]


def lambda_handler(event, context):

    logger.info("Received S3 event")
    logger.info(json.dumps(event))

    for record in event.get("Records", []):

        bucket_name = record["s3"]["bucket"]["name"]

        object_key = urllib.parse.unquote_plus(
            record["s3"]["object"]["key"],
            encoding="utf-8"
        )

        file_name = object_key.split("/")[-1]

        logger.info(f"Bucket: {bucket_name}")
        logger.info(f"Object key: {object_key}")
        logger.info(f"File name: {file_name}")

        # Only process ERP sales CSV files
        if not (
            object_key.startswith("raw/sales/")
            and object_key.lower().endswith(".csv")
        ):
            logger.info("File ignored")
            continue

        execution_name = create_execution_name(file_name)

        input_data = {
            "bucket": bucket_name,
            "key": object_key,
            "file_name": file_name
        }

        logger.info(
            f"Execution name: {execution_name}"
        )

        try:

            response = sfn.start_execution(
                stateMachineArn=STATE_MACHINE_ARN,
                name=execution_name,
                input=json.dumps(input_data)
            )

            logger.info(
                "Step Functions execution started: "
                f"{response['executionArn']}"
            )

        except ClientError as error:

            error_code = error.response["Error"]["Code"]

            if error_code == "ExecutionAlreadyExists":

                logger.warning(
                    f"Duplicate file detected: {file_name}. "
                    "Step Functions execution already exists."
                )

            else:

                logger.exception(
                    "Failed to start Step Functions execution"
                )

                raise

    return {
        "statusCode": 200,
        "message": "S3 event processed"
    }