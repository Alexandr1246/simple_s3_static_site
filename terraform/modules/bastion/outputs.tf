output "instance_id" {
  value = aws_instance.bastion.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.bastion_profile.name
}

output "security_group_id" {
  value = aws_security_group.bastion_sg.id
}
