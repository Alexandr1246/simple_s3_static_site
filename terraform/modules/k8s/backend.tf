terraform {
  backend "s3" {
    bucket  = "terraform-state-0205"    # назва бакету
    key     = "k8s-terraform/state.tfstate" # шлях до файлу стану в бакеті
    region  = "eu-north-1"              # регіон бакету
    encrypt = true                      # шифрування стану
  }
}