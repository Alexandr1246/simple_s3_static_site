output "acm_arn" {
  value = aws_acm_certificate.cert.arn
}

output "certificate_status" {
  value = aws_acm_certificate.cert.status
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}
