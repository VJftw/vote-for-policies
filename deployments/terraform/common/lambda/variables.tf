variable "context" {}

variable "apigateway_enabled" {
    type = bool
    default = false
    description = "Set to true to create an API gateway endpoint"
}

variable "apigateway_r53_zone_id" {
    type = string
    default = ""
    description = "The Route53 Zone ID to create the API gateway endpoint in"
}

variable "apigateway_base_dns" {
    type = string
    default = ""
    description = "The base dns for API gateway endpoint"
}

variable "lambda_environment" {
    type = map
    default = {}
    description = "Environment variables for the Lambda function"
}

variable "lambda_zip_version" {
  type = string
}
