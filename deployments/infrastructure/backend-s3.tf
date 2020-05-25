resource "aws_s3_bucket" "backend" {
  bucket = "backend-${local.safe_base_dns}"
  acl    = "private"

  tags = {
    Name = "backend-${local.safe_base_dns}"
  }
}
