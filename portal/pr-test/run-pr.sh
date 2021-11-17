#!/usr/bin/env bash
set -e
# check inputs
if [[ $# -eq 0 ]]; then
    echo 'PR number is missing'
    echo 'Usage: ./run-pr.sh Your_PR_NUMBER'
    exit 1
fi

# check if the PR is correct
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
   echo "error: Not a number. Please input the correct PR_NUMBER."
   exit 1
fi

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

echo "Pulling image of PR-$1"

export PR_NUMBER=$1
export PR=PR-${PR_NUMBER}

export ENVIRONMENT=${ENVIRONMENT:=test}
export AWS_REGION=${AWS_REGION:=ap-southeast-2}
export AWS_DYNAMODB_TABLE_PROPERTY=${ENVIRONMENT}ConfigurationDynamoTableProperties
export DYNAMIC_CONFIG_FILE=${DYNAMIC_CONFIG_FILE:=./dynamicconfig-pr.properties}

cd "$(dirname "$0")"

# command for login to ecr may vary from different aws-cli version
# if you encounter an error from the aws cli saying that the `get-login-password` command is invalid then an older version of the aws-cli is being used
# Below is for old version of aws-cli
$(aws ecr get-login --no-include-email --region ap-southeast-2)
#aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com

docker-compose --file ./docker-compose-pr.yml rm -f
docker-compose --file ./docker-compose-pr.yml up --build --force-recreate
