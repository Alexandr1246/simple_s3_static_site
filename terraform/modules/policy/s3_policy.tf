
resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"
        Principal = {
          AWS = var.cloudfront_oai_arn
        }
        Action   = "s3:GetObject"
        Resource = "${var.bucket_arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = var.log_bucket_name
  provider = aws.use1

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AWSLogDeliveryWrite",
        Effect: "Allow",
        Principal: {
          Service: "delivery.logs.amazonaws.com"
        },
        Action: "s3:PutObject",
        Resource: "${var.log_bucket_arn}/*",
        Condition: {
          StringEquals: {
            "s3:x-amz-acl": "bucket-owner-full-control",
            "aws:SourceAccount": var.aws_account_id
          }
        }
      },
      {
        Sid: "AWSLogDeliveryAclCheck",
        Effect: "Allow",
        Principal: {
          Service: "delivery.logs.amazonaws.com"
        },
        Action: "s3:GetBucketAcl",
        Resource: var.log_bucket_arn
      }
    ]
  })
}
