resource "aws_launch_template" "master_lt" {
  name_prefix   = "k8s-master-"
  image_id      = "ami-04542995864e26699"
  instance_type = "t3.medium"
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.k8s_subnet.id
    security_groups             = [aws_security_group.k8s_sg.id]
  }

   block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 20
      volume_type           = "gp2"
    }
  }

  user_data = base64encode(<<-EOF
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

    # Ініціалізуємо кластер
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # Створюємо конфіг для kubectl
    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config
    chown root:root /root/.kube/config
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    
    # Створюємо join команду і зберігаємо її в Parameter Store
    kubeadm token create --print-join-command > /tmp/join.sh
    aws ssm put-parameter \
    --name "/k8s/join-command" \
    --type "String" \
    --value "$(cat /tmp/join.sh)" \
    --overwrite \
    --region eu-north-1
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s-master"
    }
  }
}

module "asg_master" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = "k8s-master-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.k8s_subnet.id]

  launch_template_id = aws_launch_template.master_lt.id
  launch_template_description = "Launch template for Kubernetes master node"
  update_default_version      = true

  ebs_optimized     = true
  enable_monitoring = true

  tags = {
    Name        = "k8s-master"
    Environment = "dev"
    Project     = "k8s-cluster"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Name        = "k8s-master"
        Environment = "dev"
        Project     = "k8s-cluster"
      }
    },
    {
      resource_type = "volume"
      tags = {
        Name        = "k8s-master"
        Environment = "dev"
        Project     = "k8s-cluster"
      }
    }
  ]
}
