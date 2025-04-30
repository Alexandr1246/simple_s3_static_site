output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.static_site_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}
