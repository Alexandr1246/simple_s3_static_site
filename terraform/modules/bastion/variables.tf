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