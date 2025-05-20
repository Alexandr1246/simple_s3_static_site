output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain
  description = "Доменне ім'я CloudFront Distribution"
}

output "cloudfront_oai_arn" {
  value = module.cloudfront.oai_arn
  description = "ARN Origin Access Identity для CloudFront"
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

output "k8s_node_public_ip" {
  value = module.ec2.k8s_node_public_ip
}

output "worker_private_ip" {
  value = module.ec2.worker_private_ip
}

output "private_key_pem" {
  value     = module.ec2.private_key_pem
  sensitive = true
}
