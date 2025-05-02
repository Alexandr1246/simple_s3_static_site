variable "bucket_name" {
  description = "Унікальна назва S3 бакета для статичного сайту"
  type        = string
}

# 1) Створюємо S3 бакет (за замовчуванням без публічного доступу)
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "production"
  }
}

# 2) Блокуємо публічний доступ (через окремий ресурс, не ACL)
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}