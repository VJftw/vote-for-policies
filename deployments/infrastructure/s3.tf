resource "aws_s3_bucket" "client" {
  bucket = local.safe_base_dns
  acl    = "public-read"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.safe_base_dns}/*"
      ]
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = local.safe_base_dns
  }
}

resource "aws_s3_bucket" "api" {
  bucket = "api.${local.safe_base_dns}"
  acl    = "private"

  tags = {
    Name = "api.${local.safe_base_dns}"
  }
}