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