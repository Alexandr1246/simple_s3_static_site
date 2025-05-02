module "route53" {
  source         = "./modules/route53"
  domain_name    = var.domain_name
  cloudfront_dns = module.cloudfront.cloudfront_domain
  zone_id        = var.zone_id  # або отримати динамічно, якщо модуль acm/route53 повертає його
}

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
