module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name    = "eks-self-managed"
  cluster_version = "1.31"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_addons = {
    coredns                = {}
    vpc-cni                = {}
    kube-proxy             = {}
    eks-pod-identity-agent = {}
  }

  self_managed_node_groups = {
    self_mng_1 = {
      instance_type = "t3.medium"
      desired_size  = 1
      min_size      = 1
      max_size      = 2
    }

    self_mng_2 = {
      instance_type = "t3.medium"
      desired_size  = 1
      min_size      = 1
      max_size      = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
