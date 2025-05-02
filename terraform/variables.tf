variable "bucket_name" {
  type        = string
  default     = "simple-site-20253004"
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

variable "zone_id" {
  type = string
  # або передай через Terraform Cloud/TFVARS
}




