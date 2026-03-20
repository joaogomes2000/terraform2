from utils.logging_utils import setup_logger

logger = setup_logger(__name__)


def lambda_handler(event, context):
    logger.info("Lambda function started")
    # Your lambda logic here
    return {
        "statusCode": 200,
        "body": "Hello from Lambda!",
    }