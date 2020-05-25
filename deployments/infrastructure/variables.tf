variable "base_dns" {
  type        = string
  description = "the Route53 hosted zone and base dns"
}

variable "backend_version" {
  type = string
  description = "the version of lambdas to use"
  default = "0e0288c"
}
