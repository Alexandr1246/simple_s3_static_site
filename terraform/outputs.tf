output "cloudfront_distribution_domain_name" {
  value = module.cloudfront.cloudfront_domain
}

output "name_servers" {
  value = module.route53.name_servers
}

output "certificate_arn" {
  value = module.acm.acm_arn
}

output "certificate_status" {
  value = module.acm.certificate_status
}

output "certificate_domain_validation_options" {
  value = module.acm.domain_validation_options
}
