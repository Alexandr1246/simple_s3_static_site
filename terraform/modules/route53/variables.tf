variable "domain_name" {
  description = "Основне доменне ім’я для сайту (наприклад, itstep-project.online)"
  type        = string
}

variable "cloudfront_dns" {
  description = "Доменне ім’я CloudFront, яке буде використовуватись у DNS записах"
  type        = string
}

variable "zone_id" {
  description = "ID hosted zone в Route 53"
  type        = string
}
