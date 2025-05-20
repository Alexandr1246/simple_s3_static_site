output "k8s_node_public_ip" {
  value = aws_instance.k8s_master_node.public_ip
}

output "worker_private_ip" {
  value = aws_instance.k8s_worker_node.private_ip
}
