#!/bin/bash -e

frontend_bucket="vfp-vjpatel-me"

echo "-> uploading website"
aws s3 cp website/dist/. "s3://${frontend_bucket}" --acl public-read --recursive --cache-control max-age=120

echo "-> setting cache-control on static assets"
static_files=$(find website/dist/ -name '*.js' -o -name "*.css")
for static in $static_files; do
  dest_static="${static//dist\//}"
  echo "${dest_static}"
  aws s3 cp "${static}" "s3://${frontend_bucket}/${dest_static}" --acl public-read --cache-control max-age=31536000
done
