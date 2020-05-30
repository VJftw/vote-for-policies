resource "aws_s3_bucket" "lambda" {
  bucket        = module.lambda_label.id
  acl           = "private"
  force_destroy = true
}
