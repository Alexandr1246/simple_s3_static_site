variable "bucket_arn" {
  description = "ARN S3 бакета"
  type        = string
}

variable "bucket_id" {
  description = "ID S3 бакета"
  type        = string
}

variable "cloudfront_oai_arn" {
  description = "IAM ARN для CloudFront OAI"
  type        = string
}

variable "aws_account_id" {
  description = "ID AWS акаунту, використовується для політик доступу"
  type        = string
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket for CloudFront logs"
  type        = string
}

variable "log_bucket_arn" {
  description = "ARN of the S3 bucket for CloudFront logs"
  type        = string
}
