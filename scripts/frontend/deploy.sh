#!/bin/bash -e

cwd="${PWD}"
cd deployments/terraform
terraform init
export TF_VAR_lambda_zip_version="${version}"
terraform apply --auto-approve --target="module.frontend"
cd "${cwd}"

frontend_bucket="voteforpolicies-dev-frontend-origin"


echo "-> uploading website"
aws s3 cp website/dist/. "s3://${frontend_bucket}" --acl public-read --recursive --cache-control max-age=120

echo "-> setting cache-control on static assets"
static_files=$(find website/dist/ -name '*.js' -o -name "*.css")
for static in $static_files; do
  dest_static="${static//dist\//}"
  echo "${dest_static}"
  aws s3 cp "${static}" "s3://${frontend_bucket}/${dest_static}" --acl public-read --cache-control max-age=31536000
done
