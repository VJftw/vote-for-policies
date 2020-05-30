resource "aws_api_gateway_rest_api" "lambda" {
  count = var.apigateway_enabled ? 1 : 0

  name  = module.apigateway_label.id
}

resource "aws_api_gateway_resource" "proxy" {
  count       = var.apigateway_enabled ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.lambda[0].id
  parent_id   = aws_api_gateway_rest_api.lambda[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  count         = var.apigateway_enabled ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.lambda[0].id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  count       = var.apigateway_enabled ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.lambda[0].id
  resource_id = aws_api_gateway_method.proxy[0].resource_id
  http_method = aws_api_gateway_method.proxy[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  count         = var.apigateway_enabled ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.lambda[0].id
  resource_id   = aws_api_gateway_rest_api.lambda[0].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  count       = var.apigateway_enabled ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.lambda[0].id
  resource_id = aws_api_gateway_method.proxy_root[0].resource_id
  http_method = aws_api_gateway_method.proxy_root[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# resource "aws_api_gateway_stage" "lambda" {
#   count = var.apigateway_enabled ? 1 : 0

#   stage_name    = module.apigateway_label.stage
#   rest_api_id   = aws_api_gateway_rest_api.lambda[0].id
#   deployment_id = aws_api_gateway_deployment.lambda[0].id
# }


resource "aws_api_gateway_deployment" "lambda" {
  count = var.apigateway_enabled ? 1 : 0

  depends_on = [
    aws_api_gateway_integration.lambda[0],
    aws_api_gateway_integration.lambda_root[0],
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda[0].id
  stage_name = "production"
}

resource "aws_lambda_permission" "apigw" {
  count         = var.apigateway_enabled ? 1 : 0

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.lambda[0].execution_arn}/*/*"
}

resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
  count      = var.apigateway_enabled ? 1 : 0

  api_id     = aws_api_gateway_rest_api.lambda[0].id

  domain_name = aws_api_gateway_domain_name.lambda[0].domain_name
  stage_name = "production"
}


resource "aws_acm_certificate" "lambda" {
  count             = var.apigateway_enabled ? 1 : 0

  domain_name       = "${module.apigateway_label.name}.${var.apigateway_base_dns}"
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  count   = var.apigateway_enabled ? 1 : 0

  name    = aws_acm_certificate.lambda[0].domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.lambda[0].domain_validation_options.0.resource_record_type
  zone_id = var.apigateway_r53_zone_id
  records = ["${aws_acm_certificate.lambda[0].domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "lambda" {
  count                   = var.apigateway_enabled ? 1 : 0

  certificate_arn         = aws_acm_certificate.lambda[0].arn
  validation_record_fqdns = ["${aws_route53_record.validation[0].fqdn}"]
}

resource "aws_api_gateway_domain_name" "lambda" {
  count           = var.apigateway_enabled ? 1 : 0

  certificate_arn = aws_acm_certificate.lambda[0].arn
  domain_name     = "${module.apigateway_label.name}.${var.apigateway_base_dns}"
}

resource "aws_route53_record" "lambda" {
  count   = var.apigateway_enabled ? 1 : 0

  name    = aws_api_gateway_domain_name.lambda[0].domain_name
  type    = "A"
  zone_id = var.apigateway_r53_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.lambda[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.lambda[0].cloudfront_zone_id
  }
}
