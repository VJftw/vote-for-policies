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
