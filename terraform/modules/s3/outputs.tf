output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_site.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.static_site.arn
}

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.static_site.id
}


output "bucket_regional_domain_name" {
  value = aws_s3_bucket.static_site.bucket_regional_domain_name
}

output "bucket" {
  value = aws_s3_bucket.static_site.bucket
}
