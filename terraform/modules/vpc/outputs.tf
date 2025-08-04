output "vpc_id" {
  description = "VPC ID"
  value       = module.pet_vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.pet_vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.pet_vpc.public_subnets
}

output "security_group_id" {
  description = "Security group ID for Kubernetes nodes"
  value       = aws_security_group.pet_sg.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.pet_vpc.vpc_cidr_block
}