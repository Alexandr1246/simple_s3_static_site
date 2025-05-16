variable "log_bucket_name" {
  type        = string
  description = "Назва бакета для логів CloudFront"
}

variable "environment" {
  description = "Назва середовища (наприклад: dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "aws_account_id" {
  description = "ID AWS акаунту, використовується для політик доступу"
  type        = string
}

variable "log_bucket_arn" {
  description = "ARN of the S3 bucket for CloudFront logs"
  type        = string
}
