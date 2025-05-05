resource "aws_s3_bucket" "logs_bucket" {
  bucket        = var.log_bucket_name
  force_destroy = true

  tags = {
    Name = "cloudfront-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
