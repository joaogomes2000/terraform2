resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# ─── S3: upload dos ZIPs (gerados pelo build.sh no CI) ───────────────────────

resource "aws_s3_object" "utils_layer_zip" {
  bucket = aws_s3_bucket.bucket.id
  key    = "layers/utils_layer.zip"
  source = var.utils_layer_zip_path
  etag   = filemd5(var.utils_layer_zip_path)
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.bucket.id
  key    = "functions/lambda.zip"
  source = var.lambda_zip_path
  etag   = filemd5(var.lambda_zip_path)
}

# ─── Lambda Layer: utils (logging_utils) ─────────────────────────────────────

resource "aws_lambda_layer_version" "utils_layer" {
  s3_bucket         = aws_s3_bucket.bucket.id
  s3_key            = aws_s3_object.utils_layer_zip.key
  layer_name        = "${terraform.workspace}-utils-layer"
  compatible_runtimes = ["python3.12"]
  source_code_hash  = filebase64sha256(var.utils_layer_zip_path)

  description = "Shared utils layer (logging_utils)"

  depends_on = [aws_s3_object.utils_layer_zip]
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

resource "aws_lambda_function" "main" {
  s3_bucket        = aws_s3_bucket.bucket.id
  s3_key           = aws_s3_object.lambda_zip.key
  function_name    = "${terraform.workspace}-main-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  layers = [aws_lambda_layer_version.utils_layer.arn]

  environment {
    variables = {
      LOG_LEVEL = var.log_level
    }
  }

  depends_on = [aws_s3_object.lambda_zip]
}
