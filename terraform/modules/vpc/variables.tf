variable "vpc_id" {}

data "eks_vpc" "selected" {
  id = var.vpc_id
}