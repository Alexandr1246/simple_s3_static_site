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
    # echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    # Enable bridge networking
    modprobe br_netfilter
    echo 'br_netfilter' > /etc/modules-load.d/br_netfilter.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/99-kubernetes-cri.conf
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/99-kubernetes-cri.conf
    echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/99-kubernetes-cri.conf
    sysctl --system

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

    apt update -y
    apt install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    systemctl enable --now kubelet

    # Initialize master node
    kubeadm init --pod-network-cidr=10.244.0.0/16

    #mkdir -p /root/.kube
    #cp -i /etc/kubernetes/admin.conf /root/.kube/config
    #chown root:root /root/.kube/config

    export KUBECONFIG=/etc/kubernetes/admin.conf

    KUBECONFIG_B64=$(base64 /etc/kubernetes/admin.conf | tr -d '\n')

    # Install Flannel network
    sudo kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

    MAX_RETRIES=20
    RETRY_INTERVAL=10
    ATTEMPT=0

    echo "Waiting for master node to become Ready..."

    until sudo kubectl get nodes --no-headers | awk '$2 == "Ready" && $3 == "control-plane" { found=1 } END { exit !found }'; do
    ATTEMPT=$((ATTEMPT+1))
    echo "[$ATTEMPT/$MAX_RETRIES] Master node not Ready yet..."
      if [ "$ATTEMPT" -ge "$MAX_RETRIES" ]; then
        echo "Master node did not become Ready in time. Exiting."
      exit 1
      fi
    sleep $RETRY_INTERVAL
    done

    echo "Master node is Ready. Creating join command..."
    JOIN_CMD=$(kubeadm token create --print-join-command)
    
    aws ssm put-parameter \
      --name "/k8s/join-command" \
      --type "String" \
      --value "$JOIN_CMD" \
      --overwrite \
      --region eu-north-1
    
    aws ssm put-parameter \
      --name "/k8s/kubeconfig" \
      --type "SecureString" \
      --value "$KUBECONFIG_B64" \
      --overwrite \
      --region eu-north-1

    #sudo kubectl run testpod --image=nginx --port=80 --restart=Never --dry-run=client -o yaml > ~/testpod.yaml
    #sudo mv ~/testpod.yaml /etc/kubernetes/manifests/testpod.yaml
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