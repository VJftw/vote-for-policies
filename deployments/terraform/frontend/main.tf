module "frontend_label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context = var.context
}


module "cdn" {
  source               = "git::https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn.git?ref=0.23.1"
  
  namespace            = module.frontend_label.namespace
  stage                = module.frontend_label.stage
  tags                 = module.frontend_label.tags
  delimiter            = module.frontend_label.delimiter
  name                 = "frontend"

  aliases              = [var.base_dns]
  parent_zone_name     = var.base_dns
  acm_certificate_arn  = aws_acm_certificate.frontend.arn
  allowed_methods      = ["GET", "HEAD", "OPTIONS"]
  compress             = true
  cached_methods       = ["GET", "HEAD", "OPTIONS"]
  encryption_enabled   = true
  error_document       = "/4xx.html"
  origin_force_destroy = true
  website_enabled      = true
  routing_rules        = <<EOF
[
  {
      "Redirect": {
          "ReplaceKeyWith": "index.html"
      },
      "Condition": {
          "KeyPrefixEquals": "/"
      }
  }

]
EOF
}

resource "aws_acm_certificate" "frontend" {
  domain_name       = var.base_dns
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.frontend.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.frontend.domain_validation_options.0.resource_record_type
  zone_id = var.r53_zone_id
  records = ["${aws_acm_certificate.frontend.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
