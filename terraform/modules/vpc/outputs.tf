output "vpc_id" {
  description = "VPC ID"
  value       = module.pet_vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.pet_vpc.private_subnets
}

