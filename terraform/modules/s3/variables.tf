variable "bucket_name" {
  description = "Унікальна назва S3 бакета для статичного сайту"
  type        = string
}

variable "environment" {
  description = "Назва середовища (наприклад: dev, staging, prod)"
  type        = string
  default     = "production"
}