provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet"
  }
}

resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "k8s-route-table"
  }
}

resource "aws_route_table_association" "k8s_route_table_assoc" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-ssh-sg"
  description = "Allow SSH and Kubernetes internal traffic"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all traffic within the K8s cluster"
    from_port   = 0           
    to_port     = 0          
    protocol    = "-1"       
    self        = true 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-ssh-sg"
  }
}

resource "aws_instance" "k8s_master_node" {
  ami                         = "ami-04542995864e26699" 
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.k8s_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y snapd
              sudo snap install amazon-ssm-agent --classic
              sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

              echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
              sudo sysctl -p

              sudo swapoff -a
              sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

              sudo ufw disable || true 
              sudo systemctl stop firewalld || true
              sudo systemctl disable firewalld || true
              EOF

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker_node" {
  ami                         = "ami-04542995864e26699" 
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.k8s_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y snapd
              sudo snap install amazon-ssm-agent --classic
              sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

              echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
              sudo sysctl -p

              sudo swapoff -a
              sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

              sudo ufw disable || true 
              sudo systemctl stop firewalld || true
              sudo systemctl disable firewalld || true
              EOF

  tags = {
    Name = "k8s-worker"
  }
}
