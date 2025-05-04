module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}

module "policy" {
  source             = "./modules/policy"
  bucket_id          = module.s3.bucket_id
  bucket_arn         = module.s3.bucket_arn
  cloudfront_oai_arn = module.cloudfront.oai_arn
}

#module "acm" {
#  source                    = "./modules/acm"
#  domain_name               = var.domain_name
#  subject_alternative_names = ["www.${var.domain_name}"]
#  region                    = var.region
#  zone_id                   = module.route53.zone_id
#}

module "cloudfront" {
  source = "./modules/cloudfront"

  bucket_name     = aws_s3_bucket.static_site.bucket_regional_domain_name
  s3_origin_id    = aws_s3_bucket.static_site.bucket
  domain_aliases  = ["itstep-project.online", "www.itstep-project.online"]
  acm_certificate_arn = "" # можна залишити пустим або не передавати, якщо не використовується
}

#module "iam" {
#  source = "./modules/iam"
#}

#module "route53" {
#  source         = "./modules/route53"
#  domain_name    = var.domain_name
#  cloudfront_dns = module.cloudfront.cloudfront_domain
#  zone_id        = var.zone_id # або отримати динамічно, якщо модуль acm/route53 повертає його
#}