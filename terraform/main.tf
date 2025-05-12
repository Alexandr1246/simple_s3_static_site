module "s3" {
  source           = "./modules/s3"
  bucket_name      = var.bucket_name
  environment      = var.environment
}

module "logs_bucket" {
  source = "./modules/logs_bucket"
  providers = {
    aws = aws.use1
  }
  log_bucket_name = var.log_bucket_name
}

module "policy" {
  source             = "./modules/policy"
  bucket_id          = module.s3.bucket_id
  bucket_arn         = module.s3.bucket_arn
  cloudfront_oai_arn = module.cloudfront.oai_arn
  aws_account_id     = var.aws_account_id
  log_bucket_name   = module.logs_bucket.bucket
  log_bucket_arn    = module.logs_bucket.arn
}


module "acm" {
  source                    = "./modules/acm"
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  region                    = var.region
  zone_id                   = module.route53.zone_id
}

module "cloudfront" {
  source           = "./modules/cloudfront"
  bucket_name      = module.s3.bucket_regional_domain_name
  s3_origin_id     = module.s3.bucket
  domain_aliases   = ["itstep-project.online", "www.itstep-project.online"]
  acm_certificate_arn = ""
  log_bucket_name  = var.log_bucket_name 
  log_bucket_domain  = "${module.logs_bucket.bucket}.s3.amazonaws.com"
}

#module "iam" {
#  source = "./modules/iam"
#}

module "route53" {
  source = "./modules/route53"
  domain_name              = var.domain_name
  zone_id                 = var.zone_id
  cloudfront_domain_name  = module.cloudfront.cloudfront_domain
  cloudfront_hosted_zone_id = var.cloudfront_hosted_zone_id  # ← Додай це
}