output "k8s_node_public_ip" {
  value = aws_instance.k8s_master_node.public_ip
}

output "worker_private_ip" {
  description = "Private IP address of the worker node"
  value       = aws_instance.k8s_worker_node.private_ip
}

output "private_key_pem" {
  value     = tls_private_key.k8s_key.private_key_pem
  sensitive = true
}