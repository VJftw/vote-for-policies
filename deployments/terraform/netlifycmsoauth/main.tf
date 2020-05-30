module "netlifycmsoauth_label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context = var.context
  name = "netlifycmsoauth"
}

module "lambda" {
  source = "../common/lambda"

  context = module.netlifycmsoauth_label.context

  apigateway_enabled     = true
  apigateway_r53_zone_id = var.r53_zone_id
  apigateway_base_dns = var.base_dns

  lambda_zip_version = var.lambda_zip_version

  lambda_environment = {
    GITHUB_ID              = var.github_id
    GITHUB_SECRET_SSM_PATH = var.github_secret_ssm_path
    TARGET_ORIGIN          = "https://${var.base_dns}"
  }
}

module "lambda_ssm_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context    = module.lambda.label_context
  attributes = ["ssm"]
}

resource "aws_iam_policy" "lambda_ssm" {
  name        = module.lambda_ssm_label.id
  path        = "/"
  description = "IAM policy for SSM from a lambda"

  policy = data.aws_iam_policy_document.ssm_read.json
}

data "aws_iam_policy_document" "ssm_read" {
  statement {
    actions = ["ssm:GetParameter"]

    resources = [
      "arn:aws:ssm:us-east-1:${var.account_id}:parameter${var.github_secret_ssm_path}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.lambda_ssm.arn
}


