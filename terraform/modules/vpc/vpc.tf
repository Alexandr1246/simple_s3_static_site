module "eks_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "esk_self_manage_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}