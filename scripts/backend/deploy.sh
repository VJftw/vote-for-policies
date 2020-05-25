#!/bin/bash -e

version=$(git describe --always)

lambda_bucket="backend-vfp-vjpatel-me"
echo "-> uploading lambdas"

lambda_archives=$(find dist/ -name "*${version}.zip")

for lambda in $lambda_archives; do
  dest_lambda="${lambda//dist\//}"
  echo "-> ${dest_lambda}"
  aws s3 cp "${lambda}" "s3://${lambda_bucket}/${dest_lambda}"
done

echo "-> Running Terraform"

cd deployments/infrastructure

terraform init
export TF_VAR_backend_version="${version}"
terraform apply --auto-approve
