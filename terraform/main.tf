module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}

module "policy" {
  source             = "./modules/polici"
  bucket_id          = module.s3.bucket_id
  bucket_arn         = module.s3.bucket_arn
  cloudfront_oai_arn = module.cloudfront.oai_arn
}

module "acm" {
  source            = "./modules/acm"
  domain_name       = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  region            = var.region
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  bucket_name         = module.s3.bucket_name
  s3_origin_id        = module.s3.bucket_name
  acm_certificate_arn = module.acm.acm_arn
  domain_aliases      = [var.domain_name, "www.${var.domain_name}"]
}

module "iam" {
  source = "./modules/iam"
}

module "route53" {
  source         = "./modules/route53"
  domain_name    = var.domain_name
  cloudfront_dns = module.cloudfront.cloudfront_domain
  zone_id        = var.zone_id  # або отримати динамічно, якщо модуль acm/route53 повертає його
}
