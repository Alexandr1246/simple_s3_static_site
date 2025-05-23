output "acm_arn" {
  value = aws_acm_certificate.cert.arn
}

output "certificate_status" {
  value = aws_acm_certificate.cert.status
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}

output "acm_certificate_validation_arn" {
  value = aws_acm_certificate_validation.cert_validation.id
}