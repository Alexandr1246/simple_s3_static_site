output "name_servers" {
  value = data.aws_route53_zone.main.name_servers
}

output "zone_id" {
  description = "Route53 Zone ID"
  value       = data.aws_route53_zone.main.zone_id
}