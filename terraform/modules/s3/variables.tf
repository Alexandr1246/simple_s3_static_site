variable "bucket_name" {
  description = "Унікальна назва S3 бакета для статичного сайту"
  type        = string
}

variable "logs_bucket_name" {
  description = "Ім'я S3 бакета для зберігання логів CloudFront"
  type        = string
}


variable "environment" {
  description = "Назва середовища (наприклад: dev, staging, prod)"
  type        = string
  default     = "production"
}