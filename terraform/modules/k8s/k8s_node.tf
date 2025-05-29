
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
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

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

    
    while ! aws ssm get-parameter --name "/k8s/join-command" --region eu-north-1 >/dev/null 2>&1; do
    echo "Waiting for /k8s/join-command to become available..."
    sleep 5
    done

    aws ssm get-parameter \
      --name "/k8s/join-command" \
      --with-decryption \
      --query "Parameter.Value" \
      --output text \
      --region eu-north-1 \
      > /tmp/k8s_join_command.sh

    # Додаємо шебанг на початок
    sed -i '1i#!/bin/bash' /tmp/k8s_join_command.sh
    chmod +x /tmp/k8s_join_command.sh

    # Лічильник спроб
    ATTEMPTS=0
    MAX_ATTEMPTS=3

    until sudo bash /tmp/k8s_join_command.sh; do
    ATTEMPTS=$((ATTEMPTS+1))
    echo "Join failed, retrying in 10s... (attempt $ATTEMPTS/$MAX_ATTEMPTS)"
    if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
    echo "Join failed after $MAX_ATTEMPTS attempts. Exiting."
    exit 1
    fi
    sleep 10
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
