output "vpc_id" {
  value = module.vpc.vpc_id 
  description = "ID VPC for eks or k8s"
}

output "private_subnets" {
  value = module.vpc.private_subnets
  description = "ID private_subnets for eks or k8s"
}

