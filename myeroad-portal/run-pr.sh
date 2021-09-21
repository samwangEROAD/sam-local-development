#!/bin/bash

set -e

# login okta
while : ; do
  export S3_RESPONSE=$(aws s3api get-bucket-location --bucket eroad-artifact-ap-southeast-2)
  echo "S3_RESPONSE=${S3_RESPONSE}"
  if [[ $S3_RESPONSE = *"ap-southeast-2"* ]]; then
    break
  else
    gimme-aws-creds
  fi
done

# command for login to ecr may vary from different aws-cli version
# if you encounter an error from the aws cli saying that the `get-login-password` command is invalid then an older version of the aws-cli is being used
# Below is for old version of aws-cli
#$(aws ecr get-login --no-include-email --region ap-southeast-2)
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com

export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_REGION=${AWS_DEFAULT_REGION}

# Write ENV to .env file for docker-compose use
echo "PR_NUMBER=$1" > .env

# Always pull image first, as later commits to this PR will create new images with the same Tag (PR-*).
# In case of Tag with the same Digest, it will be skipped.
docker-compose pull

docker-compose up
