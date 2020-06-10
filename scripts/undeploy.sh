#!/bin/bash -e

stateBucket="s3://serverless-state-survey-vfp-vjpatel-me"
baseDomain="survey.vfp.vjpatel.me"
env="$1"

if [ -z "${env}" ]; then
  echo "required argument <env> missing"
  exit 2
fi

config="serverless.ephemeral.yaml"
export DEPLOY_DOMAIN="${env}.survey.vfp.vjpatel.me"
if [ "${env}" == "production" ]; then
  export DEPLOY_DOMAIN="${baseDomain}"
  config="serverless.persistent.yaml"
elif [ "${env}" == "staging" ]; then
  export DEPLOY_DOMAIN="${env}.survey.vfp.vjpatel.me"
  config="serverless.persistent.yaml"
fi

echo "-> using ${config}"
cp "${config}" "serverless.yaml"

# 1. Pull state from S3 if it exists
aws s3 cp "${stateBucket}/${env}.tar.gz" . && tar -xzf "${env}.tar.gz" || echo "no existing state for ${env}"

echo "-> Undeploying to ${DEPLOY_DOMAIN}"

# 2. Deploy
npx serverless remove --debug 2>&1

# 3. Remove state from S3
aws s3 rm "${stateBucket}/${env}.tar.gz"
