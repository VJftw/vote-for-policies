resource "aws_iam_role" "postresults" {
  name = "postresults-${local.safe_base_dns}"

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

resource "aws_lambda_function" "postresults" {
  function_name = "postresults-${local.safe_base_dns}"
  role          = aws_iam_role.postresults.arn
  handler       = "main"
  s3_bucket     = aws_s3_bucket.backend.bucket
  s3_key        = "lambda_postresults_${var.backend_version}.zip"
  runtime       = "go1.x"
}

resource "aws_iam_role" "emailresults" {
  name = "emailresults-${local.safe_base_dns}"

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

# resource "aws_lambda_function" "emailresults" {
#   function_name = "emailresults-${local.safe_base_dns}"
#   role          = aws_iam_role.emailresults.arn
#   handler       = "main"
#   s3_bucket     = aws_s3_bucket.backend.bucket
#   s3_key        = "emailresults-${var.backend_version}.zip"
#   runtime       = "go1.x"
# }

resource "aws_iam_role" "generatetotals" {
  name = "generatetotals-${local.safe_base_dns}"

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

# resource "aws_lambda_function" "generatetotals" {
#   function_name = "generatetotals-${local.safe_base_dns}"
#   role          = aws_iam_role.generatetotals.arn
#   handler       = "main"
#   s3_bucket     = aws_s3_bucket.backend.bucket
#   s3_key        = "generatetotals-${var.backend_version}.zip"
#   runtime       = "go1.x"
# }
