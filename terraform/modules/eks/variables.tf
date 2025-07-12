variable "vpc_id" {
  description = "The VPC ID for the EKS cluster"
  type        = string
  
}

variable "subnet_ids" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
}