output "bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}
output "bucket" {
  value = aws_s3_bucket.logs_bucket.id
}

output "arn" {
  value = aws_s3_bucket.logs_bucket.arn
}