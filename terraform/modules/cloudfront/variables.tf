variable "bucket_name" {
  description = "Ім’я S3 бакета (без шляху), який буде джерелом для CloudFront"
  type        = string
}

variable "s3_origin_id" {
  description = "Унікальний ідентифікатор Origin в CloudFront (зазвичай такий самий, як ім’я бакета)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN ACM сертифіката (має бути у регіоні us-east-1) для HTTPS у CloudFront"
  type        = string
}

variable "domain_aliases" {
  description = "Список доменів (CNAME) для дистрибуції CloudFront"
  type        = list(string)
}

variable "logs_bucket_name" {
  description = "Ім'я S3 бакета для зберігання логів CloudFront"
  type        = string
}