output "k8s_node_public_ip" {
  value = module.ec2.k8s_node_public_ip
}

output "worker_private_ip" {
  value = module.ec2.worker_private_ip
}

output "private_key_pem" {
  value = module.ec2.private_key_pem
}