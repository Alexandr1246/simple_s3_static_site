module "eks_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "esk_self_manage_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}