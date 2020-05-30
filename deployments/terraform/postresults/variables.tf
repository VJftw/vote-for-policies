variable "context" {}

variable "region" {
  type = string
}

variable "base_dns" {
  type = string
}

variable "r53_zone_id" {
    type = string
}

variable "lambda_zip_version" {
    type = string
}

variable "s3_bucket" {
  type = string
}
