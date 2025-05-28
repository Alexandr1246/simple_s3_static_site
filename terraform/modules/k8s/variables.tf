variable "ssh_key_name" {
  description = "Name of the existing EC2 Key Pair to use for SSH"
  type        = string
  default     = "kuber-key-ec2"
}

variable "aws_account_id" {
  description = "ID AWS акаунту, використовується для політик доступу"
  type        = string
  default     = "050451395507"
}