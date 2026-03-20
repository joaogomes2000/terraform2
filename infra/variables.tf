variable "bucket_name" {
  type        = string
  description = "Nome do bucket S3 (usado também para guardar os ZIPs)"
}

variable "log_level" {
  description = "Nível de log da Lambda (DEBUG, INFO, WARNING, ERROR)"
  type        = string
  default     = "INFO"
}
