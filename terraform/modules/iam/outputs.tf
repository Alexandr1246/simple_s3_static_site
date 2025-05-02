output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_role_name" {
  description = "Name of the created GitHub OIDC IAM Role"
  value       = aws_iam_role.github_oidc_role.name
}

