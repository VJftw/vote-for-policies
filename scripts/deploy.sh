#!/bin/bash -e

stateBucket="s3://serverless-state-survey-vfp-vjpatel-me"
baseDomain="survey.vfp.vjpatel.me"
env="$1"

if [ -z "${env}" ]; then
  echo "required argument <env> missing"
  exit 2
fi

export DEPLOY_DOMAIN="${env}.survey.vfp.vjpatel.me"
if [ "${env}" == "production" ]; then
  export DEPLOY_DOMAIN="${baseDomain}"
fi

# 1. Pull state from S3 if it exists
aws s3 cp "${stateBucket}/${env}.tar.gz" . && tar -xzf "${env}.tar.gz" || echo "no existing state for ${env}"

echo "-> Deploying to ${DEPLOY_DOMAIN}"

# 2. Deploy
npx serverless --debug

# 3. Push state to S3
tar -czf "${env}.tar.gz" ".serverless" && aws s3 cp "${env}.tar.gz" "${stateBucket}/${env}.tar.gz"
