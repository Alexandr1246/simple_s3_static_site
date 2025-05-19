output "k8s_node_public_ip" {
  value = aws_instance.k8s_node.public_ip
}

output "worker_private_ip" {
  description = "Private IP address of the worker node"
  value       = aws_instance.k8s_worker.private_ip
}