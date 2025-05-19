resource "aws_iam_role" "github_oidc_role" {
  name = "github-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
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


data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
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
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:DescribeSecurityGroups",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:AllocateAddress",
          "ec2:AssociateAddress",
          "ec2:DescribeAddresses",
          "ec2:DisassociateAddress",
          "ec2:ReleaseAddress"
        ],
        Resource = "*"
      }
    ]
  })
}


