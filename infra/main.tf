resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# ─── Lambda Layer: utils (logging_utils) ────────────────────────────────────

resource "aws_lambda_layer_version" "utils_layer" {
  filename            = var.utils_layer_zip_path
  layer_name          = "${terraform.workspace}-utils-layer"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = filebase64sha256(var.utils_layer_zip_path)

  description = "Shared utils layer (logging_utils)"
}

# ─── IAM Role for Lambda ─────────────────────────────────────────────────────

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

# ─── Lambda Function ─────────────────────────────────────────────────────────

resource "aws_lambda_function" "main" {
  filename         = var.lambda_zip_path
  function_name    = "${terraform.workspace}-main-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  layers = [aws_lambda_layer_version.utils_layer.arn]

  environment {
    variables = {
      LOG_LEVEL = var.LOG_LEVEL
    }
  }
}
