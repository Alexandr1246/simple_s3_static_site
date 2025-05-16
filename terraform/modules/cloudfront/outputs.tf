output "cloudfront_domain" {
  value = aws_cloudfront_distribution.static_site_distribution.domain_name
  description = "Доменне ім'я CloudFront Distribution"
}

output "oai_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
  description = "ARN Origin Access Identity для CloudFront"
}

output "cloudfront_hosted_zone_id" {
  value       = aws_cloudfront_distribution.static_site_distribution.hosted_zone_id
  description = "Hosted zone ID для CloudFront"
}

