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
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Alexandr1246/simple_s3_static_site:*"
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
          "acm:DeleteCertificate",
          "acm:ListTagsForCertificate",
          "route53:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:*"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : "autoscaling.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:DeletePolicy",
          "iam:ListPolicies",
          "iam:CreatePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:CreateRole",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:ListRoles",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:GetRolePolicy",
          "iam:GetInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateAssumeRolePolicy",
          "iam:GetUser",
          "iam:SimulatePrincipalPolicy"
        ],
        "Resource" : "*"
      },

      {
        "Effect" : "Allow",
        "Action" : [
          "iam:ListPolicyVersions",
          "iam:ListEntitiesForPolicy",
          "iam:UpdateRole"
        ],
        "Resource" : "*"
      },

      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DeleteParameter"
        ],
        "Resource" : "arn:aws:ssm:eu-north-1:050451395507:parameter/k8s/*"
      },

      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : "*"
      }

    ]
  })
}


