
module "asg_worker" {
  version = "8.1.0"
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = "k8s-worker-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnet_ids
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

    # prepare for kubernetes
    # echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    # Enable IP forwarding
    modprobe br_netfilter
    echo 'br_netfilter' > /etc/modules-load.d/br_netfilter.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/99-kubernetes-cri.conf
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/99-kubernetes-cri.conf
    echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/99-kubernetes-cri.conf
    sysctl --system

    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    ufw disable || true
    systemctl stop firewalld || true
    systemctl disable firewalld || true

    # install containerd
    apt update -y
    apt install -y containerd
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    #Install aws cli 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    sudo apt install -y unzip
    sudo unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install

    # install kubernetes
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    systemctl enable --now kubelet

    
      echo "Waiting for /k8s/join-command to become available in Parameter Store..."
    while ! aws ssm get-parameter --name "/k8s/join-command" --region eu-north-1 >/dev/null 2>&1; do
      echo "Waiting for /k8s/join-command to become available..."
      sleep 10
    done

    MAX_RETRIES=20
    RETRY_INTERVAL=15
    ATTEMPT=0

    while true; do
      echo "Fetching join command from SSM..."
    timeout 10s aws ssm get-parameter \
      --name "/k8s/join-command" \
      --with-decryption \
      --query "Parameter.Value" \
      --output text \
      --region eu-north-1 > /tmp/k8s_join_command.sh

    sed -i '1i#!/bin/bash' /tmp/k8s_join_command.sh
    chmod +x /tmp/k8s_join_command.sh

      echo "Attempting to join the Kubernetes cluster..."
    if timeout 30s sudo bash /tmp/k8s_join_command.sh; then
      echo "Successfully joined the cluster."
    break
    fi

    ATTEMPT=$((ATTEMPT + 1))
    if [ "$ATTEMPT" -ge "$MAX_RETRIES" ]; then
      echo "Failed to join after $MAX_RETRIES attempts."
    exit 1
    fi

      echo "Join attempt failed. Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
    done

    EOF
  )

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
