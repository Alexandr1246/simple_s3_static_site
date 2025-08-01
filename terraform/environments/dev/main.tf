#module "acm" {
#  source                    = "../../modules/acm"
#  providers                 = { aws = aws.use1 }
#  domain_name               = var.domain_name
#  subject_alternative_names = ["www.${var.domain_name}"]
#  region                    = var.region
#  zone_id                   = module.route53.zone_id
#}

#module "cloudfront" {
#  source                         = "../../modules/cloudfront"
#  bucket_name                    = module.s3.bucket_regional_domain_name
#  s3_origin_id                   = module.s3.bucket
#  domain_aliases                 = ["itstep-project.online", "www.itstep-project.online"]
#  acm_certificate_arn            = module.acm.acm_arn
#  log_bucket_name                = var.log_bucket_name
#  log_bucket_domain              = "${module.logs_bucket.bucket}.s3.amazonaws.com"
#  acm_certificate_validation_arn = module.acm.acm_certificate_validation_arn

#}

#module "k8s" {
#  source         = "../../modules/k8s"
#  ssh_key_name   = var.ssh_key_name
#  aws_account_id = var.aws_account_id
#}

module "vpc" {
  source      = "../../modules/vpc"
}

module "eks" {
  source      = "../../modules/eks"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
}

module "bastion" {
  source                      = "../../modules/bastion"

  vpc_id                      = module.vpc.vpc_id
  public_subnet_ids           = module.vpc.public_subnet_ids
  bastion_ami_id              = var.ami_id
  instance_type               = var.instance_type
  bastion_name                = var.bastion_name
  iam_instance_profile_name   = module.bastion.iam_instance_profile_name
  security_group_id           = module.vpc.security_group_id
}


#module "logs_bucket" {
#  source          = "../../modules/logs_bucket"
#  providers       = { aws = aws.use1 }
#  log_bucket_name = var.log_bucket_name
#  aws_account_id  = var.aws_account_id
#}

#module "route53" {
#  source                    = "../../modules/route53"
#  domain_name               = var.domain_name
#  cloudfront_domain_name    = module.cloudfront.cloudfront_domain
#  cloudfront_hosted_zone_id = var.cloudfront_hosted_zone_id
#}

#module "s3" {
#  source             = "../../modules/s3"
#  bucket_name        = var.bucket_name
#  environment        = var.environment
#  cloudfront_oai_arn = module.cloudfront.oai_arn
#}

#module "policy" {
#  source             = "./modules/policy"
#  bucket_id          = module.s3.bucket_id
#  bucket_arn         = module.s3.bucket_arn
#  cloudfront_oai_arn = module.cloudfront.oai_arn
#  aws_account_id     = var.aws_account_id
#  log_bucket_name    = module.logs_bucket.bucket
#  log_bucket_arn     = module.logs_bucket.arn
#}





