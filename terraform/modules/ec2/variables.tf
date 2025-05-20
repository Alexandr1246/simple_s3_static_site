variable "ssh_key_name" {
  description = "Name of the existing EC2 Key Pair to use for SSH"
  type        = string
  default = "kuber-key-ec2"
}
