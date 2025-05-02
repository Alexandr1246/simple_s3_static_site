output "certificate_arn" {
  description = "ARN виданого сертифіката"
  value       = aws_acm_certificate.cert.arn
}

output "certificate_domain_name" {
  description = "Основне ім'я домену сертифіката"
  value       = aws_acm_certificate.cert.domain_name
}