output "cloudfront_domain" {
  value = aws_cloudfront_distribution.static_site_distribution.domain_name
}

output "oai_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
}
