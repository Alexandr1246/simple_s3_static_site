
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami_id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  associate_public_ip_address = true

  tags = {
    Name        = "bastion-host"
    SSMManaged  = "true"
  }
}
