
module "asg_worker" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = "k8s-worker-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.k8s_subnet.id]
  security_groups           = [aws_security_group.k8s_sg.id]

  launch_template_name        = "k8s-worker-lt"
  launch_template_description = "Launch template for Kubernetes worker nodes"
  update_default_version      = true

  image_id          = "ami-04542995864e26699"
  instance_type     = "t3.medium"
  ebs_optimized     = true
  enable_monitoring = true
  key_name          = var.ssh_key_name

  create_iam_instance_profile = false
  iam_instance_profile_name   = aws_iam_instance_profile.ssm_instance_profile.name


  user_data = base64encode(<<-EOF
    #!/bin/bash
    # install ssm-agent
    sudo apt update -y
    sudo apt install -y snapd
    sudo snap install amazon-ssm-agent --classic
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

    # prepare for kubernetes
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    sudo ufw disable || true 
    sudo systemctl stop firewalld || true
    sudo systemctl disable firewalld || true

    # install containerd
    sudo apt update -y
    sudo apt install -y containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # install kubernetes
    sudo apt-get update -y 
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
    
    set -e

    # Отримуємо join команду з Parameter Store
    JOIN_COMMAND=$(aws ssm get-parameter \
    --name "/k8s/join-command" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region eu-north-1)

    # Долучаємося до кластеру
    $JOIN_COMMAND
    
    EOF
  )

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }
  ]

  tags = {
    Name        = "k8s-worker"
    Environment = "dev"
    Project     = "k8s-cluster"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Name        = "k8s-worker"
        Environment = "dev"
        Project     = "k8s-cluster"
      }
    },
    {
      resource_type = "volume"
      tags = {
        Name        = "k8s-worker"
        Environment = "dev"
        Project     = "k8s-cluster"
      }
    }
  ]
}
