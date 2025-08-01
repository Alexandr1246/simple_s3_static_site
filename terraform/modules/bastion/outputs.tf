output "instance_id" {
  value = aws_instance.bastion.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.bastion_profile.name
}

