terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.99.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region = "eu-north-1"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}