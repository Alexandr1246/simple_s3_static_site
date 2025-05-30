variable "domain_name" {
  description = "Основний домен"
  type        = string
}

variable "subject_alternative_names" {
  description = "Альтернативні імена домену"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Регіон (має бути us-east-1 для CloudFront)"
  type        = string
}

variable "zone_id" {
  description = "ID Route53 Hosted Zone для DNS‑валідації"
  type        = string
}