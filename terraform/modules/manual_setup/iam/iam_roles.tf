resource "aws_iam_role" "github_oidc_role" {
  name = "github-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:*"
          }
        }
      }
    ]
  })
}


resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role_policy" "github_oidc_role_policy" {
  name = "github-oidc-role-policy"
  role = aws_iam_role.github_oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "cloudfront:*",
          "acm:RequestCertificate",
          "acm:AddTagsToCertificate",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate",
          "route53:*"
        ],
        Resource = "*"
      }
    ]
  })
}


