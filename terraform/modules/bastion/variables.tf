variable "vpc_id" {
  type = string
}

variable "bastion_ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_name" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
  default = null
}

variable "allowed_security_groups" {
  type = list(string)
  default = []
}

variable "security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the Bastion host"
  type        = list(string)
}