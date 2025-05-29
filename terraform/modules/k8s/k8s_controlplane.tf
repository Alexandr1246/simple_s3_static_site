module "asg_master" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = "k8s-master-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.k8s_subnet.id]
  security_groups           = [aws_security_group.k8s_sg.id]

  image_id      = "ami-04542995864e26699"
  instance_type = "t3.medium"
  key_name      = var.ssh_key_name

  create_iam_instance_profile = false
  iam_instance_profile_name   = aws_iam_instance_profile.ssm_instance_profile.name

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
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    LOG_FILE="/var/log/user_data.log"
    exec > >(tee -a "$LOG_FILE") 2>&1

    # Install updates and dependencies
    apt update -y

    #Install aws cli 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    sudo apt install -y unzip
    sudo unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install

    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

    # Disable swap
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # Disable firewalls
    ufw disable || true
    systemctl stop firewalld || true
    systemctl disable firewalld || true

    # Install containerd
    apt install -y containerd
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    # Add Kubernetes repo
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

    apt update
    apt install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    systemctl enable --now kubelet

    # Initialize master node
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # Setup kubectl for root
    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config
    chown root:root /root/.kube/config

    # Install Flannel network
    sudo kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

    # Store join command in Parameter Store
    JOIN_CMD=$(kubeadm token create --print-join-command)
    aws ssm put-parameter \
      --name "/k8s/join-command" \
      --type "String" \
      --value "$JOIN_CMD" \
      --overwrite \
      --region eu-north-1
    EOF
  )

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