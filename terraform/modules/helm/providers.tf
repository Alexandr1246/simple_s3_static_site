provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # або через data.aws_ssm_parameter / remote backend
  }
}