variable "base_dns" {
  type        = string
  description = "the Route53 hosted zone and base dns"
}

variable "backend_version" {
  type = string
  description = "the version of lambdas to use"
}

variable "github_id" {
  type = string
  description = "the GitHub OAuth2 ID"
}

variable "github_secret_ssm_path" {
  type = string
  description = "the GitHub OAuth2 Secret stored in AWS SSM Parameter store"
}
