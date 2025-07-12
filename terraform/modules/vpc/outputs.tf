output "vpc_id" {
  description = "VPC ID"
  value       = module.eks_vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.eks_vpc.private_subnets
}

