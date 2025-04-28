// cloudfront.tf

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI для доступу до приватного S3 бакета"
}

resource "aws_cloudfront_distribution" "static_site_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_site.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

default_cache_behavior {
target_origin_id       = "S3-${aws_s3_bucket.static_site.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods {
cached_methods           = ["GET", "HEAD"]
    items                    = ["GET", "HEAD"]
      
    }
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Якщо потрібно використовувати свій домен:
  aliases {
    items = ["www.example.com"]  # Якщо потрібно використовувати свій домен
  }

  logging_config {
    include_cookies = false
    bucket           = "logs.example.com.s3.amazonaws.com"
    prefix           = "cloudfront-logs/"
  }

  tags = {
    Name = "static-site-cloudfront-distribution"
  }

  # Якщо ти хочеш використовувати SSL сертифікат
  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn  # Замінити на ARN свого сертифікату
    ssl_support_method  = "sni-only"
  }
}
