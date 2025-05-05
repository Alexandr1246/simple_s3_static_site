resource "aws_s3_bucket" "logs_bucket" {
  provider      = aws.use1
  bucket        = var.log_bucket_name
  force_destroy = true

  tags = {
    Name = "cloudfront-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_configuration" "logs_bucket_ownership" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_bucket_pab" {
  provider                  = aws.use1
  bucket                    = aws_s3_bucket.logs_bucket.id
  block_public_acls         = false
  block_public_policy       = false
  ignore_public_acls        = false
  restrict_public_buckets = false
}