data "aws_route53_zone" "organisation" {
  name = "${var.base_dns}."
}
