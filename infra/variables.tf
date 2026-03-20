variable "bucket_name" {
  type = string
}

variable "utils_layer_zip_path" {
  description = "Caminho local para o ZIP da utils layer"
  type        = string
  default     = "../build/utils_layer.zip"
}

variable "lambda_zip_path" {
  description = "Caminho local para o ZIP da Lambda Function"
  type        = string
  default     = "../build/lambda.zip"
}

variable "log_level" {
  description = "Nível de log da Lambda (DEBUG, INFO, WARNING, ERROR)"
  type        = string
  default     = "INFO"
}
