resource "aws_s3_bucket" "logs_bucket" {
  provider = aws.use1           
  bucket   = var.bucket_name
}
