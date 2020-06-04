module "postresults_label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context = var.context
  name    = "postresults"
}

module "lambda" {
  source = "../common/lambda"

  context = module.postresults_label.context

  apigateway_enabled     = true
  apigateway_r53_zone_id = var.r53_zone_id
  apigateway_base_dns    = var.base_dns

  lambda_zip_version = var.lambda_zip_version

  lambda_environment = {
    DYNAMODB_TABLE = module.results_table.table_name
    RESULTS_BUCKET = var.s3_bucket
    RESULTS_BUCKET_KEY_PREFIX = "/results"
    ORIGIN_ADDRESS = "https://${var.base_dns}"
    GIN_MODE = "release"
  }
}

module "results_table" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=0.15.0"

  namespace   = module.postresults_label.namespace
  stage       = module.postresults_label.stage
  name        = module.postresults_label.name
  environment = module.postresults_label.environment

  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"
  #   autoscale_write_target       = 50
  #   autoscale_read_target        = 50
  #   autoscale_min_read_capacity  = 5
  #   autoscale_max_read_capacity  = 20
  #   autoscale_min_write_capacity = 5
  #   autoscale_max_write_capacity = 20
  #   enable_autoscaler            = true
}


module "lambda_dynamodb_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context    = module.lambda.label_context
  attributes = ["dynamodb"]
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = module.lambda_dynamodb_label.id
  path        = "/"
  description = "IAM policy for DynamoDB from a lambda"

  policy = data.aws_iam_policy_document.dynamodb.json
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = ["dynamodb:PutItem"]

    resources = [
      module.results_table.table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

module "lambda_s3_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context    = module.lambda.label_context
  attributes = ["s3"]
}

resource "aws_iam_policy" "lambda_s3" {
  name        = module.lambda_s3_label.id
  path        = "/"
  description = "IAM policy for S3 from a lambda"

  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}/results/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.lambda_s3.arn
}
