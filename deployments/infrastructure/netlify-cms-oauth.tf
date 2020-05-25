resource "aws_iam_role" "netlifycmsoauth" {
  name = "netlifycmsoauth-${local.safe_base_dns}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "netlifycmsoauth" {
  function_name = "netlifycmsoauth-${local.safe_base_dns}"
  role          = aws_iam_role.netlifycmsoauth.arn
  handler       = "main"
  s3_bucket     = aws_s3_bucket.backend.bucket
  s3_key        = "lambda_netlifycmsoauth_${var.backend_version}.zip"
  runtime       = "go1.x"
}

resource "aws_api_gateway_rest_api" "netlifycmsoauth" {
  name        = "netlifycmsoauth-${local.safe_base_dns}"
  description = "netlifycmsoauth for ${local.safe_base_dns}"
}

resource "aws_api_gateway_resource" "netlifycmsoauth_proxy" {
  rest_api_id = aws_api_gateway_rest_api.netlifycmsoauth.id
  parent_id   = aws_api_gateway_rest_api.netlifycmsoauth.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "netlifycmsoauth_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.netlifycmsoauth.id
  resource_id   = aws_api_gateway_resource.netlifycmsoauth_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "netlifycmsoauth_lambda" {
  rest_api_id = aws_api_gateway_rest_api.netlifycmsoauth.id
  resource_id = aws_api_gateway_method.netlifycmsoauth_proxy.resource_id
  http_method = aws_api_gateway_method.netlifycmsoauth_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.netlifycmsoauth.invoke_arn
}

resource "aws_api_gateway_method" "netlifycmsoauth_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.netlifycmsoauth.id
  resource_id   = aws_api_gateway_rest_api.netlifycmsoauth.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "netlifycmsoauth_lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.netlifycmsoauth.id
  resource_id = aws_api_gateway_method.netlifycmsoauth_proxy_root.resource_id
  http_method = aws_api_gateway_method.netlifycmsoauth_proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.netlifycmsoauth.invoke_arn
}

resource "aws_api_gateway_deployment" "netlifycmsoauth" {
  depends_on = [
    aws_api_gateway_integration.netlifycmsoauth_lambda,
    aws_api_gateway_integration.netlifycmsoauth_lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.netlifycmsoauth.id
  stage_name  = "production"
}

resource "aws_lambda_permission" "netlifycmsoauth_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.netlifycmsoauth.arn
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.netlifycmsoauth.execution_arn}/*/*"
}

resource "aws_api_gateway_base_path_mapping" "netlifycmsoauth_base_path_mapping" {
  api_id     = aws_api_gateway_rest_api.netlifycmsoauth.id
  stage_name = "production"

  domain_name = aws_api_gateway_domain_name.netlifycmsoauth.domain_name
}


resource "aws_acm_certificate" "netlifycmsoauth" {
  domain_name       = "netlifycmsoauth.${var.base_dns}"
  validation_method = "DNS"
}

resource "aws_route53_record" "netlifycmsoauth_validation" {
  name    = aws_acm_certificate.netlifycmsoauth.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.netlifycmsoauth.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.organisation.zone_id
  records = ["${aws_acm_certificate.netlifycmsoauth.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "netlifycmsoauth" {
  certificate_arn         = aws_acm_certificate.netlifycmsoauth.arn
  validation_record_fqdns = ["${aws_route53_record.netlifycmsoauth_validation.fqdn}"]
}

resource "aws_api_gateway_domain_name" "netlifycmsoauth" {
  certificate_arn = aws_acm_certificate.netlifycmsoauth.arn
  domain_name     = "netlifycmsoauth.${var.base_dns}"
}

resource "aws_route53_record" "netlifycmsoauth" {
  name    = aws_api_gateway_domain_name.netlifycmsoauth.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.organisation.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.netlifycmsoauth.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.netlifycmsoauth.cloudfront_zone_id
  }
}