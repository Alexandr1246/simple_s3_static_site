module "pet_vpc" {
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

resource "aws_security_group" "pet_sg" {
  name        = "k8s-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = module.pet_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API Server"
  }

  ingress {
    from_port   = 8285
    to_port     = 8285
    protocol    = "udp"
    cidr_blocks = [module.pet_vpc.vpc_cidr_block]
    description = "Flannel VXLAN UDP port"
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [module.pet_vpc.vpc_cidr_block]
    description = "Flannel VXLAN UDP port (alternative)"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [module.pet_vpc.vpc_cidr_block]
    description = "NodePort traffic"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort traffic from internet"
  }

  ingress {
    description = "Inter-node and kubelet access"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "k8s-sg"
  }
}
