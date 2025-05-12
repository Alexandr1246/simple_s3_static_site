variable "domain_name" {
  type        = string
  description = "Primary domain name"
}

variable "zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain name"
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront distribution hosted zone ID"
}
