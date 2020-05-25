resource "aws_api_gateway_rest_api" "postresults" {
  name        = "postresults-${local.safe_base_dns}"
  description = "postresults for ${local.safe_base_dns}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.postresults.id
  parent_id   = aws_api_gateway_rest_api.postresults.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.postresults.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.postresults.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postresults.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.postresults.id
  resource_id   = aws_api_gateway_rest_api.postresults.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.postresults.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postresults.invoke_arn
}

resource "aws_api_gateway_deployment" "postresults" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.postresults.id
  stage_name  = "production"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postresults.arn
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.postresults.execution_arn}/*/*"
}

resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
  api_id     = aws_api_gateway_rest_api.postresults.id
  stage_name = "production"

  domain_name = aws_api_gateway_domain_name.postresults.domain_name
}


resource "aws_acm_certificate" "postresults" {
  domain_name       = "postresults.${var.base_dns}"
  validation_method = "DNS"
}

resource "aws_route53_record" "postresults_validation" {
  name    = aws_acm_certificate.postresults.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.postresults.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.organisation.zone_id
  records = ["${aws_acm_certificate.postresults.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "postresults" {
  certificate_arn         = aws_acm_certificate.postresults.arn
  validation_record_fqdns = ["${aws_route53_record.postresults_validation.fqdn}"]
}

resource "aws_api_gateway_domain_name" "postresults" {
  certificate_arn = aws_acm_certificate.postresults.arn
  domain_name     = "postresults.${var.base_dns}"
}

resource "aws_route53_record" "postresults" {
  name    = aws_api_gateway_domain_name.postresults.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.organisation.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.postresults.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.postresults.cloudfront_zone_id
  }
}
