
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

 resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = var.logs_bucket_name

   policy = jsonencode({
     Version = "2012-10-17"
     Statement = [
       {
         Sid       = "AllowCloudFrontLogs"
         Effect    = "Allow"
         Principal = { Service = "cloudfront.amazonaws.com" }
         Resource  = "${var.logs_bucket_arn}/*"
         Condition = {
           StringEquals = {
             "AWS:SourceAccount" = var.aws_account_id
           }
         }
       },
       {
         Sid       = "AllowGetBucketAcl"
         Effect    = "Allow"
         Principal = { Service = "cloudfront.amazonaws.com" }
         ction    = "s3:GetBucketAcl"
         Resource  = var.logs_bucket_arn
       }
     ]
   })
 }

