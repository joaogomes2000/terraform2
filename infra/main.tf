resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# ─── Lambda Layer: utils ──────────────────────────────────────────────────────
# O ZIP já foi uploaded pelo build.sh antes do Terraform correr.
# Usamos data source para ler o etag do S3 — sem ficheiros locais.

data "aws_s3_object" "utils_layer_zip" {
  bucket = var.bucket_name
  key    = "layers/utils_layer.zip"

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_lambda_layer_version" "utils_layer" {
  s3_bucket         = var.bucket_name
  s3_key            = "layers/utils_layer.zip"
  layer_name        = "${terraform.workspace}-utils-layer"
  compatible_runtimes = ["python3.12"]
  source_code_hash  = data.aws_s3_object.utils_layer_zip.etag

  description = "Shared utils layer (logging_utils)"
}

# ─── IAM Role para a Lambda ───────────────────────────────────────────────────

resource "aws_iam_role" "lambda_role" {
  name = "${terraform.workspace}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─── Lambda Function ──────────────────────────────────────────────────────────

data "aws_s3_object" "lambda_zip" {
  bucket = var.bucket_name
  key    = "functions/lambda.zip"

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_lambda_function" "main" {
  s3_bucket        = var.bucket_name
  s3_key           = "functions/lambda.zip"
  function_name    = "${terraform.workspace}-main-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.aws_s3_object.lambda_zip.etag

  layers = [aws_lambda_layer_version.utils_layer.arn]

  environment {
    variables = {
      LOG_LEVEL = var.log_level
    }
  }
}
