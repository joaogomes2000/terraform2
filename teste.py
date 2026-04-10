# glue_copy_table.py
import sys
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("CopyIcebergTable") \
    .config("spark.jars.packages",
            "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.5.0,"
            "software.amazon.awssdk:bundle:2.20.18,"
            "org.apache.hadoop:hadoop-aws:3.3.4") \
    .config("spark.sql.extensions",
            "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.sql.catalog.glue_catalog.warehouse", "s3://fame-iceberg-data/iceberg-tables/") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.DefaultAWSCredentialsProviderChain") \
    .getOrCreate()

spark.sql("""
    INSERT INTO glue_catalog.fame_vehicles_db.fame_vehicles_new
    SELECT * FROM glue_catalog.fame_vehicles_db.fame_vehicles
""")

print("Done!")