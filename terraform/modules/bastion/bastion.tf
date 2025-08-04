resource "aws_instance" "bastion" {
  ami                     = var.bastion_ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_ids[0]
  vpc_security_group_ids  = [var.security_group_id]

  iam_instance_profile    = aws_iam_instance_profile.bastion_profile.name

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    exec > /var/log/bastion-setup.log 2>&1
    set -x

    echo "[INFO] Updating system packages..."
    apt-get update -y

    echo "[INFO] Installing socat and awscli..."
    apt-get install -y socat awscli

    echo "[INFO] Fetching EKS cluster endpoint..."
    ENDPOINT=$(aws eks describe-cluster --name eks-self-managed --region eu-north-1 --query "cluster.endpoint" --output text | sed 's~https://~~')

    echo "[INFO] Starting socat to forward port 443 to EKS API endpoint $ENDPOINT"
    sudo nohup socat TCP-LISTEN:443,reuseaddr,fork TCP:[$ENDPOINT]:443 > ~/socat.log 2>&1 &
    EOF


  tags = {
    Name        = "bastion-host"
    SSMManaged  = "true"
  }
}
