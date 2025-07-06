module "eks_self_managed_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "= 20.36.1"

  cluster_name    = "eks_self_managed_cluster"
  cluster_version = "1.31"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  self_managed_node_groups = {
    example = {
      ami_type      = "AL2_x86_64"
      instance_type = "t3.medium"

      min_size = 1
      max_size = 1
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2
    }
  }

  tags = {
    name = "eks_k8s_cluster"
    environment = "dev" 
  }
}