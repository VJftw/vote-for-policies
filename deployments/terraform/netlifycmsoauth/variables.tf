variable "context" {}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "base_dns" {
  type = string
}

variable "r53_zone_id" {
    type = string
}

variable "github_id" {
  type = string
}

variable "github_secret_ssm_path" {
  type = string
}

variable "lambda_zip_version" {
    type = string
}
