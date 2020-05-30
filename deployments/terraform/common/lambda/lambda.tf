
resource "aws_lambda_function" "lambda" {
  function_name = module.lambda_label.id
  role          = aws_iam_role.lambda.arn
  handler       = "main"
  s3_bucket     = aws_s3_bucket.lambda.bucket
  s3_key        = "${var.lambda_zip_version}_${module.lambda_label.name}.zip"
  runtime       = "go1.x"

#   environment {
#       variables = {
#           HOST = aws_api_gateway_domain_name.netlifycmsoauth.domain_name
#           GITHUB_ID = var.github_id
#           GITHUB_SECRET_SSM_PATH = var.github_secret_ssm_path
#           TARGET_ORIGIN = "https://${var.base_dns}"
#       }
#   }

    environment {
        variables = merge(
            var.lambda_environment, 
            local.lambda_environment["${var.apigateway_enabled ? "apigateway_enabled" : "apigateway_disabled"}"],
        )
    }
}

locals {
    lambda_environment = {
        "apigateway_enabled" = {
            HOST = aws_api_gateway_domain_name.lambda[0].domain_name
            LAMBDA = "true"
        }
        "apigateway_disabled" = {
            LAMBDA = "true"
        }
    }
}
