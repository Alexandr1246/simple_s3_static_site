variable "bucket_name" {
  type    = string
  default = "simple-site-20253004"
}

variable "log_bucket_name" {
  type    = string
  default = "logs-itstep-project-20250505"
}

variable "domain_name" {
  description = "Основне ім'я домену"
  type        = string
  default     = "itstep-project.online"
}

variable "subject_alternative_names" {
  description = "Додаткові доменні імена для сертифіката"
  type        = list(string)
  default     = ["www.itstep-project.online"]
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-east-1" # для ACM у CloudFront
}

#variable "zone_id" {
#  type = string
#або передай через Terraform Cloud/TFVARS
#}

variable "aws_account_id" {
  description = "ID AWS акаунту, використовується для політик доступу"
  type        = string
  default     = "050451395507"
}

variable "cloudfront_oai_arn" {
  description = "CloudFront Origin Access Identity ARN"
  default     = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity/E25ZYR4CVUHJBN"
}

variable "cloudfront_hosted_zone_id" {
  description = "Hosted Zone ID для CloudFront (опційно)"
  type        = string
  default     = "Z2FDTNDATAQYW2"
}

variable "ssh_key_name" {
  description = "Name of the existing EC2 Key Pair to use for SSH"
  type        = string
  default     = "kuber-key-ec2"
}

variable "ami_id" {
  description = "AMI ID для bastion EC2"
  type        = string
}

variable "instance_type" {
  description = "Тип EC2 інстансу"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID ami образу"
  type        = string
  default = "ami-0abcdef1234567890"
}

variable "subnet_id" {
  description = "ID приватної сабнети для bastion"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID для bastion"
  type        = string
}

variable "security_group_id" {
  type = list(string)
}