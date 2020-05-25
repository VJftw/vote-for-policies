#!/bin/bash -e

lambda_bucket="backend-vfp-vjpatel-me"
echo "-> uploading lambdas"

lambda_archives=$(find dist/ -name '*.zip')

for lambda in $lambda_archives; do
  dest_lambda="${lambda//dist\//}"
  echo "-> ${dest_lambda}"
  aws s3 cp "${lambda}" "s3://${lambda_bucket}/${dest_lambda}"
done
