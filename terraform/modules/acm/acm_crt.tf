resource "aws_acm_certificate" "cert" {
  domain_name       = "itstep-project.online"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.itstep-project.online"
  ]

  tags = {
    Environment = "production"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

provider "aws" {
  alias  = "us_east_1"
  region = var.region
}