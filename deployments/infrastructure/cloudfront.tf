resource "aws_cloudfront_distribution" "client" {
  origin {
    domain_name = aws_s3_bucket.client.bucket_regional_domain_name
    origin_id   = "S3-${local.safe_base_dns}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  aliases = ["${var.base_dns}"]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${local.safe_base_dns}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"

    # viewer_protocol_policy = "redirect-to-https"
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  price_class = "PriceClass_All"
  tags = {
    Name = "${local.safe_base_dns}"
  }
  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.client.arn
    ssl_support_method  = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_acm_certificate" "client" {
  domain_name       = var.base_dns
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.client.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.client.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.organisation.zone_id
  records = ["${aws_acm_certificate.client.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.client.arn
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}


resource "aws_route53_record" "client" {
  name    = var.base_dns
  type    = "A"
  zone_id = data.aws_route53_zone.organisation.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.client.domain_name
    zone_id                = aws_cloudfront_distribution.client.hosted_zone_id
  }
}
