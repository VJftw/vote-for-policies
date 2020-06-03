#!/bin/bash -e

version=$(git describe --always)

lambda=$1

cwd="${PWD}"
cd deployments/terraform
terraform init
export TF_VAR_lambda_zip_version="${version}"
export TF_IN_AUTOMATION="true"
terraform apply --auto-approve --target="module.${lambda}.module.lambda.aws_s3_bucket.lambda"
cd "${cwd}"

lambda_bucket="voteforpolicies-dev-${lambda}"

echo "-> uploading lambda"
aws s3 cp "dist/${version}_${lambda}.zip" "s3://${lambda_bucket}/${version}_${lambda}.zip"

echo "-> Running Terraform"

cd deployments/terraform
terraform init
export TF_VAR_lambda_zip_version="${version}"
terraform apply --auto-approve --target="module.${lambda}"


# TODO: remove previous release non release tagged lambdas
