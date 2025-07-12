variable "vpc_id" {
  description = "The VPC ID for the EKS cluster"
  type        = string
  default = module.eks_vpc.vpc_id
}

variable "subnet_ids" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
  default  = module.eks_vpc.private_subnets
}