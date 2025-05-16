variable "bucket_name" {
  type    = string
  default = "simple-site-20253004"
}

variable "log_bucket_name" {
  type    = string
  default = "logs-itstep-project-20250505"
}

variable "domain_name" {
  description = "Основне ім'я домену"
  type        = string
  default     = "itstep-project.online"
}

variable "subject_alternative_names" {
  description = "Додаткові доменні імена для сертифіката"
  type        = list(string)
  default     = ["www.itstep-project.online"]
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-east-1" # для ACM у CloudFront
}

#variable "zone_id" {
#  type = string
  #або передай через Terraform Cloud/TFVARS
#}

variable "aws_account_id" {
  description = "ID AWS акаунту, використовується для політик доступу"
  type        = string
  default     = "050451395507"
}

variable "cloudfront_oai_arn" {
  description = "CloudFront Origin Access Identity ARN"
  default     = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity/E25ZYR4CVUHJBN"
}

variable "cloudfront_hosted_zone_id" {
  description = "Hosted Zone ID для CloudFront (опційно)"
  type        = string
  default     = "Z2FDTNDATAQYW2"
}

variable "log_bucket_arn" {
  description = "ARN of the S3 bucket for CloudFront logs"
  type        = string
}


