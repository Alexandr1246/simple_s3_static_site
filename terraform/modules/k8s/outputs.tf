output "k8s_node_public_ip_master" {
  value = aws_instance.k8s_master_node.public_ip
}

output "k8s_node_public_ip_worker" {
  value = aws_instance.k8s_worker_node.public_ip
}

output "worker_instance_ids" {
  description = "EC2 Instance IDs of the worker nodes"
  value       = module.asg_worker.autoscaling_group_instances[*].instance_id
}

output "master_instance_ids" {
  description = "EC2 Instance IDs of the master node"
  value       = module.asg_master.autoscaling_group_instances[*].instance_id
}