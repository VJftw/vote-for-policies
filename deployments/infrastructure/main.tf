provider "aws" {
  region = "us-east-1"
}

module "terraform_state_backend" {
  source     = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace  = "vfp"
  stage      = "dev"
  name       = "terraform"
  attributes = ["state"]
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "vfp-dev-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "vfp-dev-terraform-state-lock"
    encrypt        = true
  }
}


# variable "version" {}

locals {
  safe_base_dns = "${replace(var.base_dns, ".", "-")}"
}
