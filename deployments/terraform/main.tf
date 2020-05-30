provider "aws" {
  region = var.region
}

module "base_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  
  namespace = "voteforpolicies"
  stage = var.stage
}

module "terraform_state_backend" {
  source     = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=0.17.0"

  context    = module.base_label.context
  name       = "terraform"
  attributes = ["state"]
  region     = var.region
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "voteforpolicies-dev-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "voteforpolicies-dev-terraform-state-lock"
    encrypt        = true
  }
}



data "aws_route53_zone" "organisation" {
  name = "${var.base_dns}."
}

data "aws_caller_identity" "current" {}


module "frontend" {
  source = "./frontend"

  context = module.base_label.context

  region = var.region

  base_dns    = var.base_dns
  r53_zone_id = data.aws_route53_zone.organisation.id
}

module "netlifycmsoauth" {
  source = "./netlifycmsoauth"

  context = module.base_label.context

  region = var.region
  
  account_id = data.aws_caller_identity.current.account_id

  base_dns = var.base_dns
  r53_zone_id = data.aws_route53_zone.organisation.id
  lambda_zip_version = var.lambda_zip_version

  github_id = var.github_id
  github_secret_ssm_path = var.github_secret_ssm_path
}

module "postresults" {
  source = "./postresults"

  context = module.base_label.context

  region = var.region
  
  base_dns = var.base_dns
  r53_zone_id = data.aws_route53_zone.organisation.id
  lambda_zip_version = var.lambda_zip_version
  s3_bucket = module.frontend.s3_bucket
}

