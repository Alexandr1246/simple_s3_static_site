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

output "bucket_domain_name" {
  description = "S3 static website domain"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "bucket_website_url" {
  description = "The URL to access the static website"
  value       = aws_s3_bucket.static_site.website_url
}
