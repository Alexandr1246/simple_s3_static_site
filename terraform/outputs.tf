output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.static_site_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}
output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "certificate_arn" {
  description = "ARN of the ACM SSL Certificate"
  value       = aws_acm_certificate.cert.arn
}

output "certificate_status" {
  description = "Status of the ACM Certificate"
  value       = aws_acm_certificate.cert.status
}

output "certificate_domain_validation_options" {
  description = "Domain validation information for the certificate"
  value       = aws_acm_certificate.cert.domain_validation_options
}