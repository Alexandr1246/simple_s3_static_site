resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI для доступу до приватного S3 бакета"
}

resource "aws_cloudfront_distribution" "static_site_distribution" {
  origin {
    domain_name = var.bucket_name
    origin_id   = "S3-${var.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_origin_id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  logging_config {
    bucket = var.log_bucket_domain
    prefix = "cloudfront-logs/"
  }

  tags = {
    Name = "static-site-cloudfront-distribution"
  }

  aliases = [
    "itstep-project.online",
    "www.itstep-project.online"
  ]

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  depends_on = [var.acm_certificate_validation_arn]
}